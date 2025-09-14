import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';

class AppTheme {
  // Light Theme Colors
  static const Color lightPrimary = Color(0xFF6366F1); // Indigo
  static const Color lightSecondary = Color(0xFF8B5CF6); // Purple
  static const Color lightAccent = Color(0xFF06B6D4); // Cyan
  static const Color lightSurface = Color(0xFFF8FAFC); // Light Gray
  static const Color lightCard = Color(0xFFFFFFFF); // White
  static const Color lightTextPrimary = Color(0xFF1E293B); // Dark Gray
  static const Color lightTextSecondary = Color(0xFF64748B); // Medium Gray
  static const Color lightSuccess = Color(0xFF10B981); // Green
  static const Color lightWarning = Color(0xFFF59E0B); // Amber
  static const Color lightError = Color(0xFFEF4444); // Red

  // Dark Theme Colors
  static const Color darkPrimary = Color(0xFF818CF8); // Light Indigo
  static const Color darkSecondary = Color(0xFFA78BFA); // Light Purple
  static const Color darkAccent = Color(0xFF22D3EE); // Light Cyan
  static const Color darkSurface = Color(0xFF0F172A); // Dark Blue Gray
  static const Color darkCard = Color(0xFF1E293B); // Dark Gray
  static const Color darkTextPrimary = Color(0xFFF1F5F9); // Light Gray
  static const Color darkTextSecondary = Color(0xFF94A3B8); // Medium Light Gray
  static const Color darkSuccess = Color(0xFF34D399); // Light Green
  static const Color darkWarning = Color(0xFFFBBF24); // Light Amber
  static const Color darkError = Color(0xFFF87171); // Light Red

  // Static getters for backward compatibility
  static Color get primaryColor => lightPrimary;
  static Color get errorColor => lightError;

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
    ).copyWith(
      colorScheme: const ColorScheme.light(
        primary: lightPrimary,
        secondary: lightSecondary,
        surface: lightSurface,
        background: lightSurface,
        error: lightError,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: lightTextPrimary,
        onBackground: lightTextPrimary,
        onError: Colors.white,
      ),
      cardColor: lightCard,
      scaffoldBackgroundColor: lightSurface,
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
    ).copyWith(
      colorScheme: const ColorScheme.dark(
        primary: darkPrimary,
        secondary: darkSecondary,
        surface: darkSurface,
        background: darkSurface,
        error: darkError,
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        onSurface: darkTextPrimary,
        onBackground: darkTextPrimary,
        onError: Colors.black,
      ),
      cardColor: darkCard,
      scaffoldBackgroundColor: darkSurface,
    );
  }
}