class StudyCard {
  final int id;
  final String title;
  final String? notes;
  final String? filePath;
  final DateTime createdAt;

  StudyCard({
    required this.id,
    required this.title,
    this.notes,
    this.filePath,
    required this.createdAt,
  });

  factory StudyCard.fromJson(Map<String, dynamic> json) {
    return StudyCard(
      id: json['id'] as int,
      title: json['title'] as String,
      notes: json['notes'] as String?,
      filePath: json['file_path'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'notes': notes,
      'file_path': filePath,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
