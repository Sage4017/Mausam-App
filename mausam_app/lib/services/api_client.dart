import 'package:dio/dio.dart';

import '../core/token_storage.dart';

class ApiClient {
  late final Dio dio;

  // The base URL of your Python FastAPI server
  // 10.0.2.2 is the localhost alias for Android Emulators
  // Change this to your backend's actual IP or domain later
  static const String baseUrl = 'http://10.0.2.2:8000';

  ApiClient() {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );

    // This Interceptor runs automatically before EVERY API call
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // 1. Check if we have a logged-in user token
          final token = await TokenStorage.getToken();

          // 2. If token exists, securely attach it to the request headers
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          return handler.next(options); // Let the request continue
        },
        onError: (DioException e, handler) async {
          // 3. Handle 401 Unauthorized (Token expired)
          if (e.response?.statusCode == 401) {
            // TODO: Call POST /auth/refresh here to get a new token automatically
            print("WARNING: Token expired! User needs to re-authenticate.");
          }
          return handler.next(e); // Let the error bubble up to the UI
        },
      ),
    );
  }

  // --- EXAMPLE ENDPOINTS FOR YOUR TEAM ---

  // Fetches the personalized dashboard
  Future<Response> getHomepage() async {
    return await dio.get('/homepage');
  }

  // Posts user onboarding answers
  Future<Response> submitOnboarding(Map<String, dynamic> answers) async {
    return await dio.post('/onboarding/answers', data: answers);
  }
}

// A global instance of the ApiClient that your team can use anywhere
final apiClient = ApiClient();
