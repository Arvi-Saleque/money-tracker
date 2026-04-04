import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:translator/translator.dart';

import '../../shared/models/category_model.dart';
import '../../shared/models/transaction_model.dart';
import '../../shared/models/wallet_model.dart';
import '../../shared/providers/firebase_providers.dart';
import '../auth/auth_providers.dart';
import 'category_service.dart';
import 'finance_catalog.dart';
import 'transaction_history_models.dart';
import 'transaction_service.dart';
import 'wallet_service.dart';

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

final walletTransactionsProvider =
    StreamProvider.family<List<TransactionModel>, String>((ref, walletId) {
      final uid = ref.watch(currentUserIdProvider);
      if (uid == null) {
        return Stream<List<TransactionModel>>.value(const <TransactionModel>[]);
      }

      return ref
          .watch(transactionServiceProvider)
          .watchWalletTransactions(uid, walletId);
    });

final allCategoriesProvider = StreamProvider<List<CategoryModel>>((ref) {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) {
    return Stream<List<CategoryModel>>.value(const <CategoryModel>[]);
  }

  return ref.watch(categoryServiceProvider).watchCategories(uid);
});

final categoriesByTypeProvider = Provider.family<List<CategoryModel>, String>((
  ref,
  type,
) {
  final categories =
      ref.watch(allCategoriesProvider).asData?.value ?? const <CategoryModel>[];

  return categories.where((category) => category.type == type).toList();
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
    if (transaction.isTransfer) {
      continue;
    }
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

final transactionHistoryControllerProvider =
    NotifierProvider<TransactionHistoryController, TransactionHistoryState>(
      TransactionHistoryController.new,
    );

final transactionActionControllerProvider =
    AsyncNotifierProvider<TransactionActionController, void>(
      TransactionActionController.new,
    );

final categoryActionControllerProvider =
    AsyncNotifierProvider<CategoryActionController, void>(
      CategoryActionController.new,
    );

final walletActionControllerProvider =
    AsyncNotifierProvider<WalletActionController, void>(
      WalletActionController.new,
    );

final transferActionControllerProvider =
    AsyncNotifierProvider<TransferActionController, void>(
      TransferActionController.new,
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

class TransactionHistoryState {
  const TransactionHistoryState({
    this.filter = const TransactionHistoryFilter(),
    this.items = const <TransactionModel>[],
    this.isInitialLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.errorMessage,
  });

  final TransactionHistoryFilter filter;
  final List<TransactionModel> items;
  final bool isInitialLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? errorMessage;

  TransactionHistoryState copyWith({
    TransactionHistoryFilter? filter,
    List<TransactionModel>? items,
    bool? isInitialLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? errorMessage,
    bool clearError = false,
  }) {
    return TransactionHistoryState(
      filter: filter ?? this.filter,
      items: items ?? this.items,
      isInitialLoading: isInitialLoading ?? this.isInitialLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class TransactionHistoryController extends Notifier<TransactionHistoryState> {
  static const int _pageSize = 24;

  TransactionService get _service => ref.read(transactionServiceProvider);

  DocumentSnapshot<Map<String, dynamic>>? _lastDocument;
  List<TransactionModel> _fetchedItems = const <TransactionModel>[];
  String? _loadedForUserId;

  @override
  TransactionHistoryState build() {
    final uid = ref.watch(currentUserIdProvider);
    if (uid == null) {
      _loadedForUserId = null;
      _lastDocument = null;
      _fetchedItems = const <TransactionModel>[];
      return const TransactionHistoryState(
        hasMore: false,
        isInitialLoading: false,
      );
    }

    if (_loadedForUserId != uid) {
      _loadedForUserId = uid;
      _lastDocument = null;
      _fetchedItems = const <TransactionModel>[];
      Future<void>.microtask(refresh);
      return const TransactionHistoryState(isInitialLoading: true);
    }

    return state;
  }

  Future<void> refresh() async {
    final uid = _requireUserId();
    _lastDocument = null;
    _fetchedItems = const <TransactionModel>[];
    state = state.copyWith(
      isInitialLoading: true,
      isLoadingMore: false,
      hasMore: true,
      items: const <TransactionModel>[],
      clearError: true,
    );

    try {
      final page = await _service.fetchTransactionPage(
        uid,
        filter: state.filter,
        limit: _pageSize,
      );
      _fetchedItems = page.items;
      _lastDocument = page.lastDocument;
      _publishLoadedItems(
        hasMore: page.hasMore,
        isInitialLoading: false,
        isLoadingMore: false,
      );
    } catch (error) {
      state = state.copyWith(
        isInitialLoading: false,
        isLoadingMore: false,
        hasMore: false,
        errorMessage: _messageForError(error),
      );
    }
  }

  Future<void> loadMore() async {
    final uid = _requireUserId();
    if (state.isInitialLoading ||
        state.isLoadingMore ||
        !state.hasMore ||
        _lastDocument == null) {
      return;
    }

    state = state.copyWith(isLoadingMore: true, clearError: true);

    try {
      final page = await _service.fetchTransactionPage(
        uid,
        filter: state.filter,
        limit: _pageSize,
        startAfter: _lastDocument,
      );
      _fetchedItems = <TransactionModel>[..._fetchedItems, ...page.items];
      _lastDocument = page.lastDocument;
      _publishLoadedItems(
        hasMore: page.hasMore,
        isInitialLoading: false,
        isLoadingMore: false,
      );
    } catch (error) {
      state = state.copyWith(
        isLoadingMore: false,
        errorMessage: _messageForError(error),
      );
    }
  }

  Future<void> deleteTransaction(TransactionModel transaction) async {
    final uid = _requireUserId();
    state = state.copyWith(clearError: true);

    try {
      await _service.deleteTransaction(uid, transaction);
      _fetchedItems = _fetchedItems
          .where(
            (item) =>
                item.id != transaction.id &&
                item.id != transaction.linkedTransactionId,
          )
          .toList(growable: false);
      _publishLoadedItems(
        hasMore: state.hasMore,
        isInitialLoading: false,
        isLoadingMore: false,
      );
    } catch (error) {
      state = state.copyWith(errorMessage: _messageForError(error));
      rethrow;
    }
  }

  Future<void> setType(String type) async {
    final nextFilter = state.filter.copyWith(type: type);
    state = state.copyWith(filter: nextFilter);
    await refresh();
  }

  Future<void> setCategoryIds(Set<String> categoryIds) async {
    final nextFilter = state.filter.copyWith(categoryIds: categoryIds);
    state = state.copyWith(filter: nextFilter);
    await refresh();
  }

  Future<void> setWalletIds(Set<String> walletIds) async {
    final nextFilter = state.filter.copyWith(walletIds: walletIds);
    state = state.copyWith(filter: nextFilter);
    await refresh();
  }

  Future<void> setDateRange({DateTime? startDate, DateTime? endDate}) async {
    final nextFilter = state.filter.copyWith(
      startDate: startDate,
      endDate: endDate,
      clearStartDate: startDate == null,
      clearEndDate: endDate == null,
    );
    state = state.copyWith(filter: nextFilter);
    await refresh();
  }

  Future<void> setSort(TransactionHistorySort sort) async {
    final nextFilter = state.filter.copyWith(sort: sort);
    state = state.copyWith(filter: nextFilter);
    await refresh();
  }

  void setSearchQuery(String query) {
    final nextFilter = state.filter.copyWith(searchQuery: query);
    state = state.copyWith(
      filter: nextFilter,
      items: _applyClientSideView(_fetchedItems, nextFilter),
      clearError: true,
    );
  }

  Future<void> clearFilters() async {
    state = state.copyWith(filter: const TransactionHistoryFilter());
    await refresh();
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  void _publishLoadedItems({
    required bool hasMore,
    required bool isInitialLoading,
    required bool isLoadingMore,
  }) {
    state = state.copyWith(
      items: _applyClientSideView(_fetchedItems, state.filter),
      hasMore: hasMore,
      isInitialLoading: isInitialLoading,
      isLoadingMore: isLoadingMore,
      clearError: true,
    );
  }

  List<TransactionModel> _applyClientSideView(
    List<TransactionModel> source,
    TransactionHistoryFilter filter,
  ) {
    final query = filter.searchQuery.trim().toLowerCase();
    final items = source
        .where((transaction) {
          if (filter.type != TransactionHistoryFilter.allTypes &&
              transaction.type != filter.type) {
            return false;
          }

          if (filter.categoryIds.isNotEmpty &&
              !transaction.normalizedCategoryIds.any(
                filter.categoryIds.contains,
              )) {
            return false;
          }

          if (filter.walletIds.isNotEmpty &&
              !filter.walletIds.contains(transaction.walletId)) {
            return false;
          }

          if (filter.startDate != null) {
            final startDay = DateTime(
              filter.startDate!.year,
              filter.startDate!.month,
              filter.startDate!.day,
            );
            if (transaction.date.isBefore(startDay)) {
              return false;
            }
          }

          if (filter.endDate != null) {
            final exclusiveEnd = DateTime(
              filter.endDate!.year,
              filter.endDate!.month,
              filter.endDate!.day + 1,
            );
            if (!transaction.date.isBefore(exclusiveEnd)) {
              return false;
            }
          }

          if (query.isEmpty) {
            return true;
          }

          final haystack = <String>[
            transaction.note,
            transaction.amount.toStringAsFixed(0),
            transaction.amount.toStringAsFixed(2),
          ].join(' ').toLowerCase();

          return haystack.contains(query);
        })
        .toList(growable: false);

    items.sort((a, b) {
      switch (filter.sort) {
        case TransactionHistorySort.latest:
          final dateCompare = b.date.compareTo(a.date);
          if (dateCompare != 0) {
            return dateCompare;
          }
          return b.createdAt.compareTo(a.createdAt);
        case TransactionHistorySort.oldest:
          final dateCompare = a.date.compareTo(b.date);
          if (dateCompare != 0) {
            return dateCompare;
          }
          return a.createdAt.compareTo(b.createdAt);
        case TransactionHistorySort.highestAmount:
          final amountCompare = b.amount.compareTo(a.amount);
          if (amountCompare != 0) {
            return amountCompare;
          }
          final recentCompare = b.date.compareTo(a.date);
          if (recentCompare != 0) {
            return recentCompare;
          }
          return b.createdAt.compareTo(a.createdAt);
        case TransactionHistorySort.lowestAmount:
          final amountCompare = a.amount.compareTo(b.amount);
          if (amountCompare != 0) {
            return amountCompare;
          }
          final olderCompare = a.date.compareTo(b.date);
          if (olderCompare != 0) {
            return olderCompare;
          }
          return a.createdAt.compareTo(b.createdAt);
      }
    });

    return items;
  }

  String _requireUserId() {
    final uid = ref.read(currentUserIdProvider);
    if (uid == null) {
      throw StateError('User is not signed in.');
    }
    return uid;
  }

  String _messageForError(Object error) {
    if (error is FirebaseException && error.code == 'failed-precondition') {
      return 'This filter combination needs a Firestore index. Create the suggested index from the Firebase console link in the error details, then try again.';
    }

    return error.toString();
  }
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
  final GoogleTranslator _translator = GoogleTranslator();

  @override
  Future<void> build() async {}

  Future<CategoryModel> createManual({
    required String inputName,
    required String iconKey,
    required int colorValue,
    required String type,
  }) async {
    final uid = _requireUserId();
    final names = await _resolveNames(inputName);
    final category = CategoryModel(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      name: names.$1,
      nameBn: names.$2,
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

  Future<CategoryModel> createFromTemplate({
    required FinanceCategoryTemplate template,
    required List<CategoryModel> existingCategories,
  }) async {
    for (final category in existingCategories) {
      if (category.id == template.id ||
          category.name.toLowerCase() == template.name.toLowerCase()) {
        return category;
      }
    }

    final uid = _requireUserId();
    final category = template.toCategoryModel(
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

  Future<void> deleteCategory(CategoryModel category) async {
    final uid = _requireUserId();
    state = const AsyncLoading<void>();
    state = await AsyncValue.guard(
      () => _service.deleteCategory(uid, category.id),
    );
    if (state.hasError) {
      throw state.error!;
    }
  }

  Future<(String, String)> _resolveNames(String inputName) async {
    final trimmed = inputName.trim();
    if (trimmed.isEmpty) {
      throw StateError('Category name cannot be empty.');
    }

    final isBangla = RegExp(r'[\u0980-\u09FF]').hasMatch(trimmed);
    final sourceLanguage = isBangla ? 'bn' : 'en';
    final targetLanguage = isBangla ? 'en' : 'bn';

    try {
      final translated = await _translator.translate(
        trimmed,
        from: sourceLanguage,
        to: targetLanguage,
      );
      final translatedText = translated.text.trim();

      if (isBangla) {
        return (translatedText.isEmpty ? trimmed : translatedText, trimmed);
      }

      return (trimmed, translatedText.isEmpty ? trimmed : translatedText);
    } catch (_) {
      return (trimmed, trimmed);
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

class WalletActionController extends AsyncNotifier<void> {
  WalletService get _service => ref.read(walletServiceProvider);

  @override
  Future<void> build() async {}

  Future<WalletModel> addWallet(WalletModel wallet) async {
    final uid = _requireUserId();
    state = const AsyncLoading<void>();
    WalletModel? createdWallet;
    state = await AsyncValue.guard(() async {
      createdWallet = await _service.addWallet(uid, wallet);
    });
    if (state.hasError) {
      throw state.error!;
    }
    return createdWallet!;
  }

  Future<void> updateWallet(WalletModel wallet) async {
    final uid = _requireUserId();
    state = const AsyncLoading<void>();
    state = await AsyncValue.guard(() => _service.updateWallet(uid, wallet));
    if (state.hasError) {
      throw state.error!;
    }
  }

  Future<void> deleteWallet(WalletModel wallet) async {
    final uid = _requireUserId();
    state = const AsyncLoading<void>();
    state = await AsyncValue.guard(() => _service.deleteWallet(uid, wallet));
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

class TransferActionController extends AsyncNotifier<void> {
  WalletService get _walletService => ref.read(walletServiceProvider);
  TransactionService get _transactionService =>
      ref.read(transactionServiceProvider);

  @override
  Future<void> build() async {}

  Future<void> createTransfer({
    required String fromWalletId,
    required String toWalletId,
    required double amount,
    required String note,
    required DateTime date,
  }) async {
    final uid = _requireUserId();
    state = const AsyncLoading<void>();
    state = await AsyncValue.guard(
      () => _walletService.transferBetweenWallets(
        uid,
        fromWalletId: fromWalletId,
        toWalletId: toWalletId,
        amount: amount,
        note: note,
        date: date,
      ),
    );
    if (state.hasError) {
      throw state.error!;
    }
  }

  Future<(TransactionModel, TransactionModel)> loadTransferPair(
    TransactionModel transaction,
  ) async {
    final uid = _requireUserId();
    if (!transaction.isTransfer || transaction.linkedTransactionId == null) {
      throw StateError('This is not a linked transfer entry.');
    }
    final linked = await _transactionService.getTransaction(
      uid,
      transaction.linkedTransactionId!,
    );
    if (linked == null) {
      throw StateError('The linked transfer entry could not be found.');
    }
    return (transaction, linked);
  }

  Future<void> updateTransfer({
    required TransactionModel baseTransaction,
    required TransactionModel linkedTransaction,
    required String fromWalletId,
    required String toWalletId,
    required double amount,
    required String note,
    required DateTime date,
  }) async {
    final uid = _requireUserId();
    state = const AsyncLoading<void>();
    state = await AsyncValue.guard(
      () => _walletService.updateTransferPair(
        uid,
        baseTransaction: baseTransaction,
        linkedTransaction: linkedTransaction,
        fromWalletId: fromWalletId,
        toWalletId: toWalletId,
        amount: amount,
        note: note,
        date: date,
      ),
    );
    if (state.hasError) {
      throw state.error!;
    }
  }

  Future<void> deleteTransfer({
    required TransactionModel baseTransaction,
    TransactionModel? linkedTransaction,
  }) async {
    final uid = _requireUserId();
    state = const AsyncLoading<void>();
    state = await AsyncValue.guard(
      () => _walletService.deleteTransferPair(
        uid,
        baseTransaction: baseTransaction,
        linkedTransaction: linkedTransaction,
      ),
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
