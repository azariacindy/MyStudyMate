import 'package:flutter/material.dart';

class QuizResultScreen extends StatelessWidget {
  const QuizResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(color: Colors.white),
          child: Column(
            children: [
              const SizedBox(height: 40),

              // TEKS "Congratulations!"
              const Text(
                'Congratulations !',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF5B9FED),
                ),
              ),

              const SizedBox(height: 32),

              // GAMBAR PILA EMAS DALAM LINGKARAN BIRU
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue.shade800,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // ✅ EMOJI PILA — TIDAK ADA ERROR ICON.TROPHY
                    const Text('🏆', style: TextStyle(fontSize: 100)),
                    Positioned(
                      top: 20,
                      child: Icon(Icons.star, size: 40, color: Colors.yellow),
                    ),
                    Positioned(
                      left: -10,
                      top: 60,
                      child: Icon(Icons.star, size: 16, color: Colors.yellow.withOpacity(0.7)),
                    ),
                    Positioned(
                      right: -5,
                      bottom: 50,
                      child: Icon(Icons.star, size: 12, color: Colors.yellow.withOpacity(0.7)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // AKURASI
              const Text(
                'Accuracy 95%',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 40),

              // BOX MISTAKES — DIPERBAIKI (GUNAKAN GESTUREDETECTOR)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/mistake');
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.orange,
                          ),
                          child: const Center(
                            child: Text(
                              '1',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Mistakes',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              Text(
                                'To see more click here',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // TOMBOL REPEAT & CLOSE
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // Ulangi kuis
                          // Navigator.pushReplacementNamed(context, '/quiz_question');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5B9FED),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                        ),
                        child: const Text('Repeat'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context); // Tutup hasil
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF5B9FED),
                          side: const BorderSide(color: const Color(0xFF5B9FED)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                        ),
                        child: const Text('Close'),
                      ),
                    ),
                  ],
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
                      isActive: false,
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