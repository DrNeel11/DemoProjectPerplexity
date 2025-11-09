class Paper {
  final String id;
  final String title;
  final List<String> authors;
  final int year;
  final String source;
  final String abstract;
  final String methodology;
  final String results;
  final String limitations;
  final String dataset;
  final String shortSummary;
  final DateTime cachedAt;
  final String? doi;
  final String? url;

  Paper({
    required this.id,
    required this.title,
    required this.authors,
    required this.year,
    required this.source,
    required this.abstract,
    required this.methodology,
    required this.results,
    required this.limitations,
    required this.dataset,
    required this.shortSummary,
    required this.cachedAt,
    this.doi,
    this.url,
  });

  factory Paper.fromJson(Map<String, dynamic> json) {
    return Paper(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      authors: List<String>.from(json['authors'] ?? []),
      year: json['year'] ?? DateTime.now().year,
      source: json['source'] ?? '',
      abstract: json['abstract'] ?? '',
      methodology: json['methodology'] ?? '',
      results: json['results'] ?? '',
      limitations: json['limitations'] ?? '',
      dataset: json['dataset'] ?? '',
      shortSummary: json['shortSummary'] ?? '',
      cachedAt: json['cachedAt'] != null
          ? DateTime.parse(json['cachedAt'])
          : DateTime.now(),
      doi: json['doi'],
      url: json['url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'authors': authors,
      'year': year,
      'source': source,
      'abstract': abstract,
      'methodology': methodology,
      'results': results,
      'limitations': limitations,
      'dataset': dataset,
      'shortSummary': shortSummary,
      'cachedAt': cachedAt.toIso8601String(),
      'doi': doi,
      'url': url,
    };
  }
}
