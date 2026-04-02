import 'package:cloud_firestore/cloud_firestore.dart';

import '../../shared/models/wallet_model.dart';

class WalletService {
  WalletService({required FirebaseFirestore firestore})
    : _firestore = firestore;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _walletsRef(String uid) {
    return _firestore.collection('users').doc(uid).collection('wallets');
  }

  Stream<List<WalletModel>> watchWallets(String uid) {
    return _walletsRef(uid)
        .orderBy('createdAt')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map(WalletModel.fromDocument).toList(),
        );
  }

  Future<List<WalletModel>> getWallets(String uid) async {
    final snapshot = await _walletsRef(uid).orderBy('createdAt').get();
    return snapshot.docs.map(WalletModel.fromDocument).toList();
  }
}
