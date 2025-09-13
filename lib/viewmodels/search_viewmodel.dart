import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:logger/logger.dart';
import '../models/note.dart';

part 'search_viewmodel.g.dart';

/// Search view model
@riverpod
class SearchViewModel extends _$SearchViewModel {
  final Logger _logger = Logger();

  @override
  List<Note> build() {
    // Return empty list initially
    return [];
  }

  /// Search notes by query
  void searchNotes(String query, List<Note> allNotes) {
    if (query.isEmpty) {
      // If query is empty, return all notes
      state = allNotes;
      return;
    }

    try {
      // Filter notes by title or content
      final filteredNotes = allNotes.where((note) {
        final titleMatch = note.title.toLowerCase().contains(query.toLowerCase());
        final contentMatch = note.content.toLowerCase().contains(query.toLowerCase());
        return titleMatch || contentMatch;
      }).toList();
      
      state = filteredNotes;
      _logger.d('Search completed: ${filteredNotes.length} notes found for "$query"');
    } catch (e) {
      _logger.e('Search error: $e');
      state = [];
    }
  }

  /// Clear search
  void clearSearch(List<Note> allNotes) {
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
