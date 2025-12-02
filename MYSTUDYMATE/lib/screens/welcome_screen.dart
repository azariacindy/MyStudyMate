import 'package:flutter/material.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ========== Top Blue Section with Logo ==========
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.bottomCenter,
              children: [
                // Gradient rounded container
                Container(
                  width: double.infinity,
                  height: screenHeight * 0.45,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(86),
                      bottomRight: Radius.circular(86),
                    ),
                  ),
                ),
                
                // Logo in white circle (overlapping) with scale animation
                Positioned(
                  bottom: -68,
                  child: ScaleTransition(
                    scale: _fadeAnimation,
                    child: Container(
                      width: 136,
                      height: 136,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(25), // 0.1 * 255 ≈ 25
                            blurRadius: 20,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/ui_design/element_splash/LogoApp.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // ========== Content Section with Animations ==========
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 80),
                        
                        // Title
                        const Text(
                          'MyStudyMate',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF2B2D42),
                            fontSize: 24,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Subtitle
                        const Text(
                          'A smart companion to organize your academic journey',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF2B2D42),
                            fontSize: 14,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w400,
                            height: 1.5,
                          ),
                        ),
                        
                        const Spacer(),
                        
                        // ========== Get Started Button ==========
                        _GetStartedButton(
                          onTap: () {
                            Navigator.pushNamed(context, '/signin');
                          },
                        ),
                        
                        const SizedBox(height: 60),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ========== Custom Button Widget ==========
class _GetStartedButton extends StatefulWidget {
  final VoidCallback onTap;
  
  const _GetStartedButton({required this.onTap});

  @override
  State<_GetStartedButton> createState() => _GetStartedButtonState();
}

class _GetStartedButtonState extends State<_GetStartedButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
          horizontal: 32,
          vertical: 16,
        ),
        decoration: BoxDecoration(
          color: _isPressed 
              ? const Color(0xFF3A6BC9) 
              : const Color(0xFF4C84F1),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4C84F1).withAlpha(_isPressed ? 51 : 76), // 0.2 : 0.3
              blurRadius: _isPressed ? 10 : 15,
              offset: Offset(0, _isPressed ? 3 : 5),
            ),
          ],
        ),
       child: Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    const Text(
      'Get Started for Free',
      style: TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w700,
        letterSpacing: 0.6,
      ),
    ),
    const SizedBox(width: 12),
    Image.asset(
      'assets/ui_design/element_welcome/Arrow.png',
      width: 10,  // Tambahkan width
      height: 19, // Tambahkan height
      fit: BoxFit.contain,
      color: Colors.white, // Optional: jika gambar hitam dan ingin di-tint putih
      errorBuilder: (context, error, stackTrace) {
        // Fallback jika gambar tidak ditemukan
        return const Icon(
          Icons.arrow_forward,
          color: Colors.black,
          size: 20,
        );
      },
    ),
  ],
),
      ),
    );
  }
}