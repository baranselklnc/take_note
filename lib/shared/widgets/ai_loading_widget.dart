import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AiLoadingWidget extends StatelessWidget {
  final String message;
  final double size;

  const AiLoadingWidget({
    super.key,
    required this.message,
    this.size = 100,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // AI Brain Animation
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.psychology,
              size: size * 0.5,
              color: Theme.of(context).primaryColor,
            ),
          ).animate(onPlay: (controller) => controller.repeat())
              .scale(duration: 1000.ms, curve: Curves.easeInOut)
              .then()
              .scale(duration: 1000.ms, curve: Curves.easeInOut, begin: const Offset(1.0, 1.0), end: const Offset(1.1, 1.1)),
          const SizedBox(height: 16),
          
          // Loading Text
          Text(
            message,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          
          // Loading Indicator
          SizedBox(
            width: 30,
            height: 30,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
