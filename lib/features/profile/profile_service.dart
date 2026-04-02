import 'package:cloud_firestore/cloud_firestore.dart';

import '../../shared/models/user_model.dart';

class ProfileService {
  ProfileService({required FirebaseFirestore firestore})
    : _firestore = firestore;

  final FirebaseFirestore _firestore;

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
}
