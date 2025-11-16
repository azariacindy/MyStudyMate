import 'package:flutter/material.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Controllers untuk multiple phases
  late AnimationController _throwController;
  late AnimationController _slideController;

  // Animations untuk logo keluar dari lubang
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoPositionAnimation;
  late Animation<double> _logoOpacityAnimation;

  // Animations untuk logo slide ke kiri + text muncul
  late Animation<Offset> _logoSlideAnimation;
  late Animation<Offset> _textSlideAnimation;
  late Animation<double> _textOpacityAnimation;
  late Animation<double> _ovalFadeAnimation;

  @override
  void initState() {
    super.initState();

    // ========== PHASE 1 & 2: Logo thrown from hole ==========
    _throwController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Logo scale: dari kecil (di dalam lubang) ke normal
    _logoScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.3,
          end: 1.2,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.2,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.bounceOut)),
        weight: 40,
      ),
    ]).animate(_throwController);

    // Logo position: dari posisi oval ke tengah
    _logoPositionAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _throwController, curve: Curves.easeOutBack),
    );

    // Logo opacity: fade in saat keluar
    _logoOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _throwController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );

    // Oval fade out saat logo keluar
    _ovalFadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _throwController,
        curve: const Interval(0.3, 0.7, curve: Curves.easeOut),
      ),
    );

    // ========== PHASE 3: Logo slide to left + Text appears ==========
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Logo slide ke kiri - DIKURANGI supaya tidak terlalu ke pinggir
    _logoSlideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-0.18, 0), // UBAH: dari -0.35 ke -0.18
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeInOut),
    );

    // Text slide dari kanan
    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0.6, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    // Text fade in
    _textOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeIn));

    // ========== Timing Sequence ==========
    _startAnimationSequence();
  }

  void _startAnimationSequence() async {
    // Delay awal 500ms
    await Future.delayed(const Duration(milliseconds: 500));

    // Phase 1 & 2: Logo thrown from hole (1200ms)
    if (mounted) {
      await _throwController.forward();
    }

    // Delay sebentar sebelum slide
    await Future.delayed(const Duration(milliseconds: 300));

    // Phase 3: Logo slide + Text appear (800ms)
    if (mounted) {
      await _slideController.forward();
    }

    // Delay sebelum navigasi
    await Future.delayed(const Duration(milliseconds: 1000));

    // Navigate to next page
    if (mounted) {
      _navigateToNext();
    }
  }

  void _navigateToNext() {
    // Option 1: Ke Onboarding
    Navigator.pushReplacementNamed(context, '/onboarding');

    // Option 2: Ke Welcome
    // Navigator.pushReplacementNamed(context, '/welcome');

    // Option 3: Ke Home (jika user sudah login)
    // Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  void dispose() {
    _throwController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Posisi oval (tengah layar) - disesuaikan untuk compact
    final ovalCenterX = screenWidth / 2 - 100; // Dikurangi untuk compact
    final ovalCenterY = screenHeight * 0.46;

    return Scaffold(
      backgroundColor: const Color(0xFFEEF4FF),
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: [
            // ========== Oval "Lubang" ==========
            AnimatedBuilder(
              animation: _throwController,
              builder: (context, child) {
                return Positioned(
                  left: ovalCenterX,
                  top: ovalCenterY,
                  child: Opacity(
                    opacity: _ovalFadeAnimation.value,
                    child: Container(
                      width: 200, // Dikurangi dari 262
                      height: 90, // Dikurangi dari 118
                      decoration: const ShapeDecoration(
                        color: Color(0xFF2B2D42),
                        shape: OvalBorder(),
                      ),
                    ),
                  ),
                );
              },
            ),

            // ========== Logo Animation ==========
            AnimatedBuilder(
              animation: Listenable.merge([_throwController, _slideController]),
              builder: (context, child) {
                // Calculate logo position during throw animation
                final throwProgress = _logoPositionAnimation.value;
                final startY = ovalCenterY + 45; // Adjusted for smaller oval
                final endY = screenHeight / 2 - 80; // Adjusted
                final currentY = startY + (endY - startY) * throwProgress;

                return SlideTransition(
                  position: _logoSlideAnimation,
                  child: Center(
                    child: Transform.translate(
                      offset: Offset(0, currentY - screenHeight / 2 + 80),
                      child: Opacity(
                        opacity: _logoOpacityAnimation.value,
                        child: Transform.scale(
                          scale: _logoScaleAnimation.value,
                          child: Image.asset(
                            'assets/ui_design/element_splash/LogoApp.png',
                            width: 80, // Dikurangi dari 120
                            height: 80, // Dikurangi dari 120
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

            // ========== Text "MyStudyMate" ==========
            AnimatedBuilder(
              animation: _slideController,
              builder: (context, child) {
                return Center(
                  child: SlideTransition(
                    position: _textSlideAnimation,
                    child: Opacity(
                      opacity: _textOpacityAnimation.value,
                      child: Transform.translate(
                        offset: const Offset(
                          65,
                          0,
                        ), // UBAH: dari 75 ke 95 (tambah spacing)
                        child: const Text(
                          'MyStudyMate',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2B2D42),
                            letterSpacing: 0.3,
                            fontFamily: 'poppins',
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
