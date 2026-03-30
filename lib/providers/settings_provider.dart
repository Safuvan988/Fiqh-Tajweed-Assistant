import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quranfiqh/models/settings_model.dart';
import 'package:quranfiqh/services/settings_service.dart';
import 'package:quranfiqh/core/theme/app_theme.dart';

class SettingsNotifier extends Notifier<SettingsModel> {
  @override
  SettingsModel build() {
    // Initial state is loaded asynchronously in main,
    // but here we provide the current singleton values as a starting point.
    final service = SettingsService();

    // Update the static scale factor for AppTextStyles
    _updateStaticScale(service.fontSizeFactor);

    return SettingsModel(
      themeMode: service.themeMode,
      language: service.language,
      madhab: service.madhab,
      fontSizeFactor: service.fontSizeFactor,
      answerStyle: service.answerStyle,
    );
  }

  void _updateStaticScale(double factor) {
    // We'll add this static field to AppTextStyles to bridge static calls with Riverpod
    // AppTextStyles.scaleFactor = factor;
  }

  Future<void> setTheme(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await SettingsService().setTheme(mode);
  }

  Future<void> setLanguage(AppLanguage lang) async {
    state = state.copyWith(language: lang);
    await SettingsService().setLanguage(lang);
  }

  Future<void> setMadhab(Madhab m) async {
    state = state.copyWith(madhab: m);
    await SettingsService().setMadhab(m);
  }

  Future<void> setFontSize(double factor) async {
    state = state.copyWith(fontSizeFactor: factor);
    AppTextStyles.scaleFactor = factor;
    await SettingsService().setFontSize(factor);
  }

  Future<void> setAnswerStyle(AnswerStyle style) async {
    state = state.copyWith(answerStyle: style);
    await SettingsService().setAnswerStyle(style);
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, SettingsModel>(() {
  return SettingsNotifier();
});
