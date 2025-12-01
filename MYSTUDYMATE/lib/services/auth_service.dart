import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_model.dart';
import 'dio_client.dart';
import 'firebase_messaging_service.dart';

class AuthService {
  final Dio _dio = DioClient.getInstance();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static const String _tokenKey = 'auth_token';

  Future<bool> get isLoggedIn async {
    final token = await _storage.read(key: _tokenKey);
    return token != null && token.isNotEmpty;
  }

  Future<String?> get currentToken async {
    return await _storage.read(key: _tokenKey);
  }

  /// Get current authenticated user from backend
  Future<User?> getCurrentUser() async {
    try {
      final token = await currentToken;
      if (token == null) return null;

      // Set token in headers
      _dio.options.headers['Authorization'] = 'Bearer $token';

      final response = await _dio.get('/current-user');
      if (response.statusCode == 200) {
        final user = User.fromJson(response.data['user']);
        
        // Set user ID to DioClient and save to storage
        DioClient.setUserId(user.id);
        await _storage.write(key: 'user_id', value: user.id.toString());
        
        return user;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Register user via Laravel
  Future<User> signup({
    required String name,
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post('/register', data: {
        'name': name,
        'username': username,
        'email': email,
        'password': password,
      });

      final userData = response.data['user'] as Map<String, dynamic>;
      return User.fromJson(userData);
    } on DioException catch (e) {
      final message = _extractErrorMessage(e);
      throw Exception(message);
    }
  }

  /// Login dengan email ATAU username
  Future<User> signin({
    required String loginIdentifier,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/login',
        data: {
          'login_identifier': loginIdentifier,
          'password': password,
        },
      );

      final data = response.data as Map<String, dynamic>;
      final user = User.fromJson(data['user']);
      final token = data['token'] as String;

      // Simpan token dan user_id
      await _storage.write(key: _tokenKey, value: token);
      await _storage.write(key: 'user_id', value: user.id.toString());

      // Set interceptor
      _dio.interceptors.clear();
      _dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) async {
            options.headers['Authorization'] = 'Bearer $token';
            return handler.next(options);
          },
        ),
      );

      // Set user ID to DioClient
      DioClient.setUserId(user.id);

      // Save FCM token to backend (pass user directly)
      await _saveFCMToken(user);

      return user;
    } on DioException catch (e) {
      final message = _extractErrorMessage(e);
      throw Exception(message);
    }
  }

  /// Save FCM token to backend (with retry for token availability)
  Future<void> _saveFCMToken(User user) async {
    try {
      // Wait for FCM token (retry up to 3 times with 500ms delay)
      String? fcmToken = FirebaseMessagingService().fcmToken;
      int retries = 0;
      while (fcmToken == null && retries < 3) {
        await Future.delayed(const Duration(milliseconds: 500));
        fcmToken = FirebaseMessagingService().fcmToken;
        retries++;
      }
      
      if (fcmToken != null) {
        await _dio.post('/save-fcm-token', data: {
          'user_id': user.id,
          'fcm_token': fcmToken,
        });
        print('[Auth] FCM token saved for user ${user.id}');
      }
    } catch (e) {
      print('[Auth] Error saving FCM token: $e');
    }
  }

  /// Logout
  Future<void> signout() async {
    try {
      await _dio.post('/logout');
    } catch (e) {
      // Abaikan error server
    }

    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: 'user_id');
    _dio.interceptors.clear();
    _dio.options.headers.remove('Authorization');
    
    // Reset DioClient user ID to 0 (no user)
    DioClient.setUserId(0);
  }

  String _extractErrorMessage(DioException e) {
    if (e.response != null) {
      final data = e.response?.data;
      if (data is Map) {
        if (data.containsKey('message')) return data['message'] as String;
        if (data.containsKey('errors') && data['errors'] is Map) {
          final firstError = data['errors'].values.first;
          if (firstError is List && firstError.isNotEmpty) {
            return firstError[0].toString();
          }
        }
      }
    }
    return 'Network error or server unavailable.';
  }
}