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
        title: const Text('Notu Sil'),
        content: Text('"${note?.title}" notunu silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteNote();
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
            child: const Text('Sil'),
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
        content: const Text('Not silindi'),
        action: SnackBarAction(
          label: 'GERİ AL',
          onPressed: () async {
            final success = await ref.read(notesViewModelProvider.notifier).restoreNote(widget.noteId);
            if (success && mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Not başarıyla geri yüklendi'),
                  behavior: SnackBarBehavior.floating,
                  duration: Duration(seconds: 2),
                ),
              );
            } else if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Not geri yüklenemedi'),
                  behavior: SnackBarBehavior.floating,
                  duration: Duration(seconds: 2),
                ),
              );
            }
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
                tooltip: note.isPinned ? 'Sabitlemeyi Kaldır' : 'Sabitle',
              ),
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: _editNote,
                tooltip: 'Düzenle',
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: _showDeleteConfirmation,
                tooltip: 'Sil',
              ),
            ],
          ),
          body: GestureDetector(
            onTap: _editNote,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    note.title,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: AppConstants.smallPadding),

                  // Metadata
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${_formatDate(note.createdAt)} oluşturuldu',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      if (note.updatedAt != note.createdAt) ...[
                        const SizedBox(width: 16),
                        Icon(
                          Icons.edit,
                          size: 16,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${_formatDate(note.updatedAt)} güncellendi',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: AppConstants.defaultPadding),

                  // Content
                  Text(
                    note.content,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: const Text('Hata')),
        body: Center(
          child: Text('Not yüklenirken hata oluştu: $error'),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} gün${difference.inDays == 1 ? '' : ''} önce';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} saat${difference.inHours == 1 ? '' : ''} önce';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} dk${difference.inMinutes == 1 ? '' : ''} önce';
    } else {
      return 'Az önce';
    }
  }
}
