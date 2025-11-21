import 'package:intl/intl.dart';

class Task {
  final int id;
  final int userId;
  final String title;
  final String? description;
  final DateTime? deadline;
  final String? category;
  final String priority; // low, medium, high, urgent
  final bool isCompleted;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Task({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    this.deadline,
    this.category,
    required this.priority,
    required this.isCompleted,
    this.createdAt,
    this.updatedAt,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: int.parse(json['id'].toString()),
      userId: int.parse(json['user_id'].toString()),
      title: json['title'],
      description: json['description'],
      deadline: json['deadline'] != null ? DateTime.parse(json['deadline']) : null,
      category: json['category'],
      priority: json['priority'] ?? 'medium',
      isCompleted: json['is_completed'] == true || json['is_completed'] == 1,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'deadline': deadline?.toIso8601String(),
      'category': category,
      'priority': priority,
      'is_completed': isCompleted,
    };
  }

  // Helper methods
  bool hasDeadline() => deadline != null;

  bool isOverdue() {
    if (deadline == null || isCompleted) return false;
    return deadline!.isBefore(DateTime.now());
  }

  bool isDueToday() {
    if (deadline == null) return false;
    final now = DateTime.now();
    return deadline!.year == now.year &&
        deadline!.month == now.month &&
        deadline!.day == now.day;
  }

  String getFormattedDeadline() {
    if (deadline == null) return 'No deadline';
    return DateFormat('MMM dd, yyyy HH:mm').format(deadline!);
  }

  String getDeadlineDate() {
    if (deadline == null) return '';
    return DateFormat('yyyy-MM-dd').format(deadline!);
  }
}
