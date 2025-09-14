import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../viewmodels/notes_viewmodel.dart';
import '../../viewmodels/search_viewmodel.dart';
import '../../shared/widgets/note_card.dart';
import '../../shared/widgets/modern_search_bar.dart';
import '../../shared/widgets/loading_widget.dart' as custom;
import '../../shared/widgets/ai_summary_dialog.dart';
import '../../shared/widgets/ai_tags_dialog.dart';
import '../../shared/widgets/ai_loading_widget.dart';
import '../../models/note.dart';
import 'create_note_page.dart';
import 'note_detail_page.dart';

class NotesListPage extends ConsumerStatefulWidget {
  const NotesListPage({super.key});

  @override
  ConsumerState<NotesListPage> createState() => _NotesListPageState();
}

class _NotesListPageState extends ConsumerState<NotesListPage> {
  bool _isSummarizing = false;
  bool _isAutoTagging = false;

  void _onSearch(String query, SearchType searchType) {
    final allNotes = ref.read(notesViewModelProvider).value ?? [];
    ref.read(searchViewModelProvider.notifier).searchNotes(query, allNotes);
  }

  void _onClearSearch() {
    final allNotes = ref.read(notesViewModelProvider).value ?? [];
    ref.read(searchViewModelProvider.notifier).clearSearch(allNotes);
  }

  void _showAiSummaryDialog(Map<String, dynamic> result, Note note) {
    showDialog(
      context: context,
      builder: (context) => AiSummaryDialog(
        originalTitle: note.title,
        summary: result['summary'] ?? 'Özet oluşturulamadı',
        originalLength: note.content.length,
        summaryLength: (result['summary'] ?? '').length,
        compressionRatio: result['compression_ratio']?.toDouble() ?? 0.0,
      ),
    );
  }

  void _showAiTagsDialog(Map<String, dynamic> result, Note note) {
    final tags = (result['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
    showDialog(
      context: context,
      builder: (context) => AiTagsDialog(
        tags: tags,
        onTagSelected: (tag) {
          // TODO: Implement tag selection logic
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Tag "$tag" seçildi'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      ),
    );
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
        title: const Text('Notu Sil'),
        content: Text('"$noteTitle" notunu silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteNote(noteId);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }

  void _deleteNote(String noteId) {
    ref.read(notesViewModelProvider.notifier).deleteNote(noteId);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Not silindi'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        action: SnackBarAction(
          label: 'GERİ AL',
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
    final isSearching = ref.watch(searchViewModelProvider.notifier).currentQuery.isNotEmpty;

    final displayNotes = isSearching 
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
          'Notlar',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: Column(
        children: [
          // Modern Search Bar - Always visible
          ModernSearchBar(
            onSearch: _onSearch,
            onClear: _onClearSearch,
          ),

          // Notes grid
          Expanded(
            child: notesState.when(
              data: (notes) {
                if (sortedNotes.isEmpty) {
                  return _buildEmptyState(isSearching);
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(notesViewModelProvider);
                  },
                  child: MasonryGridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    padding: const EdgeInsets.all(16),
                    itemCount: sortedNotes.length,
                    itemBuilder: (context, index) {
                      final note = sortedNotes[index];
                      return NoteCard(
                        note: note,
                        searchQuery: isSearching ? ref.read(searchViewModelProvider.notifier).currentQuery : null,
                        onTap: () => _navigateToNoteDetail(note.id),
                        onPin: () {
                          ref.read(notesViewModelProvider.notifier).togglePin(note.id);
                        },
                        onDelete: () => _showDeleteConfirmation(note.id, note.title),
                        onSummarize: () async {
                          if (_isSummarizing) return;
                          setState(() {
                            _isSummarizing = true;
                          });
                          
                          // Show loading dialog
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => const AiLoadingWidget(
                              message: 'AI özet oluşturuluyor...',
                            ),
                          );
                          
                          try {
                            final result = await ref.read(notesViewModelProvider.notifier).summarizeNote(note.id);
                            if (mounted) {
                              Navigator.of(context).pop(); // Close loading dialog
                              if (result != null) {
                                _showAiSummaryDialog(result, note);
                              }
                            }
                          } finally {
                            if (mounted) {
                              setState(() {
                                _isSummarizing = false;
                              });
                            }
                          }
                        },
                        onAutoTag: () async {
                          if (_isAutoTagging) return;
                          setState(() {
                            _isAutoTagging = true;
                          });
                          
                          // Show loading dialog
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => const AiLoadingWidget(
                              message: 'AI etiketler oluşturuluyor...',
                            ),
                          );
                          
                          try {
                            final result = await ref.read(notesViewModelProvider.notifier).autoTagNote(note.id);
                            if (mounted) {
                              Navigator.of(context).pop(); // Close loading dialog
                              if (result != null) {
                                _showAiTagsDialog(result, note);
                              }
                            }
                          } finally {
                            if (mounted) {
                              setState(() {
                                _isAutoTagging = false;
                              });
                            }
                          }
                        },
                      );
                    },
                  ),
                );
              },
              loading: () => const custom.LoadingWidget(message: 'Notlar yükleniyor...'),
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
        backgroundColor: const Color(0xFFfeceab),
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isSearching) {
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
              isSearching ? Icons.sentiment_very_dissatisfied  : Icons.note_add_outlined, //üzgün surat icon 

              size: 64,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            isSearching ? 'Aradığını bulamadık' : 'Henüz not yok',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isSearching 
                ? 'Burada öyle bir şey yok'
                : 'Başlamak için ilk notunuzu oluşturun',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}