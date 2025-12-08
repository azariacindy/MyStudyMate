import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_model.dart';
import 'dio_client.dart';
import 'dart:io';

class ProfileService {
  final Dio _dio = DioClient.getInstance();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  /// Get user ID from storage (set by DioClient)
  Future<int?> get _userId async {
    final userIdStr = await _storage.read(key: 'user_id');
    return userIdStr != null ? int.tryParse(userIdStr) : null;
  }

  /// Update user profile (name only)
  Future<Map<String, dynamic>> updateProfile({
    required String name,
  }) async {
    try {
      final userId = await _userId;
      if (userId == null) {
        throw Exception('User not logged in');
      }

      final response = await _dio.put('/update-profile', data: {
        'user_id': userId,
        'name': name,
      });

      if (response.data['success'] == true) {
        return {
          'success': true,
          'message': response.data['message'],
          'user': User.fromJson(response.data['user']),
        };
      } else {
        throw Exception(response.data['message'] ?? 'Failed to update profile');
      }
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Failed to update profile';
      return {
        'success': false,
        'message': message,
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  /// Change password
  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final userId = await _userId;
      if (userId == null) {
        throw Exception('User not logged in');
      }

      // Validate passwords match on client side
      if (newPassword != confirmPassword) {
        return {
          'success': false,
          'message': 'New password and confirm password do not match',
        };
      }

      final response = await _dio.post('/change-password', data: {
        'user_id': userId,
        'current_password': currentPassword,
        'new_password': newPassword,
        'new_password_confirmation': confirmPassword,
      });

      return {
        'success': response.data['success'] ?? false,
        'message': response.data['message'] ?? 'Password changed successfully',
      };
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Failed to change password';
      return {
        'success': false,
        'message': message,
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  /// Upload profile photo
  Future<Map<String, dynamic>> uploadProfilePhoto(File imageFile) async {
    try {
      final userId = await _userId;
      if (userId == null) {
        throw Exception('User not logged in');
      }

      // Create form data with the image
      String fileName = imageFile.path.split('/').last;
      FormData formData = FormData.fromMap({
        'user_id': userId,
        'photo': await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        ),
      });

      final response = await _dio.post(
        '/upload-profile-photo',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (response.data['success'] == true) {
        return {
          'success': true,
          'message': response.data['message'],
          'profile_photo_url': response.data['profile_photo_url'],
        };
      } else {
        throw Exception(response.data['message'] ?? 'Failed to upload photo');
      }
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Failed to upload photo';
      return {
        'success': false,
        'message': message,
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  /// Get streak data (mock for now - can be implemented with real data later)
  Future<Map<String, dynamic>> getStreakData() async {
    try {
      final userId = await _userId;
      if (userId == null) {
        throw Exception('User not logged in');
      }

      final response = await _dio.get(
        '/get-streak',
        queryParameters: {'user_id': userId},
      );

      if (response.data['success'] == true) {
        return {
          'success': true,
          'streak': response.data['streak'] ?? 0,
          'last_streak_date': response.data['last_streak_date'],
          'streak_days': response.data['streak'] ?? 0,
          'current_month': response.data['current_month'] ?? 'December 2025',
          'completed_days': response.data['completed_days'] ?? [],
        };
      } else {
        throw Exception(response.data['message'] ?? 'Failed to get streak data');
      }
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Failed to get streak data';
      return {
        'success': false,
        'message': message,
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  /// Record streak when user completes Pomodoro cycles
  Future<Map<String, dynamic>> recordStreak() async {
    try {
      final userId = await _userId;
      if (userId == null) {
        throw Exception('User not logged in');
      }

      final response = await _dio.post(
        '/record-streak',
        data: {'user_id': userId},
      );

      if (response.data['success'] == true) {
        return {
          'success': true,
          'message': response.data['message'],
          'streak': response.data['streak'],
          'is_consecutive': response.data['is_consecutive'] ?? false,
          'already_recorded': response.data['already_recorded'] ?? false,
        };
      } else {
        throw Exception(response.data['message'] ?? 'Failed to record streak');
      }
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Failed to record streak';
      return {
        'success': false,
        'message': message,
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  /// Get current streak
  Future<Map<String, dynamic>> getCurrentStreak() async {
    try {
      final userId = await _userId;
      if (userId == null) {
        throw Exception('User not logged in');
      }

      final response = await _dio.get(
        '/get-streak',
        queryParameters: {'user_id': userId},
      );

      if (response.data['success'] == true) {
        return {
          'success': true,
          'streak': response.data['streak'] ?? 0,
          'last_streak_date': response.data['last_streak_date'],
          'is_active': response.data['is_active'] ?? false,
        };
      } else {
        throw Exception(response.data['message'] ?? 'Failed to get streak');
      }
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Failed to get streak';
      return {
        'success': false,
        'message': message,
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }
}
