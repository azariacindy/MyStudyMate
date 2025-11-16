// lib/services/assignment_service.dart
import 'package:dio/dio.dart';
import '../models/assignment_model.dart';
import 'dio_client.dart';

class AssignmentService {
  final Dio _dio = DioClient.getInstance();

  Future<List<Assignment>> getAssignments({String? search}) async {
    final query = search != null ? '?search=$search' : '';
    final response = await _dio.get('/assignments$query');
    return (response.data as List)
        .map((e) => Assignment.fromJson(e))
        .toList();
  }

  Future<void> createAssignment({
    required String title,
    String? description,
    required DateTime deadline,
  }) async {
    await _dio.post('/assignments', data: {
      'title': title,
      'description': description,
      'deadline': deadline.toIso8601String(),
    });
  }

  Future<void> updateAssignment(int id, {
    String? title,
    String? description,
    DateTime? deadline,
    bool? isDone,
  }) async {
    await _dio.put('/assignments/$id', data: {
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (deadline != null) 'deadline': deadline.toIso8601String(),
      if (isDone != null) 'is_done': isDone,
    });
  }

  Future<void> deleteAssignment(int id) async {
    await _dio.delete('/assignments/$id');
  }

  Future<void> markAsDone(int id) async {
    await _dio.patch('/assignments/$id/mark-done');
  }

  Future<Map<String, dynamic>> getWeeklyProgress() async {
    final response = await _dio.get('/assignments/weekly-progress');
    return response.data;
  }
}