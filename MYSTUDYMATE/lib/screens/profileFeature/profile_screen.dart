import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/profile_service.dart';
import '../../widgets/custom_bottom_nav.dart';
import 'edit_profile_screen.dart';
import 'change_password_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final ProfileService _profileService = ProfileService();
  
  User? _currentUser;
  bool _isLoading = true;
  
  // Streak data
  String _currentMonth = 'July 2025';
  List<int> _completedDays = [3, 4, 5, 6];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadStreakData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = await _authService.getCurrentUser();
      if (mounted) {
        setState(() {
          _currentUser = user;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading profile: $e')),
        );
      }
    }
  }

  Future<void> _loadStreakData() async {
    try {
      final streakData = await _profileService.getStreakData();
      debugPrint('🔍 Streak Data from API: $streakData');
      
      if (streakData['success'] == true && mounted) {
        final completedDays = List<int>.from(streakData['completed_days'] ?? []);
        debugPrint('📅 Completed Days: $completedDays');
        
        setState(() {
          _currentMonth = streakData['current_month'] ?? 'December 2025';
          _completedDays = completedDays;
        });
      }
    } catch (e) {
      debugPrint('❌ Error loading streak data: $e');
    }
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(foregroundColor: const Color(0xFF3B82F6)),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4C84F1),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await _authService.signout();
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/welcome', (route) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                await _loadUserData();
                await _loadStreakData();
              },
              child: SafeArea(
                bottom: false,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 100),
                  child: Column(
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 24),
                    _buildAvatar(),
                    const SizedBox(height: 12),
                    _buildUserName(),
                    const SizedBox(height: 24),
                    _buildStreakCalendar(),
                    const SizedBox(height: 24),
                    _buildMenuItems(),
                    const SizedBox(height: 32),
                    _buildLogoutButton(),
                  ],
                ),
              ),
            ),
          ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 3),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withAlpha(77),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              const Expanded(
                child: Text(
                  'Profile',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(width: 56),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return GestureDetector(
      onTap: () async {
        final updatedUser = await Navigator.push<User?>(
          context,
          MaterialPageRoute(
            builder: (context) => EditProfileScreen(user: _currentUser),
          ),
        );
        
        // If user was updated (photo uploaded or profile saved), update state
        if (updatedUser != null && mounted) {
          setState(() {
            _currentUser = updatedUser;
          });
        }
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF5B9FED),
                width: 3,
              ),
              color: Colors.white,
            ),
            child: ClipOval(
              child: _currentUser?.profilePhotoUrl != null
                  ? CachedNetworkImage(
                      imageUrl: _currentUser!.profilePhotoUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const CircularProgressIndicator(),
                      errorWidget: (context, url, error) => Icon(
                        Icons.person,
                        size: 50,
                        color: Colors.grey.shade400,
                      ),
                    )
                  : Icon(
                      Icons.person,
                      size: 50,
                      color: Colors.grey.shade400,
                    ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF5B9FED),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(
                Icons.edit,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserName() {
    return Text(
      _currentUser?.name ?? 'User',
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        fontFamily: 'Poppins',
        color: Color(0xFF2B2D42),
      ),
    );
  }

  Widget _buildStreakCalendar() {
    // Get current date info
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
    final daysInMonth = lastDayOfMonth.day;
    final firstWeekday = firstDayOfMonth.weekday; // 1 = Monday, 7 = Sunday
    
    // Generate calendar grid (6 weeks max to fit any month)
    final List<List<int?>> weekData = [];
    int day = 1;
    
    for (int week = 0; week < 6; week++) {
      List<int?> weekDays = [];
      for (int weekday = 1; weekday <= 7; weekday++) {
        if (week == 0 && weekday < firstWeekday) {
          weekDays.add(null); // Empty cell before month starts
        } else if (day <= daysInMonth) {
          weekDays.add(day);
          day++;
        } else {
          weekDays.add(null); // Empty cell after month ends
        }
      }
      weekData.add(weekDays);
      if (day > daysInMonth) break; // Stop if month is complete
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Streak',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                  color: Color(0xFF2B2D42),
                ),
              ),
              Row(
                children: [
                  Icon(Icons.chevron_left, size: 20, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  Text(
                    _currentMonth,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.chevron_right, size: 20, color: Colors.grey.shade600),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Day headers
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
          const SizedBox(height: 8),
          // Calendar grid
          Builder(
            builder: (context) {
              debugPrint('🔥 Calendar rendering - Completed days: $_completedDays');
              if (_completedDays.isNotEmpty) {
                debugPrint('🔥 Last completed day (flame position): ${_completedDays.last}');
              }
              
              return Column(
                children: weekData.map((week) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      children: week.map((day) {
                        if (day == null) {
                          return const Expanded(child: SizedBox()); // Empty cell
                        }
                        
                        bool isCompleted = _completedDays.contains(day);
                        bool hasFlame = _completedDays.isNotEmpty && day == _completedDays.last;
                        
                        if (hasFlame) {
                          debugPrint('🔥 Flame should be on day: $day');
                        }
                        
                        return Expanded(
                          child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: isCompleted
                                    ? const Color(0xFFFFF59D)
                                    : const Color(0xFFF8F9FE),
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '$day',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                            ),
                            if (hasFlame)
                              const Positioned(
                                top: -4,
                                right: -4,
                                child: Text('🔥', style: TextStyle(fontSize: 16)),
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
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItems() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _MenuItem(
            icon: Icons.edit_outlined,
            label: 'Edit Profile',
            onTap: () async {
              final updatedUser = await Navigator.push<User?>(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProfileScreen(user: _currentUser),
                ),
              );
              
              // If user was updated, update state
              if (updatedUser != null && mounted) {
                setState(() {
                  _currentUser = updatedUser;
                });
              }
            },
          ),
          Divider(height: 1, color: Colors.grey.shade200),
          _MenuItem(
            icon: Icons.lock_outline,
            label: 'Change Password',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ChangePasswordScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _handleLogout,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4C84F1),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.logout, size: 20),
            SizedBox(width: 8),
            Text(
              'Logout',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
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
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF5B9FED).withAlpha(26),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: const Color(0xFF4C84F1), size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF2B2D42),
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.grey.shade400,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
