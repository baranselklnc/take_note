import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/storage/local_storage.dart';

class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier(this._localStorage) : super(ThemeMode.system) {
    _loadThemeMode();
  }

  final LocalStorage _localStorage;
  static const String _themeKey = 'theme_mode';

  Future<void> _loadThemeMode() async {
    try {
      final themeIndex = await _localStorage.getAppSetting<int>(_themeKey);
      if (themeIndex != null) {
        state = ThemeMode.values[themeIndex];
      }
    } catch (e) {
      // If there's an error, use system theme
      state = ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await _localStorage.saveAppSetting(_themeKey, mode.index);
    state = mode;
  }

  Future<void> toggleTheme() async {
    final newMode = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await setThemeMode(newMode);
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  final localStorage = ref.watch(localStorageProvider);
  return ThemeNotifier(localStorage);
});

