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
import 'utils/app_theme.dart';
import 'services/firebase_messaging_service.dart';
import 'screens/taskManagerFeature/plan_task_screen.dart';
import 'screens/scheduleFeature/scheduleScreen.dart';
import 'screens/profileFeature/profile_screen.dart';
import 'screens/pomodoroFeature/pomodoro_screen.dart';
import 'screens/studyCards/study_cards_screen.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase with error handling
  try {
    await Firebase.initializeApp();
    // Initialize Firebase Messaging only if Firebase initialized successfully
    await FirebaseMessagingService().initialize();
  } catch (e) {
    print('⚠️ Firebase initialization failed: $e');
    // App can still work without Firebase
  }
  
  try {
    await initializeSupabaseIfConfigured();
  } catch (e) {
    // Supabase optional
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
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
      routes: {
        '/splash': (_) => const SplashScreen(),
        '/welcome': (_) => const WelcomeScreen(),
        '/signin': (_) => const SignInScreen(),
        '/signup': (_) => const RegisterScreen(),
        '/home': (_) => const HomeScreen(),
        '/onboarding': (_) => const OnboardingScreen(),
        '/plan_task': (_) => const PlanTaskScreen(),
        '/schedule': (_) => const ScheduleScreen(),
        '/profile': (_) => const ProfileScreen(),
        '/pomodoro': (_) => const PomodoroScreen(),
        '/study_cards': (_) => const StudyCardsScreen(),
      },
    );
  }
}