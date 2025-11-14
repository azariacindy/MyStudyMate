import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  late Animation<double> _ovalWidth;
  late Animation<double> _ovalHeight;
  late Animation<double> _ovalRadius;
  late Animation<double> _ovalOpacity;

  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    // ====== OVAL ANIMATION ======
    _ovalWidth = Tween<double>(begin: 200, end: 60).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.75, curve: Curves.easeInOut),
      ),
    );
    _ovalHeight = Tween<double>(begin: 100, end: 60).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.75, curve: Curves.easeInOut),
      ),
    );
    _ovalRadius = Tween<double>(begin: 50, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 0.75, curve: Curves.easeInOut),
      ),
    );
    _ovalOpacity = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.75, 1.0, curve: Curves.easeInOut),
      ),
    );

    // ====== LOGO ANIMATION ======
    _logoScale = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.33, 1.0, curve: Curves.easeOutBack),
      ),
    );
    _logoOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.33, 1.0, curve: Curves.easeIn),
      ),
    );

    _controller.forward();

    // Setelah animasi selesai → jalankan logic routing
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (!mounted) return;
          _startRouting();
        });
      }
    });
  }

  /// Logic pindah halaman (sama seperti splash sebelumnya)
  Future<void> _startRouting() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasOnboarded = prefs.getBool('hasOnboarded') ?? false;
      final authService = AuthService();

      if (!mounted) return;

      // kalau sudah login → ke home
      if (authService.isLoggedIn) {
        Navigator.pushReplacementNamed(context, '/home');
        return;
      }

      // belum login: cek sudah onboarding atau belum
      if (!hasOnboarded) {
        // sesuaikan dengan nama route Onboarding di main.dart
        Navigator.pushReplacementNamed(context, '/onboarding');
      } else {
        Navigator.pushReplacementNamed(context, '/welcome');
      }
    } catch (_) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/welcome');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFFF0F7FF); // #f0f7ff
    const navyColor = Color(0xFF2C2C44); // #2c2c44
    const blueColor = Color(0xFF1A75FF); // #1a75ff

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Stack(
              alignment: Alignment.center,
              children: [
                // OVAL
                Opacity(
                  opacity: _ovalOpacity.value,
                  child: Container(
                    width: _ovalWidth.value,
                    height: _ovalHeight.value,
                    decoration: BoxDecoration(
                      color: navyColor,
                      borderRadius: BorderRadius.circular(
                        _ovalRadius.value * 2,
                      ),
                    ),
                  ),
                ),
                // LOGO + TEXT
                Opacity(
                  opacity: _logoOpacity.value,
                  child: Transform.scale(
                    scale: _logoScale.value,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(
                          Icons.calendar_month_rounded,
                          size: 60,
                          color: blueColor,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'MyStudyMate',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: blueColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
