import 'package:quranfiqh/models/chat_message.dart';
import 'package:quranfiqh/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatHistoryService {
  static final ChatHistoryService _instance = ChatHistoryService._internal();
  factory ChatHistoryService() => _instance;
  ChatHistoryService._internal();

  Future<void> saveMessage(ChatMessage message) async {
    final user = FirebaseAuth.instance.currentUser;
    // Guests using anonymous sign-in will also have a UID and can save chats temporarily
    if (user == null) return;
    
    await FirestoreService.saveChat(user.uid, message);
  }

  Future<List<ChatMessage>> getHistory() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    return await FirestoreService.getChats(user.uid);
  }

  Future<void> clearHistory() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirestoreService.clearChats(user.uid);
  }

  // -- SESSIONS (NEW) --
  Future<void> saveToSession(String sessionId, ChatMessage message, String title) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirestoreService.saveMessageToSession(user.uid, sessionId, message);
    await FirestoreService.updateSession(user.uid, sessionId, {
      'title': title,
      'lastMessageSnippet': message.text.length > 50 
          ? '${message.text.substring(0, 47)}...' 
          : message.text,
    });
  }

  Future<List<Map<String, dynamic>>> getSessions() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];
    return await FirestoreService.getSessions(user.uid);
  }

  Future<List<ChatMessage>> getSessionMessages(String sessionId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];
    return await FirestoreService.getSessionMessages(user.uid, sessionId);
  }

  Future<void> deleteSession(String sessionId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await FirestoreService.deleteSession(user.uid, sessionId);
  }
}
