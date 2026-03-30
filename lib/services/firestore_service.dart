import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quranfiqh/models/user_model.dart';
import 'package:quranfiqh/models/chat_message.dart';
import 'package:quranfiqh/models/bookmark_model.dart';
import 'package:flutter/foundation.dart';

class FirestoreService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // -- USERS -- 
  static Future<void> saveUser(String userId, UserModel user) async {
    try {
      await _db.collection('users').doc(userId).set({
        ...user.toMap(),
        // Just in case createdAt wasn't parsed correctly by toMap logic
        'createdAt': user.createdAt != null 
            ? Timestamp.fromDate(user.createdAt!)
            : FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint("FirestoreService: Error saving user: \$e");
    }
  }

  static Future<UserModel?> getUser(String userId) async {
    try {
      final doc = await _db.collection('users').doc(userId).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        if (data['createdAt'] is Timestamp) {
            data['createdAt'] = (data['createdAt'] as Timestamp).toDate().toIso8601String();
        }
        return UserModel.fromMap(data);
      }
    } catch (e) {
      debugPrint("FirestoreService: Error getting user: \$e");
    }
    return null;
  }

  // -- SETTINGS --
  static Future<void> saveSettings(String userId, Map<String, dynamic> settings) async {
    try {
      await _db.collection('users').doc(userId).collection('settings').doc('preferences').set(settings, SetOptions(merge: true));
    } catch (e) {
      debugPrint("FirestoreService: Error saving settings: \$e");
    }
  }

  static Future<Map<String, dynamic>?> getSettings(String userId) async {
    try {
      final doc = await _db.collection('users').doc(userId).collection('settings').doc('preferences').get();
      if (doc.exists) {
        return doc.data();
      }
    } catch (e) {
      debugPrint("FirestoreService: Error getting settings: \$e");
    }
    return null;
  }

  // -- BOOKMARKS --
  static Future<void> saveBookmark(String userId, String question, String answer) async {
    try {
      final col = _db.collection('users').doc(userId).collection('bookmarks');
      await col.add({
        'question': question,
        'answer': answer,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint("FirestoreService: Error saving bookmark: \$e");
    }
  }

  static Future<List<BookmarkModel>> getBookmarks(String userId) async {
    try {
      final snapshot = await _db.collection('users').doc(userId).collection('bookmarks')
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs.map((doc) => BookmarkModel.fromMap(doc.data(), doc.id)).toList();
    } catch (e) {
      debugPrint("FirestoreService: Error getting bookmarks: \$e");
      return [];
    }
  }

  static Future<void> deleteBookmark(String userId, String bookmarkId) async {
    try {
      await _db.collection('users').doc(userId).collection('bookmarks').doc(bookmarkId).delete();
    } catch (e) {
      debugPrint("FirestoreService: Error deleting bookmark: \$e");
    }
  }

  // -- CHATS --
  static Future<void> saveChat(String userId, ChatMessage message) async {
    try {
      await _db.collection('users').doc(userId).collection('chats').add({
        ...message.toMap(),
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint("FirestoreService: Error saving chat: \$e");
    }
  }

  static Future<List<ChatMessage>> getChats(String userId) async {
    try {
      // get source cache first
      final snapshot = await _db.collection('users').doc(userId).collection('chats')
          .orderBy('timestamp', descending: false)
          .get(const GetOptions(source: Source.cache));
          
      if (snapshot.docs.isNotEmpty) {
           return snapshot.docs.map((doc) => ChatMessage.fromJson(doc.data())).toList();
      } else {
          final serverSnap = await _db.collection('users').doc(userId).collection('chats')
          .orderBy('timestamp', descending: false)
          .get(const GetOptions(source: Source.serverAndCache));
          return serverSnap.docs.map((doc) => ChatMessage.fromPersistedJson(doc.data())).toList();
      }
    } catch (e) {
      debugPrint("FirestoreService: Error getting chats: \$e");
      return [];
    }
  }

  static Future<void> clearChats(String userId) async {
    try {
      final snapshot = await _db.collection('users').doc(userId).collection('chats').get();
      WriteBatch batch = _db.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      debugPrint("FirestoreService: Error clearing chats: \$e");
    }
  }

  // -- SESSIONS (NEW) --
  static Future<void> updateSession(String userId, String sessionId, Map<String, dynamic> data) async {
    try {
      await _db.collection('users').doc(userId).collection('sessions').doc(sessionId).set({
        ...data,
        'lastUpdate': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint("FirestoreService: Error updating session: \$e");
    }
  }

  static Future<List<Map<String, dynamic>>> getSessions(String userId) async {
    try {
      final snap = await _db.collection('users').doc(userId).collection('sessions')
          .orderBy('lastUpdate', descending: true)
          .get();
      return snap.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList();
    } catch (e) {
      debugPrint("FirestoreService: Error getting sessions: \$e");
      return [];
    }
  }

  static Future<void> saveMessageToSession(String userId, String sessionId, ChatMessage message) async {
    try {
      await _db.collection('users').doc(userId)
          .collection('sessions').doc(sessionId)
          .collection('messages').add({
        ...message.toMap(),
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint("FirestoreService: Error saving message to session: \$e");
    }
  }

  static Future<List<ChatMessage>> getSessionMessages(String userId, String sessionId) async {
    try {
      final snap = await _db.collection('users').doc(userId)
          .collection('sessions').doc(sessionId)
          .collection('messages')
          .orderBy('timestamp', descending: false)
          .get();
      return snap.docs.map((doc) => ChatMessage.fromPersistedJson(doc.data())).toList();
    } catch (e) {
      debugPrint("FirestoreService: Error getting session messages: \$e");
      return [];
    }
  }

  static Future<void> deleteSession(String userId, String sessionId) async {
    try {
      // Subcollections are not deleted automatically in Firestore client SDK, 
      // but for simplicity we delete the session doc.
      // A cloud function would normally clean up the messages.
      await _db.collection('users').doc(userId).collection('sessions').doc(sessionId).delete();
    } catch (e) {
      debugPrint("FirestoreService: Error deleting session: \$e");
    }
  }
}
