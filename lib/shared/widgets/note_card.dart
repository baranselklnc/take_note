import 'package:flutter/material.dart';
import '../../models/note.dart';
import '../theme/app_theme.dart';
import '../../core/constants/app_constants.dart';

/// Note card widget
class NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback? onTap;
  final VoidCallback? onPin;
  final VoidCallback? onDelete;

  const NoteCard({
    super.key,
    required this.note,
    this.onTap,
    this.onPin,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: note.isPinned ? AppTheme.pinnedNoteColor : AppTheme.noteCardColor,
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
        vertical: AppConstants.smallPadding,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with pin icon
              Row(
                children: [
                  Expanded(
                    child: Text(
                      note.title,
                      style: AppTheme.headlineSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (note.isPinned)
                    const Icon(
                      Icons.push_pin,
                      color: AppTheme.primaryColor,
                      size: 20,
                    ),
                ],
              ),
              const SizedBox(height: AppConstants.smallPadding),
              // Content preview
              Text(
                note.content,
                style: AppTheme.bodyMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppConstants.smallPadding),
              // Footer with date and actions
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _formatDate(note.updatedAt),
                      style: AppTheme.bodySmall,
                    ),
                  ),
                  // Action buttons
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          note.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                          color: note.isPinned 
                              ? AppTheme.primaryColor 
                              : AppTheme.textSecondary,
                        ),
                        onPressed: onPin,
                        tooltip: note.isPinned ? 'Unpin' : 'Pin',
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: AppTheme.errorColor,
                        ),
                        onPressed: onDelete,
                        tooltip: 'Delete',
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
