import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class GeminiService {
  static String get apiKey =>
      dotenv.env['GEMINI_API_KEY'] ??
      (throw Exception('GEMINI_API_KEY not set in .env'));

  static Future<Map<String, dynamic>> getAnswer(String userInput) async {
    final url = Uri.parse(
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$apiKey",
    );

    final prompt =
        """
You are a strict Islamic assistant. Respond in same language as user.

Rules:
- Follow Shafi‘i fiqh by default.
- If the user explicitly asks about another madhab (Hanafi, Maliki, or Hanbali), answer according to that specific madhab ONLY.
- Do NOT mention other madhabs unless explicitly asked.
- Do NOT mix madhabs in a single response.
- Keep answers short and clear.

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
- Ruling = 1 line
- Qur’an must be Arabic if available, else empty ""
- Qur’an Translation = Meaning in the user's language
- Hadith Arabic = Arabic text of the hadith if available, else empty ""
- Hadith Translation = Meaning in the user's language
- Hadith Reference = short reference only
- Explanation = 1–2 lines

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
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey",
    );

    final prompt = """
Generate daily Islamic content for a Home Page in JSON format.
Include:
1. Verse of the Day: Arabic text, English translation, and Surah name with verse number.
2. Daily Masa'la: A short title (question-like) and a 1-sentence ruling/explanation.
3. Tajweed Tip: A short title (rule name) and a 1-sentence simple explanation.

Return response ONLY in this JSON format:
{
  "verse": {
    "arabic": "...",
    "translation": "...",
    "reference": "..."
  },
  "masala": {
    "title": "...",
    "subtitle": "..."
  },
  "tajweed": {
    "title": "...",
    "subtitle": "..."
  }
}

Use authentic sources. Keep it brief and encouraging.
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
      // Fallback
      return {
        "verse": {
          "arabic": "إِنَّ مَعَ الْعُسْرِ يُسْرًا",
          "translation": "Indeed, with hardship [will be] ease.",
          "reference": "Ash-Sharh 94:6"
        },
        "masala": {
          "title": "Importance of Intention (Niyyah)",
          "subtitle": "Actions are judged by intentions; always renew your niyyah before starting any worship."
        },
        "tajweed": {
          "title": "Mudd (Prolongation)",
          "subtitle": "Naturally prolong long vowels for two counts when not followed by hamzah or sukoon."
        }
      };
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
