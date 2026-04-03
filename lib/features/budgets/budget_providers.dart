import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/models/budget_model.dart';
import '../../shared/models/category_model.dart';
import '../../shared/providers/firebase_providers.dart';
import '../transactions/transaction_providers.dart';
import 'budget_service.dart';

final budgetServiceProvider = Provider<BudgetService>((ref) {
  return BudgetService(firestore: ref.watch(firestoreProvider));
});

final budgetMonthProvider = NotifierProvider<BudgetMonthController, DateTime>(
  BudgetMonthController.new,
);

final currentMonthBudgetsProvider = StreamProvider<List<BudgetModel>>((ref) {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) {
    return Stream<List<BudgetModel>>.value(const <BudgetModel>[]);
  }

  final selectedMonth = ref.watch(budgetMonthProvider);
  return ref
      .watch(budgetServiceProvider)
      .watchBudgets(uid, month: selectedMonth.month, year: selectedMonth.year);
});

final budgetOverviewProvider = Provider<BudgetOverview>((ref) {
  final budgets =
      ref.watch(currentMonthBudgetsProvider).value ?? const <BudgetModel>[];
  final categories =
      ref.watch(allCategoriesProvider).asData?.value ?? const <CategoryModel>[];
  return _buildBudgetOverview(budgets, categories);
});

final dashboardMonthBudgetsProvider = StreamProvider<List<BudgetModel>>((ref) {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) {
    return Stream<List<BudgetModel>>.value(const <BudgetModel>[]);
  }

  final now = DateTime.now();
  return ref
      .watch(budgetServiceProvider)
      .watchBudgets(uid, month: now.month, year: now.year);
});

final dashboardBudgetOverviewProvider = Provider<BudgetOverview>((ref) {
  final budgets =
      ref.watch(dashboardMonthBudgetsProvider).value ?? const <BudgetModel>[];
  final categories =
      ref.watch(allCategoriesProvider).asData?.value ?? const <CategoryModel>[];
  return _buildBudgetOverview(budgets, categories);
});

BudgetOverview _buildBudgetOverview(
  List<BudgetModel> budgets,
  List<CategoryModel> categories,
) {
  final categoryMap = {
    for (final category in categories) category.id: category,
  };
  BudgetModel? overallBudget;
  double categoryLimitTotal = 0;
  double categorySpentTotal = 0;
  final categoryBudgets = <BudgetViewItem>[];

  for (final budget in budgets) {
    if (budget.isOverall) {
      overallBudget = budget;
      continue;
    }
    categoryLimitTotal += budget.limit;
    categorySpentTotal += budget.spent;
    categoryBudgets.add(
      BudgetViewItem(budget: budget, category: categoryMap[budget.categoryId]),
    );
  }

  categoryBudgets.sort(
    (a, b) => b.budget.progress.compareTo(a.budget.progress),
  );

  final nearLimitBudgets = categoryBudgets
      .where((item) => item.budget.progress >= 0.8 && item.budget.progress < 1)
      .toList(growable: false);
  final exceededBudgets = categoryBudgets
      .where((item) => item.budget.progress >= 1)
      .toList(growable: false);

  return BudgetOverview(
    overallBudget: overallBudget,
    categoryBudgets: categoryBudgets,
    totalCategoryLimit: categoryLimitTotal,
    totalCategorySpent: categorySpentTotal,
    nearLimitBudgets: nearLimitBudgets,
    exceededBudgets: exceededBudgets,
  );
}

final budgetActionControllerProvider =
    AsyncNotifierProvider<BudgetActionController, void>(
      BudgetActionController.new,
    );

class BudgetMonthController extends Notifier<DateTime> {
  @override
  DateTime build() {
    final now = DateTime.now();
    return DateTime(now.year, now.month);
  }

  void setMonth(DateTime value) {
    state = DateTime(value.year, value.month);
  }

  void moveBy(int delta) {
    state = DateTime(state.year, state.month + delta);
  }
}

class BudgetViewItem {
  const BudgetViewItem({required this.budget, required this.category});

  final BudgetModel budget;
  final CategoryModel? category;
}

class BudgetOverview {
  const BudgetOverview({
    required this.overallBudget,
    required this.categoryBudgets,
    required this.totalCategoryLimit,
    required this.totalCategorySpent,
    required this.nearLimitBudgets,
    required this.exceededBudgets,
  });

  final BudgetModel? overallBudget;
  final List<BudgetViewItem> categoryBudgets;
  final double totalCategoryLimit;
  final double totalCategorySpent;
  final List<BudgetViewItem> nearLimitBudgets;
  final List<BudgetViewItem> exceededBudgets;

  bool get hasWarnings =>
      nearLimitBudgets.isNotEmpty || exceededBudgets.isNotEmpty;
}

class BudgetActionController extends AsyncNotifier<void> {
  BudgetService get _service => ref.read(budgetServiceProvider);

  @override
  FutureOr<void> build() {}

  Future<BudgetModel> saveBudget(BudgetModel budget) async {
    final uid = _requireUserId();
    BudgetModel? savedBudget;
    state = const AsyncLoading<void>();
    state = await AsyncValue.guard(() async {
      savedBudget = await _service.saveBudget(uid, budget);
    });
    if (state.hasError) {
      throw state.error!;
    }
    return savedBudget!;
  }

  Future<void> deleteBudget(String budgetId) async {
    final uid = _requireUserId();
    state = const AsyncLoading<void>();
    state = await AsyncValue.guard(() => _service.deleteBudget(uid, budgetId));
    if (state.hasError) {
      throw state.error!;
    }
  }

  String _requireUserId() {
    final uid = ref.read(currentUserIdProvider);
    if (uid == null) {
      throw StateError('User is not signed in.');
    }
    return uid;
  }
}
