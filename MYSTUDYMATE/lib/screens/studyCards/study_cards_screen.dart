import 'package:flutter/material.dart';
import '../../widgets/custom_bottom_nav.dart';

class StudyCardsScreen extends StatefulWidget {
  const StudyCardsScreen({super.key});

  @override
  State<StudyCardsScreen> createState() => _StudyCardsScreenState();
}

class _StudyCardsScreenState extends State<StudyCardsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: const Text('Study Cards'),
        backgroundColor: const Color(0xFF8B5CF6),
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.school,
              size: 100,
              color: Color(0xFF8B5CF6),
            ),
            SizedBox(height: 20),
            Text(
              'Study Cards',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Ready to start fresh!',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 2),
    );
  }
}
