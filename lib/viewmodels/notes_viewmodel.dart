import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';
import '../models/note.dart';
import '../services/api_service.dart';
import '../core/network/api_client.dart';
import '../core/network/network_info.dart';
import '../core/constants/api_constants.dart';
import 'auth_viewmodel.dart';

part 'notes_viewmodel.g.dart';

/// Notes view model
@riverpod
class NotesViewModel extends _$NotesViewModel {
  final Logger _logger = Logger();
  
  // In-memory storage for notes (temporary solution)
  static List<Note> _inMemoryNotes = [];

  @override
  Future<List<Note>> build() async {
    // Try to load from backend API first, then fallback to local storage
    try {
      final apiService = ref.read(apiServiceProvider);
      final authUser = ref.read(authViewModelProvider).value;
      
      if (authUser != null) {
        // Set auth token for API calls
        final supabaseService = ref.read(supabaseServiceProvider);
        final session = supabaseService.supabase.auth.currentSession;
        if (session != null) {
          apiService.setAuthToken(session.accessToken);
        }
        
        // Load notes from backend
        final notes = await apiService.getNotes();
        _logger.d('Loaded ${notes.length} notes from backend API');
        
        // Save to local storage for offline access
        try {
          final storageService = ref.read(storageServiceProvider);
          await storageService.saveNotes(notes);
        } catch (storageError) {
          _logger.w('Failed to save notes to local storage: $storageError');
        }
        
        _inMemoryNotes = notes; // Update in-memory storage
        return notes;
      } else {
        _logger.w('No authenticated user, loading from local storage');
        throw Exception('No authenticated user');
      }
    } catch (e) {
      _logger.e('Error loading notes from backend: $e');
      
      // Fallback to local storage
      try {
        final storageService = ref.read(storageServiceProvider);
        final notes = await storageService.getNotes();
        _logger.d('Loaded ${notes.length} notes from local storage');
        _inMemoryNotes = notes;
        return notes;
      } catch (storageError) {
        _logger.e('Error loading notes from storage: $storageError');
        _logger.d('Using in-memory storage with ${_inMemoryNotes.length} notes');
        return _inMemoryNotes;
      }
    }
  }

