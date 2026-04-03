import 'package:cloud_firestore/cloud_firestore.dart';

import '../../shared/models/goal_model.dart';
import '../../shared/models/transaction_model.dart';
import '../transactions/finance_catalog.dart';
import '../transactions/transaction_service.dart';

class GoalService {
  GoalService({
    required FirebaseFirestore firestore,
    required TransactionService transactionService,
  }) : _firestore = firestore,
       _transactionService = transactionService;

  final FirebaseFirestore _firestore;
  final TransactionService _transactionService;

  CollectionReference<Map<String, dynamic>> _goalsRef(String uid) {
    return _firestore.collection('users').doc(uid).collection('goals');
  }

  Stream<List<GoalModel>> watchGoals(String uid) {
    return _goalsRef(uid)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(GoalModel.fromDocument).toList());
  }

  Future<GoalModel> addGoal(String uid, GoalModel goal) async {
    final docRef = _goalsRef(uid).doc();
    final nextGoal = goal.copyWith(id: docRef.id);
    await docRef.set(nextGoal.toMap());
    return nextGoal;
  }

  Future<void> updateGoal(String uid, GoalModel goal) async {
    await _goalsRef(uid).doc(goal.id).set(goal.toMap());
  }

  Future<void> deleteGoal(String uid, String goalId) async {
    await _goalsRef(uid).doc(goalId).delete();
  }

  Future<GoalContributionResult> contributeToGoal(
    String uid, {
    required GoalModel goal,
    required double amount,
    required String walletId,
    required String note,
  }) async {
    final contributionDate = DateTime.now();
    final nextSavedAmount = goal.savedAmount + amount;
    final completed = nextSavedAmount >= goal.targetAmount;

    final transaction = TransactionModel(
      id: '',
      amount: amount,
      type: FinanceCatalog.expenseType,
      categoryId: FinanceCatalog.goalContributionCategoryId,
      walletId: walletId,
      isTransfer: false,
      note: note.trim().isEmpty
          ? 'Goal contribution: ${goal.name}'
          : 'Goal contribution: ${goal.name} - ${note.trim()}',
      date: contributionDate,
      createdAt: contributionDate,
    );

    final updatedGoal = goal.copyWith(
      savedAmount: nextSavedAmount,
      completedAt: completed ? contributionDate : null,
      clearCompletedAt: !completed,
    );

    final batch = _firestore.batch();
    await _transactionService.stageAddTransaction(batch, uid, transaction);
    batch.set(_goalsRef(uid).doc(goal.id), updatedGoal.toMap());
    await batch.commit();

    return GoalContributionResult(
      updatedGoal: updatedGoal,
      justCompleted: completed && !goal.isCompleted,
    );
  }
}

class GoalContributionResult {
  const GoalContributionResult({
    required this.updatedGoal,
    required this.justCompleted,
  });

  final GoalModel updatedGoal;
  final bool justCompleted;
}
