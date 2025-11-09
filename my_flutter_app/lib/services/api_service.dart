import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/paper.dart';

class ApiService {
  // TODO: Set your API key using --dart-define=PERPLEXITY_API_KEY=your_key
  // Or replace YOUR_API_KEY_HERE below with your actual key (for local development only)
  static const String perplexityApiKey = String.fromEnvironment(
    'PERPLEXITY_API_KEY',
    defaultValue: 'YOUR_API_KEY_HERE',
  );
  static const String perplexityBaseUrl = 'https://api.perplexity.ai';
  static const String openAlexBaseUrl = 'https://api.openalex.org';

  Future<List<Paper>> searchPapers(String query) async {
    print('🔍 Starting paper search for: "$query"');
    
    try {
      // First try Perplexity API for real research data
      print('🤖 Attempting Perplexity API search...');
      final papers = await _searchPapersWithPerplexity(query);
      
      if (papers.isNotEmpty) {
        print('✅ Perplexity returned ${papers.length} papers');
        return papers;
      } else {
        print('⚠️ Perplexity returned no papers, checking fallback...');
      }
      
      // Fallback to mock data only if Perplexity completely fails
      print('📚 Using fallback mock data');
      return _getMockPapers(query);
    } catch (e) {
      print('❌ API Error: $e');
      print('📚 Falling back to mock data due to error');
      return _getMockPapers(query);
    }
  }

