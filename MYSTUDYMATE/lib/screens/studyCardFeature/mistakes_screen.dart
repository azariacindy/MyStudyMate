import 'package:flutter/material.dart';

class MistakesScreen extends StatelessWidget {
  const MistakesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(color: Colors.white),
          child: Column(
            children: [
              // HEADER BIRU DENGAN TEKS "Mistakes"
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
                        'Mistakes',
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

              const SizedBox(height: 40),

              // KOTAK DETAIL KESALAHAN
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // PERTANYAAN
                      const Text(
                        'What the next process after cleaning data in Data Mining?',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // JAWABAN SALAH
                      const Text(
                        'Your answer:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      const Text(
                        'Data Cleaning',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // JAWABAN BENAR
                      const Text(
                        'Correct answer:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const Text(
                        'Data Integration',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              // BOTTOM NAVIGATION BAR — TANPA LINGKARAN PUTIH
              Container(
                decoration: const BoxDecoration(
                  color: const Color(0xFF5B9FED),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _BottomNavItem(
                      icon: Icons.home_rounded,
                      isActive: false,
                      onTap: () {
                        Navigator.pushReplacementNamed(context, '/home');

                      },
                    ),
                    _BottomNavItem(
                      icon: Icons.calendar_today,
                      isActive: false,
                      onTap: () {
                        Navigator.pushNamed(context, '/schedule');
                      },
                    ),
                    _BottomNavItem(
                      icon: Icons.assignment,
                      isActive: true,
                      onTap: () {
                        Navigator.pushNamed(context, '/study_cards');
                      },
                    ),
                    _BottomNavItem(
                      icon: Icons.person,
                      isActive: false,
                      onTap: () {
                        Navigator.pushNamed(context, '/profile');
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ✅ BOTTOM NAV ITEM — TANPA LINGKARAN TRANSPARAN
class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _BottomNavItem({
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ✅ HANYA IKON — TANPA BACKGROUND LINGKARAN
          Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}