import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../core/token_storage.dart';

class ApiClient {
  late final Dio dio;

  // Platform-aware baseUrl: 10.0.2.2 for Android Emulator, 127.0.0.1 for Web/Desktop/iOS
  static String get baseUrl {
    if (kIsWeb) return 'http://127.0.0.1:8000';
    try {
      if (Platform.isAndroid) return 'http://10.0.2.2:8000';
    } catch (_) {}
    return 'http://127.0.0.1:8000';
  }

  ApiClient() {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Automatic token attachment and error logging
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await TokenStorage.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          if (e.response?.statusCode == 401) {
            debugPrint("WARNING: Token expired! User needs to re-authenticate.");
          }
          return handler.next(e);
        },
      ),
    );
  }

  /// Fetches the live personalized homepage feed with scored widgets
  Future<Response> getHomepage({
    double? lat,
    double? lon,
    String climateZone = 'tropical',
    int heroCount = 4,
  }) async {
    final queryParams = <String, dynamic>{
      'climate_zone': climateZone,
      'hero_count': heroCount,
    };
    if (lat != null) queryParams['lat'] = lat;
    if (lon != null) queryParams['lon'] = lon;

    return await dio.get('/homepage', queryParameters: queryParams);
  }

  /// Generates a live custom scored feed with active user preferences
  Future<Response> getCustomFeed({
    required Map<String, dynamic> userPreferences,
    int heroCount = 4,
    double? lat,
    double? lon,
  }) async {
    final body = <String, dynamic>{
      'user_preferences': userPreferences,
      'hero_count': heroCount,
    };
    if (lat != null) body['latitude'] = lat;
    if (lon != null) body['longitude'] = lon;
    return await dio.post('/homepage/custom', data: body);
  }

  /// Fetches real-time ambient weather & AQI context
  Future<Response> getCurrentWeather({
    double? lat,
    double? lon,
    String climateZone = 'tropical',
  }) async {
    final queryParams = <String, dynamic>{
      'climate_zone': climateZone,
    };
    if (lat != null) queryParams['lat'] = lat;
    if (lon != null) queryParams['lon'] = lon;

    return await dio.get('/api/v1/weather/current', queryParameters: queryParams);
  }

  /// Posts user onboarding answers
  Future<Response> submitOnboarding(Map<String, dynamic> answers) async {
    return await dio.post('/onboarding/answers', data: {'answers': answers});
  }
}

// Global instance of ApiClient
final apiClient = ApiClient();
