import 'package:dio/dio.dart';
import '../config/api_constant.dart';

class DioClient {
  static final Dio _dio = Dio();
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

      // Add error logging only (disable verbose logs for production)
      _dio.interceptors.clear();
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