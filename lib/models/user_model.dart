import 'dart:convert';

class UserModel {
  final String name;
  final String email;
  final bool isGuest;
  final DateTime? createdAt;

  UserModel({
    required this.name,
    required this.email,
    this.isGuest = false,
    this.createdAt,
  });

  factory UserModel.guest() => UserModel(
        name: 'Guest User',
        email: 'guest@quranfiqh.local',
        isGuest: true,
        createdAt: DateTime.now(),
      );

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'isGuest': isGuest,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      isGuest: map['isGuest'] ?? false,
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) => UserModel.fromMap(json.decode(source));
}
