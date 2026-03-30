import 'package:cloud_firestore/cloud_firestore.dart';

class SessionModel {
  final String id;
  final String title;
  final String lastMessageSnippet;
  final DateTime lastUpdate;

  SessionModel({
    required this.id,
    required this.title,
    required this.lastMessageSnippet,
    required this.lastUpdate,
  });

  factory SessionModel.fromMap(Map<String, dynamic> map, String id) {
    return SessionModel(
      id: id,
      title: map['title'] ?? 'New Chat',
      lastMessageSnippet: map['lastMessageSnippet'] ?? '',
      lastUpdate: map['lastUpdate'] is Timestamp 
          ? (map['lastUpdate'] as Timestamp).toDate() 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'lastMessageSnippet': lastMessageSnippet,
      'lastUpdate': Timestamp.fromDate(lastUpdate),
    };
  }
}
