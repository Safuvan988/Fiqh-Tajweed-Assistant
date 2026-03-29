enum MessageSender { user, bot }

enum AppLanguage { en, ml, ar }

class LocalizedContent {
  final String text;
  final String? ruling;
  final String? quranTranslation;
  final String? hadithTranslation;
  final String? fiqhExplanation;
  final String? otherViews;

  const LocalizedContent({
    required this.text,
    this.ruling,
    this.quranTranslation,
    this.hadithTranslation,
    this.fiqhExplanation,
    this.otherViews,
  });

  factory LocalizedContent.fromJson(Map<String, dynamic> json) {
    return LocalizedContent(
      text: json['text'] ?? '',
      ruling: json['ruling'],
      quranTranslation: json['quranTranslation'],
      hadithTranslation: json['hadithTranslation'],
      fiqhExplanation: json['fiqhExplanation'],
      otherViews: json['otherViews'],
    );
  }
}

class ChatMessage {
  final MessageSender sender;
  final String text;
  final Map<AppLanguage, LocalizedContent>? translations;
  AppLanguage currentLang;
  final String? quranArabic;
  final String? quranReference;
  final String? hadithArabic;
  final String? hadithReference;

  ChatMessage({
    required this.sender,
    required this.text,
    this.translations,
    this.currentLang = AppLanguage.en,
    this.quranArabic,
    this.quranReference,
    this.hadithArabic,
    this.hadithReference,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    // Detect masaala.json format (has 'id')
    final isMasaala = json.containsKey('id');

    if (isMasaala) {
      final questionMap = json['question'] as Map<String, dynamic>? ?? {};
      final answerMap = json['answer'] as Map<String, dynamic>? ?? {};
      final fiqhMap = json['fiqh'] as Map<String, dynamic>? ?? {};
      final quran = json['quran'] as Map<String, dynamic>?;

      final Map<AppLanguage, LocalizedContent> translations = {};
      for (var lang in AppLanguage.values) {
        final langKey = lang.name; // 'en', 'ml', 'ar'
        translations[lang] = LocalizedContent(
          text: answerMap[langKey]?.toString() ?? '',
          fiqhExplanation: fiqhMap[langKey]?.toString(),
        );
      }

      return ChatMessage(
        sender: MessageSender.bot,
        text: questionMap['en']?.toString() ?? '',
        translations: translations,
        currentLang: AppLanguage.en,
        quranArabic: quran?['arabic'],
        quranReference: quran?['reference'],
        hadithReference:
            json['hadith']?.toString() == '—' ? null : json['hadith']?.toString(),
      );
    }

    // Default structure for other JSON formats
    final translationsJson = json['translations'] as Map<String, dynamic>?;
    final Map<AppLanguage, LocalizedContent>? translations =
        translationsJson?.map(
      (key, value) {
        final lang = AppLanguage.values.firstWhere(
          (e) => e.name == key,
          orElse: () => AppLanguage.en,
        );
        return MapEntry(lang, LocalizedContent.fromJson(value));
      },
    );

    return ChatMessage(
      sender: MessageSender.bot,
      text: json['question']?.toString() ?? '',
      translations: translations,
      currentLang: AppLanguage.en,
      quranArabic: json['quranArabic'],
      quranReference: json['quranReference'],
      hadithArabic: json['hadithArabic'],
      hadithReference: json['hadithReference'],
    );
  }
}
