import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../widgets/custom_bottom_nav.dart';

/// HomeScreen - Halaman utama MyStudyMate (Fixed Overflow)
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedNavIndex = 0;
  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // === HEADER CARD ===
              _buildHeaderCard(),
              const SizedBox(height: 20),

              // === QUICK ACTIONS ===
              _buildQuickActions(context),
              const SizedBox(height: 20),

              // === SCHEDULE SECTION ===
              _buildScheduleSection(screenWidth),
              const SizedBox(height: 20),

              // === UPCOMING TASKS ===
              _buildUpcomingTasks(),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),

      // === BOTTOM NAVIGATION ===
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _selectedNavIndex,
        onTap: (index) {
          setState(() => _selectedNavIndex = index);
          if (index == 1) Navigator.pushNamed(context, '/schedule');
          if (index == 3) Navigator.pushNamed(context, '/profile');
        },
      ),
      floatingActionButton: CustomFAB(
        onPressed: () => Navigator.pushNamed(context, '/manage_task'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  /// Header Card - Fixed Icons
  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color.fromARGB(255, 34, 3, 107), Color.fromARGB(255, 89, 147, 240)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withAlpha(77),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Row - FIXED
          Row(
            children: [
              // Avatar with Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(38),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  CupertinoIcons.person,
                  color: Color(0xFF8B5CF6),
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),

              // Greeting - FIXED Overflow
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Good Morning',
                          style: TextStyle(
                            color: Colors.white.withAlpha(204),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          CupertinoIcons.sun_max,
                          color: Color(0xFFFFA726),
                          size: 14,
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Satriya',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Streak - Fixed Icon
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(38),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      CupertinoIcons.flame_fill,
                      color: Color.fromRGBO(252, 149, 8, 1),
                      size: 19,
                    ),
                    SizedBox(width: 4),
                    Text(
                      '5',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Progress - FIXED
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Circular Progress
              SizedBox(
                width: 65,
                height: 65,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 65,
                      height: 65,
                      child: CircularProgressIndicator(
                        value: 0.6,
                        strokeWidth: 5,
                        backgroundColor: Colors.white.withAlpha(51),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF10B981),
                        ),
                      ),
                    ),
                    const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '60%',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Done',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),

              // Progress Text - FIXED Overflow
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Today Progress',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '3 of 5 Tasks',
                      style: TextStyle(
                        color: Colors.white.withAlpha(179),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          CupertinoIcons.graph_circle,
                          color: Color(0xFF10B981),
                          size: 19,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            'Keep going!',
                            style: TextStyle(
                              color: Colors.white.withAlpha(204),
                              fontSize: 11,
                              fontStyle: FontStyle.italic,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Quick Actions - Fixed Layout
  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                context,
                CupertinoIcons.book,
                'Study Cards',
                '12 Sets',
                const Color(0xFF3B82F6),
                '/schedule',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildActionCard(
                context,
                CupertinoIcons.clock_fill,
                'Pomodoro',
                '25 min',
                const Color(0xFFEC4899),
                '/pomodoro',
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                context,
                CupertinoIcons.create,
                'Notes',
                '8 Notes',
                const Color(0xFF8B5CF6),
                '/notes',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildActionCard(
                context,
                CupertinoIcons.news_solid,
                'Quiz',
                '5 Active',
                const Color(0xFF10B981),
                '/quiz',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    Color color,
    String route,
  ) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withAlpha(38),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: color.withAlpha(26),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.withAlpha(179),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  /// Schedule Section - FIXED OVERFLOW
  Widget _buildScheduleSection(double screenWidth) {
    final scheduleColors = [
      [const Color(0xFF3B82F6), const Color(0xFF06B6D4)],
      [const Color(0xFF8B5CF6), const Color(0xFFEC4899)],
      [const Color(0xFF10B981), const Color(0xFF3B82F6)],
    ];

    final dates = ['Today', 'Tomorrow', '17 Dec'];
    
    final scheduleData = [
      [
        {'icon': Icons.business, 'title': 'Management', 'time': '12:20 - 02:30'},
        {'icon': Icons.phone_android, 'title': 'Mobile Dev', 'time': '09:20 - 12:00'},
        {'icon': Icons.design_services, 'title': 'UI Design', 'time': '14:00 - 16:00'},
      ],
      [
        {'icon': Icons.code, 'title': 'Programming', 'time': '08:00 - 10:00'},
        {'icon': Icons.science, 'title': 'Research', 'time': '10:30 - 12:30'},
        {'icon': Icons.group, 'title': 'Team Meet', 'time': '13:00 - 15:00'},
      ],
      [
        {'icon': Icons.book, 'title': 'Study Group', 'time': '09:00 - 11:00'},
        {'icon': Icons.laptop, 'title': 'Workshop', 'time': '13:00 - 15:00'},
        {'icon': Icons.sports_esports, 'title': 'Break', 'time': '15:30 - 16:30'},
      ],
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Schedule',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6).withAlpha(26),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'This Week',
                style: TextStyle(
                  color: Color(0xFF3B82F6),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // FIXED: Naikkan height dari 170 ke 195
        SizedBox(
          height: 195,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 3,
            itemBuilder: (context, index) {
              return Container(
                width: screenWidth * 0.65,
                margin: EdgeInsets.only(right: index < 2 ? 10 : 0),
                // FIXED: Kurangi padding dari 14 ke 12
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: scheduleColors[index],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: scheduleColors[index][0].withAlpha(51),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min, // FIXED: Tambahkan ini
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          dates[index],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 1,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(38),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            '3 Classes',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                    // FIXED: Kurangi spacing dari 12 ke 10
                    const SizedBox(height: 10),
                    // FIXED: Kurangi bottom padding dari 6 ke 5
                    ...scheduleData[index].map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: _buildScheduleItem(
                        item['icon'] as IconData,
                        item['title'] as String,
                        item['time'] as String,
                      ),
                    )),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildScheduleItem(IconData icon, String title, String time) {
  return Container(
    // FIXED: Kurangi padding dari 8 ke 7
    padding: const EdgeInsets.all(7),
    decoration: BoxDecoration(
      color: Colors.white.withAlpha(26),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      children: [
        Icon(icon, color: Colors.white, size: 15), // FIXED: size dari 16 ke 15
        const SizedBox(width: 7), // FIXED: dari 8 ke 7
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 1), // FIXED: dari 2 ke 1
              Text(
                time,
                style: TextStyle(
                  color: Colors.white.withAlpha(179),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
        // === TOMBOL DETAIL BARU ===
        GestureDetector(
          onTap: () {
            // Navigasi ke detail schedule
            Navigator.pushNamed(
              context, 
              '/schedule_detail',
              arguments: {
                'title': title,
                'time': time,
                'icon': icon,
              },
            );
            
            // Atau bisa show bottom sheet untuk quick view
            // _showScheduleDetails(title, time, icon);
          },
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(38),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              Icons.arrow_forward_ios,
              color: Colors.white.withAlpha(204),
              size: 12,
            ),
          ),
        ),
      ],
    ),
  );
}

  /// Upcoming Tasks - Fixed
  Widget _buildUpcomingTasks() {
    final tasks = [
      {
        'title': 'Metodologi Penelitian',
        'time': '02:00 - 03:30',
        'priority': 'High',
        'icon': Icons.article,
        'color': const Color(0xFFEF4444),
      },
      {
        'title': 'Mobile Development',
        'time': '10:00 - 12:00',
        'priority': 'Medium',
        'icon': Icons.smartphone,
        'color': const Color(0xFFF59E0B),
      },
      {
        'title': 'UI/UX Design',
        'time': '14:00 - 16:00',
        'priority': 'Low',
        'icon': Icons.palette,
        'color': const Color(0xFF10B981),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Upcoming Tasks',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            Text(
              'View All',
              style: TextStyle(
                color: Color(0xFF3B82F6),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...tasks.map((task) => _buildTaskCard(
              title: task['title'] as String,
              time: task['time'] as String,
              priority: task['priority'] as String,
              icon: task['icon'] as IconData,
              color: task['color'] as Color,
            )),
      ],
    );
  }

  Widget _buildTaskCard({
    required String title,
    required String time,
    required String priority,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withAlpha(51), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(26),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon Circle
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 2),
            ),
            child: Center(
              child: Icon(icon, color: color, size: 12),
            ),
          ),
          const SizedBox(width: 10),

          // Task Info - FIXED Overflow
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: color.withAlpha(26),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        priority,
                        style: TextStyle(
                          color: color,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 12,
                      color: Colors.grey.withAlpha(179),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.withAlpha(179),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
