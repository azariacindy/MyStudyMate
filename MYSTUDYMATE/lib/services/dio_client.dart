import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/api_constant.dart';

class DioClient {
  static final Dio _dio = Dio();
  static final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static int _currentUserId = 0; // Default: no user (must login first)
  static bool _initialized = false;

  /// Set current user ID for API requests
  static void setUserId(int userId) {
    _currentUserId = userId;
    // Update header immediately when user changes
    _dio.options.headers['X-User-Id'] = _currentUserId.toString();
  }

  /// Get current user ID
  static int getCurrentUserId() {
    return _currentUserId;
  }

  static Dio getInstance() {
    if (!_initialized) {
      String cleanBaseUrl = baseUrl.replaceAll(RegExp(r'/$'), '');
      _dio.options.baseUrl = '$cleanBaseUrl/api/';

      // Reduced timeouts for better performance
      _dio.options.connectTimeout = const Duration(seconds: 10);
      _dio.options.receiveTimeout = const Duration(seconds: 15);
      _dio.options.sendTimeout = const Duration(seconds: 10);
      _dio.options.contentType = 'application/json';
      _dio.options.headers['Accept'] = 'application/json';
      _dio.options.headers['X-User-Id'] = _currentUserId.toString();

      // Minimal logging for better performance
      _dio.interceptors.clear();
      
      // Auth token interceptor (without excessive logging)
      _dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) async {
            // Get token from secure storage
            final token = await _storage.read(key: 'auth_token');
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
            return handler.next(options);
          },
          onResponse: (response, handler) {
            return handler.next(response);
          },
          onError: (error, handler) {
            // Only log errors, not every request
            if (error.response?.statusCode != null && error.response!.statusCode! >= 500) {
              print('❌ Server Error: ${error.response?.statusCode} ${error.requestOptions.uri}');
            }
            return handler.next(error);
          },
        ),
      );

      _initialized = true;
    }

    return _dio;
  }
}