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
      // This would normally fetch from API
      // For now, return mock data
      await Future.delayed(const Duration(milliseconds: 500));
      
      return {
        'success': true,
        'streak_days': 4,
        'current_month': 'July 2025',
        'completed_days': [3, 4, 5, 6], // Day numbers in current month
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }
}
