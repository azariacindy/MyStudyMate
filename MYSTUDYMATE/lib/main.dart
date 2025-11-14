import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/signin_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'utils/supabase_config.dart';
import 'screens/taskManagerFeature/manage_task_screen.dart';
import 'screens/taskManagerFeature/plan_task_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Try to initialize Supabase if the project owner filled in the values.
  // If not provided, initialization is skipped and app still runs.
  try {
    await initializeSupabaseIfConfigured();
  } catch (e) {
    // ignore: avoid_print
    print('Warning: Supabase initialization failed: $e');
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
        fontFamily: 'Inter', // optional: samakan dgn Figma
      ),
      // Splash jadi entry point
      home: const SplashScreen(),
      routes: {
        '/welcome': (_) => const WelcomeScreen(),
        '/signin': (_) => const SignInScreen(),
        '/register': (_) => const RegisterScreen(),
        '/login': (_) => const SignInScreen(), // Alias untuk backward compatibility
        '/home': (_) => const HomeScreen(),
        '/onboarding': (_) => const OnboardingScreen(),
        '/manage_task': (_) => const ManageTaskScreen(),
        '/plan_task': (_) => const PlanTaskScreen(),
      },
    );
  }
}
