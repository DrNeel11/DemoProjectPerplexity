import 'package:flutter/material.dart';
import '../services/connectivity_service.dart';
import '../services/storage_service.dart';
import '../services/api_service.dart';
import '../models/research_query.dart';
import '../models/comparison_data.dart';
import '../models/paper.dart';
import 'search_results_screen.dart';
import 'cached_library_screen.dart';
import 'perplexity_insights_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ConnectivityService _connectivityService = ConnectivityService();
  final StorageService _storageService = StorageService();
  final ApiService _apiService = ApiService();

  bool _isOnline = true;
  bool _isLoading = false;
  List<ResearchQuery> _recentSearches = [];

  @override
  void initState() {
    super.initState();
    _connectivityService.connectivityStream.listen((isOnline) {
      setState(() {
        _isOnline = isOnline;
      });
    });
    _loadRecentSearches();
  }

  Future<void> _loadRecentSearches() async {
    final queries = await _storageService.getAllQueries();
    setState(() {
      _recentSearches = queries.take(5).toList();
    });
  }

  List<ComparisonData> _createComparisonData(List<Paper> papers) {
    return papers.map((paper) => ComparisonData.fromPaper(paper)).toList();
  }

  Future<void> _performSearch() async {
    if (_searchController.text.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final query = _searchController.text.trim();

      if (_isOnline) {
        // Online search
        final papers = await _apiService.searchPapers(query);
        final comparison = await _apiService.generateComparison(papers);

        // Save to cache
        await _storageService.savePapers(papers);

        final researchQuery = ResearchQuery(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          query: query,
          searchedAt: DateTime.now(),
          paperIds: papers.map((p) => p.id).toList(),
          comparisonSummary: comparison,
        );

        await _storageService.saveQuery(researchQuery);

        // Navigate to results
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SearchResultsScreen(
              query: researchQuery,
              papers: papers,
              comparison: comparison,
              isOffline: false,
              comparisonData: _createComparisonData(papers),
            ),
          ),
        );
      } else {
        // Offline search
        final papers = await _storageService.searchPapers(query);

        if (papers.isEmpty) {
          _showSnackBar('No cached results found for "$query"');
        } else {
          final comparison = await _apiService.generateComparison(papers);

          final researchQuery = ResearchQuery(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            query: query,
            searchedAt: DateTime.now(),
            paperIds: papers.map((p) => p.id).toList(),
            comparisonSummary: comparison,
          );

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SearchResultsScreen(
                query: researchQuery,
                papers: papers,
                comparison: comparison,
                isOffline: true,
                comparisonData: _createComparisonData(papers),
              ),
            ),
          );
        }
      }
    } catch (e) {
      _showSnackBar('Error: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'EdgeScholar',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w300,
                                    color: Colors.black87,
                                    letterSpacing: -0.5,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  'Edge-Enabled Research Companion',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: Colors.grey.shade600,
                                        fontWeight: FontWeight.w400,
                                        letterSpacing: 0.2,
                                      ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: const Text(
                                    'AI',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black87,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        // Connection Status Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _isOnline
                                ? Colors.grey.shade100
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _isOnline
                                  ? Colors.grey.shade300
                                  : Colors.grey.shade400,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: _isOnline 
                                      ? Colors.black87 
                                      : Colors.grey.shade600,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _isOnline ? 'Online' : 'Offline',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: _isOnline
                                      ? Colors.black87
                                      : Colors.grey.shade700,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Search Bar
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Latest research on...',
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(20),
                          hintStyle: TextStyle(
                            color: Colors.grey.shade400,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.2,
                          ),
                        ),
                        onSubmitted: (_) => _performSearch(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Search Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _performSearch,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          padding:
                              const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                ),
                              )
                            : const Text(
                                'Search',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Action Buttons Row
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const CachedLibraryScreen(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.folder_outlined),
                            label: const Text('Cached'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 16),
                              side: BorderSide(
                                  color: Colors.grey.shade300),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed:
                                _searchController.text.trim().isEmpty
                                    ? null
                                    : () {
                                        showDialog(
                                          context: context,
                                          builder: (context) =>
                                              PerplexityInsightsDialog(
                                            query: _searchController.text
                                                .trim(),
                                          ),
                                        );
                                      },
                            icon: const Icon(Icons.auto_awesome, size: 18),
                            label: const Text('AI Insights'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Recent Searches
            if (_recentSearches.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.fromLTRB(24, 16, 24, 12),
                  child: Text(
                    'Recent Searches',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              SliverPadding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final search = _recentSearches[index];
                      return Card(
                        margin:
                            const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                Colors.grey.shade100,
                            child: Icon(
                              Icons.history,
                              color: Colors.black87,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            search.query,
                            style: const TextStyle(
                                fontWeight: FontWeight.w500),
                          ),
                          subtitle: Text(
                            _formatDateTime(search.searchedAt),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.grey.shade400,
                          ),
                          onTap: () {
                            _searchController.text =
                                search.query;
                            _performSearch();
                          },
                        ),
                      );
                    },
                    childCount: _recentSearches.length,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _connectivityService.dispose();
    super.dispose();
  }
}
