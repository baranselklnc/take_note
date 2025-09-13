import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logger/logger.dart';
import '../models/user.dart' as models;

/// Supabase service for authentication only
class SupabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final Logger _logger = Logger();
  
  // Public getter for accessing supabase client
  SupabaseClient get supabase => _supabase;

  /// Get current user
  models.User? get currentUser {
    final session = _supabase.auth.currentUser;
    if (session != null) {
      return models.User(
        id: session.id,
        email: session.email ?? '',
        name: session.userMetadata?['name'] ?? '',
        createdAt: DateTime.parse(session.createdAt),
        updatedAt: DateTime.parse(session.updatedAt ?? session.createdAt),
      );
    }
    return null;
  }

  /// Sign up user
  Future<models.User> signUp(String name, String email, String password) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'name': name},
      );

      if (response.user == null) {
        throw Exception('Sign up failed');
      }

      final user = models.User(
        id: response.user!.id,
        email: response.user!.email ?? '',
        name: name,
        createdAt: DateTime.parse(response.user!.createdAt),
        updatedAt: DateTime.parse(response.user!.updatedAt ?? response.user!.createdAt),
      );

      _logger.i('User signed up: ${user.email}');
      return user;
    } catch (e) {
      _logger.e('Sign up error: $e');
      rethrow;
    }
  }

  /// Sign in user
  Future<models.User> signIn(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('Sign in failed');
      }

      final user = models.User(
        id: response.user!.id,
        email: response.user!.email ?? '',
        name: response.user!.userMetadata?['name'] ?? '',
        createdAt: DateTime.parse(response.user!.createdAt),
        updatedAt: DateTime.parse(response.user!.updatedAt ?? response.user!.createdAt),
      );

      _logger.i('User signed in: ${user.email}');
      return user;
    } catch (e) {
      _logger.e('Sign in error: $e');
      rethrow;
    }
  }

  /// Sign out user
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
      _logger.i('User signed out');
    } catch (e) {
      _logger.e('Sign out error: $e');
      rethrow;
    }
  }

  /// Listen to auth state changes
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  /// Check if user is authenticated
  bool get isAuthenticated => _supabase.auth.currentUser != null;
}
