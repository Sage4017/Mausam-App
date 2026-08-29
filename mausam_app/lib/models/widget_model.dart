class WidgetCard {
  final int rank;
  final String widgetId;
  final String category;
  final String title;
  final String badge;
  final Map<String, dynamic> highlights;

  WidgetCard({
    required this.rank,
    required this.widgetId,
    required this.category,
    required this.title,
    required this.badge,
    required this.highlights,
  });

  factory WidgetCard.fromJson(Map<String, dynamic> json) {
    return WidgetCard(
      rank: json['rank'] ?? 0,
      widgetId: json['widget_id'] ?? '',
      category: json['category'] ?? '',
      title: json['title'] ?? '',
      badge: json['badge'] ?? '',
      highlights: json['highlights'] ?? {},
    );
  }
}

class HomeFeedResponse {
  final String status;
  final int heroCount;
  final Map<String, dynamic> weatherSummary;
  final List<WidgetCard> primaryWidgets;
  final List<WidgetCard> secondaryWidgets;

  HomeFeedResponse({
    required this.status,
    required this.heroCount,
    required this.weatherSummary,
    required this.primaryWidgets,
    required this.secondaryWidgets,
  });

  factory HomeFeedResponse.fromJson(Map<String, dynamic> json) {
    return HomeFeedResponse(
      status: json['status'] ?? '',
      heroCount: json['hero_count'] ?? 3,
      weatherSummary: json['weather_summary'] ?? {},
      primaryWidgets: (json['primary_widgets'] as List?)
              ?.map((e) => WidgetCard.fromJson(e))
              .toList() ??
          [],
      secondaryWidgets: (json['secondary_widgets'] as List?)
              ?.map((e) => WidgetCard.fromJson(e))
              .toList() ??
          [],
    );
  }
}
