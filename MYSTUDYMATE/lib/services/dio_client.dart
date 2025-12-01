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
      _dio.options.baseUrl = '$cleanBaseUrl/api/'; // ✅ Bersih, tanpa spasi

      _dio.options.connectTimeout = const Duration(seconds: 10);
      _dio.options.receiveTimeout = const Duration(seconds: 10);
      _dio.options.contentType = 'application/json';
      _dio.options.headers['Accept'] = 'application/json';
      _dio.options.headers['X-User-Id'] = _currentUserId.toString();

      // Add interceptors
      _dio.interceptors.clear();
      
      // Auth token interceptor
      _dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) async {
            // Get token from secure storage
            final token = await _storage.read(key: 'auth_token');
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
              print('DEBUG DioClient: Token added to request');
              print('DEBUG DioClient: URL: ${options.baseUrl}${options.path}');
            } else {
              print('DEBUG DioClient: No token found in storage!');
            }
            return handler.next(options);
          },
          onError: (error, handler) {
            print('DEBUG DioClient ERROR: ${error.response?.statusCode}');
            print('DEBUG DioClient ERROR MSG: ${error.response?.data}');
            return handler.next(error);
          },
        ),
      );
      
      // Error logging
      _dio.interceptors.add(LogInterceptor(
        requestBody: false,
        responseBody: false,
        error: true,
        requestHeader: false,
        responseHeader: false,
        request: false,
      ));

      _initialized = true;
    }

    return _dio;
  }
}