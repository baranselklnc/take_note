import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:logger/logger.dart';
import '../models/note.dart';
import 'notes_viewmodel.dart';

part 'search_viewmodel.g.dart';

/// Search view model
@riverpod
class SearchViewModel extends _$SearchViewModel {
  final Logger _logger = Logger();
  String _currentQuery = '';

  @override
  List<Note> build() {
    // Return empty list initially
    return [];
  }

  /// Get current search query
  String get currentQuery => _currentQuery;

  /// Search notes by query
  Future<void> searchNotes(String query, List<Note> allNotes) async {
    _currentQuery = query;
    
    if (query.isEmpty) {
      // If query is empty, return all notes
      state = allNotes;
      return;
    }

    try {
      // Try backend search first
      final notesViewModel = ref.read(notesViewModelProvider.notifier);
      final backendResults = await notesViewModel.searchNotes(query);
      
      if (backendResults.isNotEmpty) {
        state = backendResults;
        _logger.d('Backend search completed: ${backendResults.length} notes found for "$query"');
      } else {
        // Fallback to local search
        final filteredNotes = allNotes.where((note) {
          final titleMatch = note.title.toLowerCase().contains(query.toLowerCase());
          final contentMatch = note.content.toLowerCase().contains(query.toLowerCase());
          return titleMatch || contentMatch;
        }).toList();
        
        state = filteredNotes;
        _logger.d('Local search completed: ${filteredNotes.length} notes found for "$query"');
      }
    } catch (e) {
      _logger.e('Search error: $e');
      
      // Fallback to local search on error
      try {
        final filteredNotes = allNotes.where((note) {
          final titleMatch = note.title.toLowerCase().contains(query.toLowerCase());
          final contentMatch = note.content.toLowerCase().contains(query.toLowerCase());
          return titleMatch || contentMatch;
        }).toList();
        
        state = filteredNotes;
        _logger.d('Fallback local search completed: ${filteredNotes.length} notes found for "$query"');
      } catch (fallbackError) {
        _logger.e('Fallback search error: $fallbackError');
        state = [];
      }
    }
  }

  /// Clear search
  void clearSearch(List<Note> allNotes) {
    _currentQuery = '';
    state = allNotes;
  }

  /// Get search results
  List<Note> get searchResults {
    return state;
  }

  /// Check if currently searching
  bool get isSearching {
    return false; // Simple search, no loading state needed
  }
}
