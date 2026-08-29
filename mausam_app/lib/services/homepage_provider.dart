import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/widget_model.dart';
import 'api_client.dart';

// AsyncNotifier is the modern Riverpod way to handle live network data
class HomepageNotifier extends AsyncNotifier<HomeFeedResponse> {
  @override
  Future<HomeFeedResponse> build() async {
    return _fetchHomepageData();
  }

  Future<HomeFeedResponse> _fetchHomepageData() async {
    try {
      // Calling the actual Python backend!
      final response = await apiClient.getHomepage();
      
      // Converting the JSON map into our structured Dart objects
      return HomeFeedResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to load personalized homepage: $e');
    }
  }

  // A method for the UI to implement "Pull down to refresh"
  Future<void> refresh() async {
    state = const AsyncLoading(); // Shows loading spinner
    state = await AsyncValue.guard(() => _fetchHomepageData());
  }
}

// The global provider that your UI team will use
final homepageProvider = AsyncNotifierProvider<HomepageNotifier, HomeFeedResponse>(() {
  return HomepageNotifier();
});
