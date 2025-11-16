// lib/models/assignment_model.dart
class Assignment {
  final int id;
  final int userId;
  final String title;
  final String? description;
  final DateTime deadline;
  final bool isDone;
  final DateTime createdAt;
  final DateTime updatedAt;

  Assignment({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.deadline,
    required this.isDone,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Assignment.fromJson(Map<String, dynamic> json) {
    return Assignment(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'],
      description: json['description'],
      deadline: DateTime.parse(json['deadline']),
      isDone: json['is_done'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}