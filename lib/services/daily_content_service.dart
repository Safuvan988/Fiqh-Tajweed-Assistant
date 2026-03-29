import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quranfiqh/services/gemini_service.dart';

class DailyContentService {
  static const String _keyContent = 'daily_content';
  static const String _keyDate = 'daily_content_date';

  static Future<Map<String, dynamic>> getDailyContent() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10); // YYYY-MM-DD
    final cachedDate = prefs.getString(_keyDate);

    if (cachedDate == today) {
      final cachedContent = prefs.getString(_keyContent);
      if (cachedContent != null) {
        try {
          return jsonDecode(cachedContent);
        } catch (e) {
          debugPrint("Error decoding cached daily content: $e");
        }
      }
    }

    // Fetch new content
    try {
      final newContent = await GeminiService.getDailyContent();
      await prefs.setString(_keyContent, jsonEncode(newContent));
      await prefs.setString(_keyDate, today);
      return newContent;
    } catch (e) {
      debugPrint("Error fetching new daily content: $e");
      // If error, return fallback from GeminiService or a static one
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
}
