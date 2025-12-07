// main.dart
import 'package:flutter/material.dart';
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
    debugPrint('⚠️ Firebase initialization failed: $e');
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
      // Lazy loading routes untuk mengurangi initial bundle size
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/splash':
            return MaterialPageRoute(builder: (_) => const SplashScreen());
          case '/welcome':
            return MaterialPageRoute(builder: (_) => const WelcomeScreen());
          case '/signin':
            return MaterialPageRoute(builder: (_) => const SignInScreen());
          case '/signup':
            return MaterialPageRoute(builder: (_) => const RegisterScreen());
          case '/home':
            return MaterialPageRoute(builder: (_) => const HomeScreen());
          case '/onboarding':
            return MaterialPageRoute(builder: (_) => const OnboardingScreen());
          case '/plan_task':
            return MaterialPageRoute(builder: (_) => const PlanTaskScreen());
          case '/schedule':
            return MaterialPageRoute(builder: (_) => const ScheduleScreen());
          case '/profile':
            return MaterialPageRoute(builder: (_) => const ProfileScreen());
          case '/pomodoro':
            return MaterialPageRoute(builder: (_) => const PomodoroScreen());
          case '/study_cards':
            return MaterialPageRoute(builder: (_) => const StudyCardsScreen());
          default:
            return null;
        }
      },
    );
  }
}