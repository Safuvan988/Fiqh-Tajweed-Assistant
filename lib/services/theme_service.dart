import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  ThemeService._();
  
  static const String _themeKey = 'theme_mode';
  
  /// Global notifier for theme mode changes
  static final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

  /// Load the saved theme from SharedPreferences
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(_themeKey) ?? 1; // Default to Light (1)
    themeNotifier.value = ThemeMode.values[themeIndex];
  }

  /// Update the theme and persist the choice
  static Future<void> setTheme(ThemeMode mode) async {
    themeNotifier.value = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, mode.index);
  }
}
