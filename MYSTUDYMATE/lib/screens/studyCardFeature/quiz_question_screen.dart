import 'package:flutter/material.dart';

class QuizQuestionScreen extends StatefulWidget {
  final String? selectedTitle; // 👈 terima data dari halaman sebelumnya

  const QuizQuestionScreen({super.key, this.selectedTitle});

  @override
  State<QuizQuestionScreen> createState() => _QuizQuestionScreenState();
}

class _QuizQuestionScreenState extends State<QuizQuestionScreen> {
  late List<String> options;
  late String questionText;

  int? _selectedOption;

  double _progress = 0.5;
  int _currentQuestion = 5;
  int _totalQuestions = 10;

  @override
  void initState() {
    super.initState();
    _setupQuizData();
  }

  void _setupQuizData() {
    // Default
    questionText = 'What is the next process after cleaning data in Data Mining?';
    options = [
      'Data Integration',
      'Data Transformation',
      'Data Mining',
      'Evaluation',
    ];

    // Jika butuh kustomisasi berdasarkan judul, tambahkan logika di sini
    // Contoh:
    if (widget.selectedTitle?.contains('Mobile') == true) {
      questionText = 'What is the main thread in Android called?';
      options = [
        'Main Thread',
        'UI Thread',
        'Background Thread',
        'Looper Thread',
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(color: Colors.white),
          child: Column(
            children: [
              // HEADER
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    padding: const EdgeInsets.only(
                      top: 24,
                      bottom: 32,
                      left: 16,
                      right: 16,
                    ),
                    decoration: const BoxDecoration(
                      color: const Color(0xFF5B9FED),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(48),
                        bottomRight: Radius.circular(48),
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        'Question !',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // PROGRESS BAR
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    LinearProgressIndicator(
                      value: _progress,
                      backgroundColor: const Color(0xFF5B9FED).withOpacity(0.1),
                      color: const Color(0xFF5B9FED),
                      minHeight: 8,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${(_progress * 100).toInt()}%',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          '$_currentQuestion / $_totalQuestions',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // PERTANYAAN
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  questionText, // 👈 dinamis
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // PILIHAN JAWABAN
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: options.asMap().entries.map((entry) {
                    final index = entry.key;
                    final option = entry.value;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0xFF5B9FED).withOpacity(0.5),
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: RadioListTile<int>(
                          value: index,
                          groupValue: _selectedOption,
                          onChanged: (value) {
                            setState(() {
                              _selectedOption = value;
                            });
                          },
                          title: Text(
                            option,
                            style: const TextStyle(fontSize: 16),
                          ),
                          activeColor: const Color(0xFF5B9FED),
                          selected: _selectedOption == index,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                          ),
                          tileColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 40),

              // TOMBOL CONTINUE
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _selectedOption != null
                        ? () {
                            Navigator.pushNamed(context, '/resultQuiz');
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _selectedOption != null
                              ? const Color(0xFF5B9FED)
                              : Colors.grey.shade300,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    child: const Text('Continue'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}