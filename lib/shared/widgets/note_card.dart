import 'package:flutter/material.dart';
import '../../models/note.dart';
import 'highlighted_text.dart';

class NoteCard extends StatelessWidget {
  final Note note;
  final String? searchQuery;
  final VoidCallback? onTap;
  final VoidCallback? onPin;
  final VoidCallback? onDelete;
  final VoidCallback? onSummarize;
  final VoidCallback? onAutoTag;

  const NoteCard({
    super.key,
    required this.note,
    this.searchQuery,
    this.onTap,
    this.onPin,
    this.onDelete,
    this.onSummarize,
    this.onAutoTag,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with title and pin
                Row(
                  children: [
                    Expanded(
                      child: HighlightedText(
                        text: note.title,
                        searchQuery: searchQuery ?? '',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (note.isPinned)
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.push_pin,
                          color: Colors.orange,
                          size: 16,
                        ),
                      ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Content preview
                HighlightedText(
                  text: note.content,
                  searchQuery: searchQuery ?? '',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                  maxLines: searchQuery?.isNotEmpty == true ? 5 : 3,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 16),
                
                // Footer with date and actions
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatDate(note.updatedAt),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        // AI Actions - only for backend notes (UUID format)
                        if (_isBackendNote(note.id)) ...[
                          _buildActionButton(
                            context,
                            icon: Icons.auto_awesome_outlined,
                            onPressed: onSummarize,
                            tooltip: 'Summarize',
                          ),
                          _buildActionButton(
                            context,
                            icon: Icons.label_outline,
                            onPressed: onAutoTag,
                            tooltip: 'Auto Tag',
                          ),
                        ],
                        _buildActionButton(
                          context,
                          icon: note.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                          onPressed: onPin,
                          tooltip: note.isPinned ? 'Unpin' : 'Pin',
                          color: note.isPinned ? Colors.orange : null,
                        ),
                        _buildActionButton(
                          context,
                          icon: Icons.delete_outline,
                          onPressed: onDelete,
                          tooltip: 'Delete',
                          color: Colors.red,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback? onPressed,
    required String tooltip,
    Color? color,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (color ?? Theme.of(context).primaryColor).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 18,
              color: color ?? Theme.of(context).primaryColor,
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} g önce';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} s önce';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} dk önce';
    } else {
      return 'Az önce';
    }
  }

  /// Check if note ID is UUID format (backend note)
  bool _isBackendNote(String id) {
    final uuidRegex = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
      caseSensitive: false,
    );
    return uuidRegex.hasMatch(id);
  }
}