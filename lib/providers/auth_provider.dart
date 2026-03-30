import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:quranfiqh/services/firestore_service.dart';
import 'package:quranfiqh/models/user_model.dart';

// Firebase Auth Provider
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);

// Auth State Provider streams the current user
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
});

class AuthNotifier {
  final Ref ref;

  AuthNotifier(this.ref);

  Future<void> login(String email, String password) async {
    final cred = await ref.read(firebaseAuthProvider).signInWithEmailAndPassword(
          email: email,
          password: password,
        );
    if (cred.user != null) {
      await _syncUserToFirestore(cred.user!, isGuest: false);
    }
  }

  Future<void> register(String name, String email, String password) async {
    final cred = await ref.read(firebaseAuthProvider).createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
    if (cred.user != null) {
      // Set display name locally
      await cred.user!.updateDisplayName(name);
      await _syncUserToFirestore(cred.user!, overrideName: name, isGuest: false);
    }
  }

  Future<void> loginWithGoogle() async {
    // 1. Trigger the Google Authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    
    // Will be null if the user cancelled the sign-in flow
    if (googleUser == null) {
      throw Exception('Google Sign-In was cancelled by the user.');
    }

    // 2. Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    // 3. Create a new credential
    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // 4. Once signed in, return the UserCredential
    final cred = await ref.read(firebaseAuthProvider).signInWithCredential(credential);
    if (cred.user != null) {
      await _syncUserToFirestore(cred.user!, isGuest: false);
    }
  }

  Future<void> loginAsGuest() async {
    // We use Anonymous Sign In for the "Continue as Guest" feature
    final cred = await ref.read(firebaseAuthProvider).signInAnonymously();
    if (cred.user != null) {
      await _syncUserToFirestore(cred.user!, isGuest: true);
    }
  }

  Future<void> _syncUserToFirestore(User user, {String? overrideName, required bool isGuest}) async {
    final userModel = UserModel(
      name: overrideName ?? user.displayName ?? (isGuest ? 'Guest User' : 'Unknown User'),
      email: user.email ?? (isGuest ? 'guest@quranfiqh.local' : ''),
      isGuest: isGuest,
      createdAt: user.metadata.creationTime,
    );
    await FirestoreService.saveUser(user.uid, userModel);
  }

  Future<void> updateName(String newName) async {
    final user = ref.read(firebaseAuthProvider).currentUser;
    if (user != null) {
      await user.updateDisplayName(newName);
      await _syncUserToFirestore(user, overrideName: newName, isGuest: user.isAnonymous);
    }
  }

  Future<void> logout() async {
    await ref.read(firebaseAuthProvider).signOut();
  }
}

// Auth Notifier Provider exposes actions like login/logout
final authNotifierProvider = Provider<AuthNotifier>((ref) {
  return AuthNotifier(ref);
});
