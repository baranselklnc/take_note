import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AiTagsDialog extends StatefulWidget {
  final List<String> tags;
  final Function(String tag)? onTagSelected;
  final VoidCallback? onClose;

  const AiTagsDialog({
    super.key,
    required this.tags,
    this.onTagSelected,
    this.onClose,
  });

  @override
  State<AiTagsDialog> createState() => _AiTagsDialogState();
}

class _AiTagsDialogState extends State<AiTagsDialog>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  final List<Color> _tagColors = [
    const Color(0xFF6366F1), // Indigo
    const Color(0xFF8B5CF6), // Purple
    const Color(0xFF06B6D4), // Cyan
    const Color(0xFF10B981), // Green
    const Color(0xFFF59E0B), // Amber
    const Color(0xFFEF4444), // Red
    const Color(0xFFEC4899), // Pink
    const Color(0xFF84CC16), // Lime
    const Color(0xFFF97316), // Orange
    const Color(0xFF8B5A2B), // Brown
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color _getTagColor(int index) {
    return _tagColors[index % _tagColors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withOpacity(0.2),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.psychology,
                      color: Theme.of(context).primaryColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI Oluşturulan Etiketler',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Notunuza eklemek için herhangi bir etikete dokunun',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: widget.onClose,
                    icon: Icon(
                      Icons.close_rounded,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: Theme.of(context).cardColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ).animate()
                .slideY(begin: -0.3, end: 0, curve: Curves.easeOutCubic)
                .fadeIn(duration: 400.ms),

            // Tags Content
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.tags.isEmpty)
                    _buildEmptyState()
                  else
                    _buildTagsGrid(),
                  
                  const SizedBox(height: 24),
                  
                  // Action Buttons
                  Row(
                    children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: widget.onClose,
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              side: BorderSide(
                                color: Theme.of(context).dividerColor.withOpacity(0.3),
                              ),
                            ),
                            child: const Text('Kapat'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              // Add all tags
                              for (final tag in widget.tags) {
                                widget.onTagSelected?.call(tag);
                              }
                              widget.onClose?.call();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            child: const Text('Tümünü Ekle'),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ).animate(delay: 200.ms)
                .slideY(begin: 0.3, end: 0, curve: Curves.easeOutCubic)
                .fadeIn(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.tag_faces_outlined,
            size: 64,
            color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
                        Text(
                          'Etiket oluşturulamadı',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'AI bu not için herhangi bir ilgili etiket oluşturamadı.',
                          style: Theme.of(context).textTheme.bodySmall,
                          textAlign: TextAlign.center,
                        ),
        ],
      ),
    );
  }

  Widget _buildTagsGrid() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: widget.tags.asMap().entries.map((entry) {
        final index = entry.key;
        final tag = entry.value;
        final color = _getTagColor(index);
        
        return _buildTagChip(tag, color, index);
      }).toList(),
    );
  }

  Widget _buildTagChip(String tag, Color color, int index) {
    return GestureDetector(
      onTap: () {
        widget.onTagSelected?.call(tag);
        // Show feedback
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added tag: $tag'),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              tag,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.add_circle_outline,
              color: color,
              size: 16,
            ),
          ],
        ),
      ),
    ).animate(delay: (index * 100).ms)
        .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.0, 1.0))
        .fadeIn(duration: 300.ms);
  }
}
