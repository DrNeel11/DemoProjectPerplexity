import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/research_query.dart';
import '../models/paper.dart';
import '../models/comparison_data.dart';
import '../services/storage_service.dart';
import 'search_results_screen.dart';

class CachedLibraryScreen extends StatefulWidget {
  const CachedLibraryScreen({Key? key}) : super(key: key);

  @override
  State<CachedLibraryScreen> createState() => _CachedLibraryScreenState();
}

class _CachedLibraryScreenState extends State<CachedLibraryScreen> {
  final StorageService _storageService = StorageService();
  List<ResearchQuery> _queries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCachedData();
  }

  Future<void> _loadCachedData() async {
    setState(() {
      _isLoading = true;
    });

    final queries = await _storageService.getAllQueries();
    
    setState(() {
      _queries = queries;
      _isLoading = false;
    });
  }

  List<ComparisonData> _createComparisonData(List<Paper> papers) {
    return papers.map((paper) => ComparisonData.fromPaper(paper)).toList();
  }

  Future<void> _deleteQuery(ResearchQuery query) async {
    await _storageService.deleteQuery(query.id);
    _loadCachedData();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Query removed from cache'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _openQuery(ResearchQuery query) async {
    // Load papers for this query
    final papers = <Paper>[];
    for (final paperId in query.paperIds) {
      final paper = await _storageService.getPaper(paperId);
      if (paper != null) {
        papers.add(paper);
      }
    }

    if (papers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No cached papers found for this query'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchResultsScreen(
          query: query,
          papers: papers,
          comparison: query.comparisonSummary ?? 'No comparison available',
          isOffline: true,
          comparisonData: _createComparisonData(papers),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Cached Library',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          if (_queries.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep, color: Colors.red),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Clear All Cache'),
                    content: const Text('Are you sure you want to clear all cached data?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () async {
                          await _storageService.clearAllData();
                          Navigator.pop(context);
                          _loadCachedData();
                        },
                        child: const Text('Clear', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _queries.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadCachedData,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _queries.length,
                    itemBuilder: (context, index) {
                      final query = _queries[index];
                      return _CachedQueryCard(
                        query: query,
                        onTap: () => _openQuery(query),
                        onDelete: () => _deleteQuery(query),
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.folder_open,
              size: 80,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Cached Topics',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Search for papers to cache them for offline use',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _CachedQueryCard extends StatelessWidget {
  final ResearchQuery query;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _CachedQueryCard({
    required this.query,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      query.query,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete_outline, color: Colors.red.shade400),
                    onPressed: onDelete,
                    tooltip: 'Delete',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildChip(
                    Icons.article,
                    '${query.paperIds.length} papers',
                    Colors.blue,
                  ),
                  const SizedBox(width: 8),
                  _buildChip(
                    Icons.access_time,
                    _formatDate(query.searchedAt),
                    Colors.grey,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChip(IconData icon, String label, Color color) {
    final darkColor = color == Colors.grey ? Colors.grey.shade700 : color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: darkColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: darkColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return DateFormat('MMM d, yyyy').format(date);
    }
  }
}
