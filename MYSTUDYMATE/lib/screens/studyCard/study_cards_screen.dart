import 'package:flutter/material.dart';

class StudyCardsScreen extends StatefulWidget {
  const StudyCardsScreen({super.key});

  @override
  State<StudyCardsScreen> createState() => _StudyCardsScreenState();
}

class _StudyCardsScreenState extends State<StudyCardsScreen> {
  final List<String> studyCards = [
    'Data Mining Quiz',
    'Mobile Programming Mid Term',
    'Management Project Quiz',
    'Business Intelligence Mid Term',
    'Mobile Programming Quiz',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // Kolom utama (header + list + bottom nav)
            Column(
              children: [
                // HEADER BIRU
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
                        color: Colors.blue,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(48),
                          bottomRight: Radius.circular(48),
                        ),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(
                              Icons.chevron_left,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const Expanded(
                            child: Text(
                              'Study Cards',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // LIST STUDY CARDS
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: ListView.separated(
                      itemCount: studyCards.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        return Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.grey.shade200),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            title: Text(
                              studyCards[index],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.blue,
                              ),
                            ),
                            trailing: const Icon(
                              Icons.chevron_right,
                              color: Colors.grey,
                            ),
                            onTap: () {},
                          ),
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // BOTTOM NAVIGATION BAR
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.blue,
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
                        icon: Icons.home_filled,
                        label: 'Home',
                        isActive: false,
                        onTap: () => Navigator.pushNamed(context, '/home'),
                      ),
                      _BottomNavItem(
                        icon: Icons.calendar_today,
                        label: 'Calendar',
                        isActive: false,
                        onTap: () => Navigator.pushNamed(context, '/plan_task'),
                      ),
                      _BottomNavItem(
                        icon: Icons.menu_book_rounded,
                        label: 'Book',
                        isActive: true,
                        onTap: () {},
                      ),
                      _BottomNavItem(
                        icon: Icons.person,
                        label: 'Profile',
                        isActive: false,
                        onTap: () => Navigator.pushNamed(context, '/profile'),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // ✅ TOMBOL + DI POJOK KANAN BAWAH (DI DALAM STACK)
            Positioned(
              bottom: 72, // jarak dari bottom (di atas bottom nav)
              right: 24,
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/add_study_card');
                },
                backgroundColor: Colors.blue,
                child: const Icon(Icons.add, size: 28, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ✅ BOTTOM NAV ITEM — TANPA LINGKARAN TRANSPARAN
class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _BottomNavItem({
    required this.icon,
    required this.label,
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
          Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}