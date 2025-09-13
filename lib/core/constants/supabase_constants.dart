import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Supabase configuration constants
class SupabaseConstants {
  // Supabase URL ve Anon Key - .env dosyasından güvenli şekilde alınıyor
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  
  // Table names
  static const String usersTable = 'users';
  static const String notesTable = 'notes';
  
  // Auth events
  static const String authStateChanged = 'authStateChanged';
}
