import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AnswerStyle { concise, detailed, scholarly }

enum AppLanguage { english, malayalam, arabic }

enum Madhab { shafii, hanafi, maliki, hanbali }

class SettingsService extends ChangeNotifier {
  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal();

  // Keys
  static const String _themeKey = 'theme_mode';
  static const String _langKey = 'app_language';
  static const String _madhabKey = 'app_madhab';
  static const String _fontSizeKey = 'font_size_factor';
  static const String _answerStyleKey = 'answer_style';

  // State
  ThemeMode _themeMode = ThemeMode.system;
  AppLanguage _language = AppLanguage.english;
  Madhab _madhab = Madhab.shafii;
  double _fontSizeFactor = 1.0;
  AnswerStyle _answerStyle = AnswerStyle.detailed;

  // Getters
  ThemeMode get themeMode => _themeMode;
  AppLanguage get language => _language;
  Madhab get madhab => _madhab;
  double get fontSizeFactor => _fontSizeFactor;
  AnswerStyle get answerStyle => _answerStyle;

  /// Initialize and load saved settings
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    
    _themeMode = ThemeMode.values[prefs.getInt(_themeKey) ?? ThemeMode.system.index];
    _language = AppLanguage.values[prefs.getInt(_langKey) ?? AppLanguage.english.index];
    _madhab = Madhab.values[prefs.getInt(_madhabKey) ?? Madhab.shafii.index];
    _fontSizeFactor = prefs.getDouble(_fontSizeKey) ?? 1.0;
    _answerStyle = AnswerStyle.values[prefs.getInt(_answerStyleKey) ?? AnswerStyle.detailed.index];
    
    notifyListeners();
  }

  // Setters with persistence
  Future<void> setTheme(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, mode.index);
    notifyListeners();
  }

  Future<void> setLanguage(AppLanguage lang) async {
    _language = lang;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_langKey, lang.index);
    notifyListeners();
  }

  Future<void> setMadhab(Madhab m) async {
    _madhab = m;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_madhabKey, m.index);
    notifyListeners();
  }

  Future<void> setFontSize(double factor) async {
    _fontSizeFactor = factor;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_fontSizeKey, factor);
    notifyListeners();
  }

  Future<void> setAnswerStyle(AnswerStyle style) async {
    _answerStyle = style;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_answerStyleKey, style.index);
    notifyListeners();
  }
}
