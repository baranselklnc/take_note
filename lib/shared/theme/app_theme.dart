import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';

class AppTheme {
  // Color Palette - Soft Pastels
  static const Color primaryColor = Color(0xFF6366F1); // Indigo
  static const Color secondaryColor = Color(0xFF8B5CF6); // Purple
  static const Color accentColor = Color(0xFF06B6D4); // Cyan
  static const Color surfaceColor = Color(0xFFF8FAFC); // Light Gray
  static const Color cardColor = Color(0xFFFFFFFF); // White
  static const Color textPrimary = Color(0xFF1E293B); // Dark Gray
  static const Color textSecondary = Color(0xFF64748B); // Medium Gray
  static const Color successColor = Color(0xFF10B981); // Green
  static const Color warningColor = Color(0xFFF59E0B); // Amber
  static const Color errorColor = Color(0xFFEF4444); // Red

  static ThemeData get lightTheme {
    return FlexThemeData.light(
      scheme: FlexScheme.material,
      surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
      blendLevel: 7,
      appBarStyle: FlexAppBarStyle.background,
      appBarOpacity: 0.95,
      appBarElevation: 0,
      transparentStatusBar: true,
      tabBarStyle: FlexTabBarStyle.forAppBar,
      tooltipsMatchBackground: true,
      swapColors: false,
      lightIsWhite: false,
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
      fontFamily: GoogleFonts.inter().fontFamily,
    );
  }

  static ThemeData get darkTheme {
    return FlexThemeData.dark(
      scheme: FlexScheme.material,
      surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
      blendLevel: 13,
      appBarStyle: FlexAppBarStyle.background,
      appBarOpacity: 0.90,
      appBarElevation: 0,
      transparentStatusBar: true,
      tabBarStyle: FlexTabBarStyle.forAppBar,
      tooltipsMatchBackground: true,
      swapColors: false,
      darkIsTrueBlack: false,
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
      fontFamily: GoogleFonts.inter().fontFamily,
    );
  }
}