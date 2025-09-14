import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:logger/logger.dart';
import '../models/user.dart';
import '../services/supabase_service.dart';
import '../services/storage_service.dart';
import '../core/storage/local_storage.dart';

part 'auth_viewmodel.g.dart';




@riverpod
class AuthViewModel extends _$AuthViewModel {
  final Logger _logger = Logger();

  @override
  Future<User?> build() async {

    try {
      final storageService = ref.read(storageServiceProvider);
      return await storageService.getCurrentUser();
    } catch (e) {
      _logger.e('Error loading user from storage: $e');
      return null;
    }
  }


  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    
    try {
      final supabaseService = ref.read(supabaseServiceProvider);
      
      final user = await supabaseService.signIn(email, password);
      

      try {
        final storageService = ref.read(storageServiceProvider);
        await storageService.saveUser(user);
      } catch (storageError) {
        _logger.w('Failed to save user to local storage: $storageError');

      }
      
      state = AsyncValue.data(user);
      _logger.i('User logged in: ${user.email}');
    } catch (e) {
      String userFriendlyMessage = _getUserFriendlyErrorMessage(e);
      state = AsyncValue.error(userFriendlyMessage, StackTrace.current);
      _logger.e('Login failed: $e');
    }
  }

  /// Signup user
  Future<void> signup(String name, String email, String password) async {
    state = const AsyncValue.loading();
    
    try {
      final supabaseService = ref.read(supabaseServiceProvider);
      
      final user = await supabaseService.signUp(name, email, password);
      
      
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
      String userFriendlyMessage = _getUserFriendlyErrorMessage(e);
      state = AsyncValue.error(userFriendlyMessage, StackTrace.current);
      _logger.e('Signup failed: $e');
    }
  }

  
  Future<void> logout() async {
    try {
      final supabaseService = ref.read(supabaseServiceProvider);
      final storageService = ref.read(storageServiceProvider);
      
      await supabaseService.signOut();
      await storageService.clearUser();
      
      state = const AsyncValue.data(null);
      _logger.i('User logged out');
    } catch (e) {
  
      try {
        final storageService = ref.read(storageServiceProvider);
        await storageService.clearUser();
      } catch (clearError) {
        _logger.e('Error clearing user data: $clearError');
      }
      state = const AsyncValue.data(null);
      _logger.e('Logout error: $e');
    }
  }

  bool get isAuthenticated {
    return state.value != null;
  }

  /// Get current user
  User? get currentUser {
    return state.value;
  }

  String _getUserFriendlyErrorMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();
    
    if (errorString.contains('invalid login credentials') || 
        errorString.contains('invalid_credentials')) {
      return 'E-posta adresi veya şifre hatalı. Lütfen bilgilerinizi kontrol edin.';
    }
    
    if (errorString.contains('user not found')) {
      return 'Bu e-posta adresi ile kayıtlı kullanıcı bulunamadı.';
    }
    
    if (errorString.contains('email not confirmed')) {
      return 'E-posta adresinizi doğrulamanız gerekiyor. Lütfen e-posta kutunuzu kontrol edin.';
    }
    
    if (errorString.contains('user already registered') || 
        errorString.contains('email already registered')) {
      return 'Bu e-posta adresi zaten kayıtlı. Giriş yapmayı deneyin.';
    }
    
    if (errorString.contains('password should be at least')) {
      return 'Şifre en az 6 karakter olmalıdır.';
    }
    
    if (errorString.contains('invalid email')) {
      return 'Geçerli bir e-posta adresi girin.';
    }
    
    if (errorString.contains('network') || errorString.contains('connection')) {
      return 'İnternet bağlantınızı kontrol edin ve tekrar deneyin.';
    }
    
    if (errorString.contains('timeout')) {
      return 'İşlem zaman aşımına uğradı. Lütfen tekrar deneyin.';
    }
    
    // Varsayılan mesaj
    return 'Bir hata oluştu. Lütfen tekrar deneyin.';
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
