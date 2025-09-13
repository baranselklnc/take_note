import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';
import '../constants/app_constants.dart';
import '../errors/exceptions.dart';
import '../../models/note.dart';
import '../../models/user.dart';

/// Local storage service using Hive
class LocalStorage {
  final Logger _logger = Logger();
  Box<Map>? _notesBox;
  Box<Map>? _userBox;
  Box<Map>? _syncQueueBox;
  bool _isInitialized = false;

  /// Initialize Hive boxes
  Future<void> init() async {
    if (_isInitialized) return;
    
    await Hive.initFlutter();
    
    _notesBox = await Hive.openBox<Map>(AppConstants.notesBoxName);
    _userBox = await Hive.openBox<Map>(AppConstants.userBoxName);
    _syncQueueBox = await Hive.openBox<Map>(AppConstants.syncQueueBoxName);
    
    _isInitialized = true;
    _logger.i('Local storage initialized');
  }

  /// Check if storage is initialized
  void _ensureInitialized() {
    if (!_isInitialized || _notesBox == null || _userBox == null || _syncQueueBox == null) {
      throw CacheException('Local storage not initialized. Call init() first.');
    }
  }

  /// Save notes to local storage
  Future<void> saveNotes(List<Note> notes) async {
    _ensureInitialized();
    try {
      final notesMap = <String, Map>{};
      for (final note in notes) {
        notesMap[note.id] = note.toJson();
      }
      await _notesBox!.putAll(notesMap);
      _logger.d('Saved ${notes.length} notes to local storage');
    } catch (e) {
      _logger.e('Error saving notes: $e');
      throw CacheException('Failed to save notes locally');
    }
  }

  /// Get notes from local storage
  Future<List<Note>> getNotes() async {
    _ensureInitialized();
    try {
      final notesList = <Note>[];
      for (final noteData in _notesBox!.values) {
        try {
          notesList.add(Note.fromJson(Map<String, dynamic>.from(noteData)));
        } catch (e) {
          _logger.w('Error parsing note: $e');
        }
      }
      _logger.d('Retrieved ${notesList.length} notes from local storage');
      return notesList;
    } catch (e) {
      _logger.e('Error getting notes: $e');
      throw CacheException('Failed to get notes from local storage');
    }
  }

  /// Save single note
  Future<void> saveNote(Note note) async {
    _ensureInitialized();
    try {
      await _notesBox!.put(note.id, note.toJson());
      _logger.d('Saved note: ${note.id}');
    } catch (e) {
      _logger.e('Error saving note: $e');
      throw CacheException('Failed to save note locally');
    }
  }

  /// Delete note from local storage
  Future<void> deleteNote(String noteId) async {
    _ensureInitialized();
    try {
      await _notesBox!.delete(noteId);
      _logger.d('Deleted note: $noteId');
    } catch (e) {
      _logger.e('Error deleting note: $e');
      throw CacheException('Failed to delete note from local storage');
    }
  }

  /// Save user data
  Future<void> saveUser(User user) async {
    _ensureInitialized();
    try {
      await _userBox!.put('current_user', user.toJson());
      _logger.d('Saved user: ${user.id}');
    } catch (e) {
      _logger.e('Error saving user: $e');
      throw CacheException('Failed to save user locally');
    }
  }

  /// Get current user
  Future<User?> getCurrentUser() async {
    _ensureInitialized();
    try {
      final userData = _userBox!.get('current_user');
      if (userData != null) {
        return User.fromJson(Map<String, dynamic>.from(userData));
      }
      return null;
    } catch (e) {
      _logger.e('Error getting user: $e');
      throw CacheException('Failed to get user from local storage');
    }
  }

  /// Clear user data
  Future<void> clearUser() async {
    _ensureInitialized();
    try {
      await _userBox!.clear();
      _logger.d('Cleared user data');
    } catch (e) {
      _logger.e('Error clearing user: $e');
      throw CacheException('Failed to clear user data');
    }
  }

  /// Add operation to sync queue
  Future<void> addToSyncQueue(String operation, Map<String, dynamic> data) async {
    _ensureInitialized();
    try {
      final syncId = DateTime.now().millisecondsSinceEpoch.toString();
      await _syncQueueBox!.put(syncId, {
        'operation': operation,
        'data': data,
        'timestamp': DateTime.now().toIso8601String(),
      });
      _logger.d('Added to sync queue: $operation');
    } catch (e) {
      _logger.e('Error adding to sync queue: $e');
      throw CacheException('Failed to add to sync queue');
    }
  }

  /// Get sync queue
  Future<List<Map<String, dynamic>>> getSyncQueue() async {
    _ensureInitialized();
    try {
      final queue = <Map<String, dynamic>>[];
      for (final item in _syncQueueBox!.values) {
        queue.add(Map<String, dynamic>.from(item));
      }
      return queue;
    } catch (e) {
      _logger.e('Error getting sync queue: $e');
      throw CacheException('Failed to get sync queue');
    }
  }

  /// Clear sync queue
  Future<void> clearSyncQueue() async {
    _ensureInitialized();
    try {
      await _syncQueueBox!.clear();
      _logger.d('Cleared sync queue');
    } catch (e) {
      _logger.e('Error clearing sync queue: $e');
      throw CacheException('Failed to clear sync queue');
    }
  }

  /// Close all boxes
  Future<void> close() async {
    if (_isInitialized) {
      await _notesBox?.close();
      await _userBox?.close();
      await _syncQueueBox?.close();
      _isInitialized = false;
      _logger.i('Local storage closed');
    }
  }
}
