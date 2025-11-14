import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_colors.dart';
import '../services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _holeOpacity;
  late Animation<double> _logoScale;
  late Animation<Offset> _logoPosition;
  late Animation<double> _textOpacity;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    // 1. Lubang muncul (0s - 0.4s)
    _holeOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.13)),
    );

    // 2. Logo muncul dari dalam lubang → skala 0.3 → 1.0 (0.4s - 0.8s)
    _logoScale = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.13, 0.26)),
    );

    // 3. Logo turun & geser ke kiri (0.8s - 1.3s)
    _logoPosition = Tween<Offset>(
      begin: const Offset(0, -80), // Awal: di atas lubang
      end: const Offset(-60, 0),    // Akhir: geser kiri 60px, di tengah vertikal
    ).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.26, 0.43)),
    );

    // 4. Teks muncul dengan fade-in (1.3s - 1.7s)
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.43, 0.56)),
    );

    _controller.forward();
    Future.delayed(const Duration(seconds: 3), _startRouting);
  }

  Future<void> _startRouting() async {
    if (!mounted) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final hasOnboarded = prefs.getBool('hasOnboarded') ?? false;
      final authService = AuthService();

      if (await authService.isLoggedIn) {
        Navigator.pushReplacementNamed(context, '/home');
      } else if (!hasOnboarded) {
        Navigator.pushReplacementNamed(context, '/onboarding');
      } else {
        Navigator.pushReplacementNamed(context, '/welcome');
      }
    } catch (e) {
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
    final size = MediaQuery.of(context).size;
    final isLandscape = size.width > size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFEEF4FF),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;
          final screenHeight = constraints.maxHeight;

          // Hitung posisi proporsional dari desain 412x917
          final holeLeft = screenWidth * (75 / 412);
          final holeTop = screenHeight * (424 / 917);
          final textLeft = screenWidth * (141 / 412);
          final textTop = screenHeight * (442 / 917);

          return Stack(
            children: [
              // 🔲 Lubang hitam oval
              Positioned(
                left: holeLeft,
                top: holeTop,
                child: AnimatedOpacity(
                  opacity: _holeOpacity.value,
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    width: screenWidth * (262 / 412),
                    height: screenHeight * (118 / 917),
                    decoration: ShapeDecoration(
                      color: const Color(0xFF2B2D42),
                      shape: const OvalBorder(),
                    ),
                  ),
                ),
              ),

              // 🎓 Logo: Gunakan LogoApp.png dari assets/ui_design/element_splash/
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Transform.translate(
                    offset: _logoPosition.value,
                    child: Transform.scale(
                      scale: _logoScale.value,
                      child: Opacity(
                        opacity: 1.0,
                        child: Image.asset(
                          'assets/ui_design/element_splash/LogoApp.png',
                          width: 120,
                          height: 120,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            // Fallback jika gambar tidak ditemukan
                            return Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: const Icon(
                                Icons.school_rounded,
                                size: 70,
                                color: Color(0xFF2979FF),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),

              // 📝 Teks "MyStudyMate" — sesuai layer terakhir
              Positioned(
                left: textLeft,
                top: textTop,
                child: SizedBox(
                  width: screenWidth * (201 / 412),
                  child: AnimatedOpacity(
                    opacity: _textOpacity.value,
                    duration: const Duration(milliseconds: 400),
                    child: Text(
                      'MyStudyMate',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontFamily: 'Poppins', // Pastikan font ini ada di pubspec.yaml
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}