import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../models/schedule_model.dart';
import 'dio_client.dart';

class ScheduleService {
  final Dio _dio = DioClient.getInstance();

  // Get all schedules
  Future<List<Schedule>> getSchedules() async {
    try {
      final response = await _dio.get('/schedules');
      
      if (response.data['success'] == true) {
        final List data = response.data['data'] as List;
        return data.map((e) => Schedule.fromJson(e)).toList();
      }
      throw Exception(response.data['message'] ?? 'Failed to fetch schedules');
    } catch (e) {
      throw Exception('Failed to fetch schedules: $e');
    }
  }

  // Get schedules by date range (for calendar)
  Future<List<Schedule>> getSchedulesByDateRange(DateTime startDate, DateTime endDate) async {
    try {
      final response = await _dio.get('/schedules/range', queryParameters: {
        'start_date': startDate.toIso8601String().split('T')[0],
        'end_date': endDate.toIso8601String().split('T')[0],
      });

      if (response.data['success'] == true) {
        final List data = response.data['data'] as List;
        return data.map((e) => Schedule.fromJson(e)).toList();
      }
      throw Exception(response.data['message'] ?? 'Failed to fetch schedules');
    } catch (e) {
      throw Exception('Failed to fetch schedules: $e');
    }
  }

  // Get schedules by specific date
  Future<List<Schedule>> getSchedulesByDate(DateTime date) async {
    try {
      final dateStr = date.toIso8601String().split('T')[0];
      final response = await _dio.get('/schedules/date/$dateStr');

      if (response.data['success'] == true) {
        final List data = response.data['data'] as List;
        return data.map((e) => Schedule.fromJson(e)).toList();
      }
      throw Exception(response.data['message'] ?? 'Failed to fetch schedules');
    } catch (e) {
      throw Exception('Failed to fetch schedules: $e');
    }
  }

  // Get upcoming schedules
  Future<List<Schedule>> getUpcomingSchedules({int limit = 5}) async {
    try {
      final response = await _dio.get('/schedules/upcoming', queryParameters: {
        'limit': limit,
      });

      if (response.data['success'] == true) {
        final List data = response.data['data'] as List;
        return data.map((e) => Schedule.fromJson(e)).toList();
      }
      throw Exception(response.data['message'] ?? 'Failed to fetch upcoming schedules');
    } catch (e) {
      throw Exception('Failed to fetch upcoming schedules: $e');
    }
  }

  // Create schedule
  Future<Schedule> createSchedule({
    required String title,
    String? description,
    required DateTime date,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
    String? location,
    String? lecturer,
    String? color,
    String type = "lecture",
    bool hasReminder = true,
    int reminderMinutes = 30,
  }) async {
    try {
      final startTimeStr = '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
      final endTimeStr = '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';
      
      final response = await _dio.post('/schedules', data: {
        'title': title,
        'description': description,
        'date': date.toIso8601String().split('T')[0],
        'start_time': startTimeStr,
        'end_time': endTimeStr,
        'location': location,
        'lecturer': lecturer,
        'color': color ?? '#5B9FED',
        'type': type,
        'has_reminder': hasReminder,
        'reminder_minutes': reminderMinutes,
      });

      if (response.data['success'] == true) {
        return Schedule.fromJson(response.data['data']);
      }
      throw Exception(response.data['message'] ?? 'Failed to create schedule');
    } catch (e) {
      if (e is DioException && e.response?.data != null) {
        throw Exception(e.response!.data['message'] ?? 'Failed to create schedule');
      }
      throw Exception('Failed to create schedule: $e');
    }
  }

