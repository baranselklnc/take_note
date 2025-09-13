import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:logger/logger.dart';
import '../models/note.dart';
import '../services/api_service.dart';
import '../core/network/api_client.dart';
import '../core/network/network_info.dart';
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
            id: DateTime.now().millisecondsSinceEpoch.toString(),
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
      // Update locally
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
          // Continue anyway - note is still updated in memory
        }
        
        // Update state and in-memory storage
        final updatedNotes = [...currentNotes];
        updatedNotes[noteIndex] = updatedNote;
        state = AsyncValue.data(updatedNotes);
        _inMemoryNotes = updatedNotes; // Update in-memory storage
        
        _logger.d('Note updated: $id');
      }
    } catch (e) {
      _logger.e('Error updating note: $e');
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  /// Delete note (soft delete)
  Future<void> deleteNote(String id) async {
    try {
      // Soft delete locally
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
          // Continue anyway - note is still deleted in memory
        }
        
        // Update state and in-memory storage (remove from list)
        final updatedNotes = currentNotes.where((note) => note.id != id).toList();
        state = AsyncValue.data(updatedNotes);
        _inMemoryNotes = updatedNotes; // Update in-memory storage
        
        _logger.d('Note deleted: $id');
      }
    } catch (e) {
      _logger.e('Error deleting note: $e');
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  /// Restore deleted note
  Future<void> restoreNote(String id) async {
    try {
      final storageService = ref.read(storageServiceProvider);
      
      // Restore locally
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
        
        _logger.d('Note restored: $id');
      }
    } catch (e) {
      _logger.e('Error restoring note: $e');
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  /// Toggle pin status
  Future<void> togglePin(String id) async {
    try {
      // Toggle locally
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
          // Continue anyway - note is still pinned in memory
        }
        
        // Update state and in-memory storage
        final updatedNotes = [...currentNotes];
        updatedNotes[noteIndex] = toggledNote;
        state = AsyncValue.data(updatedNotes);
        _inMemoryNotes = updatedNotes; // Update in-memory storage
        
        _logger.d('Note pin toggled: $id');
      }
    } catch (e) {
      _logger.e('Error toggling pin: $e');
      state = AsyncValue.error(e, StackTrace.current);
    }
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
