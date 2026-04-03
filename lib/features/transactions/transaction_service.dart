import 'package:cloud_firestore/cloud_firestore.dart';

import '../../shared/models/transaction_model.dart';
import 'finance_catalog.dart';
import 'transaction_history_models.dart';

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

  Stream<List<TransactionModel>> watchTransactionsInRange(
    String uid, {
    required DateTime start,
    required DateTime end,
  }) {
    return _userRef(uid)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThan: Timestamp.fromDate(end))
        .orderBy('date', descending: false)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map(TransactionModel.fromDocument).toList(),
        );
  }

  Future<TransactionHistoryPage> fetchTransactionPage(
    String uid, {
    required TransactionHistoryFilter filter,
    int limit = 24,
    DocumentSnapshot<Map<String, dynamic>>? startAfter,
  }) async {
    Query<Map<String, dynamic>> query = _userRef(uid);

    if (filter.type != TransactionHistoryFilter.allTypes) {
      query = query.where('type', isEqualTo: filter.type);
    }

    if (filter.usesServerWalletFilter) {
      final walletIds = filter.walletIds.toList(growable: false);
      if (walletIds.length == 1) {
        query = query.where('walletId', isEqualTo: walletIds.single);
      } else {
        query = query.where('walletId', whereIn: walletIds);
      }
    }

    if (filter.usesServerCategoryFilter) {
      final categoryIds = filter.categoryIds.toList(growable: false);
      if (categoryIds.length == 1) {
        query = query.where('categoryId', isEqualTo: categoryIds.single);
      } else {
        query = query.where('categoryId', whereIn: categoryIds);
      }
    }

    if (filter.startDate != null) {
      query = query.where(
        'date',
        isGreaterThanOrEqualTo: Timestamp.fromDate(
          DateTime(
            filter.startDate!.year,
            filter.startDate!.month,
            filter.startDate!.day,
          ),
        ),
      );
    }

    if (filter.endDate != null) {
      final exclusiveEnd = DateTime(
        filter.endDate!.year,
        filter.endDate!.month,
        filter.endDate!.day + 1,
      );
      query = query.where('date', isLessThan: Timestamp.fromDate(exclusiveEnd));
    }

    if (filter.sort == TransactionHistorySort.latest ||
        filter.sort == TransactionHistorySort.oldest) {
      query = query.orderBy('date', descending: filter.sort.descending);
    } else {
      query = query
          .orderBy('amount', descending: filter.sort.descending)
          .orderBy('date', descending: true);
    }

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    final snapshot = await query.limit(limit).get();
    final items = snapshot.docs.map(TransactionModel.fromDocument).toList();

    return TransactionHistoryPage(
      items: items,
      lastDocument: snapshot.docs.isEmpty ? null : snapshot.docs.last,
      hasMore: snapshot.docs.length == limit,
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
    final existingWalletIds = (await _walletsRef(
      uid,
    ).get()).docs.map((doc) => doc.id).toSet();
    final batch = _firestore.batch();

    for (var index = 0; index < FinanceCatalog.starterWallets.length; index++) {
      final walletTemplate = FinanceCatalog.starterWallets[index];
      if (existingWalletIds.contains(walletTemplate.id)) {
        continue;
      }
      final wallet = walletTemplate.toWalletModel(
        createdAt: DateTime.fromMillisecondsSinceEpoch(index * 1000),
      );
      batch.set(_walletsRef(uid).doc(wallet.id), wallet.toMap());
    }

    for (
      var index = 0;
      index < FinanceCatalog.defaultCategoryTemplates.length;
      index++
    ) {
      final template = FinanceCatalog.defaultCategoryTemplates[index];
      final category = template.toCategoryModel(
        isDefault: true,
        createdAt: DateTime.fromMillisecondsSinceEpoch(index * 1000),
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
