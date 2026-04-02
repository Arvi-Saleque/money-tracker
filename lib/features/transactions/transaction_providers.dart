import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/models/category_model.dart';
import '../../shared/models/transaction_model.dart';
import '../../shared/models/wallet_model.dart';
import '../auth/auth_providers.dart';
import 'category_service.dart';
import 'finance_catalog.dart';
import 'transaction_service.dart';
import 'wallet_service.dart';
import '../../shared/providers/firebase_providers.dart';

final transactionServiceProvider = Provider<TransactionService>((ref) {
  return TransactionService(firestore: ref.watch(firestoreProvider));
});

final categoryServiceProvider = Provider<CategoryService>((ref) {
  return CategoryService(firestore: ref.watch(firestoreProvider));
});

final walletServiceProvider = Provider<WalletService>((ref) {
  return WalletService(firestore: ref.watch(firestoreProvider));
});

final currentUserIdProvider = Provider<String?>((ref) {
  return ref.watch(authStateProvider).value?.uid;
});

final walletsProvider = StreamProvider<List<WalletModel>>((ref) {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) {
    return Stream<List<WalletModel>>.value(const <WalletModel>[]);
  }
  return ref.watch(walletServiceProvider).watchWallets(uid);
});

final categoriesByTypeProvider =
    StreamProvider.family<List<CategoryModel>, String>((ref, type) {
      final uid = ref.watch(currentUserIdProvider);
      if (uid == null) {
        return Stream<List<CategoryModel>>.value(const <CategoryModel>[]);
      }

      return ref
          .watch(categoryServiceProvider)
          .watchCategories(uid, type: type);
    });

final allCategoriesProvider = StreamProvider<List<CategoryModel>>((ref) {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) {
    return Stream<List<CategoryModel>>.value(const <CategoryModel>[]);
  }

  return ref.watch(categoryServiceProvider).watchCategories(uid);
});

final recentTransactionsProvider = StreamProvider<List<TransactionModel>>((
  ref,
) {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) {
    return Stream<List<TransactionModel>>.value(const <TransactionModel>[]);
  }

  return ref.watch(transactionServiceProvider).watchRecentTransactions(uid);
});

final todayTransactionsProvider = StreamProvider<List<TransactionModel>>((ref) {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) {
    return Stream<List<TransactionModel>>.value(const <TransactionModel>[]);
  }

  return ref.watch(transactionServiceProvider).watchTodayTransactions(uid);
});

final transactionsProvider = StreamProvider<List<TransactionModel>>((ref) {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) {
    return Stream<List<TransactionModel>>.value(const <TransactionModel>[]);
  }

  return ref
      .watch(transactionServiceProvider)
      .watchRecentTransactions(uid, limit: 100);
});

final starterDataBootstrapProvider = FutureProvider<void>((ref) async {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) {
    return;
  }

  await ref.read(transactionServiceProvider).ensureStarterData(uid);
});

final dashboardSummaryProvider = Provider<DashboardSummary>((ref) {
  final wallets = ref.watch(walletsProvider).value ?? const <WalletModel>[];
  final today =
      ref.watch(todayTransactionsProvider).value ?? const <TransactionModel>[];

  double totalBalance = 0;
  for (final wallet in wallets) {
    totalBalance += wallet.balance;
  }

  double todayIncome = 0;
  double todayExpense = 0;
  for (final transaction in today) {
    if (transaction.type == FinanceCatalog.incomeType) {
      todayIncome += transaction.amount;
    } else {
      todayExpense += transaction.amount;
    }
  }

  return DashboardSummary(
    totalBalance: totalBalance,
    todayIncome: todayIncome,
    todayExpense: todayExpense,
  );
});

final transactionActionControllerProvider =
    AsyncNotifierProvider<TransactionActionController, void>(
      TransactionActionController.new,
    );

final categoryActionControllerProvider =
    AsyncNotifierProvider<CategoryActionController, void>(
      CategoryActionController.new,
    );

class DashboardSummary {
  const DashboardSummary({
    required this.totalBalance,
    required this.todayIncome,
    required this.todayExpense,
  });

  final double totalBalance;
  final double todayIncome;
  final double todayExpense;
}

class TransactionActionController extends AsyncNotifier<void> {
  TransactionService get _service => ref.read(transactionServiceProvider);

  @override
  Future<void> build() async {}

  Future<void> add(TransactionModel transaction) async {
    final uid = _requireUserId();
    state = const AsyncLoading<void>();
    state = await AsyncValue.guard(
      () => _service.addTransaction(uid, transaction),
    );
    if (state.hasError) {
      throw state.error!;
    }
  }

  Future<void> updateTransaction({
    required TransactionModel previous,
    required TransactionModel next,
  }) async {
    final uid = _requireUserId();
    state = const AsyncLoading<void>();
    state = await AsyncValue.guard(
      () => _service.updateTransaction(uid, previous: previous, next: next),
    );
    if (state.hasError) {
      throw state.error!;
    }
  }

  Future<void> delete(TransactionModel transaction) async {
    final uid = _requireUserId();
    state = const AsyncLoading<void>();
    state = await AsyncValue.guard(
      () => _service.deleteTransaction(uid, transaction),
    );
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

class CategoryActionController extends AsyncNotifier<void> {
  CategoryService get _service => ref.read(categoryServiceProvider);

  @override
  Future<void> build() async {}

  Future<CategoryModel> create({
    required String name,
    required String nameBn,
    required String iconKey,
    required int colorValue,
    required String type,
  }) async {
    final uid = _requireUserId();
    final category = CategoryModel(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim(),
      nameBn: nameBn.trim(),
      iconKey: iconKey,
      colorValue: colorValue,
      type: type,
      isDefault: false,
      createdAt: DateTime.now(),
    );

    state = const AsyncLoading<void>();
    state = await AsyncValue.guard(() => _service.addCategory(uid, category));
    if (state.hasError) {
      throw state.error!;
    }

    return category;
  }

  String _requireUserId() {
    final uid = ref.read(currentUserIdProvider);
    if (uid == null) {
      throw StateError('User is not signed in.');
    }
    return uid;
  }
}