  // Update schedule
  Future<Schedule> updateSchedule(
    int id, {
    String? title,
    String? description,
    DateTime? date,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    String? location,
    String? lecturer,
    String? color,
    String? type,
    bool? hasReminder,
    int? reminderMinutes,
    bool? isCompleted,
  }) async {
    try {
      final data = <String, dynamic>{};
      
      if (title != null) data['title'] = title;
      if (description != null) data['description'] = description;
      if (date != null) data['date'] = date.toIso8601String().split('T')[0];
      if (startTime != null) {
        data['start_time'] = '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
      }
      if (endTime != null) {
        data['end_time'] = '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';
      }
      if (location != null) data['location'] = location;
      if (lecturer != null) data['lecturer'] = lecturer;
      if (color != null) data['color'] = color;
      if (type != null) data['type'] = type;
      if (hasReminder != null) data['has_reminder'] = hasReminder;
      if (reminderMinutes != null) data['reminder_minutes'] = reminderMinutes;
      if (isCompleted != null) data['is_completed'] = isCompleted;

      final response = await _dio.put('/schedules/$id', data: data);

      if (response.data['success'] == true) {
        return Schedule.fromJson(response.data['data']);
      }
      throw Exception(response.data['message'] ?? 'Failed to update schedule');
    } catch (e) {
      if (e is DioException && e.response?.data != null) {
        throw Exception(e.response!.data['message'] ?? 'Failed to update schedule');
      }
      throw Exception('Failed to update schedule: $e');
    }
  }

  // Toggle schedule completion
  Future<Schedule> toggleScheduleCompletion(int id, bool isCompleted) async {
    try {
      final response = await _dio.patch('/schedules/$id/toggle-complete', data: {
        'is_completed': isCompleted,
      });

      if (response.data['success'] == true) {
        return Schedule.fromJson(response.data['data']);
      }
      throw Exception(response.data['message'] ?? 'Failed to update schedule');
    } catch (e) {
      throw Exception('Failed to update schedule: $e');
    }
  }

