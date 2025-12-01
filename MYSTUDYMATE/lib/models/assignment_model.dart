// lib/models/assignment_model.dart
import 'package:flutter/material.dart';

class Assignment {
  final int id;
  final int userId;
  final String title;
  final String? description;
  final DateTime deadline;
  final bool isDone;
  final String color;
  final bool hasReminder;
  final int reminderMinutes;
  final String? lastNotificationType;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  Assignment({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.deadline,
    required this.isDone,
    required this.color,
    required this.hasReminder,
    required this.reminderMinutes,
    this.lastNotificationType,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory Assignment.fromJson(Map<String, dynamic> json) {
    return Assignment(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      title: json['title'] as String,
      description: json['description'] as String?,
      deadline: DateTime.parse(json['deadline'] as String),
      isDone: json['is_done'] as bool? ?? false,
      color: json['color'] as String? ?? '#5B9FED',
      hasReminder: json['has_reminder'] as bool? ?? true,
      reminderMinutes: json['reminder_minutes'] as int? ?? 30,
      lastNotificationType: json['last_notification_type'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] != null 
          ? DateTime.parse(json['deleted_at'] as String) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'deadline': deadline.toIso8601String(),
      'is_done': isDone,
      'color': color,
      'has_reminder': hasReminder,
      'reminder_minutes': reminderMinutes,
      'last_notification_type': lastNotificationType,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      if (deletedAt != null) 'deleted_at': deletedAt!.toIso8601String(),
    };
  }

  Assignment copyWith({
    int? id,
    int? userId,
    String? title,
    String? description,
    DateTime? deadline,
    bool? isDone,
    String? color,
    bool? hasReminder,
    int? reminderMinutes,
    String? lastNotificationType,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return Assignment(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      deadline: deadline ?? this.deadline,
      isDone: isDone ?? this.isDone,
      color: color ?? this.color,
      hasReminder: hasReminder ?? this.hasReminder,
      reminderMinutes: reminderMinutes ?? this.reminderMinutes,
      lastNotificationType: lastNotificationType ?? this.lastNotificationType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  bool get isOverdue => !isDone && deadline.isBefore(DateTime.now());
  
  bool get isDueToday {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final deadlineDate = DateTime(deadline.year, deadline.month, deadline.day);
    return !isDone && deadlineDate.isAtSameMomentAs(today);
  }

  /// Get priority level: 'critical', 'high', 'medium', 'low', 'completed'
  String get priority {
    if (isDone) return 'completed';

    final now = DateTime.now();
    final daysUntilDeadline = deadline.difference(now).inDays;

    if (deadline.isBefore(now)) {
      return 'critical'; // Overdue
    } else if (daysUntilDeadline <= 1) {
      return 'high'; // Due today or tomorrow
    } else if (daysUntilDeadline <= 3) {
      return 'medium'; // Due in 2-3 days
    } else {
      return 'low'; // More than 3 days
    }
  }

  /// Get priority label for display
  String get priorityLabel {
    switch (priority) {
      case 'critical':
        return 'Overdue';
      case 'high':
        return 'Urgent';
      case 'medium':
        return 'Soon';
      case 'low':
        return 'Upcoming';
      case 'completed':
        return 'Done';
      default:
        return 'Unknown';
    }
  }

  /// Get priority color
  Color get priorityColor {
    switch (priority) {
      case 'critical':
        return const Color(0xFFDC2626); // Red-600
      case 'high':
        return const Color(0xFFF59E0B); // Orange-500
      case 'medium':
        return const Color(0xFF3B82F6); // Blue-500
      case 'low':
        return const Color(0xFF10B981); // Green-500
      default:
        return const Color(0xFF6B7280); // Gray-500
    }
  }

  /// Get days until deadline (negative if overdue)
  int get daysUntilDeadline {
    final now = DateTime.now();
    return deadline.difference(now).inDays;
  }
}