  /// Create new note
  Future<void> createNote(String title, String content) async {
    try {
      final apiService = ref.read(apiServiceProvider);
      final authUser = ref.read(authViewModelProvider).value;
      
      if (authUser != null) {
        // Set auth token for API calls
        final supabaseService = ref.read(supabaseServiceProvider);
        final session = supabaseService.supabase.auth.currentSession;
        if (session != null) {
          apiService.setAuthToken(session.accessToken);
        }
        
        try {
          // Try to create note via backend API first
          final note = await apiService.createNote(title, content);
          _logger.d('Note created via API: ${note.id}');
          
          // Save to local storage for offline access
          try {
            final storageService = ref.read(storageServiceProvider);
            await storageService.saveNote(note);
          } catch (storageError) {
            _logger.w('Failed to save note to local storage: $storageError');
          }
          
          // Update state and in-memory storage
          final currentNotes = await future;
          final updatedNotes = [...currentNotes, note];
          state = AsyncValue.data(updatedNotes);
          _inMemoryNotes = updatedNotes;
          
          _logger.d('Note created successfully via API: ${note.id}');
        } catch (apiError) {
          _logger.w('Backend API not available, creating note locally: $apiError');
          
          // Fallback: Create note locally
          final note = Note(
            id: const Uuid().v4(),
            title: title,
            content: content,
            userId: authUser.id,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          
          // Save to local storage
          try {
            final storageService = ref.read(storageServiceProvider);
            await storageService.saveNote(note);
          } catch (storageError) {
            _logger.w('Failed to save note to local storage: $storageError');
          }
          
          // Update state and in-memory storage
          final currentNotes = await future;
          final updatedNotes = [...currentNotes, note];
          state = AsyncValue.data(updatedNotes);
          _inMemoryNotes = updatedNotes;
          
          _logger.d('Note created locally: ${note.id}');
        }
      } else {
        throw Exception('No authenticated user');
      }
    } catch (e) {
      _logger.e('Error creating note: $e');
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  /// Update note
  Future<void> updateNote(String id, String title, String content) async {
    try {
      final apiService = ref.read(apiServiceProvider);
      final authUser = ref.read(authViewModelProvider).value;
      
      if (authUser != null) {
        // Set auth token for API calls
        final supabaseService = ref.read(supabaseServiceProvider);
        final session = supabaseService.supabase.auth.currentSession;
        if (session != null) {
          apiService.setAuthToken(session.accessToken);
        }
        
        try {
          // Try to update note via backend API first
          final updatedNote = await apiService.updateNote(id, title, content);
          _logger.d('Note updated via API: $id');
          
          // Save to local storage for offline access
          try {
            final storageService = ref.read(storageServiceProvider);
            await storageService.saveNote(updatedNote);
          } catch (storageError) {
            _logger.w('Failed to save updated note to local storage: $storageError');
          }
          
          // Update state and in-memory storage
          final currentNotes = await future;
          final noteIndex = currentNotes.indexWhere((note) => note.id == id);
          if (noteIndex != -1) {
            final updatedNotes = [...currentNotes];
            updatedNotes[noteIndex] = updatedNote;
            state = AsyncValue.data(updatedNotes);
            _inMemoryNotes = updatedNotes;
          }
          
          _logger.d('Note updated successfully via API: $id');
        } catch (apiError) {
          _logger.w('Backend API not available, updating note locally: $apiError');
          
          // Fallback: Update note locally
          final currentNotes = await future;
          final noteIndex = currentNotes.indexWhere((note) => note.id == id);
          
          if (noteIndex != -1) {
            final updatedNote = currentNotes[noteIndex].copyWith(
              title: title,
              content: content,
              updatedAt: DateTime.now(),
            );
            
            // Try to save to local storage, but don't fail if it doesn't work
            try {
              final storageService = ref.read(storageServiceProvider);
              await storageService.saveNote(updatedNote);
            } catch (storageError) {
              _logger.w('Failed to save updated note to local storage: $storageError');
            }
            
            // Update state and in-memory storage
            final updatedNotes = [...currentNotes];
            updatedNotes[noteIndex] = updatedNote;
            state = AsyncValue.data(updatedNotes);
            _inMemoryNotes = updatedNotes;
            
            _logger.d('Note updated locally: $id');
          }
        }
      } else {
        throw Exception('No authenticated user');
      }
    } catch (e) {
      _logger.e('Error updating note: $e');
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  /// Delete note (soft delete)
  Future<void> deleteNote(String id) async {
    try {
      final apiService = ref.read(apiServiceProvider);
      final authUser = ref.read(authViewModelProvider).value;
      
      if (authUser != null) {
        // Set auth token for API calls
        final supabaseService = ref.read(supabaseServiceProvider);
        final session = supabaseService.supabase.auth.currentSession;
        if (session != null) {
          apiService.setAuthToken(session.accessToken);
        }
        
        try {
          // Try to delete note via backend API first
          await apiService.deleteNote(id);
          _logger.d('Note deleted via API: $id');
          
          // Update state and in-memory storage (remove from list)
          final currentNotes = await future;
          final updatedNotes = currentNotes.where((note) => note.id != id).toList();
          state = AsyncValue.data(updatedNotes);
          _inMemoryNotes = updatedNotes;
          
          _logger.d('Note deleted successfully via API: $id');
        } catch (apiError) {
          _logger.w('Backend API not available, deleting note locally: $apiError');
          
          // Fallback: Soft delete locally
          final currentNotes = await future;
          final noteIndex = currentNotes.indexWhere((note) => note.id == id);
          
          if (noteIndex != -1) {
            final deletedNote = currentNotes[noteIndex].copyWith(
              isDeleted: true,
              updatedAt: DateTime.now(),
            );
            
            // Try to save to local storage, but don't fail if it doesn't work
            try {
              final storageService = ref.read(storageServiceProvider);
              await storageService.saveNote(deletedNote);
            } catch (storageError) {
              _logger.w('Failed to save deleted note to local storage: $storageError');
            }
            
            // Update state and in-memory storage (remove from list)
            final updatedNotes = currentNotes.where((note) => note.id != id).toList();
            state = AsyncValue.data(updatedNotes);
            _inMemoryNotes = updatedNotes;
            
            _logger.d('Note deleted locally: $id');
          }
        }
      } else {
        throw Exception('No authenticated user');
      }
    } catch (e) {
      _logger.e('Error deleting note: $e');
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  /// Restore deleted note
  Future<bool> restoreNote(String id) async {
    try {
      final apiService = ref.read(apiServiceProvider);
      final authUser = ref.read(authViewModelProvider).value;
      
      if (authUser != null) {
        // Set auth token for API calls
        final supabaseService = ref.read(supabaseServiceProvider);
        final session = supabaseService.supabase.auth.currentSession;
        if (session != null) {
          apiService.setAuthToken(session.accessToken);
        }
        
        try {
          // Try to restore note via backend API first
          await apiService.restoreNote(id);
          _logger.d('Note restored via API: $id');
          
          // Reload notes from backend to get updated state
          ref.refresh(notesViewModelProvider);
          
          _logger.d('Note restored successfully via API: $id');
          return true;
        } catch (apiError) {
          _logger.w('Backend API not available, restoring note locally: $apiError');
          
          // Fallback: Restore locally
          final storageService = ref.read(storageServiceProvider);
          final currentNotes = await future;
          final noteIndex = currentNotes.indexWhere((note) => note.id == id);
          
          if (noteIndex != -1) {
            final restoredNote = currentNotes[noteIndex].copyWith(
              isDeleted: false,
              updatedAt: DateTime.now(),
            );
            
            // Save to local storage
            await storageService.saveNote(restoredNote);
            
            // Update state (add back to list)
            final updatedNotes = [...currentNotes, restoredNote];
            state = AsyncValue.data(updatedNotes);
            
            _logger.d('Note restored locally: $id');
            return true;
          } else {
            _logger.w('Note not found for restoration: $id');
            return false;
          }
        }
      } else {
        throw Exception('No authenticated user');
      }
    } catch (e) {
      _logger.e('Error restoring note: $e');
      state = AsyncValue.error(e, StackTrace.current);
      return false;
    }
  }

  /// Toggle pin status
  Future<void> togglePin(String id) async {
    try {
      final apiService = ref.read(apiServiceProvider);
      final authUser = ref.read(authViewModelProvider).value;
      
      if (authUser != null) {
        // Set auth token for API calls
        final supabaseService = ref.read(supabaseServiceProvider);
        final session = supabaseService.supabase.auth.currentSession;
        if (session != null) {
          apiService.setAuthToken(session.accessToken);
        }
        
        try {
          // Try to toggle pin via backend API first
          final toggledNote = await apiService.togglePinNote(id);
          _logger.d('Note pin toggled via API: $id');
          
          // Save to local storage for offline access
          try {
            final storageService = ref.read(storageServiceProvider);
            await storageService.saveNote(toggledNote);
          } catch (storageError) {
            _logger.w('Failed to save pinned note to local storage: $storageError');
          }
          
          // Update state and in-memory storage
          final currentNotes = await future;
          final noteIndex = currentNotes.indexWhere((note) => note.id == id);
          if (noteIndex != -1) {
            final updatedNotes = [...currentNotes];
            updatedNotes[noteIndex] = toggledNote;
            state = AsyncValue.data(updatedNotes);
            _inMemoryNotes = updatedNotes;
          }
          
          _logger.d('Note pin toggled successfully via API: $id');
        } catch (apiError) {
          _logger.w('Backend API not available, toggling pin locally: $apiError');
          
          // Fallback: Toggle locally
          final currentNotes = await future;
          final noteIndex = currentNotes.indexWhere((note) => note.id == id);
          
          if (noteIndex != -1) {
            final toggledNote = currentNotes[noteIndex].copyWith(
              isPinned: !currentNotes[noteIndex].isPinned,
              updatedAt: DateTime.now(),
            );
            
            // Try to save to local storage, but don't fail if it doesn't work
            try {
              final storageService = ref.read(storageServiceProvider);
              await storageService.saveNote(toggledNote);
            } catch (storageError) {
              _logger.w('Failed to save pinned note to local storage: $storageError');
            }
            
            // Update state and in-memory storage
            final updatedNotes = [...currentNotes];
            updatedNotes[noteIndex] = toggledNote;
            state = AsyncValue.data(updatedNotes);
            _inMemoryNotes = updatedNotes;
            
            _logger.d('Note pin toggled locally: $id');
          }
        }
      } else {
        throw Exception('No authenticated user');
      }
    } catch (e) {
      _logger.e('Error toggling pin: $e');
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  /// Summarize note using AI
  Future<Map<String, dynamic>?> summarizeNote(String id) async {
    try {
      // Check if note ID is UUID format (backend note)
      if (!_isValidUuid(id)) {
        _logger.w('Cannot summarize local note with ID: $id');
        return {
          'error': 'AI özellikleri sadece backend\'den senkronize edilen notlar için kullanılabilir.',
          'summary': 'Bu not henüz backend\'e senkronize edilmemiş. Lütfen notu düzenleyip kaydedin.'
        };
      }

      final apiService = ref.read(apiServiceProvider);
      final authUser = ref.read(authViewModelProvider).value;
      
      if (authUser != null) {
        // Set auth token for API calls
        final supabaseService = ref.read(supabaseServiceProvider);
        final session = supabaseService.supabase.auth.currentSession;
        if (session != null) {
          _logger.d('Setting auth token for user: ${authUser.email}');
          _logger.d('Session exists: ${session.accessToken.isNotEmpty}');
          apiService.setAuthToken(session.accessToken);
        } else {
          _logger.e('No active session found for user: ${authUser.email}');
          return {
            'error': 'Oturum bulunamadı',
            'summary': 'Lütfen tekrar giriş yapın.'
          };
        }
        
        try {
          _logger.d('Attempting to summarize note with ID: $id');
          _logger.d('API endpoint: ${ApiConstants.summarizeNote(id)}');
          _logger.d('Base URL: ${ApiConstants.baseUrl}');
          
          final result = await apiService.summarizeNote(id);
          _logger.d('Note summarized via API successfully: $id');
          return result;
        } catch (apiError) {
          _logger.e('AI summarization failed for note $id: $apiError');
          _logger.e('Error type: ${apiError.runtimeType}');
          
          // Check if it's a specific backend error
          if (apiError.toString().contains('not found')) {
            return {
              'error': 'Not bulunamadı',
              'summary': 'Bu not backend\'de bulunamadı. Lütfen notu yeniden kaydedin.'
            };
          }
          
          return {
            'error': 'AI özetleme başarısız oldu',
            'summary': 'Backend AI servisi şu anda kullanılamıyor: $apiError'
          };
        }
      } else {
        throw Exception('No authenticated user');
      }
    } catch (e) {
      _logger.e('Error summarizing note: $e');
      return {
        'error': 'Beklenmeyen hata',
        'summary': 'AI özetleme sırasında bir hata oluştu.'
      };
    }
  }

  /// Auto tag note using AI
  Future<Map<String, dynamic>?> autoTagNote(String id) async {
    try {
      // Check if note ID is UUID format (backend note)
      if (!_isValidUuid(id)) {
        _logger.w('Cannot auto-tag local note with ID: $id');
        return {
          'error': 'AI özellikleri sadece backend\'den senkronize edilen notlar için kullanılabilir.',
          'tags': ['Bu not henüz backend\'e senkronize edilmemiş']
        };
      }

      final apiService = ref.read(apiServiceProvider);
      final authUser = ref.read(authViewModelProvider).value;
      
      if (authUser != null) {
        // Set auth token for API calls
        final supabaseService = ref.read(supabaseServiceProvider);
        final session = supabaseService.supabase.auth.currentSession;
        if (session != null) {
          apiService.setAuthToken(session.accessToken);
        }
        
        try {
          final result = await apiService.autoTagNote(id);
          _logger.d('Note auto-tagged via API: $id');
          return result;
        } catch (apiError) {
          _logger.e('AI auto-tagging failed: $apiError');
          return {
            'error': 'AI etiketleme başarısız oldu',
            'tags': ['Backend AI servisi şu anda kullanılamıyor']
          };
        }
      } else {
        throw Exception('No authenticated user');
      }
    } catch (e) {
      _logger.e('Error auto-tagging note: $e');
      return {
        'error': 'Beklenmeyen hata',
        'tags': ['AI etiketleme sırasında bir hata oluştu']
      };
    }
  }

  /// Categorize note using AI
  Future<Map<String, dynamic>?> categorizeNote(String id) async {
    try {
      final apiService = ref.read(apiServiceProvider);
      final authUser = ref.read(authViewModelProvider).value;
      
      if (authUser != null) {
        // Set auth token for API calls
        final supabaseService = ref.read(supabaseServiceProvider);
        final session = supabaseService.supabase.auth.currentSession;
        if (session != null) {
          apiService.setAuthToken(session.accessToken);
        }
        
        try {
          final result = await apiService.categorizeNote(id);
          _logger.d('Note categorized via API: $id');
          return result;
        } catch (apiError) {
          _logger.e('AI categorization failed: $apiError');
          return null;
        }
      } else {
        throw Exception('No authenticated user');
      }
    } catch (e) {
      _logger.e('Error categorizing note: $e');
      return null;
    }
  }

  /// AI process note (all AI features)
  Future<Map<String, dynamic>?> aiProcessNote(String id) async {
    try {
      final apiService = ref.read(apiServiceProvider);
      final authUser = ref.read(authViewModelProvider).value;
      
      if (authUser != null) {
        // Set auth token for API calls
        final supabaseService = ref.read(supabaseServiceProvider);
        final session = supabaseService.supabase.auth.currentSession;
        if (session != null) {
          apiService.setAuthToken(session.accessToken);
        }
        
        try {
          final result = await apiService.aiProcessNote(id);
          _logger.d('Note AI processed via API: $id');
          return result;
        } catch (apiError) {
          _logger.e('AI processing failed: $apiError');
          return null;
        }
      } else {
        throw Exception('No authenticated user');
      }
    } catch (e) {
      _logger.e('Error AI processing note: $e');
      return null;
    }
  }

  /// Search notes using backend API
  Future<List<Note>> searchNotes(String query) async {
    try {
      final apiService = ref.read(apiServiceProvider);
      final authUser = ref.read(authViewModelProvider).value;
      
      if (authUser != null) {
        // Set auth token for API calls
        final supabaseService = ref.read(supabaseServiceProvider);
        final session = supabaseService.supabase.auth.currentSession;
        if (session != null) {
          apiService.setAuthToken(session.accessToken);
        }
        
        try {
          final notes = await apiService.searchNotes(query);
          _logger.d('Found ${notes.length} notes for query: $query');
          return notes;
        } catch (apiError) {
          _logger.w('Backend search failed, using local search: $apiError');
          
          // Fallback to local search
          final currentNotes = await future;
          return currentNotes.where((note) => 
            note.title.toLowerCase().contains(query.toLowerCase()) ||
            note.content.toLowerCase().contains(query.toLowerCase())
          ).toList();
        }
      } else {
        throw Exception('No authenticated user');
      }
    } catch (e) {
      _logger.e('Error searching notes: $e');
      return [];
    }
  }

  /// Check if string is a valid UUID
  bool _isValidUuid(String id) {
    final uuidRegex = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
      caseSensitive: false,
    );
    return uuidRegex.hasMatch(id);
  }

}

/// API service provider
@riverpod
ApiService apiService(ApiServiceRef ref) {
  final apiClient = ref.read(apiClientProvider);
  return ApiService(apiClient);
}

/// API client provider
@riverpod
ApiClient apiClient(ApiClientRef ref) {
  return ApiClient();
}

/// Network info provider
@riverpod
NetworkInfo networkInfo(NetworkInfoRef ref) {
  return NetworkInfo();
}
