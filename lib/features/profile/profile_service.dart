import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import '../../shared/models/user_model.dart';

class ProfileService {
  ProfileService({
    required FirebaseFirestore firestore,
    required FirebaseStorage storage,
  }) : _firestore = firestore,
       _storage = storage;

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  Stream<UserModel?> watchUserProfile(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((snapshot) {
      if (!snapshot.exists) {
        return null;
      }

      return UserModel.fromDocument(snapshot);
    });
  }

  Future<UserModel?> getUserProfile(String uid) async {
    final snapshot = await _firestore.collection('users').doc(uid).get();
    if (!snapshot.exists) {
      return null;
    }

    return UserModel.fromDocument(snapshot);
  }

  Future<void> updateUserProfile(UserModel profile) async {
    await _firestore.collection('users').doc(profile.uid).set(<String, dynamic>{
      'name': profile.name,
      'email': profile.email,
      'avatarUrl': profile.avatarUrl,
      'currency': profile.currency,
      'language': profile.language,
      'theme': profile.theme,
    }, SetOptions(merge: true));
  }

  Future<String> uploadAvatar({
    required String uid,
    required XFile file,
  }) async {
    final ref = _storage.ref().child('users/$uid/avatar.jpg');

    if (kIsWeb) {
      final bytes = await file.readAsBytes();
      await ref.putData(bytes);
    } else {
      await ref.putFile(File(file.path));
    }

    return ref.getDownloadURL();
  }
}
