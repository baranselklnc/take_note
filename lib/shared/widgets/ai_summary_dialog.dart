import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AiSummaryDialog extends StatefulWidget {
  final String summary;
  final String originalTitle;
  final int originalLength;
  final int summaryLength;
  final double compressionRatio;

  const AiSummaryDialog({
    super.key,
    required this.summary,
    required this.originalTitle,
    required this.originalLength,
    required this.summaryLength,
    required this.compressionRatio,
  });

  @override
  State<AiSummaryDialog> createState() => _AiSummaryDialogState();
}

class _AiSummaryDialogState extends State<AiSummaryDialog>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isCopied = false;

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

  /// Calculate the correct compression ratio
  double _calculateCompressionRatio() {
    if (widget.originalLength == 0) return 0.0;
    
    // Compression ratio = (original - summary) / original * 100
    final compression = (widget.originalLength - widget.summaryLength) / widget.originalLength * 100;
    return compression;
  }

  Future<void> _copyToClipboard() async {
    await Clipboard.setData(ClipboardData(text: widget.summary));
    setState(() {
      _isCopied = true;
    });
    
    // Reset copied state after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isCopied = false;
        });
      }
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text('Özet panoya kopyalandı'),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.9,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
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
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor.withOpacity(0.1),
                    Theme.of(context).primaryColor.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
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
                      Icons.auto_awesome,
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
                          'AI Özet',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '"${widget.originalTitle}"',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).textTheme.bodySmall?.color,
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
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

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Summary Stats
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Theme.of(context).primaryColor.withOpacity(0.1),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildStatItem(
                              'Orijinal',
                              '${widget.originalLength} karakter',
                              Icons.description_outlined,
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: Theme.of(context).dividerColor.withOpacity(0.3),
                          ),
                          Expanded(
                            child: _buildStatItem(
                              'Özet',
                              '${widget.summaryLength} karakter',
                              Icons.compress,
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: Theme.of(context).dividerColor.withOpacity(0.3),
                          ),
                          Expanded(
                            child: _buildStatItem(
                              'Sıkıştırma',
                              '${_calculateCompressionRatio().toStringAsFixed(1)}%',
                              Icons.trending_down,
                            ),
                          ),
                        ],
                      ),
                    ).animate(delay: 200.ms)
                        .slideY(begin: 0.3, end: 0, curve: Curves.easeOutCubic)
                        .fadeIn(),

                    const SizedBox(height: 20),

                    // Summary Text
                    Text(
                      'Özet',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ).animate(delay: 300.ms)
                        .slideY(begin: 0.3, end: 0, curve: Curves.easeOutCubic)
                        .fadeIn(),

                    const SizedBox(height: 12),

                    // Summary Content
                    Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(maxHeight: 200),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Theme.of(context).dividerColor.withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Copy button header
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withOpacity(0.05),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.auto_awesome,
                                  color: Theme.of(context).primaryColor,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'AI Özet',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const Spacer(),
                                GestureDetector(
                                  onTap: _copyToClipboard,
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: _isCopied 
                                          ? Colors.green.withOpacity(0.1)
                                          : Theme.of(context).primaryColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: _isCopied 
                                            ? Colors.green.withOpacity(0.3)
                                            : Theme.of(context).primaryColor.withOpacity(0.3),
                                      ),
                                    ),
                                    child: Icon(
                                      _isCopied ? Icons.check : Icons.copy,
                                      color: _isCopied 
                                          ? Colors.green
                                          : Theme.of(context).primaryColor,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Scrollable summary text
                          Expanded(
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                widget.summary,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  height: 1.6,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ).animate(delay: 400.ms)
                        .slideY(begin: 0.3, end: 0, curve: Curves.easeOutCubic)
                        .fadeIn(),

                    const SizedBox(height: 24),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _copyToClipboard,
                            icon: Icon(
                              _isCopied ? Icons.check : Icons.copy,
                              size: 16,
                            ),
                            label: Text(
                              _isCopied ? 'Kopyalandı' : 'Kopyala',
                              style: const TextStyle(fontSize: 14),
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              side: BorderSide(
                                color: _isCopied 
                                    ? Colors.green
                                    : Theme.of(context).primaryColor,
                              ),
                              foregroundColor: _isCopied 
                                  ? Colors.green
                                  : Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.close, size: 16),
                            label: const Text(
                              'Kapat',
                              style: TextStyle(fontSize: 14),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),
                      ],
                    ).animate(delay: 500.ms)
                        .slideY(begin: 0.3, end: 0, curve: Curves.easeOutCubic)
                        .fadeIn(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: Theme.of(context).primaryColor,
          size: 20,
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).textTheme.bodySmall?.color,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
