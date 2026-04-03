import 'package:cloud_firestore/cloud_firestore.dart';

import '../../shared/models/debt_record_model.dart';

class DebtService {
  DebtService({required FirebaseFirestore firestore}) : _firestore = firestore;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _debtsRef(String uid) {
    return _firestore.collection('users').doc(uid).collection('debts');
  }

  Stream<List<DebtRecordModel>> watchDebts(String uid) {
    return _debtsRef(uid)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map(DebtRecordModel.fromDocument).toList(),
        );
  }

  Future<DebtRecordModel> saveDebt(String uid, DebtRecordModel debt) async {
    final now = DateTime.now();
    final id = debt.id.trim().isEmpty ? _debtsRef(uid).doc().id : debt.id;
    final nextDebt = debt.copyWith(
      id: id,
      updatedAt: now,
      closedAt: debt.remainingAmount <= 0 ? (debt.closedAt ?? now) : null,
      clearClosedAt: debt.remainingAmount > 0,
    );

    await _debtsRef(uid).doc(id).set(nextDebt.toMap(), SetOptions(merge: true));
    return nextDebt;
  }

  Future<void> deleteDebt(String uid, String debtId) async {
    await _debtsRef(uid).doc(debtId).delete();
  }

  Future<DebtRecordModel> addPayment(
    String uid, {
    required String debtId,
    required double amount,
    required DateTime date,
    required String note,
  }) async {
    final docRef = _debtsRef(uid).doc(debtId);

    return _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) {
        throw StateError('Debt record was not found.');
      }

      final debt = DebtRecordModel.fromDocument(snapshot);
      if (amount <= 0) {
        throw StateError('Payment amount must be greater than zero.');
      }
      if (amount - debt.remainingAmount > 0.009) {
        throw StateError('Payment exceeds the remaining amount.');
      }

      final now = DateTime.now();
      final payment = DebtPaymentModel(
        id: now.microsecondsSinceEpoch.toString(),
        amount: amount,
        date: date,
        note: note.trim(),
        createdAt: now,
      );
      final nextPaidAmount = debt.paidAmount + amount;
      final nextPayments = <DebtPaymentModel>[payment, ...debt.payments]
        ..sort((a, b) => b.date.compareTo(a.date));
      final nextDebt = debt.copyWith(
        paidAmount: nextPaidAmount,
        payments: nextPayments,
        updatedAt: now,
        closedAt: nextPaidAmount >= debt.totalAmount
            ? (debt.closedAt ?? now)
            : null,
        clearClosedAt: nextPaidAmount < debt.totalAmount,
      );

      transaction.set(docRef, nextDebt.toMap());
      return nextDebt;
    });
  }
}
