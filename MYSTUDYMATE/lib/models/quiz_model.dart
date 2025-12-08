class Quiz {
  final int id;
  final int studyCardId;
  final String studyCardTitle;
  final List<QuizQuestion> questions;
  final int totalQuestions;
  final int timesAttempted;
  final double? bestScore;

  Quiz({
    required this.id,
    required this.studyCardId,
    required this.studyCardTitle,
    required this.questions,
    required this.totalQuestions,
    required this.timesAttempted,
    this.bestScore,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) {
    List<QuizQuestion> questionsList = [];
    if (json['questions'] != null) {
      questionsList =
          (json['questions'] as List)
              .map((q) => QuizQuestion.fromJson(q))
              .toList();
    }

    return Quiz(
      id: json['id'],
      studyCardId: json['study_card']?['id'] ?? 0,
      studyCardTitle: json['study_card']?['title'] ?? '',
      questions: questionsList,
      totalQuestions: json['total_questions'] ?? questionsList.length,
      timesAttempted: json['times_attempted'] ?? 0,
      bestScore: json['best_score']?.toDouble(),
    );
  }
}

class QuizQuestion {
  final int? id;
  final String question;
  final List<String> options;
  final int correctAnswer;
  final String? explanation;
  final String? questionType;
  final int? points;

  QuizQuestion({
    this.id,
    required this.question,
    required this.options,
    required this.correctAnswer,
    this.explanation,
    this.questionType,
    this.points,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    // Handle new backend format
    if (json.containsKey('question_text') && json.containsKey('answers')) {
      // New format from backend
      List<dynamic> answers = json['answers'] ?? [];
      List<String> options = [];
      int correctIndex = 0;

      for (int i = 0; i < answers.length; i++) {
        options.add(answers[i]['answer_text'] ?? '');
        if (answers[i]['is_correct'] == true) {
          correctIndex = i;
        }
      }

      return QuizQuestion(
        id: json['id'],
        question: json['question_text'],
        options: options,
        correctAnswer: correctIndex,
        explanation: json['explanation'],
        questionType: json['question_type'],
        points: json['points'],
      );
    }

    // Old format (fallback)
    return QuizQuestion(
      id: json['id'],
      question: json['question'],
      options: List<String>.from(json['options'] ?? []),
      correctAnswer: json['correct_answer'] ?? 0,
      explanation: json['explanation'],
      questionType: json['question_type'],
      points: json['points'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'options': options,
      'correct_answer': correctAnswer,
      'explanation': explanation,
      'question_type': questionType,
      'points': points,
    };
  }
}

class QuizResult {
  final int attemptId;
  final double score;
  final int correctAnswers;
  final int totalQuestions;
  final bool passed;
  final List<QuestionResult> results;
  final double? bestScore;

  QuizResult({
    required this.attemptId,
    required this.score,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.passed,
    required this.results,
    this.bestScore,
  });

  factory QuizResult.fromJson(Map<String, dynamic> json) {
    List<QuestionResult> resultsList = [];
    if (json['results'] != null) {
      resultsList =
          (json['results'] as List)
              .map((r) => QuestionResult.fromJson(r))
              .toList();
    }

    return QuizResult(
      attemptId: json['attempt_id'],
      score: (json['score'] ?? 0).toDouble(),
      correctAnswers: json['correct_answers'] ?? 0,
      totalQuestions: json['total_questions'] ?? 0,
      passed: json['passed'] ?? false,
      results: resultsList,
      bestScore: json['best_score']?.toDouble(),
    );
  }

  double get percentage => score;

  String get grade {
    if (score >= 90) return 'A';
    if (score >= 80) return 'B';
    if (score >= 70) return 'C';
    if (score >= 60) return 'D';
    return 'F';
  }
}

class QuestionResult {
  final int questionIndex;
  final int? userAnswer;
  final int correctAnswer;
  final bool isCorrect;
  final String? explanation;

  QuestionResult({
    required this.questionIndex,
    this.userAnswer,
    required this.correctAnswer,
    required this.isCorrect,
    this.explanation,
  });

  factory QuestionResult.fromJson(Map<String, dynamic> json) {
    return QuestionResult(
      questionIndex: json['question_index'],
      userAnswer: json['user_answer'],
      correctAnswer: json['correct_answer'],
      isCorrect: json['is_correct'] ?? false,
      explanation: json['explanation'],
    );
  }
}

class QuizAttempt {
  final int id;
  final double score;
  final int correctAnswers;
  final int totalQuestions;
  final double percentage;
  final bool passed;
  final int? timeSpent;
  final DateTime createdAt;

  QuizAttempt({
    required this.id,
    required this.score,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.percentage,
    required this.passed,
    this.timeSpent,
    required this.createdAt,
  });

  factory QuizAttempt.fromJson(Map<String, dynamic> json) {
    return QuizAttempt(
      id: json['id'],
      score: (json['score'] ?? 0).toDouble(),
      correctAnswers: json['correct_answers'] ?? 0,
      totalQuestions: json['total_questions'] ?? 0,
      percentage: (json['percentage'] ?? 0).toDouble(),
      passed: json['passed'] ?? false,
      timeSpent: json['time_spent'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
