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
}
