class ResearchQuery {
  final String id;
  final String query;
  final DateTime searchedAt;
  final List<String> paperIds;
  final String? comparisonSummary;

  ResearchQuery({
    required this.id,
    required this.query,
    required this.searchedAt,
    required this.paperIds,
    this.comparisonSummary,
  });

  factory ResearchQuery.fromJson(Map<String, dynamic> json) {
    return ResearchQuery(
      id: json['id'] ?? '',
      query: json['query'] ?? '',
      searchedAt: json['searchedAt'] != null
          ? DateTime.parse(json['searchedAt'])
          : DateTime.now(),
      paperIds: List<String>.from(json['paperIds'] ?? []),
      comparisonSummary: json['comparisonSummary'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'query': query,
      'searchedAt': searchedAt.toIso8601String(),
      'paperIds': paperIds,
      'comparisonSummary': comparisonSummary,
    };
  }
}
