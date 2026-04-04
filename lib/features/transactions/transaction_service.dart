import 'package:cloud_firestore/cloud_firestore.dart';

import '../../shared/models/budget_model.dart';
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

  CollectionReference<Map<String, dynamic>> _budgetsRef(String uid) {
    return _firestore.collection('users').doc(uid).collection('budgets');
  }

  Stream<List<TransactionModel>> watchRecentTransactions(
    String uid, {
    int limit = 10,
  }) {
    return _userRef(
      uid,
    ).orderBy('date', descending: true).limit(limit).snapshots().map((
      snapshot,
    ) {
      final items = snapshot.docs.map(TransactionModel.fromDocument).toList();
      items.sort(_compareMostRecentFirst);
      return items;
    });
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
        .map((snapshot) {
          final items = snapshot.docs
              .map(TransactionModel.fromDocument)
              .toList();
          items.sort(_compareMostRecentFirst);
          return items;
        });
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

  Stream<List<TransactionModel>> watchWalletTransactions(
    String uid,
    String walletId, {
    int limit = 100,
  }) {
    return _userRef(uid)
        .where('walletId', isEqualTo: walletId)
        .orderBy('date', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
          final items = snapshot.docs
              .map(TransactionModel.fromDocument)
              .toList();
          items.sort(_compareMostRecentFirst);
          return items;
        });
  }

  Future<TransactionModel?> getTransaction(
    String uid,
    String transactionId,
  ) async {
    final snapshot = await _userRef(uid).doc(transactionId).get();
    if (!snapshot.exists) {
      return null;
    }
    return TransactionModel.fromDocument(snapshot);
  }

  Future<TransactionHistoryPage> fetchTransactionPage(
    String uid, {
    required TransactionHistoryFilter filter,
    int limit = 24,
    DocumentSnapshot<Map<String, dynamic>>? startAfter,
  }) async {
    Query<Map<String, dynamic>> query = _userRef(uid);
    final effectiveLimit = filter.categoryIds.isNotEmpty ? limit * 3 : limit;

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

    final snapshot = await query.limit(effectiveLimit).get();
    final items = snapshot.docs.map(TransactionModel.fromDocument).toList();
    if (filter.sort == TransactionHistorySort.latest ||
        filter.sort == TransactionHistorySort.oldest) {
      items.sort(
        filter.sort == TransactionHistorySort.latest
            ? _compareMostRecentFirst
            : _compareOldestFirst,
      );
    }

    return TransactionHistoryPage(
      items: items,
      lastDocument: snapshot.docs.isEmpty ? null : snapshot.docs.last,
      hasMore: snapshot.docs.length == effectiveLimit,
    );
  }

  Future<List<TransactionModel>> fetchTransactionsForExport(
    String uid, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    Query<Map<String, dynamic>> query = _userRef(uid);

    if (startDate != null) {
      query = query.where(
        'date',
        isGreaterThanOrEqualTo: Timestamp.fromDate(
          DateTime(startDate.year, startDate.month, startDate.day),
        ),
      );
    }

    if (endDate != null) {
      final exclusiveEnd = DateTime(
        endDate.year,
        endDate.month,
        endDate.day + 1,
      );
      query = query.where('date', isLessThan: Timestamp.fromDate(exclusiveEnd));
    }

    final snapshot = await query.orderBy('date', descending: false).get();
    return snapshot.docs
        .map(TransactionModel.fromDocument)
        .toList(growable: false);
  }

  Future<void> addTransaction(String uid, TransactionModel transaction) async {
    final batch = _firestore.batch();
    await stageAddTransaction(batch, uid, transaction);
    await batch.commit();
  }

  Future<TransactionModel> stageAddTransaction(
    WriteBatch batch,
    String uid,
    TransactionModel transaction, {
    String? documentId,
  }) async {
    final walletRef = _walletsRef(uid).doc(transaction.walletId);
    final docRef = _userRef(uid).doc(documentId);
    final nextTransaction = transaction.copyWith(id: docRef.id);

    batch.set(docRef, nextTransaction.toMap());
    batch.update(walletRef, <String, dynamic>{
      'balance': FieldValue.increment(_signedAmount(transaction)),
    });
    await _applyBudgetDelta(
      batch,
      uid,
      transaction: nextTransaction,
      deltaSign: 1,
    );
    return nextTransaction;
  }

  Future<void> updateTransaction(
    String uid, {
    required TransactionModel previous,
    required TransactionModel next,
  }) async {
    if (previous.isTransfer || next.isTransfer) {
      throw StateError(
        'Transfer entries should be updated from the transfer flow.',
      );
    }

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
    await _applyBudgetDelta(batch, uid, transaction: previous, deltaSign: -1);
    await _applyBudgetDelta(batch, uid, transaction: next, deltaSign: 1);
    await batch.commit();
  }

  Future<void> deleteTransaction(
    String uid,
    TransactionModel transaction,
  ) async {
    if (transaction.isTransfer && transaction.linkedTransactionId != null) {
      final linked = await getTransaction(
        uid,
        transaction.linkedTransactionId!,
      );
      if (linked != null) {
        final outgoing = transaction.type == FinanceCatalog.expenseType
            ? transaction
            : linked;
        final incoming = transaction.type == FinanceCatalog.incomeType
            ? transaction
            : linked;
        final batch = _firestore.batch();
        batch.delete(_userRef(uid).doc(outgoing.id));
        batch.delete(_userRef(uid).doc(incoming.id));
        batch.update(_walletsRef(uid).doc(outgoing.walletId), <String, dynamic>{
          'balance': FieldValue.increment(outgoing.amount),
        });
        batch.update(_walletsRef(uid).doc(incoming.walletId), <String, dynamic>{
          'balance': FieldValue.increment(-incoming.amount),
        });
        await batch.commit();
        return;
      }
    }

    final batch = _firestore.batch();
    batch.delete(_userRef(uid).doc(transaction.id));
    batch.update(_walletsRef(uid).doc(transaction.walletId), <String, dynamic>{
      'balance': FieldValue.increment(-_signedAmount(transaction)),
    });
    await _applyBudgetDelta(
      batch,
      uid,
      transaction: transaction,
      deltaSign: -1,
    );
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

  int _compareMostRecentFirst(TransactionModel a, TransactionModel b) {
    final dateCompare = b.date.compareTo(a.date);
    if (dateCompare != 0) {
      return dateCompare;
    }
    return b.createdAt.compareTo(a.createdAt);
  }

  int _compareOldestFirst(TransactionModel a, TransactionModel b) {
    final dateCompare = a.date.compareTo(b.date);
    if (dateCompare != 0) {
      return dateCompare;
    }
    return a.createdAt.compareTo(b.createdAt);
  }

  Future<void> _applyBudgetDelta(
    WriteBatch batch,
    String uid, {
    required TransactionModel transaction,
    required int deltaSign,
  }) async {
    if (transaction.isTransfer ||
        transaction.type != FinanceCatalog.expenseType) {
      return;
    }

    final splitItems = transaction.normalizedSplitItems;
    final categoryTotals = <String, double>{};
    for (final item in splitItems) {
      categoryTotals.update(
        item.categoryId,
        (value) => value + item.amount,
        ifAbsent: () => item.amount,
      );
    }

    for (final entry in categoryTotals.entries) {
      final budgetRef = _budgetsRef(uid).doc(
        _budgetDocumentId(
          categoryId: entry.key,
          year: transaction.date.year,
          month: transaction.date.month,
        ),
      );
      final snapshot = await budgetRef.get();
      if (snapshot.exists) {
        batch.update(budgetRef, <String, dynamic>{
          'spent': FieldValue.increment(entry.value * deltaSign),
        });
      }
    }

    final overallBudgetRef = _budgetsRef(uid).doc(
      _budgetDocumentId(
        categoryId: BudgetModel.overallCategoryId,
        year: transaction.date.year,
        month: transaction.date.month,
      ),
    );
    final overallSnapshot = await overallBudgetRef.get();
    if (overallSnapshot.exists) {
      batch.update(overallBudgetRef, <String, dynamic>{
        'spent': FieldValue.increment(transaction.amount * deltaSign),
      });
    }
  }

  String _budgetDocumentId({
    required String categoryId,
    required int year,
    required int month,
  }) {
    return '${categoryId}_${year}_${month.toString().padLeft(2, '0')}';
  }
}
