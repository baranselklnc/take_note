import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../viewmodels/notes_viewmodel.dart';
import '../../shared/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import 'edit_note_page.dart';

/// Note detail page
class NoteDetailPage extends ConsumerStatefulWidget {
  final String noteId;

  const NoteDetailPage({
    super.key,
    required this.noteId,
  });

  @override
  ConsumerState<NoteDetailPage> createState() => _NoteDetailPageState();
}

class _NoteDetailPageState extends ConsumerState<NoteDetailPage> {
  void _editNote() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditNotePage(noteId: widget.noteId),
      ),
    );
  }

  void _showDeleteConfirmation() {
    final notesState = ref.read(notesViewModelProvider);
    final note = notesState.value?.firstWhere(
      (note) => note.id == widget.noteId,
      orElse: () => throw Exception('Note not found'),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: Text('Are you sure you want to delete "${note?.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteNote();
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _deleteNote() {
    ref.read(notesViewModelProvider.notifier).deleteNote(widget.noteId);
    
    // Show undo snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Note deleted'),
        action: SnackBarAction(
          label: 'UNDO',
          onPressed: () {
            ref.read(notesViewModelProvider.notifier).restoreNote(widget.noteId);
          },
        ),
        duration: const Duration(seconds: AppConstants.undoTimeoutSeconds),
      ),
    );

    Navigator.of(context).pop();
  }

  void _togglePin() {
    ref.read(notesViewModelProvider.notifier).togglePin(widget.noteId);
  }

  @override
  Widget build(BuildContext context) {
    final notesState = ref.watch(notesViewModelProvider);

    return notesState.when(
      data: (notes) {
        final note = notes.firstWhere(
          (note) => note.id == widget.noteId,
          orElse: () => throw Exception('Note not found'),
        );

        return Scaffold(
          appBar: AppBar(
            title: Text(note.title),
            actions: [
              IconButton(
                icon: Icon(
                  note.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                  color: note.isPinned ? AppTheme.primaryColor : null,
                ),
                onPressed: _togglePin,
                tooltip: note.isPinned ? 'Unpin' : 'Pin',
              ),
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: _editNote,
                tooltip: 'Edit',
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: _showDeleteConfirmation,
                tooltip: 'Delete',
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  note.title,
                  style: AppTheme.headlineMedium,
                ),
                const SizedBox(height: AppConstants.smallPadding),

                // Metadata
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: AppTheme.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Created ${_formatDate(note.createdAt)}',
                      style: AppTheme.bodySmall,
                    ),
                    if (note.updatedAt != note.createdAt) ...[
                      const SizedBox(width: 16),
                      Icon(
                        Icons.edit,
                        size: 16,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Updated ${_formatDate(note.updatedAt)}',
                        style: AppTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: AppConstants.defaultPadding),

                // Content
                Text(
                  note.content,
                  style: AppTheme.bodyLarge,
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Text('Error loading note: $error'),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }
}
