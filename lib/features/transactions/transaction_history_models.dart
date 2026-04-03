import 'package:cloud_firestore/cloud_firestore.dart';

import '../../shared/models/transaction_model.dart';

enum TransactionHistorySort { latest, oldest, highestAmount, lowestAmount }

extension TransactionHistorySortX on TransactionHistorySort {
  String get label {
    switch (this) {
      case TransactionHistorySort.latest:
        return 'Latest';
      case TransactionHistorySort.oldest:
        return 'Oldest';
      case TransactionHistorySort.highestAmount:
        return 'Highest amount';
      case TransactionHistorySort.lowestAmount:
        return 'Lowest amount';
    }
  }

  bool get descending {
    switch (this) {
      case TransactionHistorySort.latest:
      case TransactionHistorySort.highestAmount:
        return true;
      case TransactionHistorySort.oldest:
      case TransactionHistorySort.lowestAmount:
        return false;
    }
  }
}

class TransactionHistoryFilter {
  const TransactionHistoryFilter({
    this.type = allTypes,
    this.searchQuery = '',
    this.categoryIds = const <String>{},
    this.walletIds = const <String>{},
    this.startDate,
    this.endDate,
    this.sort = TransactionHistorySort.latest,
  });

  static const String allTypes = 'all';

  final String type;
  final String searchQuery;
  final Set<String> categoryIds;
  final Set<String> walletIds;
  final DateTime? startDate;
  final DateTime? endDate;
  final TransactionHistorySort sort;

  bool get hasActiveFilters =>
      type != allTypes ||
      searchQuery.trim().isNotEmpty ||
      categoryIds.isNotEmpty ||
      walletIds.isNotEmpty ||
      startDate != null ||
      endDate != null ||
      sort != TransactionHistorySort.latest;

  bool get usesServerCategoryFilter =>
      categoryIds.isNotEmpty && categoryIds.length <= 10;

  bool get usesServerWalletFilter =>
      walletIds.isNotEmpty && walletIds.length <= 10;

  TransactionHistoryFilter copyWith({
    String? type,
    String? searchQuery,
    Set<String>? categoryIds,
    Set<String>? walletIds,
    DateTime? startDate,
    bool clearStartDate = false,
    DateTime? endDate,
    bool clearEndDate = false,
    TransactionHistorySort? sort,
  }) {
    return TransactionHistoryFilter(
      type: type ?? this.type,
      searchQuery: searchQuery ?? this.searchQuery,
      categoryIds: categoryIds ?? this.categoryIds,
      walletIds: walletIds ?? this.walletIds,
      startDate: clearStartDate ? null : startDate ?? this.startDate,
      endDate: clearEndDate ? null : endDate ?? this.endDate,
      sort: sort ?? this.sort,
    );
  }
}

class TransactionHistoryPage {
  const TransactionHistoryPage({
    required this.items,
    required this.hasMore,
    this.lastDocument,
  });

  final List<TransactionModel> items;
  final bool hasMore;
  final DocumentSnapshot<Map<String, dynamic>>? lastDocument;
}
