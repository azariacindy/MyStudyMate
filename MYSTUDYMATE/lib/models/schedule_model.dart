import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Schedule {
  final int id;
  final int userId;
  final String title;
  final String? description;
  final DateTime date;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final String? location;
  final String? lecturer;
  final String? color;
  final String type;
  final bool hasReminder;
  final int reminderMinutes;
  final bool isCompleted;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  
  // Assignment-specific fields
  final bool? isDone;
  final DateTime? deadline; // For assignment type

  Schedule({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.date,
    required this.startTime,
    required this.endTime,
    this.location,
    this.lecturer,
    this.color,
    required this.type,
    required this.hasReminder,
    required this.reminderMinutes,
    required this.isCompleted,
    this.createdAt,
    this.updatedAt,
    this.isDone,
    this.deadline,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      id: int.parse(json['id'].toString()),
      userId: int.parse(json['user_id'].toString()),
      title: json['title'],
      description: json['description'],
      date: DateTime.parse(json['date']),
      startTime: _parseTimeOfDay(json['start_time']),
      endTime: _parseTimeOfDay(json['end_time']),
      location: json['location'],
      lecturer: json['lecturer'],
      color: json['color'],
      type: json['type'],
      hasReminder: json['has_reminder'] == true || json['has_reminder'] == 1,
      reminderMinutes: int.parse(json['reminder_minutes'].toString()),
      isCompleted: json['is_completed'] == true || json['is_completed'] == 1,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      isDone: json['is_done'] == true || json['is_done'] == 1,
      deadline: json['deadline'] != null ? DateTime.parse(json['deadline']) : null,
    );
  }

  // Parse time string (HH:mm) to TimeOfDay
  static TimeOfDay _parseTimeOfDay(String time) {
    final parts = time.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  // Convert TimeOfDay to HH:mm string
  static String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Map<String, dynamic> toJson() {
    final data = {
      'title': title,
      'description': description,
      'date': DateFormat('yyyy-MM-dd').format(date),
      'start_time': _formatTimeOfDay(startTime),
      'end_time': _formatTimeOfDay(endTime),
      'location': location,
      'lecturer': lecturer,
      'color': color ?? '#5B9FED',
      'type': type,
      'has_reminder': hasReminder,
      'reminder_minutes': reminderMinutes,
      'is_completed': isCompleted,
    };
    
    // Add assignment-specific fields
    if (type == 'assignment') {
      if (isDone != null) data['is_done'] = isDone;
      if (deadline != null) data['deadline'] = DateFormat('yyyy-MM-dd HH:mm:ss').format(deadline!);
    }
    
    return data;
  }

  // Helper to get formatted time string for display
  String getFormattedStartTime() => _formatTimeOfDay(startTime);
  String getFormattedEndTime() => _formatTimeOfDay(endTime);
  
  // Helper to check if schedule is today
  bool isToday() {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  // Helper to get reminder datetime
  DateTime getReminderDateTime() {
    final scheduleDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      startTime.hour,
      startTime.minute,
    );
    return scheduleDateTime.subtract(Duration(minutes: reminderMinutes));
  }
}
