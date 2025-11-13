import 'package:supabase_flutter/supabase_flutter.dart';

// TODO: Fill these with your Supabase project values from https://supabase.com/dashboard
// Project Settings > API > Project URL & anon/public key
const String kSupabaseUrl = ''; // Example: 'https://xxxxx.supabase.co'
const String kSupabaseAnonKey = ''; // Example: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...'

/// Initializes Supabase only when both values are provided.
Future<void> initializeSupabaseIfConfigured() async {
  if (kSupabaseUrl.isEmpty || kSupabaseAnonKey.isEmpty) {
    // No supabase config provided; skip initialization.
    // ignore: avoid_print
    print('Supabase init skipped: no URL/anon key provided.');
    return;
  }

  await Supabase.initialize(
    url: kSupabaseUrl,
    anonKey: kSupabaseAnonKey,
  );
}

/// Get the Supabase client instance
SupabaseClient get supabase => Supabase.instance.client;
