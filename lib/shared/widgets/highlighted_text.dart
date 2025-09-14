import 'package:flutter/material.dart';

/// Widget that highlights search terms in text and shows context around matches
class HighlightedText extends StatelessWidget {
  final String text;
  final String searchQuery;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextAlign? textAlign;

  const HighlightedText({
    super.key,
    required this.text,
    required this.searchQuery,
    this.style,
    this.maxLines,
    this.overflow,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    if (searchQuery.isEmpty) {
      return Text(
        text,
        style: style,
        maxLines: maxLines,
        overflow: overflow,
        textAlign: textAlign,
      );
    }

    final lowerText = text.toLowerCase();
    final lowerQuery = searchQuery.toLowerCase();

    if (!lowerText.contains(lowerQuery)) {
      return Text(
        text,
        style: style,
        maxLines: maxLines,
        overflow: overflow,
        textAlign: textAlign,
      );
    }

    // Find the first match and create context around it
    final firstMatchIndex = lowerText.indexOf(lowerQuery);
    if (firstMatchIndex == -1) {
      return Text(
        text,
        style: style,
        maxLines: maxLines,
        overflow: overflow,
        textAlign: textAlign,
      );
    }

    // Always show the full text with highlighting for now
    // This ensures the search term is always visible
    return _buildHighlightedText(text, lowerQuery, style);
  }

  Widget _buildHighlightedText(String textToHighlight, String lowerQuery, TextStyle? baseStyle) {
    final List<TextSpan> spans = [];
    int start = 0;
    
    while (start < textToHighlight.length) {
      final index = textToHighlight.toLowerCase().indexOf(lowerQuery, start);
      
      if (index == -1) {
        // No more matches, add remaining text
        spans.add(TextSpan(
          text: textToHighlight.substring(start),
          style: baseStyle,
        ));
        break;
      }
      
      // Add text before match
      if (index > start) {
        spans.add(TextSpan(
          text: textToHighlight.substring(start, index),
          style: baseStyle,
        ));
      }
      
      // Add highlighted match
      spans.add(TextSpan(
        text: textToHighlight.substring(index, index + searchQuery.length),
        style: (baseStyle ?? const TextStyle()).copyWith(
          backgroundColor: Colors.yellow.withOpacity(0.5),
          fontWeight: FontWeight.w700,
          color: Colors.black,
        ),
      ));
      
      start = index + searchQuery.length;
    }

    return RichText(
      text: TextSpan(children: spans),
      maxLines: maxLines,
      overflow: overflow ?? TextOverflow.ellipsis,
      textAlign: textAlign ?? TextAlign.start,
    );
  }
}
