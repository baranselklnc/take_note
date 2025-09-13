import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../viewmodels/notes_viewmodel.dart';
import '../../viewmodels/search_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../shared/widgets/note_card.dart';
import '../../shared/widgets/search_bar.dart' as custom;
import '../../shared/widgets/loading_widget.dart' as custom;
import '../../shared/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../models/note.dart';
import 'create_note_page.dart';
import 'note_detail_page.dart';
import '../auth/login_page.dart';

/// Notes list page
class NotesListPage extends ConsumerStatefulWidget {
  const NotesListPage({super.key});

  @override
  ConsumerState<NotesListPage> createState() => _NotesListPageState();
}

class _NotesListPageState extends ConsumerState<NotesListPage> {
  bool _isSearching = false;

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
    });
    
    if (!_isSearching) {
      // Clear search when closing
      final allNotes = ref.read(notesViewModelProvider).value ?? [];
      ref.read(searchViewModelProvider.notifier).clearSearch(allNotes);
    }
  }

  void _navigateToCreateNote() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const CreateNotePage()),
    );
  }

  void _navigateToNoteDetail(String noteId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => NoteDetailPage(noteId: noteId),
      ),
    );
  }

  void _showDeleteConfirmation(String noteId, String noteTitle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: Text('Are you sure you want to delete "$noteTitle"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteNote(noteId);
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _deleteNote(String noteId) {
    ref.read(notesViewModelProvider.notifier).deleteNote(noteId);
    
    // Show undo snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Note deleted'),
        action: SnackBarAction(
          label: 'UNDO',
          onPressed: () {
            ref.read(notesViewModelProvider.notifier).restoreNote(noteId);
          },
        ),
        duration: const Duration(seconds: AppConstants.undoTimeoutSeconds),
      ),
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(authViewModelProvider.notifier).logout();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notesState = ref.watch(notesViewModelProvider);
    final searchState = ref.watch(searchViewModelProvider);
    final authState = ref.watch(authViewModelProvider);

    // Use search results if searching, otherwise use all notes
    final displayNotes = _isSearching 
        ? searchState
        : notesState.value ?? [];

    // Sort notes: pinned first, then by updated date
    final sortedNotes = List<Note>.from(displayNotes)
      ..sort((a, b) {
        if (a.isPinned && !b.isPinned) return -1;
        if (!a.isPinned && b.isPinned) return 1;
        return b.updatedAt.compareTo(a.updatedAt);
      });

    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, ${authState.value?.name ?? 'User'}'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: _toggleSearch,
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: AppTheme.errorColor),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'logout') _logout();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar (shown when searching)
          if (_isSearching)
            custom.SearchBar(
              onChanged: (query) {
                final allNotes = notesState.value ?? [];
                ref.read(searchViewModelProvider.notifier).searchNotes(query, allNotes);
              },
              onClear: () {
                final allNotes = notesState.value ?? [];
                ref.read(searchViewModelProvider.notifier).clearSearch(allNotes);
              },
            ),

          // Notes list
          Expanded(
            child: notesState.when(
              data: (notes) {
                if (sortedNotes.isEmpty) {
                  return custom.EmptyStateWidget(
                    title: _isSearching ? 'No results found' : 'No notes yet',
                    message: _isSearching 
                        ? 'Try a different search term'
                        : 'Create your first note to get started',
                    icon: _isSearching ? Icons.search_off : Icons.note_add,
                    action: _isSearching 
                        ? null 
                        : ElevatedButton(
                            onPressed: _navigateToCreateNote,
                            child: const Text('Create Note'),
                          ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    // Refresh notes
                    ref.invalidate(notesViewModelProvider);
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: AppConstants.smallPadding),
                    itemCount: sortedNotes.length,
                    itemBuilder: (context, index) {
                      final note = sortedNotes[index];
                      return NoteCard(
                        note: note,
                        onTap: () => _navigateToNoteDetail(note.id),
                        onPin: () {
                          ref.read(notesViewModelProvider.notifier).togglePin(note.id);
                        },
                        onDelete: () => _showDeleteConfirmation(note.id, note.title),
                      );
                    },
                  ),
                );
              },
              loading: () => const custom.LoadingWidget(message: 'Loading notes...'),
              error: (error, stack) => custom.ErrorWidget(
                message: error.toString(),
                onRetry: () {
                  ref.invalidate(notesViewModelProvider);
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateNote,
        child: const Icon(Icons.add),
      ),
    );
  }
}
