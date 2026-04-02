import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../core/constants/app_constants.dart';
import '../../shared/models/user_model.dart';

class AuthService {
  AuthService({
    required FirebaseAuth firebaseAuth,
    required FirebaseFirestore firestore,
    required GoogleSignIn googleSignIn,
  }) : _firebaseAuth = firebaseAuth,
       _firestore = firestore,
       _googleSignIn = googleSignIn;

  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  static bool _googleInitialized = false;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<UserCredential> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    await credential.user?.updateDisplayName(name.trim());
    await ensureUserDocument(
      firebaseUser: credential.user,
      preferredName: name.trim(),
    );

    return credential;
  }

  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    await ensureUserDocument(firebaseUser: credential.user);
    return credential;
  }

  Future<UserCredential> signInWithGoogle() async {
    if (kIsWeb) {
      final provider = GoogleAuthProvider();
      provider.setCustomParameters(<String, String>{
        'prompt': 'select_account',
      });

      final credential = await _firebaseAuth.signInWithPopup(provider);
      await ensureUserDocument(firebaseUser: credential.user);
      return credential;
    }

    await _initializeGoogleSignIn();
    final googleUser = await _googleSignIn.authenticate();
    final googleAuth = googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );
    final userCredential = await _firebaseAuth.signInWithCredential(credential);
    await ensureUserDocument(firebaseUser: userCredential.user);
    return userCredential;
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();

    if (!kIsWeb) {
      try {
        await _googleSignIn.disconnect();
      } catch (_) {
        await _googleSignIn.signOut();
      }
    }
  }

  Future<void> resetPassword(String email) {
    return _firebaseAuth.sendPasswordResetEmail(email: email.trim());
  }

  User? getCurrentUser() => _firebaseAuth.currentUser;

  Future<void> ensureUserDocument({
    required User? firebaseUser,
    String? preferredName,
  }) async {
    if (firebaseUser == null) {
      return;
    }

    final userRef = _firestore.collection('users').doc(firebaseUser.uid);
    final snapshot = await userRef.get();

    final name = preferredName?.trim().isNotEmpty == true
        ? preferredName!.trim()
        : (firebaseUser.displayName?.trim().isNotEmpty == true
              ? firebaseUser.displayName!.trim()
              : firebaseUser.email?.split('@').first ?? 'Money User');

    if (!snapshot.exists) {
      final userModel = UserModel(
        uid: firebaseUser.uid,
        name: name,
        email: firebaseUser.email ?? '',
        avatarUrl: firebaseUser.photoURL ?? '',
        currency: AppConstants.defaultCurrency,
        language: AppConstants.defaultLanguageCode,
        theme: AppConstants.sapphireDarkTheme,
        createdAt: DateTime.now(),
      );
      await userRef.set(userModel.toMap());
      return;
    }

    await userRef.set(<String, dynamic>{
      'uid': firebaseUser.uid,
      'name': snapshot.data()?['name'] ?? name,
      'email': firebaseUser.email ?? snapshot.data()?['email'] ?? '',
      'avatarUrl': firebaseUser.photoURL ?? snapshot.data()?['avatarUrl'] ?? '',
    }, SetOptions(merge: true));
  }

  Future<void> _initializeGoogleSignIn() async {
    if (_googleInitialized) {
      return;
    }

    await _googleSignIn.initialize(
      serverClientId: AppConstants.googleWebClientId,
    );
    _googleInitialized = true;
  }
}
