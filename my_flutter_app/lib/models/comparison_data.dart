class ComparisonData {
  final String paperId;
  final String paperTitle;
  final int year;
  final String method;
  final String dataset;
  final String results;
  final String limitation;

  ComparisonData({
    required this.paperId,
    required this.paperTitle,
    required this.year,
    required this.method,
    required this.dataset,
    required this.results,
    required this.limitation,
  });

  factory ComparisonData.fromPaper(dynamic paper) {
    return ComparisonData(
      paperId: paper.id,
      paperTitle: paper.title,
      year: paper.year,
      method: paper.methodology,
      dataset: paper.dataset,
      results: paper.results,
      limitation: paper.limitations,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'paperId': paperId,
      'paperTitle': paperTitle,
      'year': year,
      'method': method,
      'dataset': dataset,
      'results': results,
      'limitation': limitation,
    };
  }
}
