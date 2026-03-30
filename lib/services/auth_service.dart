import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quranfiqh/models/user_model.dart';
import 'package:quranfiqh/services/firestore_service.dart';

enum AuthStatus { authenticated, guest, unauthenticated }

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final ValueNotifier<UserModel?> currentUser = ValueNotifier<UserModel?>(null);
  final ValueNotifier<AuthStatus> status = ValueNotifier<AuthStatus>(AuthStatus.unauthenticated);

  static Future<void> init() async {
    // Listen to Firebase Auth state changes globally
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      if (user == null) {
        AuthService().currentUser.value = null;
        AuthService().status.value = AuthStatus.unauthenticated;
      } else {
        // Fetch from Firestore
        UserModel? userModel = await FirestoreService.getUser(user.uid);
        if (userModel != null) {
          AuthService().currentUser.value = userModel;
          AuthService().status.value = userModel.isGuest ? AuthStatus.guest : AuthStatus.authenticated;
        } else {
          // If no model exists yet (e.g. during sign up flow creation delay), 
          // we can rely on basic Firebase data.
          bool isGuest = user.isAnonymous;
          UserModel fallbackModel = UserModel(
            name: user.displayName ?? (isGuest ? 'Guest User' : 'Unknown'),
            email: user.email ?? (isGuest ? 'guest@quranfiqh.local' : ''),
            isGuest: isGuest,
          );
          AuthService().currentUser.value = fallbackModel;
          AuthService().status.value = isGuest ? AuthStatus.guest : AuthStatus.authenticated;
        }
      }
    });

    // Also initialize value right away if already logged in
    final User? initialUser = FirebaseAuth.instance.currentUser;
    if (initialUser != null) {
       UserModel? userModel = await FirestoreService.getUser(initialUser.uid);
       if (userModel != null) {
          AuthService().currentUser.value = userModel;
          AuthService().status.value = userModel.isGuest ? AuthStatus.guest : AuthStatus.authenticated;
       } else {
          bool isGuest = initialUser.isAnonymous;
          AuthService().currentUser.value = UserModel(
             name: initialUser.displayName ?? (isGuest ? 'Guest User' : 'Unknown'),
             email: initialUser.email ?? (isGuest ? 'guest@quranfiqh.local' : ''),
             isGuest: isGuest,
          );
          AuthService().status.value = isGuest ? AuthStatus.guest : AuthStatus.authenticated;
       }
    }
  }

  // Deprecated direct calls from AuthService, they are now handled by Riverpod AuthNotifier
  Future<bool> login(String email, String password) async {
    throw UnimplementedError('Use AuthNotifier via Riverpod');
  }

  Future<bool> register(String name, String email, String password) async {
     throw UnimplementedError('Use AuthNotifier via Riverpod');
  }

  Future<void> loginAsGuest() async {
     throw UnimplementedError('Use AuthNotifier via Riverpod');
  }

  Future<void> logout() async {
     throw UnimplementedError('Use AuthNotifier via Riverpod');
  }
}
