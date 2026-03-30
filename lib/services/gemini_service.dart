import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:quranfiqh/services/settings_service.dart';

class GeminiService {
  static String get apiKey =>
      dotenv.env['GEMINI_API_KEY'] ??
      (throw Exception('GEMINI_API_KEY not set in .env'));

  static Future<Map<String, dynamic>> getAnswer(String userInput) async {
    final url = Uri.parse(
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-pro:generateContent?key=$apiKey",
    );

    final langName = _getLanguageName();
    final prompt =
        """
You are a highly accurate and strict Islamic scholar assistant.
CRITICAL: You MUST respond entirely in $langName, regardless of the language the user types in.

Rules:
- Give highly accurate rulings based exclusively on authentic, well-established classical sources.
- Follow ${_getMadhabName()} fiqh by default.
- If the user explicitly asks about another madhab (Hanafi, Maliki, or Hanbali), answer according to that specific madhab ONLY.
- Do NOT mention other madhabs unless explicitly asked.
- Do NOT mix madhabs in a single response.
${_getStylePrompt()}

Return response ONLY in this JSON format:
{
  "ruling": "...",
  "quran_arabic": "...",
  "quran_translation": "...",
  "quran_reference": "...",
  "hadith_arabic": "...",
  "hadith_translation": "...",
  "hadith_reference": "...",
  "explanation": "..."
}

Rules:
- Qur'an must be Arabic if available, else empty ""
- Qur'an Translation = Meaning in the user's language
- Hadith Arabic = Arabic text of the hadith if available, else empty ""
- Hadith Translation = Meaning in the user's language
- Hadith Reference = short reference only

If unsure:
{
  "ruling": "Consult a scholar",
  "quran_arabic": "",
  "quran_translation": "",
  "quran_reference": "",
  "hadith_arabic": "",
  "hadith_translation": "",
  "hadith_reference": "",
  "explanation": ""
}

Question: $userInput
""";

    try {
      // 🧩 Add Delay (Prevent Spam)
      await Future.delayed(const Duration(seconds: 2));

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": prompt},
              ],
            },
          ],
        }),
      );

      debugPrint("Gemini Status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates'][0]['content']['parts'][0]['text'];

        return jsonDecode(_cleanJson(text));
      } else if (response.statusCode == 429) {
        return {
          "ruling": "Server busy. Try again in a few seconds.",
          "quran_arabic": "",
          "quran_reference": "",
          "hadith": "",
          "explanation": "",
        };
      } else {
        debugPrint("Gemini Error Body: ${response.body}");
        return {
          "ruling": "Error: ${response.statusCode}",
          "quran_arabic": "",
          "quran_reference": "",
          "hadith": "",
          "explanation": "",
        };
      }
    } catch (e) {
      debugPrint("Gemini Exception: $e");
      return {
        "ruling": "Something went wrong.",
        "quran_arabic": "",
        "quran_translation": "",
        "quran_reference": "",
        "hadith_arabic": "",
        "hadith_translation": "",
        "hadith_reference": "",
        "explanation": ""
      };
    }
  }

  static Future<Map<String, dynamic>> getDailyContent() async {
    final url = Uri.parse(
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey",
    );

    final prompt = """
Generate daily Islamic content for a Home Page in JSON format.
Include:
1. Verse of the Day: Arabic text, English translation, and Surah name with verse number.
2. Daily Masa'la: A short title (question-like), a 1-sentence subtitle, and a 3-5 sentence detailed 'details' explanation.
3. Tajweed Tip: A short title (rule name), a 1-sentence subtitle, and a 3-5 sentence detailed 'details' explanation.
4. Daily Dhikr: A short title (dhikr text/name), a 1-sentence subtitle, and a 3-4 sentence detailed 'details' explanation.

Return response ONLY in this JSON format:
{
  "verse": {
    "arabic": "...",
    "translation": "...",
    "reference": "..."
  },
  "masala": {
    "title": "...",
    "subtitle": "...",
    "details": "..."
  },
  "tajweed": {
    "title": "...",
    "subtitle": "...",
    "details": "..."
  },
  "dhikr": {
    "title": "...",
    "subtitle": "...",
    "details": "..."
  }
}

Use authentic sources. Keep titles brief. The 'details' field should be educational and encouraging.
""";

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": prompt},
              ],
            },
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates'][0]['content']['parts'][0]['text'];
        return jsonDecode(_cleanJson(text));
      } else {
        throw Exception("Failed to fetch daily content: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Gemini Daily Content Error: $e");
      // Fallback with detailed descriptions
      return {
        "verse": {
          "arabic": "إِنَّ مَعَ الْعُسْرِ يُسْرًا",
          "translation": "Indeed, with hardship [will be] ease.",
          "reference": "Ash-Sharh 94:6"
        },
        "masala": {
          "title": "Importance of Intention (Niyyah)",
          "subtitle": "Actions are judged by intentions; always renew your niyyah before starting any worship.",
          "details": "According to the Shafi'i school, the intention (niyyah) is a pillar of every act of worship. It must be made in the heart at the time the act begins. For prayers, it occurs during the Takbiratul Ihram. For fasting, it is required each night for the following day's fast. Sincerity in intention ensures that the act is for Allah's sake alone."
        },
        "tajweed": {
          "title": "Mudd (Prolongation)",
          "subtitle": "Naturally prolong long vowels for two counts when not followed by hamzah or sukoon.",
          "details": "Al-Mudd Al-Tabi'i (Natural Prolongation) occurs when one of the three letters of Mudd—Alif, Wow, or Ya—is preceded by a compatible harakah (Fatha for Alif, Damma for Wow, and Kasra for Ya) and is not followed by a Hamzah or Sukoon. It is held for two counts (harakat), which is approximately the time take to fold or unfold a finger. Mastering this ensures the correct rhythm of the Qur'an."
        },
        "dhikr": {
          "title": "SubhanAllah wa Bihamdihi",
          "subtitle": "Glorify Allah and praise Him; a simple phrase with immense weight.",
          "details": "The Prophet ﷺ said that whoever says 'SubhanAllah wa Bihamdihi' 100 times a day, their sins will be forgiven even if they are like the foam of the sea. This dhikr is beloved to Ar-Rahman (The Most Merciful) and is light on the tongue but heavy on the scale of deeds. It combines glorifying Allah's perfection with praising His countless blessings."
        }
      };
    }
  }

  static String _getLanguageName() {
    final lang = SettingsService().language;
    switch (lang) {
      case AppLanguage.english:
        return "English";
      case AppLanguage.malayalam:
        return "Malayalam (മലയാളം)";
      case AppLanguage.arabic:
        return "Arabic (العربية)";
    }
  }

  static String _getMadhabName() {
    final m = SettingsService().madhab;
    switch (m) {
      case Madhab.shafii:
        return "Shafi‘i";
      case Madhab.hanafi:
        return "Hanafi";
      case Madhab.maliki:
        return "Maliki";
      case Madhab.hanbali:
        return "Hanbali";
    }
  }

  static String _getStylePrompt() {
    final style = SettingsService().answerStyle;
    switch (style) {
      case AnswerStyle.concise:
        return "COMMAND: You MUST be strictly CONCISE. Provide ONLY the ruling in exactly 1 direct sentence. Zero explanation or context is permitted.";
      case AnswerStyle.detailed:
        return "COMMAND: You MUST be DETAILED. Provide a clear ruling (2-3 lines) followed by a comprehensive explanation (3-4 lines) regarding context and conditions.";
      case AnswerStyle.scholarly:
        return "COMMAND: You MUST be SCHOLARLY and PROFOUND. Provide the ruling clearly, then provide a long, academic explanation (5-8 heavy lines) citing deep fiqh principles and analytical proofs.";
    }
  }

  static String _cleanJson(String text) {
    try {
      final start = text.indexOf('{');
      final end = text.lastIndexOf('}');
      if (start == -1 || end == -1) return text;
      return text.substring(start, end + 1);
    } catch (e) {
      return text;
    }
  }
}
