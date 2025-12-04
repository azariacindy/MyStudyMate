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
      
      print('🌐 DioClient Base URL: ${_dio.options.baseUrl}');

      _dio.options.connectTimeout = const Duration(seconds: 30);
      _dio.options.receiveTimeout = const Duration(seconds: 30);
      _dio.options.sendTimeout = const Duration(seconds: 30);
      _dio.options.contentType = 'application/json';
      _dio.options.headers['Accept'] = 'application/json';
      _dio.options.headers['X-User-Id'] = _currentUserId.toString();

      // Add detailed logging
      _dio.interceptors.clear();
      
      // Auth token interceptor
      _dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) async {
            print('🔵 REQUEST: ${options.method} ${options.uri}');
            print('🔵 Headers: ${options.headers}');
            // Get token from secure storage
            final token = await _storage.read(key: 'auth_token');
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
            return handler.next(options);
          },
          onResponse: (response, handler) {
            print('✅ RESPONSE: ${response.statusCode} ${response.requestOptions.uri}');
            return handler.next(response);
          },
          onError: (error, handler) {
            print('❌ ERROR: ${error.type}');
            print('❌ Message: ${error.message}');
            print('❌ URL: ${error.requestOptions.uri}');
            if (error.response != null) {
              print('❌ Response Status: ${error.response?.statusCode}');
              print('❌ Response Data: ${error.response?.data}');
            }
            return handler.next(error);
          },
        ),
      );

      _initialized = true;
      print('✅ DioClient initialized');
    }

    return _dio;
  }
}