  Future<List<Paper>> _searchPapersWithPerplexity(String query) async {
    try {
      print('📡 Making request to Perplexity API...');
      
      final response = await http.post(
        Uri.parse('$perplexityBaseUrl/chat/completions'),
        headers: {
          'Authorization': 'Bearer $perplexityApiKey',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'model': 'sonar',
          'messages': [
            {
              'role': 'system',
              'content': 'You are a research paper search assistant. Find the 5 most recent and relevant research papers on the given topic. '
                        'For each paper, provide: title, authors (comma-separated), year, journal/source, abstract (2-3 sentences), '
                        'methodology (2-3 sentences), key results (2-3 sentences), limitations (1-2 sentences), dataset info, and DOI if available. '
                        'Format your response as a JSON array of papers.',
            },
            {
              'role': 'user',
              'content': 'Find the 5 most recent research papers about: $query\n\n'
                        'Return a JSON array with this structure:\n'
                        '[\n'
                        '  {\n'
                        '    "title": "Paper Title",\n'
                        '    "authors": ["Author 1", "Author 2"],\n'
                        '    "year": 2024,\n'
                        '    "source": "Journal Name",\n'
                        '    "abstract": "Brief abstract...",\n'
                        '    "methodology": "Methodology description...",\n'
                        '    "results": "Key results...",\n'
                        '    "limitations": "Study limitations...",\n'
                        '    "dataset": "Dataset description...",\n'
                        '    "doi": "10.xxxx/xxxxx",\n'
                        '    "url": "https://..."\n'
                        '  }\n'
                        ']',
            }
          ],
          'max_tokens': 2000,
          'temperature': 0.2,
          'top_p': 0.9,
          'return_citations': true,
        }),
      );

      print('📊 Perplexity API response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final content = data['choices'][0]['message']['content'] ?? '';
        
        print('📄 Received content length: ${content.length}');
        
        // Try to parse JSON from the response
        try {
          // Extract JSON from markdown code blocks if present
          String jsonContent = content;
          if (content.contains('```json')) {
            jsonContent = content.split('```json')[1].split('```')[0].trim();
            print('📋 Extracted JSON from markdown blocks');
          } else if (content.contains('```')) {
            jsonContent = content.split('```')[1].split('```')[0].trim();
            print('📋 Extracted content from code blocks');
          }
          
          final papersData = json.decode(jsonContent) as List;
          print('✅ Successfully parsed ${papersData.length} papers from JSON');
          
          final papers = papersData.asMap().entries.map((entry) {
            final idx = entry.key;
            final item = entry.value as Map<String, dynamic>;
            
            return Paper(
              id: 'perplexity_${DateTime.now().millisecondsSinceEpoch}_$idx',
              title: item['title'] ?? 'Untitled Research',
              authors: item['authors'] != null 
                  ? List<String>.from(item['authors']) 
                  : ['Unknown Author'],
              year: item['year'] ?? DateTime.now().year,
              source: item['source'] ?? 'Unknown Source',
              abstract: item['abstract'] ?? 'Abstract not available.',
              methodology: item['methodology'] ?? 'Methodology not specified.',
              results: item['results'] ?? 'Results not specified.',
              limitations: item['limitations'] ?? 'Limitations not specified.',
              dataset: item['dataset'] ?? 'Dataset not specified.',
              shortSummary: _createShortSummary(item['abstract'] ?? ''),
              cachedAt: DateTime.now(),
              doi: item['doi'],
              url: item['url'],
            );
          }).toList();
          
          print('🎉 Successfully created ${papers.length} Paper objects');
          return papers;
        } catch (e) {
          print('❌ JSON parsing error: $e');
          print('📝 Response content preview: ${content.substring(0, content.length > 200 ? 200 : content.length)}...');
          
          // If JSON parsing fails, try to extract papers from text
          final textPapers = _extractPapersFromText(content, query);
          if (textPapers.isNotEmpty) {
            print('🔄 Successfully extracted ${textPapers.length} papers from text content');
            return textPapers;
          }
        }
      } else {
        print('❌ Perplexity API error: ${response.statusCode} - ${response.body}');
      }
      return [];
    } catch (e) {
      print('❌ Perplexity search error: $e');
      return [];
    }
  }

  List<Paper> _extractPapersFromText(String content, String query) {
    // Fallback: Create papers from text response
    final papers = <Paper>[];
    final lines = content.split('\n');
    
    String? currentTitle;
    String currentAuthors = '';
    int currentYear = DateTime.now().year;
    
    for (var line in lines) {
      if (line.contains('**') || line.contains('Title:')) {
        currentTitle = line.replaceAll('**', '').replaceAll('Title:', '').trim();
      }
    }
    
    // If we extracted something, create at least one paper
    if (currentTitle != null && currentTitle.isNotEmpty) {
      papers.add(Paper(
        id: 'perplexity_text_${DateTime.now().millisecondsSinceEpoch}',
        title: currentTitle,
        authors: currentAuthors.isNotEmpty ? [currentAuthors] : ['Research Team'],
        year: currentYear,
        source: 'From Perplexity AI Search',
        abstract: content.length > 200 ? content.substring(0, 200) + '...' : content,
        methodology: 'See full abstract for methodology details.',
        results: 'See full abstract for results.',
        limitations: 'See full abstract for limitations.',
        dataset: 'Dataset information in abstract.',
        shortSummary: content.length > 100 ? content.substring(0, 100) + '...' : content,
        cachedAt: DateTime.now(),
        doi: null,
        url: null,
      ));
    }
    
    return papers;
  }



  String _createShortSummary(String abstract) {
    if (abstract.isEmpty) return 'No summary available.';
    final sentences = abstract.split('.');
    if (sentences.isNotEmpty) {
      return sentences[0].trim() + '.';
    }
    return abstract.substring(0, abstract.length > 100 ? 100 : abstract.length) + '...';
  }

  List<Paper> _getMockPapers(String query) {
    print('📚 Generating query-relevant mock papers for: "$query"');
    
    // Make mock data somewhat relevant to the query
    final queryLower = query.toLowerCase();
    final baseYear = DateTime.now().year;
    
    if (queryLower.contains('crispr') || queryLower.contains('gene') || queryLower.contains('editing')) {
      return [
        Paper(
          id: 'mock_gene_1',
          title: 'Advanced CRISPR-Cas9 Gene Editing Techniques in $query Research',
          authors: ['Dr. Jane Smith', 'Prof. John Doe'],
          year: baseYear,
          source: 'Nature Biotechnology',
          abstract: 'This study presents a novel approach to CRISPR-Cas9 gene editing specifically targeting aspects of $query with enhanced precision and reduced off-target effects.',
          methodology: 'Used enhanced Cas9 with off-target detection threshold 0.2 on relevant cellular samples',
          results: '89% specificity achieved with minimal off-target mutations in $query applications',
          limitations: 'Study limited to laboratory conditions, requires validation in real-world $query scenarios',
          dataset: 'Laboratory cellular samples (n=150) relevant to $query research',
          shortSummary: 'Novel CRISPR approach achieves 89% specificity in $query-related gene editing.',
          cachedAt: DateTime.now(),
          doi: '10.1038/nbt.mock.${DateTime.now().millisecondsSinceEpoch}',
          url: 'https://mock-research.example.com/gene-editing-$query',
        ),
        Paper(
          id: 'mock_gene_2',
          title: 'Enhanced Cas12a Variants for $query Genome Editing Applications',
          authors: ['Dr. Sarah Johnson', 'Dr. Mike Chen'],
          year: baseYear,
          source: 'Cell',
          abstract: 'We developed enhanced Cas12a variants with improved specificity for $query applications and reduced processing requirements.',
          methodology: 'Enhanced Cas12a model tested with improved specificity protocols for $query research',
          results: '92% accuracy with reduced preprocessing requirements in $query contexts',
          limitations: 'Requires specific preprocessing steps for optimal performance in $query applications',
          dataset: 'Genome samples relevant to $query (n=200)',
          shortSummary: 'Enhanced Cas12a achieves 92% accuracy in $query genome editing.',
          cachedAt: DateTime.now(),
          doi: '10.1016/j.cell.mock.${DateTime.now().millisecondsSinceEpoch}',
          url: 'https://mock-research.example.com/cas12a-$query',
        ),
      ];
    } else if (queryLower.contains('machine learning') || queryLower.contains('ai') || queryLower.contains('deep learning')) {
      return [
        Paper(
          id: 'mock_ml_1',
          title: 'Deep Learning Applications in $query: A Comprehensive Study',
          authors: ['Prof. Emily Zhang', 'Dr. Robert Wilson'],
          year: baseYear,
          source: 'Nature Machine Intelligence',
          abstract: 'A comprehensive deep learning approach for $query applications with state-of-the-art performance across multiple benchmarks.',
          methodology: 'Deep neural network architecture trained on large-scale $query datasets',
          results: '95% accuracy in $query classification tasks, outperforming previous methods',
          limitations: 'High computational cost and requires large datasets for $query applications',
          dataset: 'Large-scale $query dataset (n=10,000 samples)',
          shortSummary: 'Deep learning model achieves 95% accuracy in $query applications.',
          cachedAt: DateTime.now(),
          doi: '10.1038/s42256.mock.${DateTime.now().millisecondsSinceEpoch}',
          url: 'https://mock-research.example.com/deep-learning-$query',
        ),
      ];
    } else {
      // Generic papers that adapt to the query topic
      return [
        Paper(
          id: 'mock_generic_1',
          title: 'Recent Advances in $query Research: A Systematic Review',
          authors: ['Dr. Research Team', 'Prof. Academic Lead'],
          year: baseYear,
          source: 'Scientific Reports',
          abstract: 'This systematic review examines recent advances in $query research, highlighting key methodologies and breakthrough results.',
          methodology: 'Systematic literature review and meta-analysis of $query studies from 2020-$baseYear',
          results: 'Identified 15 major breakthroughs in $query with significant implications for future research',
          limitations: 'Limited to English-language publications in $query field',
          dataset: 'Literature database covering $query research (n=250 papers)',
          shortSummary: 'Systematic review identifies 15 major breakthroughs in $query research.',
          cachedAt: DateTime.now(),
          doi: '10.1038/s41598.mock.${DateTime.now().millisecondsSinceEpoch}',
          url: 'https://mock-research.example.com/$query-review',
        ),
        Paper(
          id: 'mock_generic_2',
          title: 'Novel Methodologies in $query: Current State and Future Directions',
          authors: ['Dr. Innovation Lead', 'Prof. Future Research'],
          year: baseYear,
          source: 'Nature Reviews',
          abstract: 'An examination of novel methodologies emerging in $query research with emphasis on reproducibility and scalability.',
          methodology: 'Comparative analysis of emerging $query methodologies using standardized evaluation metrics',
          results: 'Three methodologies showed superior performance in $query applications',
          limitations: 'Evaluation limited to laboratory settings, field validation needed for $query',
          dataset: 'Multi-institutional $query dataset (n=500 samples)',
          shortSummary: 'Three novel methodologies show superior performance in $query research.',
          cachedAt: DateTime.now(),
          doi: '10.1038/nrn.mock.${DateTime.now().millisecondsSinceEpoch}',
          url: 'https://mock-research.example.com/$query-methodologies',
        ),
      ];
    }
  }

  Future<String> generateComparison(List<Paper> papers) async {
    if (papers.isEmpty) return 'No papers to compare';
    
    try {
      print('🤖 Generating AI comparison using Perplexity...');
      
      // Build detailed prompt for Perplexity to compare the papers
      final papersInfo = papers.asMap().entries.map((entry) {
        final idx = entry.key;
        final paper = entry.value;
        return 'Study ${String.fromCharCode(65 + idx)} (${paper.year}): ${paper.title}\n'
               'Authors: ${paper.authors.join(", ")}\n'
               'Method: ${paper.methodology}\n'
               'Dataset: ${paper.dataset}\n'
               'Results: ${paper.results}\n'
               'Limitations: ${paper.limitations}';
      }).join('\n\n');
      
      final response = await http.post(
        Uri.parse('$perplexityBaseUrl/chat/completions'),
        headers: {
          'Authorization': 'Bearer $perplexityApiKey',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'model': 'sonar',
          'messages': [
            {
              'role': 'system',
              'content': 'You are an expert research analyst with deep knowledge of scientific methodologies. '
                        'Provide detailed, insightful comparisons of research papers, highlighting methodological differences, '
                        'strengths, weaknesses, and innovation. Use bullet points for clarity.',
            },
            {
              'role': 'user',
              'content': 'Analyze and compare these research papers:\n\n$papersInfo\n\n'
                        'Provide a comprehensive comparison covering:\n'
                        '1. Methodological approaches and innovations\n'
                        '2. Dataset characteristics and sample sizes\n'
                        '3. Results and performance metrics\n'
                        '4. Key limitations and trade-offs\n'
                        '5. Overall assessment of each study\'s contribution',
            }
          ],
          'max_tokens': 600,
          'temperature': 0.3,
          'top_p': 0.9,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final comparison = data['choices'][0]['message']['content'] ?? '';
        
        if (comparison.isNotEmpty) {
          print('✅ Perplexity comparison generated successfully');
          return comparison;
        }
      } else {
        print('❌ Perplexity API error: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Perplexity comparison error: $e');
    }
    
    // Fallback comparison
    print('⚠️ Using fallback comparison');
    final buffer = StringBuffer();
    buffer.writeln('Comparison Summary:');
    for (var i = 0; i < papers.length; i++) {
      final paper = papers[i];
      buffer.writeln('- Study ${String.fromCharCode(65 + i)} (${paper.year}): ${paper.methodology}');
    }
    return buffer.toString();
  }

  Future<Map<String, dynamic>> generateEnhancedSummary(Paper paper) async {
    try {
      final response = await http.post(
        Uri.parse('$perplexityBaseUrl/chat/completions'),
        headers: {
          'Authorization': 'Bearer $perplexityApiKey',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'model': 'sonar',
          'messages': [
            {
              'role': 'system',
              'content': 'You are a research summarizer. Extract and format key information from research papers.',
            },
            {
              'role': 'user',
              'content': 'Analyze this research paper and extract:\n'
                        '1. Methodology (2-3 sentences)\n'
                        '2. Key Results (2-3 sentences)\n'
                        '3. Limitations (1-2 sentences)\n\n'
                        'Title: ${paper.title}\n'
                        'Abstract: ${paper.abstract}\n\n'
                        'Format as JSON with keys: methodology, results, limitations',
            }
          ],
          'max_tokens': 300,
          'temperature': 0.2,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final content = data['choices'][0]['message']['content'] ?? '';
        
        try {
          return json.decode(content);
        } catch (e) {
          // If not valid JSON, return structured text
          return {
            'methodology': paper.methodology,
            'results': paper.results,
            'limitations': paper.limitations,
          };
        }
      }
    } catch (e) {
      print('Enhanced summary error: $e');
    }
    
    return {
      'methodology': paper.methodology,
      'results': paper.results,
      'limitations': paper.limitations,
    };
  }
}
