// lib/services/schedule_service.dart
import 'package:dio/dio.dart';
import '../models/schedule_model.dart';
import 'dio_client.dart';

class ScheduleService {
  final Dio _dio = DioClient.getInstance();

  Future<List<Schedule>> getSchedules({DateTime? start, DateTime? end}) async {
    String url = '/schedules';
    if (start != null && end != null) {
      url += '?start=${start.toIso8601String()}&end=${end.toIso8601String()}';
    }
    final response = await _dio.get(url);
    return (response.data as List)
        .map((e) => Schedule.fromJson(e))
        .toList();
  }

  Future<void> createSchedule({
    required String title,
    String? description,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    await _dio.post('/schedules', data: {
      'title': title,
      'description': description,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
    });
  }

  Future<void> updateSchedule(int id, {
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
  }) async {
    await _dio.put('/schedules/$id', data: {
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (startTime != null) 'start_time': startTime.toIso8601String(),
      if (endTime != null) 'end_time': endTime.toIso8601String(),
    });
  }

  Future<void> deleteSchedule(int id) async {
    await _dio.delete('/schedules/$id');
  }
}