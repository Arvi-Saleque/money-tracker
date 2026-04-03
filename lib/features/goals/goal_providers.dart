import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/models/goal_model.dart';
import '../../shared/providers/firebase_providers.dart';
import '../auth/auth_providers.dart';
import '../transactions/transaction_providers.dart';
import 'goal_service.dart';

final goalServiceProvider = Provider<GoalService>((ref) {
  return GoalService(
    firestore: ref.watch(firestoreProvider),
    transactionService: ref.watch(transactionServiceProvider),
  );
});

final goalsProvider = StreamProvider<List<GoalModel>>((ref) {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) {
    return Stream<List<GoalModel>>.value(const <GoalModel>[]);
  }
  return ref.watch(goalServiceProvider).watchGoals(uid);
});

final activeGoalsProvider = Provider<List<GoalModel>>((ref) {
  final goals = ref.watch(goalsProvider).asData?.value ?? const <GoalModel>[];
  final active = goals
      .where((goal) => !goal.isCompleted)
      .toList(growable: false);
  active.sort((a, b) => a.targetDate.compareTo(b.targetDate));
  return active;
});

final completedGoalsProvider = Provider<List<GoalModel>>((ref) {
  final goals = ref.watch(goalsProvider).asData?.value ?? const <GoalModel>[];
  final completed = goals
      .where((goal) => goal.isCompleted)
      .toList(growable: false);
  completed.sort(
    (a, b) =>
        (b.completedAt ?? b.createdAt).compareTo(a.completedAt ?? a.createdAt),
  );
  return completed;
});

final topActiveGoalProvider = Provider<GoalModel?>((ref) {
  final active = ref.watch(activeGoalsProvider);
  if (active.isEmpty) {
    return null;
  }

  active.sort((a, b) {
    final progressCompare = b.progress.compareTo(a.progress);
    if (progressCompare != 0) {
      return progressCompare;
    }
    return a.targetDate.compareTo(b.targetDate);
  });
  return active.first;
});

final goalActionControllerProvider =
    AsyncNotifierProvider<GoalActionController, void>(GoalActionController.new);

class GoalActionController extends AsyncNotifier<void> {
  GoalService get _service => ref.read(goalServiceProvider);

  @override
  Future<void> build() async {}

  Future<void> addGoal(GoalModel goal) async {
    final uid = _requireUserId();
    state = const AsyncLoading<void>();
    state = await AsyncValue.guard(() => _service.addGoal(uid, goal));
    if (state.hasError) {
      throw state.error!;
    }
  }

  Future<void> updateGoal(GoalModel goal) async {
    final uid = _requireUserId();
    state = const AsyncLoading<void>();
    state = await AsyncValue.guard(() => _service.updateGoal(uid, goal));
    if (state.hasError) {
      throw state.error!;
    }
  }

  Future<void> deleteGoal(String goalId) async {
    final uid = _requireUserId();
    state = const AsyncLoading<void>();
    state = await AsyncValue.guard(() => _service.deleteGoal(uid, goalId));
    if (state.hasError) {
      throw state.error!;
    }
  }

  Future<GoalContributionResult> contributeToGoal({
    required GoalModel goal,
    required double amount,
    required String walletId,
    required String note,
  }) async {
    final uid = _requireUserId();
    state = const AsyncLoading<void>();
    GoalContributionResult? result;
    state = await AsyncValue.guard(() async {
      result = await _service.contributeToGoal(
        uid,
        goal: goal,
        amount: amount,
        walletId: walletId,
        note: note,
      );
    });
    if (state.hasError) {
      throw state.error!;
    }
    return result!;
  }

  String _requireUserId() {
    final uid = ref.read(authStateProvider).value?.uid;
    if (uid == null) {
      throw StateError('User is not signed in.');
    }
    return uid;
  }
}
