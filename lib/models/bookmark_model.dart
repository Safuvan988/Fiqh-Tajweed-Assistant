import 'package:cloud_firestore/cloud_firestore.dart';

class BookmarkModel {
  final String id;
  final String question;
  final String answer;
  final DateTime createdAt;

  BookmarkModel({
    required this.id,
    required this.question,
    required this.answer,
    required this.createdAt,
  });

  factory BookmarkModel.fromMap(Map<String, dynamic> map, String docId) {
    return BookmarkModel(
      id: docId,
      question: map['question'] ?? '',
      answer: map['answer'] ?? '',
      createdAt: map['createdAt'] != null 
          ? (map['createdAt'] as Timestamp).toDate() 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'question': question,
      'answer': answer,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
