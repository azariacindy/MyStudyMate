// main.dart
import 'package:flutter/material.dart';
import 'package:my_study_mate/screens/scheduleFeature/scheduleScreen.dart';
import 'screens/splash_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/signin_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'utils/supabase_config.dart';
import 'services/firebase_messaging_service.dart';
import 'screens/scheduleFeature/scheduleScreen.dart';
import 'screens/profileFeature/profile_screen.dart';
import 'screens/pomodoroFeature/pomodoro_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase Messaging (optional - skip if not configured)
  try {
    await FirebaseMessagingService().initialize();
  } catch (e) {
    print('⚠️ Firebase not configured, skipping initialization: $e');
  }
  
  try {
    await initializeSupabaseIfConfigured();
  } catch (e) {
    print('⚠️ Supabase not configured, skipping initialization: $e');
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyStudyMate',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4C84F1)),
        useMaterial3: true,
        
        // ✅ SET FONT DI TEXT THEME, BUKAN DI ROOT
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontFamily: 'Inter'),
          displayMedium: TextStyle(fontFamily: 'Inter'),
          displaySmall: TextStyle(fontFamily: 'Inter'),
          headlineLarge: TextStyle(fontFamily: 'Poppins'),
          headlineMedium: TextStyle(fontFamily: 'Poppins'),
          headlineSmall: TextStyle(fontFamily: 'Poppins'),
          titleLarge: TextStyle(fontFamily: 'Poppins'),
          titleMedium: TextStyle(fontFamily: 'Poppins'),
          titleSmall: TextStyle(fontFamily: 'Poppins'),
          bodyLarge: TextStyle(fontFamily: 'Inter'),
          bodyMedium: TextStyle(fontFamily: 'Inter'),
          bodySmall: TextStyle(fontFamily: 'Inter'),
          labelLarge: TextStyle(fontFamily: 'Inter'),
          labelMedium: TextStyle(fontFamily: 'Inter'),
          labelSmall: TextStyle(fontFamily: 'Inter'),
        ),
        
        // ✅ ICON THEME TETAP MENGGUNAKAN MATERIAL ICONS
        iconTheme: const IconThemeData(
          color: Color(0xFF2B2D42),
        ),
      ),
      home: const SplashScreen(),
      routes: {
        '/splash': (_) => const SplashScreen(),
        '/welcome': (_) => const WelcomeScreen(),
        '/signin': (_) => const SignInScreen(),
        '/signup': (_) => const RegisterScreen(),
        '/home': (_) => const HomeScreen(),
        '/onboarding': (_) => const OnboardingScreen(),
        '/schedule': (_) => const ScheduleScreen(),
        '/profile': (_) => const ProfileScreen(),
        '/pomodoro': (_) => const PomodoroScreen(),
      },
    );
  }
}