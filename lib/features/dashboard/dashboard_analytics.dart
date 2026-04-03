import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../shared/models/transaction_model.dart';
import '../transactions/finance_catalog.dart';
import '../transactions/transaction_providers.dart';

enum AnalyticsPeriod { weekly, monthly, yearly }

extension AnalyticsPeriodX on AnalyticsPeriod {
  String get label {
    switch (this) {
      case AnalyticsPeriod.weekly:
        return 'This Week';
      case AnalyticsPeriod.monthly:
        return 'This Month';
      case AnalyticsPeriod.yearly:
        return 'This Year';
    }
  }

  String get averageExpenseLabel {
    switch (this) {
      case AnalyticsPeriod.weekly:
      case AnalyticsPeriod.monthly:
        return 'Avg daily expense';
      case AnalyticsPeriod.yearly:
        return 'Avg monthly expense';
    }
  }

  String get peakExpenseLabel {
    switch (this) {
      case AnalyticsPeriod.weekly:
      case AnalyticsPeriod.monthly:
        return 'Highest spending day';
      case AnalyticsPeriod.yearly:
        return 'Highest spending month';
    }
  }
}

class AnalyticsRange {
  const AnalyticsRange({required this.start, required this.end});

  final DateTime start;
  final DateTime end;
}

class AnalyticsBucket {
  const AnalyticsBucket({
    required this.index,
    required this.label,
    required this.income,
    required this.expense,
  });

  final int index;
  final String label;
  final double income;
  final double expense;

  AnalyticsBucket copyWith({
    int? index,
    String? label,
    double? income,
    double? expense,
  }) {
    return AnalyticsBucket(
      index: index ?? this.index,
      label: label ?? this.label,
      income: income ?? this.income,
      expense: expense ?? this.expense,
    );
  }
}

class CategoryExpenseSlice {
  const CategoryExpenseSlice({required this.categoryId, required this.amount});

  final String categoryId;
  final double amount;
}

class PeriodAnalytics {
  const PeriodAnalytics({
    required this.period,
    required this.totalIncome,
    required this.totalExpense,
    required this.net,
    required this.averageExpense,
    required this.buckets,
    required this.expenseByCategory,
    this.topCategoryId,
    this.topCategoryAmount = 0,
    this.peakExpenseBucketLabel,
    this.peakExpenseAmount = 0,
  });

  final AnalyticsPeriod period;
  final double totalIncome;
  final double totalExpense;
  final double net;
  final double averageExpense;
  final List<AnalyticsBucket> buckets;
  final List<CategoryExpenseSlice> expenseByCategory;
  final String? topCategoryId;
  final double topCategoryAmount;
  final String? peakExpenseBucketLabel;
  final double peakExpenseAmount;
}

final periodTransactionsProvider =
    StreamProvider.family<List<TransactionModel>, AnalyticsPeriod>((
      ref,
      period,
    ) {
      final uid = ref.watch(currentUserIdProvider);
      if (uid == null) {
        return Stream<List<TransactionModel>>.value(const <TransactionModel>[]);
      }

      final range = analyticsRangeFor(period);
      return ref
          .watch(transactionServiceProvider)
          .watchTransactionsInRange(uid, start: range.start, end: range.end);
    });

final periodAnalyticsProvider =
    Provider.family<AsyncValue<PeriodAnalytics>, AnalyticsPeriod>((
      ref,
      period,
    ) {
      final transactionsAsync = ref.watch(periodTransactionsProvider(period));

      return transactionsAsync.whenData(
        (transactions) =>
            buildPeriodAnalytics(period: period, transactions: transactions),
      );
    });

final weeklyAnalyticsProvider = Provider<AsyncValue<PeriodAnalytics>>((ref) {
  return ref.watch(periodAnalyticsProvider(AnalyticsPeriod.weekly));
});

final monthlyAnalyticsProvider = Provider<AsyncValue<PeriodAnalytics>>((ref) {
  return ref.watch(periodAnalyticsProvider(AnalyticsPeriod.monthly));
});

final yearlyAnalyticsProvider = Provider<AsyncValue<PeriodAnalytics>>((ref) {
  return ref.watch(periodAnalyticsProvider(AnalyticsPeriod.yearly));
});

