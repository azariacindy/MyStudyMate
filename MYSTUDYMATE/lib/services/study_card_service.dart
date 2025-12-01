import 'package:dio/dio.dart';
import 'dart:io';
import '../config/api_constant.dart';
import '../models/study_card_model.dart';
import '../models/quiz_model.dart';

class StudyCardService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
  ));

  /// Get all study cards
  Future<List<StudyCard>> getStudyCards() async {
    try {
      final response = await _dio.get('/api/study-cards');
      
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
    required String notes,
    File? file,
  }) async {
    try {
      FormData formData;
      
      if (file != null) {
        // Create multipart form data for file upload
        formData = FormData.fromMap({
          'title': title,
          'notes': notes,
          'file': await MultipartFile.fromFile(
            file.path,
            filename: file.path.split('/').last,
          ),
        });
      } else {
        // Regular JSON request
        formData = FormData.fromMap({
          'title': title,
          'notes': notes,
        });
      }

      final response = await _dio.post(
        '/api/study-cards',
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

  /// Generate quiz from study card using AI
  Future<Quiz> generateQuiz({
    required int studyCardId,
    int questionCount = 5,
  }) async {
    try {
      final response = await _dio.post(
        '/api/study-cards/$studyCardId/generate-quiz',
        data: {'question_count': questionCount},
      );

      if (response.data['success'] == true) {
        final data = response.data['data'];
        // Build Quiz object from response
        return Quiz(
          id: data['quiz_id'],
          studyCardId: studyCardId,
          studyCardTitle: '', // Will be filled when fetching full quiz
          questions: (data['questions'] as List)
              .map((q) => QuizQuestion.fromJson(q))
              .toList(),
          totalQuestions: data['total_questions'],
          timesAttempted: 0,
          bestScore: null,
        );
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

  /// Get quiz details
  Future<Quiz> getQuiz(int quizId) async {
    try {
      final response = await _dio.get('/api/quizzes/$quizId');

      if (response.data['success'] == true) {
        return Quiz.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['error'] ?? 'Failed to load quiz');
      }
    } catch (e) {
      throw Exception('Error loading quiz: $e');
    }
  }

  /// Submit quiz answers
  Future<QuizResult> submitQuiz({
    required int quizId,
    required List<int?> answers,
    int? timeSpent,
  }) async {
    try {
      final response = await _dio.post('/api/quizzes/$quizId/submit', data: {
        'answers': answers,
        'time_spent': timeSpent,
      });

      if (response.data['success'] == true) {
        return QuizResult.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['error'] ?? 'Failed to submit quiz');
      }
    } catch (e) {
      if (e is DioException && e.response != null) {
        throw Exception(e.response?.data['error'] ?? 'Failed to submit quiz');
      }
      throw Exception('Error submitting quiz: $e');
    }
  }

  /// Get quiz attempts history
  Future<Map<String, dynamic>> getQuizAttempts(int quizId) async {
    try {
      final response = await _dio.get('/api/quizzes/$quizId/attempts');

      if (response.data['success'] == true) {
        final data = response.data['data'];
        return {
          'quiz_id': data['quiz_id'],
          'best_score': data['best_score']?.toDouble(),
          'times_attempted': data['times_attempted'],
          'attempts': (data['attempts'] as List)
              .map((a) => QuizAttempt.fromJson(a))
              .toList(),
        };
      } else {
        throw Exception(response.data['error'] ?? 'Failed to load attempts');
      }
    } catch (e) {
      throw Exception('Error loading quiz attempts: $e');
    }
  }

  /// Delete study card
  Future<void> deleteStudyCard(int studyCardId) async {
    try {
      final response = await _dio.delete('/api/study-cards/$studyCardId');

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
}