  // Delete schedule
  Future<void> deleteSchedule(int id) async {
    try {
      final response = await _dio.delete('/schedules/$id');
      
      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to delete schedule');
      }
    } catch (e) {
      throw Exception('Failed to delete schedule: $e');
    }
  }

  // Check schedule conflict
  Future<bool> checkConflict({
    required DateTime date,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
    int? excludeId,
  }) async {
    try {
      final startTimeStr = '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
      final endTimeStr = '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';
      
      final response = await _dio.post('/schedules/check-conflict', data: {
        'date': date.toIso8601String().split('T')[0],
        'start_time': startTimeStr,
        'end_time': endTimeStr,
        if (excludeId != null) 'exclude_id': excludeId,
      });

      if (response.data['success'] == true) {
        return response.data['has_conflict'] == true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Get schedule statistics
  Future<Map<String, dynamic>> getStats() async {
    try {
      final response = await _dio.get('/schedules/stats');

      if (response.data['success'] == true) {
        return response.data['data'] as Map<String, dynamic>;
      }
      throw Exception(response.data['message'] ?? 'Failed to fetch stats');
    } catch (e) {
      throw Exception('Failed to fetch stats: $e');
    }
  }

  // Get assignments with optional search and filter
  Future<Map<String, dynamic>> getAssignments({
    String? search,
    String? status, // 'pending' or 'done'
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (status != null && status != 'all') {
        queryParams['status'] = status;
      }

      final response = await _dio.get(
        '/assignments',
        queryParameters: queryParams,
      );

      if (response.data['success'] == true) {
        return {
          'success': true,
          'data': response.data['data'],
        };
      }
      throw Exception(response.data['message'] ?? 'Failed to fetch assignments');
    } catch (e) {
      throw Exception('Failed to fetch assignments: $e');
    }
  }

  // Mark assignment as done
  Future<Map<String, dynamic>> markAsDone(String scheduleId) async {
    try {
      final response = await _dio.patch('/assignments/$scheduleId/mark-done');

      if (response.data['success'] == true) {
        return {
          'success': true,
          'data': response.data['data'],
        };
      }
      throw Exception(response.data['message'] ?? 'Failed to mark assignment as done');
    } catch (e) {
      throw Exception('Failed to mark assignment as done: $e');
    }
  }

  // Get weekly progress
  Future<Map<String, dynamic>> getWeeklyProgress() async {
    try {
      final response = await _dio.get('/assignments/weekly-progress');

      if (response.data['success'] == true) {
        return {
          'success': true,
          'data': response.data['data'],
        };
      }
      throw Exception(response.data['message'] ?? 'Failed to fetch weekly progress');
    } catch (e) {
      throw Exception('Failed to fetch weekly progress: $e');
    }
  }

  // Get assignments by status (overdue, due today, upcoming)
  Future<Map<String, dynamic>> getAssignmentsByStatus() async {
    try {
      final response = await _dio.get('/assignments/by-status');

      if (response.data['success'] == true) {
        return {
          'success': true,
          'data': response.data['data'],
        };
      }
      throw Exception(response.data['message'] ?? 'Failed to fetch assignments by status');
    } catch (e) {
      throw Exception('Failed to fetch assignments by status: $e');
    }
  }

  // Create assignment
  Future<Map<String, dynamic>> createAssignment({
    required String title,
    String? description,
    required DateTime deadline,
    String? color,
    bool hasReminder = true,
    int reminderMinutes = 30,
  }) async {
    try {
      // Format deadline as date only (YYYY-MM-DD)
      final deadlineStr = '${deadline.year}-${deadline.month.toString().padLeft(2, '0')}-${deadline.day.toString().padLeft(2, '0')}';
      
      final response = await _dio.post('/assignments', data: {
        'title': title,
        'description': description,
        'deadline': deadlineStr,
        'color': color ?? '#5B9FED',
        'has_reminder': hasReminder,
        'reminder_minutes': reminderMinutes,
      });

      if (response.data['success'] == true) {
        return {
          'success': true,
          'data': response.data['data'],
        };
      }
      throw Exception(response.data['message'] ?? 'Failed to create assignment');
    } catch (e) {
      if (e is DioException) {
        if (e.response?.data != null) {
          final errorData = e.response!.data;
          if (errorData['errors'] != null) {
            // Validation errors
            final errors = errorData['errors'] as Map<String, dynamic>;
            final firstError = errors.values.first;
            throw Exception(firstError is List ? firstError.first : firstError);
          }
          throw Exception(errorData['message'] ?? errorData['error'] ?? 'Failed to create assignment');
        }
        throw Exception('Network error: ${e.message}');
      }
      throw Exception('Failed to create assignment: $e');
    }
  }

  // Update assignment
  Future<Map<String, dynamic>> updateAssignment(
    int id, {
    String? title,
    String? description,
    DateTime? deadline,
    String? color,
    bool? hasReminder,
    int? reminderMinutes,
    bool? isDone,
  }) async {
    try {
      final data = <String, dynamic>{};
      
      if (title != null) data['title'] = title;
      if (description != null) data['description'] = description;
      if (deadline != null) {
        // Format deadline as date only (YYYY-MM-DD)
        data['deadline'] = '${deadline.year}-${deadline.month.toString().padLeft(2, '0')}-${deadline.day.toString().padLeft(2, '0')}';
      }
      if (color != null) data['color'] = color;
      if (hasReminder != null) data['has_reminder'] = hasReminder;
      if (reminderMinutes != null) data['reminder_minutes'] = reminderMinutes;
      if (isDone != null) data['is_done'] = isDone;

      final response = await _dio.put('/assignments/$id', data: data);

      if (response.data['success'] == true) {
        return {
          'success': true,
          'data': response.data['data'],
        };
      }
      throw Exception(response.data['message'] ?? 'Failed to update assignment');
    } catch (e) {
      if (e is DioException && e.response?.data != null) {
        throw Exception(e.response!.data['message'] ?? 'Failed to update assignment');
      }
      throw Exception('Failed to update assignment: $e');
    }
  }

  // Delete assignment
  Future<void> deleteAssignment(int id) async {
    try {
      final response = await _dio.delete('/assignments/$id');
      
      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to delete assignment');
      }
    } catch (e) {
      throw Exception('Failed to delete assignment: $e');
    }
  }
}
