class StudyCard {
  final int id;
  final String title;
  final String notes;
  final int quizCount;
  final int wordCount;
  final DateTime createdAt;
  final int? latestQuizId;

  StudyCard({
    required this.id,
    required this.title,
    required this.notes,
    required this.quizCount,
    required this.wordCount,
    required this.createdAt,
    this.latestQuizId,
  });

  factory StudyCard.fromJson(Map<String, dynamic> json) {
    return StudyCard(
      id: json['id'],
      title: json['title'],
      notes: json['notes'],
      quizCount: json['quiz_count'] ?? 0,
      wordCount: json['word_count'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      latestQuizId: json['latest_quiz_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'notes': notes,
      'quiz_count': quizCount,
      'word_count': wordCount,
      'created_at': createdAt.toIso8601String(),
      'latest_quiz_id': latestQuizId,
    };
  }
}
