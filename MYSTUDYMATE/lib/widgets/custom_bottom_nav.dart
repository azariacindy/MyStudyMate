import 'package:flutter/material.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int)? onTap;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(14),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(26),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavIcon(context, Icons.home, 0),
          _buildNavIcon(context, Icons.calendar_today, 1),
          const SizedBox(width: 45),
          _buildNavIcon(context, Icons.style, 2),
          _buildNavIcon(context, Icons.person, 3),
        ],
      ),
    );
  }

  Widget _buildNavIcon(BuildContext context, IconData icon, int index) {
    final isActive = currentIndex == index;
    
    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          onTap!(index);
        } else {
          _handleDefaultNavigation(context, index);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          gradient: isActive
              ? const LinearGradient(
                  colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
                )
              : null,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: isActive ? Colors.white : Colors.grey,
          size: 22,
        ),
      ),
    );
  }

  void _handleDefaultNavigation(BuildContext context, int index) {
    switch (index) {
      case 0:
        if (currentIndex != 0) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/home',
            (route) => false,
          );
        }
        break;
      case 1:
        if (currentIndex != 1) {
          Navigator.pushNamed(context, '/schedule');
        }
        break;
      case 2:
        if (currentIndex != 2) {
          Navigator.pushNamed(context, '/study_cards');
        }
        break;
      case 3:
        if (currentIndex != 3) {
          Navigator.pushNamed(context, '/profile');
        }
        break;
    }
  }
}

class CustomFAB extends StatelessWidget {
  final VoidCallback onPressed;

  const CustomFAB({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withAlpha(77),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: onPressed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: const Icon(Icons.add, color: Colors.white, size: 26),
      ),
    );
  }
}
