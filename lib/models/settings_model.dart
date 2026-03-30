import 'package:flutter/material.dart';
import 'package:quranfiqh/services/settings_service.dart';

@immutable
class SettingsModel {
  final ThemeMode themeMode;
  final AppLanguage language;
  final Madhab madhab;
  final double fontSizeFactor;
  final AnswerStyle answerStyle;

  const SettingsModel({
    required this.themeMode,
    required this.language,
    required this.madhab,
    required this.fontSizeFactor,
    required this.answerStyle,
  });

  SettingsModel copyWith({
    ThemeMode? themeMode,
    AppLanguage? language,
    Madhab? madhab,
    double? fontSizeFactor,
    AnswerStyle? answerStyle,
  }) {
    return SettingsModel(
      themeMode: themeMode ?? this.themeMode,
      language: language ?? this.language,
      madhab: madhab ?? this.madhab,
      fontSizeFactor: fontSizeFactor ?? this.fontSizeFactor,
      answerStyle: answerStyle ?? this.answerStyle,
    );
  }
}
