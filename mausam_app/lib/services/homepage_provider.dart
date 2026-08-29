import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/widget_model.dart';

// This provider simulates receiving the scored widgets from the Python backend.
// Later, you will replace this hardcoded list with a call to apiClient.getHomepage()
class HomepageNotifier extends Notifier<List<MausamWidget>> {
  @override
  List<MausamWidget> build() {
    // These scores mimic what your teammate's Python math will eventually calculate
    final mockWidgets = [
      MausamWidget(
        type: 'travel',
        score: 65.0,
        data: {'destination': 'Delhi', 'condition': 'Rain', 'temp': '29°C'},
      ),
      MausamWidget(
        type: 'fitness',
        score: 85.0, // High score, should appear near the top
        data: {'status': 'GOOD', 'best_time': '6:00 AM - 8:00 AM'},
      ),
      MausamWidget(
        type: 'uv_index',
        score: 40.0, // Lower score, should appear near the bottom
        data: {'level': 'Moderate'},
      ),
      MausamWidget(
        type: 'severe_alert',
        score: 100.0, // Highest score, safety overrides everything
        data: {'alert': 'Heavy Rain Expected', 'time': '5:00 PM - 7:00 PM'},
      ),
    ];

    // The most important part: Sorting the widgets based on the backend teammate's score!
    // This physically reorders the list so the highest score is at index 0.
    mockWidgets.sort((a, b) => b.score.compareTo(a.score));

    return mockWidgets;
  }
}

// The global provider that your UI team will use to build the screen
final homepageProvider = NotifierProvider<HomepageNotifier, List<MausamWidget>>(
  () {
    return HomepageNotifier();
  },
);
