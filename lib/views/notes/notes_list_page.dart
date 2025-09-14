import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../viewmodels/notes_viewmodel.dart';
import '../../viewmodels/search_viewmodel.dart';
import '../../shared/widgets/note_card.dart';
import '../../shared/widgets/search_bar.dart' as custom;
import '../../shared/widgets/loading_widget.dart' as custom;
import '../../models/note.dart';
import 'create_note_page.dart';
import 'note_detail_page.dart';

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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _deleteNote(String noteId) {
    ref.read(notesViewModelProvider.notifier).deleteNote(noteId);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Note deleted'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        action: SnackBarAction(
          label: 'UNDO',
          onPressed: () {
            ref.read(notesViewModelProvider.notifier).restoreNote(noteId);
          },
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notesState = ref.watch(notesViewModelProvider);
    final searchState = ref.watch(searchViewModelProvider);

    final displayNotes = _isSearching 
        ? searchState
        : notesState.value ?? [];

    final sortedNotes = List<Note>.from(displayNotes)
      ..sort((a, b) {
        if (a.isPinned && !b.isPinned) return -1;
        if (!a.isPinned && b.isPinned) return 1;
        return b.updatedAt.compareTo(a.updatedAt);
      });

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Notes',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: _toggleSearch,
            tooltip: _isSearching ? 'Close search' : 'Search notes',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          if (_isSearching)
            Container(
              padding: const EdgeInsets.all(16),
              child: custom.SearchBar(
                onChanged: (query) {
                  final allNotes = notesState.value ?? [];
                  ref.read(searchViewModelProvider.notifier).searchNotes(query, allNotes);
                },
                onClear: () {
                  final allNotes = notesState.value ?? [];
                  ref.read(searchViewModelProvider.notifier).clearSearch(allNotes);
                },
              ),
            ),

          // Notes list
          Expanded(
            child: notesState.when(
              data: (notes) {
                if (sortedNotes.isEmpty) {
                  return _buildEmptyState();
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(notesViewModelProvider);
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
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
                        onSummarize: () {
                          // TODO: Implement AI summarization
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('AI Summarization coming soon!'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        onAutoTag: () {
                          // TODO: Implement AI auto-tagging
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('AI Auto-tagging coming soon!'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _isSearching ? Icons.search_off : Icons.note_add_outlined,
              size: 64,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _isSearching ? 'No results found' : 'No notes yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _isSearching 
                ? 'Try a different search term'
                : 'Create your first note to get started',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
            textAlign: TextAlign.center,
          ),
          if (!_isSearching) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _navigateToCreateNote,
              icon: const Icon(Icons.add),
              label: const Text('Create Note'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}