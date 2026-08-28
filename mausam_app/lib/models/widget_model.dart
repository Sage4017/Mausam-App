class MausamWidget {
  final String type;
  final double score;
  final Map<String, dynamic> data;

  MausamWidget({
    required this.type,
    required this.score,
    required this.data,
  });

  // A helper method to parse JSON when the real Python API is ready
  factory MausamWidget.fromJson(Map<String, dynamic> json) {
    return MausamWidget(
      type: json['type'] ?? 'unknown',
      score: (json['score'] ?? 0.0).toDouble(),
      data: json['data'] ?? {},
    );
  }
}
