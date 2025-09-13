import 'package:logger/logger.dart';
import '../core/storage/local_storage.dart';
import '../core/errors/exceptions.dart';
import '../models/user.dart';
import '../models/note.dart';

/// Storage service for local data management
class StorageService {
  final LocalStorage _localStorage;
  final Logger _logger = Logger();

  StorageService(this._localStorage);

  /// Initialize storage
  Future<void> init() async {
    await _localStorage.init();
  }

  /// Save user data
  Future<void> saveUser(User user) async {
    try {
      await _localStorage.saveUser(user);
      _logger.d('User saved to storage: ${user.email}');
    } catch (e) {
      _logger.e('Error saving user: $e');
      throw CacheException('Failed to save user');
    }
  }

  /// Get current user
  Future<User?> getCurrentUser() async {
    try {
      return await _localStorage.getCurrentUser();
    } catch (e) {
      _logger.e('Error getting user: $e');
      throw CacheException('Failed to get user');
    }
  }

  /// Clear user data
  Future<void> clearUser() async {
    try {
      await _localStorage.clearUser();
      _logger.d('User data cleared');
    } catch (e) {
      _logger.e('Error clearing user: $e');
      throw CacheException('Failed to clear user data');
    }
  }

  /// Save notes
  Future<void> saveNotes(List<Note> notes) async {
    try {
      await _localStorage.saveNotes(notes);
      _logger.d('Saved ${notes.length} notes to storage');
    } catch (e) {
      _logger.e('Error saving notes: $e');
      throw CacheException('Failed to save notes');
    }
  }

  /// Get notes
  Future<List<Note>> getNotes() async {
    try {
      return await _localStorage.getNotes();
    } catch (e) {
      _logger.e('Error getting notes: $e');
      throw CacheException('Failed to get notes');
    }
  }

  /// Save single note
  Future<void> saveNote(Note note) async {
    try {
      await _localStorage.saveNote(note);
      _logger.d('Saved note: ${note.id}');
    } catch (e) {
      _logger.e('Error saving note: $e');
      throw CacheException('Failed to save note');
    }
  }

  /// Delete note
  Future<void> deleteNote(String noteId) async {
    try {
      await _localStorage.deleteNote(noteId);
      _logger.d('Deleted note: $noteId');
    } catch (e) {
      _logger.e('Error deleting note: $e');
      throw CacheException('Failed to delete note');
    }
  }

  /// Add to sync queue
  Future<void> addToSyncQueue(String operation, Map<String, dynamic> data) async {
    try {
      await _localStorage.addToSyncQueue(operation, data);
      _logger.d('Added to sync queue: $operation');
    } catch (e) {
      _logger.e('Error adding to sync queue: $e');
      throw CacheException('Failed to add to sync queue');
    }
  }

  /// Get sync queue
  Future<List<Map<String, dynamic>>> getSyncQueue() async {
    try {
      return await _localStorage.getSyncQueue();
    } catch (e) {
      _logger.e('Error getting sync queue: $e');
      throw CacheException('Failed to get sync queue');
    }
  }

  /// Clear sync queue
  Future<void> clearSyncQueue() async {
    try {
      await _localStorage.clearSyncQueue();
      _logger.d('Sync queue cleared');
    } catch (e) {
      _logger.e('Error clearing sync queue: $e');
      throw CacheException('Failed to clear sync queue');
    }
  }

  /// Close storage
  Future<void> close() async {
    await _localStorage.close();
  }
}
