import 'package:cloud_firestore/cloud_firestore.dart';

import '../../shared/models/category_model.dart';
import '../../shared/models/transaction_model.dart';
import '../../shared/models/wallet_model.dart';
import 'finance_catalog.dart';

class TransactionService {
  TransactionService({required FirebaseFirestore firestore})
    : _firestore = firestore;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _userRef(String uid) {
    return _firestore.collection('users').doc(uid).collection('transactions');
  }

  CollectionReference<Map<String, dynamic>> _walletsRef(String uid) {
    return _firestore.collection('users').doc(uid).collection('wallets');
  }

  CollectionReference<Map<String, dynamic>> _categoriesRef(String uid) {
    return _firestore.collection('users').doc(uid).collection('categories');
  }

  Stream<List<TransactionModel>> watchRecentTransactions(
    String uid, {
    int limit = 10,
  }) {
    return _userRef(uid)
        .orderBy('date', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map(TransactionModel.fromDocument).toList(),
        );
  }

  Stream<List<TransactionModel>> watchTodayTransactions(String uid) {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));

    return _userRef(uid)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThan: Timestamp.fromDate(end))
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map(TransactionModel.fromDocument).toList(),
        );
  }

  Future<void> addTransaction(String uid, TransactionModel transaction) async {
    final walletRef = _walletsRef(uid).doc(transaction.walletId);
    final docRef = _userRef(uid).doc();
    final batch = _firestore.batch();

    batch.set(docRef, transaction.copyWith(id: docRef.id).toMap());
    batch.update(walletRef, <String, dynamic>{
      'balance': FieldValue.increment(_signedAmount(transaction)),
    });
    await batch.commit();
  }

  Future<void> updateTransaction(
    String uid, {
    required TransactionModel previous,
    required TransactionModel next,
  }) async {
    final batch = _firestore.batch();
    final docRef = _userRef(uid).doc(previous.id);

    if (previous.walletId == next.walletId) {
      final delta = _signedAmount(next) - _signedAmount(previous);
      batch.update(_walletsRef(uid).doc(previous.walletId), <String, dynamic>{
        'balance': FieldValue.increment(delta),
      });
    } else {
      batch.update(_walletsRef(uid).doc(previous.walletId), <String, dynamic>{
        'balance': FieldValue.increment(-_signedAmount(previous)),
      });
      batch.update(_walletsRef(uid).doc(next.walletId), <String, dynamic>{
        'balance': FieldValue.increment(_signedAmount(next)),
      });
    }

    batch.set(docRef, next.toMap());
    await batch.commit();
  }

  Future<void> deleteTransaction(
    String uid,
    TransactionModel transaction,
  ) async {
    final batch = _firestore.batch();
    batch.delete(_userRef(uid).doc(transaction.id));
    batch.update(_walletsRef(uid).doc(transaction.walletId), <String, dynamic>{
      'balance': FieldValue.increment(-_signedAmount(transaction)),
    });
    await batch.commit();
  }

  Future<void> ensureStarterData(String uid) async {
    final existingWallets = await _walletsRef(uid).limit(1).get();
    if (existingWallets.docs.isEmpty) {
      final wallet = WalletModel(
        id: 'wallet_cash',
        name: 'Cash',
        type: 'cash',
        balance: 0,
        iconKey: 'account_balance_wallet',
        colorValue: 0xFF3D6BE4,
        isDefault: true,
        createdAt: DateTime.fromMillisecondsSinceEpoch(0),
      );
      await _walletsRef(uid).doc(wallet.id).set(wallet.toMap());
    }

    final batch = _firestore.batch();
    for (final raw in FinanceCatalog.defaultCategories) {
      final category = CategoryModel(
        id: raw['id']! as String,
        name: raw['name']! as String,
        nameBn: raw['nameBn']! as String,
        iconKey: raw['iconKey']! as String,
        colorValue: raw['colorValue']! as int,
        type: raw['type']! as String,
        isDefault: true,
        createdAt: DateTime.fromMillisecondsSinceEpoch(0),
      );
      batch.set(
        _categoriesRef(uid).doc(category.id),
        category.toMap(),
        SetOptions(merge: true),
      );
    }
    await batch.commit();
  }

  double _signedAmount(TransactionModel transaction) {
    return transaction.type == FinanceCatalog.incomeType
        ? transaction.amount
        : -transaction.amount;
  }
}