AnalyticsRange analyticsRangeFor(AnalyticsPeriod period) {
  final now = DateTime.now();

  switch (period) {
    case AnalyticsPeriod.weekly:
      final today = DateTime(now.year, now.month, now.day);
      final start = today.subtract(Duration(days: today.weekday - 1));
      return AnalyticsRange(
        start: start,
        end: start.add(const Duration(days: 7)),
      );
    case AnalyticsPeriod.monthly:
      final start = DateTime(now.year, now.month);
      return AnalyticsRange(
        start: start,
        end: DateTime(now.year, now.month + 1),
      );
    case AnalyticsPeriod.yearly:
      final start = DateTime(now.year);
      return AnalyticsRange(start: start, end: DateTime(now.year + 1));
  }
}

PeriodAnalytics buildPeriodAnalytics({
  required AnalyticsPeriod period,
  required List<TransactionModel> transactions,
}) {
  final range = analyticsRangeFor(period);
  final buckets = _buildInitialBuckets(period, range.start);
  final categoryTotals = <String, double>{};

  double totalIncome = 0;
  double totalExpense = 0;

  for (final transaction in transactions) {
    if (transaction.isTransfer) {
      continue;
    }

    final bucketIndex = _resolveBucketIndex(
      period: period,
      rangeStart: range.start,
      date: transaction.date,
    );
    if (bucketIndex == null ||
        bucketIndex < 0 ||
        bucketIndex >= buckets.length) {
      continue;
    }

    final bucket = buckets[bucketIndex];
    if (transaction.type == FinanceCatalog.incomeType) {
      totalIncome += transaction.amount;
      buckets[bucketIndex] = bucket.copyWith(
        income: bucket.income + transaction.amount,
      );
    } else {
      totalExpense += transaction.amount;
      buckets[bucketIndex] = bucket.copyWith(
        expense: bucket.expense + transaction.amount,
      );
      categoryTotals.update(
        transaction.categoryId,
        (value) => value + transaction.amount,
        ifAbsent: () => transaction.amount,
      );
    }
  }

  final sortedCategories = categoryTotals.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  final topCategory = sortedCategories.isEmpty ? null : sortedCategories.first;

  AnalyticsBucket? peakBucket;
  for (final bucket in buckets) {
    if (peakBucket == null || bucket.expense > peakBucket.expense) {
      peakBucket = bucket;
    }
  }

  final averageExpense = buckets.isEmpty ? 0.0 : totalExpense / buckets.length;

  return PeriodAnalytics(
    period: period,
    totalIncome: totalIncome,
    totalExpense: totalExpense,
    net: totalIncome - totalExpense,
    averageExpense: averageExpense,
    buckets: List<AnalyticsBucket>.unmodifiable(buckets),
    expenseByCategory: List<CategoryExpenseSlice>.unmodifiable(
      sortedCategories
          .map(
            (entry) => CategoryExpenseSlice(
              categoryId: entry.key,
              amount: entry.value,
            ),
          )
          .toList(),
    ),
    topCategoryId: topCategory?.key,
    topCategoryAmount: topCategory?.value ?? 0,
    peakExpenseBucketLabel: peakBucket != null && peakBucket.expense > 0
        ? peakBucket.label
        : null,
    peakExpenseAmount: peakBucket?.expense ?? 0,
  );
}

List<AnalyticsBucket> _buildInitialBuckets(
  AnalyticsPeriod period,
  DateTime rangeStart,
) {
  switch (period) {
    case AnalyticsPeriod.weekly:
      return List<AnalyticsBucket>.generate(7, (index) {
        final day = rangeStart.add(Duration(days: index));
        return AnalyticsBucket(
          index: index,
          label: DateFormat('E').format(day),
          income: 0,
          expense: 0,
        );
      });
    case AnalyticsPeriod.monthly:
      final daysInMonth = DateTime(
        rangeStart.year,
        rangeStart.month + 1,
        0,
      ).day;
      return List<AnalyticsBucket>.generate(daysInMonth, (index) {
        return AnalyticsBucket(
          index: index,
          label: '${index + 1}',
          income: 0,
          expense: 0,
        );
      });
    case AnalyticsPeriod.yearly:
      return List<AnalyticsBucket>.generate(12, (index) {
        final month = DateTime(rangeStart.year, index + 1);
        return AnalyticsBucket(
          index: index,
          label: DateFormat('MMM').format(month),
          income: 0,
          expense: 0,
        );
      });
  }
}

int? _resolveBucketIndex({
  required AnalyticsPeriod period,
  required DateTime rangeStart,
  required DateTime date,
}) {
  switch (period) {
    case AnalyticsPeriod.weekly:
    case AnalyticsPeriod.monthly:
      return DateTime(
        date.year,
        date.month,
        date.day,
      ).difference(rangeStart).inDays;
    case AnalyticsPeriod.yearly:
      return date.month - 1;
  }
}
