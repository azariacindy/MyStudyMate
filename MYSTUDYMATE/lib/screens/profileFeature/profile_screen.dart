import 'package:flutter/material.dart';
import 'change_password_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String activeNav = 'profile';

  // Data streak untuk bulan Juli 2025 (simplified view)
  final List<List<int>> streakData = [
    [1, 2, 3, 4, 5, 6, 7],
    [1, 2, 3, 4, 5, 6, 7],
    [1, 2, 3, 4, 5, 6, 7],
    [1, 2, 3, 4, 5, 6, 7],
  ];

  final List<int> completedDays = [3, 4, 5, 6];

  final List<_Badge> badges = [
    _Badge(id: 1, name: 'Storyteller\nChampion', icon: '📖', earned: false),
    _Badge(
      id: 2,
      name: 'First place of\nJuly!!!',
      icon: '🏆',
      earned: true,
      color: const Color(0xFFFFF59D),
    ),
    _Badge(id: 3, name: 'Completed first\nlevel', icon: '🎯', earned: false),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 16),
                  _buildAvatar(),
                  const SizedBox(height: 12),
                  const Text(
                    'Sabrina',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildStreakCalendar(),
                  const SizedBox(height: 20),
                  _buildMenuItems(),
                  const SizedBox(height: 12),
                  _buildBadges(),
                  const SizedBox(height: 20),
                  _buildLogoutButton(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          _buildBottomNav(),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 48, bottom: 24, left: 16, right: 16),
      decoration: const BoxDecoration(
        color: const Color(0xFF5B9FED),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft
          ),
          const Text(
            'Profile',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF5B9FED).withOpacity(0.3),
            border: Border.all(color: Colors.white),
          ),
          child: Icon(Icons.person, size: 36, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildStreakCalendar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFE3F2FD),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Streak',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      Icons.chevron_left,
                      size: 16,
                      color: Colors.grey.shade700,
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'July 2025',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      Icons.chevron_right,
                      size: 16,
                      color: Colors.grey.shade700,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: const [
                _DayHeader(label: 'Mon'),
                _DayHeader(label: 'Tue'),
                _DayHeader(label: 'Wed'),
                _DayHeader(label: 'Thu'),
                _DayHeader(label: 'Fri'),
                _DayHeader(label: 'Sat'),
                _DayHeader(label: 'Sun'),
              ],
            ),
            const SizedBox(height: 6),
            Column(
              children:
                  streakData.asMap().entries.map((entry) {
                    int weekIndex = entry.key;
                    List<int> week = entry.value;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        children:
                            week.asMap().entries.map((dayEntry) {
                              int day = dayEntry.value;
                              bool isCompleted =
                                  weekIndex == 1 && completedDays.contains(day);
                              bool hasFlame = weekIndex == 1 && day == 6;

                              return Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 2,
                                  ),
                                  child: AspectRatio(
                                    aspectRatio: 1,
                                    child: Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        Container(
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            color:
                                                isCompleted
                                                    ? const Color(0xFFFFF59D)
                                                    : Colors.white,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Text(
                                            '$day',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey.shade800,
                                            ),
                                          ),
                                        ),
                                        if (hasFlame)
                                          const Positioned(
                                            top: -4,
                                            right: -4,
                                            child: Text(
                                              '🔥',
                                              style: TextStyle(fontSize: 14),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                      ),
                    );
                  }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItems() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _MenuItem(
            icon: Icons.edit_outlined,
            label: 'Edit Profile',
            onTap: () => Navigator.pushNamed(context, '/editProfile'),
            showArrow: true,
          ),
          const SizedBox(height: 4),
          _MenuItem(
            icon: Icons.lock_outline,
            label: 'Change Password',
            onTap: () => Navigator.pushNamed(context, '/changePassword'),
            showArrow: true,
          ),
          const SizedBox(height: 4),
          _MenuItem(
            icon: Icons.workspace_premium_outlined,
            label: 'Badges',
            onTap: () {},
            showArrow: false,
          ),
        ],
      ),
    );
  }

  Widget _buildBadges() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children:
            badges.map((badge) {
              return Column(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: badge.earned ? badge.color : Colors.grey.shade200,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      badge.icon,
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    width: 85,
                    child: Text(
                      badge.name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 10,
                        height: 1.2,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.logout, size: 18),
          label: const Text('Logout'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF5B9FED),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            textStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

Widget _buildBottomNav() {
  return Container(
    decoration: const BoxDecoration(
      color: const Color(0xFF5B9FED),
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(24),
        topRight: Radius.circular(24),
      ),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _BottomNavItem(
          icon: Icons.home_rounded,
          isActive: activeNav == 'home',
          onTap: () {
            setState(() => activeNav = 'home');
            Navigator.pushNamed(context, '/home');
          },
        ),
        _BottomNavItem(
          icon: Icons.calendar_today,
          isActive: activeNav == 'calendar',
          onTap: () {
            setState(() => activeNav = 'calendar');
            Navigator.pushNamed(context, '/schedule');
          },
        ),
        _BottomNavItem(
          icon: Icons.assignment,
          isActive: activeNav == 'assignment',
          onTap: () {
            setState(() => activeNav = 'assignment');
            Navigator.pushNamed(context, '/manage_task');
          },
        ),
        _BottomNavItem(
          icon: Icons.person,
          isActive: activeNav == 'profile',
          onTap: () {
            setState(() => activeNav = 'profile');
          },
        ),
      ],
    ),
  );
}
}

class _DayHeader extends StatelessWidget {
  final String label;
  const _DayHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SizedBox(
        height: 20,
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool showArrow;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.showArrow = true,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFE3F2FD),
              ),
              child: Icon(icon, color: const Color(0xFF5B9FED), size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
            if (showArrow)
              Icon(Icons.chevron_right,
                  color: Colors.grey.shade600, size: 20),
          ],
        ),
      ),
    );
  }
}

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
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isActive ? Colors.white : Colors.transparent,
        ),
        child: Icon(icon,color: isActive ? const Color(0xFF5B9FED) : Colors.white, size: 24),
      ),
    );
  }
}

class _Badge {
  final int id;
  final String name;
  final String icon;
  final bool earned;
  final Color? color;

  const _Badge({
    required this.id,
    required this.name,
    required this.icon,
    required this.earned,
    this.color,
  });
}
