import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:logger/logger.dart';
import '../models/user.dart';
import '../services/supabase_service.dart';
import '../services/storage_service.dart';
import '../core/storage/local_storage.dart';

part 'auth_viewmodel.g.dart';

/// Authentication view model
@riverpod
class AuthViewModel extends _$AuthViewModel {
  final Logger _logger = Logger();

  @override
  Future<User?> build() async {
    // Try to get user from local storage on app start
    try {
      final storageService = ref.read(storageServiceProvider);
      return await storageService.getCurrentUser();
    } catch (e) {
      _logger.e('Error loading user from storage: $e');
      return null;
    }
  }

  /// Login user
  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    
    try {
      final supabaseService = ref.read(supabaseServiceProvider);
      
      final user = await supabaseService.signIn(email, password);
      
      // Try to save user to local storage, but don't fail if it doesn't work
      try {
        final storageService = ref.read(storageServiceProvider);
        await storageService.saveUser(user);
      } catch (storageError) {
        _logger.w('Failed to save user to local storage: $storageError');
        // Continue anyway - user is still authenticated via Supabase
      }
      
      state = AsyncValue.data(user);
      _logger.i('User logged in: ${user.email}');
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      _logger.e('Login failed: $e');
    }
  }

  /// Signup user
  Future<void> signup(String name, String email, String password) async {
    state = const AsyncValue.loading();
    
    try {
      final supabaseService = ref.read(supabaseServiceProvider);
      
      final user = await supabaseService.signUp(name, email, password);
      
      // Try to save user to local storage, but don't fail if it doesn't work
      try {
        final storageService = ref.read(storageServiceProvider);
        await storageService.saveUser(user);
      } catch (storageError) {
        _logger.w('Failed to save user to local storage: $storageError');
        // Continue anyway - user is still authenticated via Supabase
      }
      
      state = AsyncValue.data(user);
      _logger.i('User signed up: ${user.email}');
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      _logger.e('Signup failed: $e');
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      final supabaseService = ref.read(supabaseServiceProvider);
      final storageService = ref.read(storageServiceProvider);
      
      await supabaseService.signOut();
      await storageService.clearUser();
      
      state = const AsyncValue.data(null);
      _logger.i('User logged out');
    } catch (e) {
      // Even if logout fails, clear local data
      final storageService = ref.read(storageServiceProvider);
      await storageService.clearUser();
      state = const AsyncValue.data(null);
      _logger.e('Logout error: $e');
    }
  }

  /// Check if user is authenticated
  bool get isAuthenticated {
    return state.value != null;
  }

  /// Get current user
  User? get currentUser {
    return state.value;
  }
}

/// Supabase service provider
@riverpod
SupabaseService supabaseService(SupabaseServiceRef ref) {
  return SupabaseService();
}

/// Storage service provider
@riverpod
StorageService storageService(StorageServiceRef ref) {
  return StorageService(ref.read(localStorageProvider));
}

/// Local storage provider
@riverpod
LocalStorage localStorage(LocalStorageRef ref) {
  return LocalStorage();
}
