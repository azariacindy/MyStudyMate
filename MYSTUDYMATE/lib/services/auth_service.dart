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
        
        // Set user ID to DioClient
        DioClient.setUserId(user.id);
        
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
    print('🎯 URL: ${_dio.options.baseUrl}');
    print('📦 Data: name=$name, username=$username, email=$email');
    try {
      final response = await _dio.post('/register', data: {
        'name': name,
        'username': username,
        'email': email,
        'password': password,
      });
      
       // 🔍 DEBUG: Cetak respons sukses
      print('✅ Respons sukses: ${response.data}');


      // Ambil data user dari respons Laravel
      final userData = response.data['user'] as Map<String, dynamic>;
      return User.fromJson(userData);
    } on DioException catch (e) {
      print('❌ Error message: ${e.message}');
      print('Status code: ${e.response?.statusCode}');
      print('Response body: ${e.response?.data}');
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

      // Simpan token
      await _storage.write(key: _tokenKey, value: token);

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

      // Save FCM token to backend
      await _saveFCMToken();

      return user;
    } on DioException catch (e) {
      final message = _extractErrorMessage(e);
      throw Exception(message);
    }
  }

  /// Save FCM token to backend
  Future<void> _saveFCMToken() async {
    try {
      final fcmToken = FirebaseMessagingService().fcmToken;
      final user = await getCurrentUser();
      
      if (fcmToken != null && user != null) {
        await _dio.post('/save-fcm-token', data: {
          'user_id': user.id,
          'fcm_token': fcmToken,
        });
        print('[Auth] FCM token saved to backend: ${fcmToken.substring(0, 20)}...');
      } else {
        print('[Auth] Cannot save FCM token: token=$fcmToken, user=$user');
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