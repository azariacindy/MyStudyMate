import 'package:flutter/material.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController(text: 'Sabrina');
  final _usernameController = TextEditingController(text: 'Bina');
  final _emailController = TextEditingController(
    text: 'sabrinaprabadhita88@gmail.com',
  );

  String activeNav = 'profile';

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _handleSave() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Profile saved:\n'
          'Name: ${_nameController.text}\n'
          'Username: ${_usernameController.text}\n'
          'Email: ${_emailController.text}',
        ),
      ),
    );
    Navigator.pop(context);
  }

  void _handleCancel() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = const Color(0xFF5B9FED);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // ===== HEADER =====
                  _buildHeader(context, primaryBlue),

                  const SizedBox(height: 24),

                  // ===== AVATAR =====
                  _buildAvatar(primaryBlue),

                  const SizedBox(height: 32),

                  // ===== FORM =====
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name
                        const Text(
                          'Name',
                          style: TextStyle(
                            color: const Color(0xFF5B9FED),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: const BorderSide(
                                color: const Color(0xFF5B9FED),
                                width: 2,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Username
                        const Text(
                          'Username',
                          style: TextStyle(
                            color: const Color(0xFF5B9FED),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _usernameController,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: const BorderSide(
                                color: const Color(0xFF5B9FED),
                                width: 2,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Email
                        const Text(
                          'Email',
                          style: TextStyle(
                            color: const Color(0xFF5B9FED),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: const BorderSide(
                                color: const Color(0xFF5B9FED),
                                width: 2,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Buttons
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _handleSave,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey.shade300,
                              foregroundColor: Colors.grey.shade600,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                            child: const Text(
                              'Save',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _handleCancel,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF5B9FED),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          _buildBottomNav(),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Color primaryBlue) {
    return Container(
      padding: const EdgeInsets.only(top: 48, bottom: 24, left: 16, right: 16),
      decoration: BoxDecoration(
        color: primaryBlue,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: () => Navigator.maybePop(context),
              icon: const Icon(Icons.chevron_left, color: Colors.white, size: 24),
              padding: EdgeInsets.zero,
            ),
          ),
          const Text(
            'Edit Profile',
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

  Widget _buildAvatar(Color primaryBlue) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: primaryBlue.withOpacity(0.3),
          ),
          child: Icon(Icons.person, size: 50, color: Colors.white),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.edit, size: 18, color: const Color(0xFF5B9FED)),
          ),
        ),
      ],
    );
  }

Widget _buildBottomNav() {
  return Container(
    decoration: const BoxDecoration(
    color: const Color(0xFF5B9FED),
    borderRadius: BorderRadius.only(
    bottomLeft: Radius.circular(32),
    bottomRight: Radius.circular(32),
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
          isActive: activeNav == 'schedule',
          onTap: () {
            setState(() => activeNav = 'schedule');
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
          color: isActive ? Colors.white.withOpacity(0.2) : Colors.transparent,
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }
}
