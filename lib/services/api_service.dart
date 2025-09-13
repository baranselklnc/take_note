import 'package:logger/logger.dart';
import '../core/network/api_client.dart';
import '../core/constants/api_constants.dart';
import '../models/note.dart';

/// API service for backend communication
class ApiService {
  final ApiClient _apiClient;
  final Logger _logger = Logger();

  ApiService(this._apiClient);

  // Note: Authentication is handled by Supabase, not this API service
  // These methods are kept for potential future use but are not currently used
  
  /// Set authentication token for API requests
  void setAuthToken(String token) {
    _apiClient.setAuthToken(token);
    _logger.d('Auth token set for API requests');
  }

  /// Clear authentication token
  void clearAuthToken() {
    _apiClient.clearAuthToken();
    _logger.d('Auth token cleared');
  }

  /// Get user's notes
  Future<List<Note>> getNotes({
    int page = 1,
    int size = 50,
    String? search,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        ApiConstants.pageParam: page,
        ApiConstants.sizeParam: size,
      };
      
      if (search != null && search.isNotEmpty) {
        queryParams[ApiConstants.searchParam] = search;
      }
      
      final response = await _apiClient.get(
        '${ApiConstants.notes}?${_buildQueryString(queryParams)}'
      );
      
      final notesList = (response['notes'] as List)
          .map((noteJson) => Note.fromJson(noteJson))
          .toList();
      
      _logger.d('Retrieved ${notesList.length} notes from API');
      return notesList;
    } catch (e) {
      _logger.e('Get notes error: $e');
      rethrow;
    }
  }

  /// Create new note
  Future<Note> createNote(String title, String content) async {
    try {
      final response = await _apiClient.post(ApiConstants.notes, {
        'title': title,
        'content': content,
      });

      final note = Note.fromJson(response['note']);
      _logger.d('Created note: ${note.id}');
      
      return note;
    } catch (e) {
      _logger.e('Create note error: $e');
      rethrow;
    }
  }

  /// Update note
  Future<Note> updateNote(String id, String title, String content) async {
    try {
      final response = await _apiClient.put(ApiConstants.noteById(id), {
        'title': title,
        'content': content,
      });

      final note = Note.fromJson(response['note']);
      _logger.d('Updated note: ${note.id}');
      
      return note;
    } catch (e) {
      _logger.e('Update note error: $e');
      rethrow;
    }
  }

  /// Delete note
  Future<void> deleteNote(String id) async {
    try {
      await _apiClient.delete(ApiConstants.noteById(id));
      _logger.d('Deleted note: $id');
    } catch (e) {
      _logger.e('Delete note error: $e');
      rethrow;
    }
  }

  /// Toggle note pin status
  Future<Note> togglePinNote(String id) async {
    try {
      final response = await _apiClient.patch(ApiConstants.togglePin(id), {});

      final note = Note.fromJson(response);
      _logger.d('Toggled pin for note: ${note.id}');
      
      return note;
    } catch (e) {
      _logger.e('Toggle pin error: $e');
      rethrow;
    }
  }

  /// Restore deleted note
  Future<void> restoreNote(String id) async {
    try {
      await _apiClient.post(ApiConstants.restoreNote(id), {});
      _logger.d('Restored note: $id');
    } catch (e) {
      _logger.e('Restore note error: $e');
      rethrow;
    }
  }

  /// Search notes
  Future<List<Note>> searchNotes(String query, {int? limit}) async {
    try {
      final response = await _apiClient.post(ApiConstants.searchNotes, {
        'query': query,
        if (limit != null) 'limit': limit,
      });

      final notesList = (response['notes'] as List)
          .map((noteJson) => Note.fromJson(noteJson))
          .toList();
      
      _logger.d('Found ${notesList.length} notes for query: $query');
      return notesList;
    } catch (e) {
      _logger.e('Search notes error: $e');
      rethrow;
    }
  }

  /// Semantic search notes
  Future<List<Map<String, dynamic>>> semanticSearch(String query) async {
    try {
      final response = await _apiClient.post(ApiConstants.semanticSearch, {
        'query': query,
      });

      final results = (response['results'] as List)
          .cast<Map<String, dynamic>>();
      
      _logger.d('Found ${results.length} semantic search results for query: $query');
      return results;
    } catch (e) {
      _logger.e('Semantic search error: $e');
      rethrow;
    }
  }

  /// Summarize note
  Future<Map<String, dynamic>> summarizeNote(String id) async {
    try {
      final response = await _apiClient.post(ApiConstants.summarizeNote(id), {});
      _logger.d('Summarized note: $id');
      return response;
    } catch (e) {
      _logger.e('Summarize note error: $e');
      rethrow;
    }
  }

  /// Categorize note
  Future<Map<String, dynamic>> categorizeNote(String id) async {
    try {
      final response = await _apiClient.post(ApiConstants.categorizeNote(id), {});
      _logger.d('Categorized note: $id');
      return response;
    } catch (e) {
      _logger.e('Categorize note error: $e');
      rethrow;
    }
  }

  /// Auto tag note
  Future<Map<String, dynamic>> autoTagNote(String id) async {
    try {
      final response = await _apiClient.post(ApiConstants.autoTagNote(id), {});
      _logger.d('Auto tagged note: $id');
      return response;
    } catch (e) {
      _logger.e('Auto tag note error: $e');
      rethrow;
    }
  }

  /// AI process note (all AI features)
  Future<Map<String, dynamic>> aiProcessNote(String id) async {
    try {
      final response = await _apiClient.post(ApiConstants.aiProcessNote(id), {});
      _logger.d('AI processed note: $id');
      return response;
    } catch (e) {
      _logger.e('AI process note error: $e');
      rethrow;
    }
  }

  /// Process content with AI
  Future<Map<String, dynamic>> processContent(String content) async {
    try {
      final response = await _apiClient.post(ApiConstants.processContent, {
        'content': content,
      });
      _logger.d('AI processed content');
      return response;
    } catch (e) {
      _logger.e('Process content error: $e');
      rethrow;
    }
  }

  /// Build query string from parameters
  String _buildQueryString(Map<String, dynamic> params) {
    return params.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value.toString())}')
        .join('&');
  }
}
