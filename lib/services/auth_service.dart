import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/supabase_config.dart';

/// Service untuk handle authentication dengan Supabase
class AuthService {
  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  /// Check if Supabase is configured
  bool get isConfigured =>
      kSupabaseUrl.isNotEmpty && kSupabaseAnonKey.isNotEmpty;

  /// Get current user
  User? get currentUser => isConfigured ? supabase.auth.currentUser : null;

  /// Check if user is logged in
  bool get isLoggedIn => currentUser != null;

  /// Sign Up dengan email dan password
  Future<Map<String, dynamic>> signUp({
    required String email,
    required String password,
    required String fullName,
    required String username,
  }) async {
    try {
      if (!isConfigured) {
        return {
          'success': false,
          'error': 'Supabase not configured',
          'message': 'Please configure Supabase in supabase_config.dart'
        };
      }

      final response = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'username': username,
        },
      );

      if (response.user == null) {
        return {
          'success': false,
          'error': 'Sign up failed',
          'message': 'Failed to create account. Please try again.'
        };
      }

      return {
        'success': true,
        'user': response.user,
        'message': 'Account created successfully!',
      };
    } on AuthException catch (e) {
      return {
        'success': false,
        'error': e.message,
        'message': _getReadableErrorMessage(e.message),
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
        'message': 'An unexpected error occurred. Please try again.',
      };
    }
  }

  /// Sign In dengan email dan password
  Future<Map<String, dynamic>> signIn({
    required String emailOrUsername,
    required String password,
  }) async {
    try {
      if (!isConfigured) {
        return {
          'success': false,
          'error': 'Supabase not configured',
          'message': 'Please configure Supabase in supabase_config.dart'
        };
      }

      String email = emailOrUsername;
      if (!emailOrUsername.contains('@')) {
        return {
          'success': false,
          'error': 'Username login not implemented',
          'message': 'Please use your email address to sign in.',
        };
      }

      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        return {
          'success': false,
          'error': 'Sign in failed',
          'message': 'Invalid credentials. Please try again.',
        };
      }

      return {
        'success': true,
        'user': response.user,
        'session': response.session,
        'message': 'Welcome back!',
      };
    } on AuthException catch (e) {
      return {
        'success': false,
        'error': e.message,
        'message': _getReadableErrorMessage(e.message),
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
        'message': 'An unexpected error occurred. Please try again.',
      };
    }
  }

  /// Sign Out
  Future<Map<String, dynamic>> signOut() async {
    try {
      if (!isConfigured) {
        return {
          'success': false,
          'error': 'Supabase not configured',
        };
      }

      await supabase.auth.signOut();

      return {
        'success': true,
        'message': 'Signed out successfully',
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
        'message': 'Failed to sign out. Please try again.',
      };
    }
  }

  /// Reset Password
  Future<Map<String, dynamic>> resetPassword({required String email}) async {
    try {
      if (!isConfigured) {
        return {
          'success': false,
          'error': 'Supabase not configured',
        };
      }

      await supabase.auth.resetPasswordForEmail(email);

      return {
        'success': true,
        'message': 'Password reset email sent. Please check your inbox.',
      };
    } on AuthException catch (e) {
      return {
        'success': false,
        'error': e.message,
        'message': _getReadableErrorMessage(e.message),
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
        'message': 'Failed to send reset email. Please try again.',
      };
    }
  }

  /// Convert error messages to user-friendly messages
  String _getReadableErrorMessage(String error) {
    final errorLower = error.toLowerCase();

    if (errorLower.contains('invalid login credentials') ||
        errorLower.contains('invalid email or password')) {
      return 'Invalid email or password. Please try again.';
    } else if (errorLower.contains('email not confirmed')) {
      return 'Please verify your email address before signing in.';
    } else if (errorLower.contains('user already registered') ||
        errorLower.contains('email already exists')) {
      return 'An account with this email already exists.';
    } else if (errorLower.contains('password')) {
      return 'Password must be at least 6 characters long.';
    } else if (errorLower.contains('network')) {
      return 'Network error. Please check your internet connection.';
    }

    return error;
  }
}
