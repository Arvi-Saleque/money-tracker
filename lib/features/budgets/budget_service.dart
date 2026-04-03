import 'package:cloud_firestore/cloud_firestore.dart';

import '../../shared/models/budget_model.dart';
import '../transactions/finance_catalog.dart';

class BudgetService {
  BudgetService({required FirebaseFirestore firestore})
    : _firestore = firestore;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _budgetsRef(String uid) {
    return _firestore.collection('users').doc(uid).collection('budgets');
  }

  CollectionReference<Map<String, dynamic>> _transactionsRef(String uid) {
    return _firestore.collection('users').doc(uid).collection('transactions');
  }

  Stream<List<BudgetModel>> watchBudgets(
    String uid, {
    required int month,
    required int year,
  }) {
    return _budgetsRef(uid)
        .where('month', isEqualTo: month)
        .where('year', isEqualTo: year)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map(BudgetModel.fromDocument).toList()
                ..sort((a, b) {
                  if (a.isOverall == b.isOverall) {
                    return a.createdAt.compareTo(b.createdAt);
                  }
                  return a.isOverall ? -1 : 1;
                }),
        );
  }

  Future<List<BudgetModel>> getBudgets(
    String uid, {
    required int month,
    required int year,
  }) async {
    final snapshot = await _budgetsRef(
      uid,
    ).where('month', isEqualTo: month).where('year', isEqualTo: year).get();
    final items = snapshot.docs.map(BudgetModel.fromDocument).toList();
    items.sort((a, b) {
      if (a.isOverall == b.isOverall) {
        return a.createdAt.compareTo(b.createdAt);
      }
      return a.isOverall ? -1 : 1;
    });
    return items;
  }

  Future<BudgetModel> saveBudget(String uid, BudgetModel budget) async {
    final spent = await calculateSpent(
      uid,
      month: budget.month,
      year: budget.year,
      categoryId: budget.isOverall ? null : budget.categoryId,
    );
    final id = budget.id.trim().isEmpty
        ? _budgetDocumentId(
            categoryId: budget.categoryId,
            month: budget.month,
            year: budget.year,
          )
        : budget.id;
    final docRef = _budgetsRef(uid).doc(id);
    final nextBudget = budget.copyWith(id: id, spent: spent);

    await docRef.set(nextBudget.toMap(), SetOptions(merge: true));
    return nextBudget;
  }

  Future<void> deleteBudget(String uid, String budgetId) async {
    await _budgetsRef(uid).doc(budgetId).delete();
  }

  Future<double> calculateSpent(
    String uid, {
    required int month,
    required int year,
    String? categoryId,
  }) async {
    final start = DateTime(year, month);
    final end = DateTime(year, month + 1);
    final snapshot = await _transactionsRef(uid)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThan: Timestamp.fromDate(end))
        .get();

    var spent = 0.0;
    for (final doc in snapshot.docs) {
      final data = doc.data();
      final type = data['type'] as String? ?? '';
      final isTransfer = data['isTransfer'] as bool? ?? false;
      if (type != FinanceCatalog.expenseType || isTransfer) {
        continue;
      }

      final transactionCategoryId = data['categoryId'] as String? ?? '';
      if (categoryId != null && categoryId != transactionCategoryId) {
        continue;
      }

      spent += (data['amount'] as num?)?.toDouble() ?? 0;
    }
    return spent;
  }

  static String budgetDocumentId({
    required String categoryId,
    required int month,
    required int year,
  }) {
    return _budgetDocumentId(categoryId: categoryId, month: month, year: year);
  }

  static String _budgetDocumentId({
    required String categoryId,
    required int month,
    required int year,
  }) {
    return '${categoryId}_${year}_${month.toString().padLeft(2, '0')}';
  }
}
