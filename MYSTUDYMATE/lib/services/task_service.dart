import 'package:dio/dio.dart';
import '../models/task_model.dart';
import 'dio_client.dart';

class TaskService {
  final Dio _dio = DioClient.getInstance();

  // Get all tasks
  Future<List<Task>> getTasks() async {
    try {
      final response = await _dio.get('/tasks');
      
      if (response.data['success'] == true) {
        final List data = response.data['data'] as List;
        return data.map((e) => Task.fromJson(e)).toList();
      }
      throw Exception(response.data['message'] ?? 'Failed to fetch tasks');
    } catch (e) {
      throw Exception('Failed to fetch tasks: $e');
    }
  }

  // Get tasks by deadline range (for calendar integration)
  Future<List<Task>> getTasksByDeadlineRange(DateTime startDate, DateTime endDate) async {
    try {
      final response = await _dio.get('/tasks/range', queryParameters: {
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
      });

      if (response.data['success'] == true) {
        final List data = response.data['data'] as List;
        return data.map((e) => Task.fromJson(e)).toList();
      }
      throw Exception(response.data['message'] ?? 'Failed to fetch tasks');
    } catch (e) {
      throw Exception('Failed to fetch tasks: $e');
    }
  }

  // Get upcoming tasks
  Future<List<Task>> getUpcomingTasks({int limit = 10}) async {
    try {
      final response = await _dio.get('/tasks/upcoming', queryParameters: {
        'limit': limit,
      });

      if (response.data['success'] == true) {
        final List data = response.data['data'] as List;
        return data.map((e) => Task.fromJson(e)).toList();
      }
      throw Exception(response.data['message'] ?? 'Failed to fetch upcoming tasks');
    } catch (e) {
      throw Exception('Failed to fetch upcoming tasks: $e');
    }
  }

  // Create task
  Future<Task> createTask({
    required String title,
    String? description,
    DateTime? deadline,
    String? category,
    String priority = 'medium',
  }) async {
    try {
      final response = await _dio.post('/tasks', data: {
        'title': title,
        'description': description,
        'deadline': deadline?.toIso8601String(),
        'category': category,
        'priority': priority,
      });

      if (response.data['success'] == true) {
        return Task.fromJson(response.data['data']);
      }
      throw Exception(response.data['message'] ?? 'Failed to create task');
    } catch (e) {
      if (e is DioException && e.response?.data != null) {
        throw Exception(e.response!.data['message'] ?? 'Failed to create task');
      }
      throw Exception('Failed to create task: $e');
    }
  }

  // Update task
  Future<Task> updateTask(
    int id, {
    String? title,
    String? description,
    DateTime? deadline,
    String? category,
    String? priority,
    bool? isCompleted,
  }) async {
    try {
      final data = <String, dynamic>{};
      
      if (title != null) data['title'] = title;
      if (description != null) data['description'] = description;
      if (deadline != null) data['deadline'] = deadline.toIso8601String();
      if (category != null) data['category'] = category;
      if (priority != null) data['priority'] = priority;
      if (isCompleted != null) data['is_completed'] = isCompleted;

      final response = await _dio.put('/tasks/$id', data: data);

      if (response.data['success'] == true) {
        return Task.fromJson(response.data['data']);
      }
      throw Exception(response.data['message'] ?? 'Failed to update task');
    } catch (e) {
      if (e is DioException && e.response?.data != null) {
        throw Exception(e.response!.data['message'] ?? 'Failed to update task');
      }
      throw Exception('Failed to update task: $e');
    }
  }

  // Toggle task completion
  Future<Task> toggleTaskCompletion(int id, bool isCompleted) async {
    try {
      final response = await _dio.patch('/tasks/$id/toggle-complete', data: {
        'is_completed': isCompleted,
      });

      if (response.data['success'] == true) {
        return Task.fromJson(response.data['data']);
      }
      throw Exception(response.data['message'] ?? 'Failed to update task');
    } catch (e) {
      throw Exception('Failed to update task: $e');
    }
  }

  // Delete task
  Future<void> deleteTask(int id) async {
    try {
      final response = await _dio.delete('/tasks/$id');
      
      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to delete task');
      }
    } catch (e) {
      throw Exception('Failed to delete task: $e');
    }
  }

  // Get task statistics
  Future<Map<String, dynamic>> getStats() async {
    try {
      final response = await _dio.get('/tasks/stats');

      if (response.data['success'] == true) {
        return response.data['data'] as Map<String, dynamic>;
      }
      throw Exception(response.data['message'] ?? 'Failed to fetch stats');
    } catch (e) {
      throw Exception('Failed to fetch stats: $e');
    }
  }
}
