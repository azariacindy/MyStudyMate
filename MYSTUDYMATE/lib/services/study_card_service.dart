import 'package:dio/dio.dart';
import 'dart:io';
import '../models/study_card_model.dart';
import 'dio_client.dart';

class StudyCardService {
  final Dio _dio = DioClient.getInstance();

  /// Get all study cards for current user
  Future<List<StudyCard>> getStudyCards() async {
    try {
      final response = await _dio.get('study-cards');
      
      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => StudyCard.fromJson(json)).toList();
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load study cards');
      }
    } catch (e) {
      throw Exception('Error loading study cards: $e');
    }
  }

  /// Create new study card
  Future<StudyCard> createStudyCard({
    required String title,
    String? description,
    required String materialType,
    String? materialContent,
    File? materialFile,
  }) async {
    try {
      FormData formData = FormData.fromMap({
        'title': title,
        'material_type': materialType,
        if (description != null && description.isNotEmpty) 
          'description': description,
        if (materialContent != null && materialContent.isNotEmpty) 
          'material_content': materialContent,
      });

      // Add file if provided
      if (materialFile != null) {
        formData.files.add(
          MapEntry(
            'material_file',
            await MultipartFile.fromFile(
              materialFile.path,
              filename: materialFile.path.split(Platform.pathSeparator).last,
            ),
          ),
        );
      }

      final response = await _dio.post(
        'study-cards',
        data: formData,
      );

      if (response.data['success'] == true) {
        return StudyCard.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['error'] ?? 'Failed to create study card');
      }
    } catch (e) {
      if (e is DioException && e.response != null) {
        throw Exception(e.response?.data['error'] ?? 'Failed to create study card');
      }
      throw Exception('Error creating study card: $e');
    }
  }

  /// Get study card by ID
  Future<StudyCard> getStudyCardById(int id) async {
    try {
      final response = await _dio.get('study-cards/$id');

      if (response.data['success'] == true) {
        return StudyCard.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load study card');
      }
    } catch (e) {
      throw Exception('Error loading study card: $e');
    }
  }

  /// Update study card
  Future<StudyCard> updateStudyCard({
    required int id,
    required String title,
    String? description,
    required String materialType,
    String? materialContent,
    File? materialFile,
  }) async {
    try {
      FormData formData = FormData.fromMap({
        '_method': 'PUT',
        'title': title,
        'material_type': materialType,
        if (description != null && description.isNotEmpty) 
          'description': description,
        if (materialContent != null && materialContent.isNotEmpty) 
          'material_content': materialContent,
      });

      // Add file if provided
      if (materialFile != null) {
        formData.files.add(
          MapEntry(
            'material_file',
            await MultipartFile.fromFile(
              materialFile.path,
              filename: materialFile.path.split(Platform.pathSeparator).last,
            ),
          ),
        );
      }

      final response = await _dio.post(
        'study-cards/$id',
        data: formData,
      );

      if (response.data['success'] == true) {
        return StudyCard.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['error'] ?? 'Failed to update study card');
      }
    } catch (e) {
      if (e is DioException && e.response != null) {
        throw Exception(e.response?.data['error'] ?? 'Failed to update study card');
      }
      throw Exception('Error updating study card: $e');
    }
  }

  /// Delete study card
  Future<void> deleteStudyCard(int id) async {
    try {
      final response = await _dio.delete('study-cards/$id');

      if (response.data['success'] != true) {
        throw Exception(response.data['error'] ?? 'Failed to delete study card');
      }
    } catch (e) {
      if (e is DioException && e.response != null) {
        throw Exception(e.response?.data['error'] ?? 'Failed to delete study card');
      }
      throw Exception('Error deleting study card: $e');
    }
  }

  /// Generate quiz from study card
  Future<Map<String, dynamic>> generateQuiz(int studyCardId, {int questionCount = 5}) async {
    try {
      final response = await _dio.post(
        'study-cards/$studyCardId/generate-quiz',
        data: {
          'question_count': questionCount,
        },
      );

      if (response.data['success'] == true) {
        return response.data['data'];
      } else {
        throw Exception(response.data['error'] ?? 'Failed to generate quiz');
      }
    } catch (e) {
      if (e is DioException && e.response != null) {
        throw Exception(e.response?.data['error'] ?? 'Failed to generate quiz');
      }
      throw Exception('Error generating quiz: $e');
    }
  }
}
