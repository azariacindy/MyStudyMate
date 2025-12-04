import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_colors.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _page = 0;

  final List<Map<String, String>> _pages = [
    {
      'image': 'assets/ui_design/element_onboarding/onboarding.png',
      'title': 'Organize Your Study',
      'subtitle': 'Kelola jadwal dan tugas kuliah kamu dengan mudah dalam satu aplikasi.',
    },
    {
      'image': 'assets/ui_design/element_onboarding/onboarding2.png',
      'title': 'Stay Focused',
      'subtitle': 'Gunakan fitur Pomodoro untuk meningkatkan fokus dan produktivitas belajar.',
    },
    {
      'image': 'assets/ui_design/element_onboarding/onboarding3.png',
      'title': 'Track Your Progress',
      'subtitle': 'Pantau progress belajar mingguan dan raih streak harian untuk motivasi lebih.',
    },
    {
      'image': 'assets/ui_design/element_onboarding/onboarding4.png',
      'title': 'Smart Study Plan',
      'subtitle': 'Buat study plan otomatis dengan soal-soal latihan berdasarkan materi kamu.',
    },
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasOnboarded', true);
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/welcome');
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button di pojok kanan atas
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (_page < _pages.length - 1)
                    TextButton(
                      onPressed: _completeOnboarding,
                      child: Text(
                        'Skip',
                        style: TextStyle(
                          fontSize: 15,
                          color: AppColors.text.withValues(alpha: 0.6),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // PageView dengan konten onboarding
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (_, i) {
                  final p = _pages[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Spacer(flex: 1),
                        
                        // Ilustrasi dari Figma
                        Container(
                          constraints: BoxConstraints(
                            maxHeight: size.height * 0.45,
                            maxWidth: size.width * 0.85,
                          ),
                          child: Image.asset(
                            p['image']!,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 280,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.image_not_supported_outlined,
                                    size: 60,
                                    color: AppColors.primary,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        
                        const Spacer(flex: 1),
                        
                        // Title
                        Text(
                          p['title']!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: AppColors.text,
                            height: 1.3,
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Subtitle
                        Text(
                          p['subtitle']!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            color: AppColors.text.withValues(alpha: 0.65),
                            height: 1.5,
                          ),
                        ),
                        
                        const Spacer(flex: 1),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Page indicators
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _page == i ? 28 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _page == i 
                          ? AppColors.primary 
                          : AppColors.primary.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ),

            // Next/Get Started button
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    if (_page == _pages.length - 1) {
                      _completeOnboarding();
                    } else {
                      _controller.nextPage(
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    _page == _pages.length - 1 ? 'Get Started' : 'Next',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
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
