import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/utils/locale_formatters.dart';
import '../../shared/models/debt_record_model.dart';
import '../../shared/models/transaction_model.dart';
import '../../shared/models/wallet_model.dart';
import '../debts/debt_providers.dart';
import '../profile/profile_providers.dart';
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

  String labelFor(String languageCode) {
    if (_isBanglaCode(languageCode)) {
      switch (this) {
        case AnalyticsPeriod.weekly:
          return 'এই সপ্তাহ';
        case AnalyticsPeriod.monthly:
          return 'এই মাস';
        case AnalyticsPeriod.yearly:
          return 'এই বছর';
      }
    }
    return label;
  }

  String averageExpenseLabelFor(String languageCode) {
    if (_isBanglaCode(languageCode)) {
      switch (this) {
        case AnalyticsPeriod.weekly:
        case AnalyticsPeriod.monthly:
          return 'গড় দৈনিক ব্যয়';
        case AnalyticsPeriod.yearly:
          return 'গড় মাসিক ব্যয়';
      }
    }
    return averageExpenseLabel;
  }

  String peakExpenseLabelFor(String languageCode) {
    if (_isBanglaCode(languageCode)) {
      switch (this) {
        case AnalyticsPeriod.weekly:
        case AnalyticsPeriod.monthly:
          return 'সর্বোচ্চ ব্যয়ের দিন';
        case AnalyticsPeriod.yearly:
          return 'সর্বোচ্চ ব্যয়ের মাস';
      }
    }
    return peakExpenseLabel;
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

class SmartInsights {
  const SmartInsights({
    required this.period,
    required this.current,
    required this.previous,
    required this.expenseDelta,
    required this.netDelta,
    required this.noSpendBucketCount,
    this.risingCategoryId,
    this.risingCategoryDelta = 0,
  });

  final AnalyticsPeriod period;
  final PeriodAnalytics current;
  final PeriodAnalytics previous;
  final double expenseDelta;
  final double netDelta;
  final int noSpendBucketCount;
  final String? risingCategoryId;
  final double risingCategoryDelta;

  bool get hasPreviousActivity =>
      previous.totalIncome > 0 || previous.totalExpense > 0;
}

class NetWorthBucket {
  const NetWorthBucket({
    required this.index,
    required this.label,
    required this.assets,
    required this.netWorth,
  });

  final int index;
  final String label;
  final double assets;
  final double netWorth;
}

class NetWorthTrend {
  const NetWorthTrend({
    required this.period,
    required this.includeDebts,
    required this.currentAssets,
    required this.receivables,
    required this.liabilities,
    required this.currentNetWorth,
    required this.startNetWorth,
    required this.buckets,
  });

  final AnalyticsPeriod period;
  final bool includeDebts;
  final double currentAssets;
  final double receivables;
  final double liabilities;
  final double currentNetWorth;
  final double startNetWorth;
  final List<NetWorthBucket> buckets;

  double get currentDebtImpact => receivables - liabilities;
  double get changeAmount => currentNetWorth - startNetWorth;
}

class NetWorthRequest {
  const NetWorthRequest({required this.period, required this.includeDebts});

  final AnalyticsPeriod period;
  final bool includeDebts;

  @override
  bool operator ==(Object other) {
    return other is NetWorthRequest &&
        other.period == period &&
        other.includeDebts == includeDebts;
  }

  @override
  int get hashCode => Object.hash(period, includeDebts);
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
      final languageCode =
          ref.watch(currentUserProfileProvider).asData?.value?.language ?? 'en';

      return transactionsAsync.whenData(
        (transactions) => buildPeriodAnalytics(
          period: period,
          transactions: transactions,
          languageCode: languageCode,
        ),
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

final previousPeriodTransactionsProvider =
    StreamProvider.family<List<TransactionModel>, AnalyticsPeriod>((
      ref,
      period,
    ) {
      final uid = ref.watch(currentUserIdProvider);
      if (uid == null) {
        return Stream<List<TransactionModel>>.value(const <TransactionModel>[]);
      }

      final range = previousAnalyticsRangeFor(period);
      return ref
          .watch(transactionServiceProvider)
          .watchTransactionsInRange(uid, start: range.start, end: range.end);
    });

final smartInsightsProvider =
    Provider.family<AsyncValue<SmartInsights>, AnalyticsPeriod>((ref, period) {
      final currentAnalyticsAsync = ref.watch(periodAnalyticsProvider(period));
      final previousTransactionsAsync = ref.watch(
        previousPeriodTransactionsProvider(period),
      );
      final languageCode =
          ref.watch(currentUserProfileProvider).asData?.value?.language ?? 'en';

      if (currentAnalyticsAsync.isLoading ||
          previousTransactionsAsync.isLoading) {
        return const AsyncLoading<SmartInsights>();
      }
      if (currentAnalyticsAsync.hasError) {
        return AsyncError<SmartInsights>(
          currentAnalyticsAsync.error!,
          currentAnalyticsAsync.stackTrace ?? StackTrace.current,
        );
      }
      if (previousTransactionsAsync.hasError) {
        return AsyncError<SmartInsights>(
          previousTransactionsAsync.error!,
          previousTransactionsAsync.stackTrace ?? StackTrace.current,
        );
      }

      final previousAnalytics = buildPeriodAnalytics(
        period: period,
        transactions: previousTransactionsAsync.asData?.value ?? const [],
        languageCode: languageCode,
      );

      return AsyncData(
        buildSmartInsights(
          period: period,
          current: currentAnalyticsAsync.asData!.value,
          previous: previousAnalytics,
        ),
      );
    });

final netWorthTrendProvider =
    Provider.family<AsyncValue<NetWorthTrend>, NetWorthRequest>((ref, request) {
      final walletsAsync = ref.watch(walletsProvider);
      final debtsAsync = ref.watch(debtsProvider);
      final transactionsAsync = ref.watch(
        periodTransactionsProvider(request.period),
      );
      final languageCode =
          ref.watch(currentUserProfileProvider).asData?.value?.language ?? 'en';

      if (walletsAsync.isLoading ||
          debtsAsync.isLoading ||
          transactionsAsync.isLoading) {
        return const AsyncLoading<NetWorthTrend>();
      }
      if (walletsAsync.hasError) {
        return AsyncError<NetWorthTrend>(
          walletsAsync.error!,
          walletsAsync.stackTrace ?? StackTrace.current,
        );
      }
      if (debtsAsync.hasError) {
        return AsyncError<NetWorthTrend>(
          debtsAsync.error!,
          debtsAsync.stackTrace ?? StackTrace.current,
        );
      }
      if (transactionsAsync.hasError) {
        return AsyncError<NetWorthTrend>(
          transactionsAsync.error!,
          transactionsAsync.stackTrace ?? StackTrace.current,
        );
      }

      return AsyncData(
        buildNetWorthTrend(
          period: request.period,
          includeDebts: request.includeDebts,
          wallets: walletsAsync.asData?.value ?? const <WalletModel>[],
          debts: debtsAsync.asData?.value ?? const <DebtRecordModel>[],
          transactions:
              transactionsAsync.asData?.value ?? const <TransactionModel>[],
          languageCode: languageCode,
        ),
      );
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

AnalyticsRange previousAnalyticsRangeFor(AnalyticsPeriod period) {
  final current = analyticsRangeFor(period);
  switch (period) {
    case AnalyticsPeriod.weekly:
      final start = current.start.subtract(const Duration(days: 7));
      return AnalyticsRange(start: start, end: current.start);
    case AnalyticsPeriod.monthly:
      final start = DateTime(current.start.year, current.start.month - 1);
      return AnalyticsRange(start: start, end: current.start);
    case AnalyticsPeriod.yearly:
      final start = DateTime(current.start.year - 1);
      return AnalyticsRange(start: start, end: current.start);
  }
}

PeriodAnalytics buildPeriodAnalytics({
  required AnalyticsPeriod period,
  required List<TransactionModel> transactions,
  String languageCode = 'en',
}) {
  final range = analyticsRangeFor(period);
  final buckets = _buildInitialBuckets(period, range.start, languageCode);
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
      for (final item in transaction.normalizedSplitItems) {
        categoryTotals.update(
          item.categoryId,
          (value) => value + item.amount,
          ifAbsent: () => item.amount,
        );
      }
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

SmartInsights buildSmartInsights({
  required AnalyticsPeriod period,
  required PeriodAnalytics current,
  required PeriodAnalytics previous,
}) {
  final currentCategoryTotals = <String, double>{
    for (final item in current.expenseByCategory) item.categoryId: item.amount,
  };
  final previousCategoryTotals = <String, double>{
    for (final item in previous.expenseByCategory) item.categoryId: item.amount,
  };

  String? risingCategoryId;
  var risingCategoryDelta = 0.0;
  for (final entry in currentCategoryTotals.entries) {
    final delta = entry.value - (previousCategoryTotals[entry.key] ?? 0);
    if (delta > risingCategoryDelta) {
      risingCategoryDelta = delta;
      risingCategoryId = entry.key;
    }
  }

  final noSpendBucketCount = current.buckets
      .where((bucket) => bucket.expense <= 0.009)
      .length;

  return SmartInsights(
    period: period,
    current: current,
    previous: previous,
    expenseDelta: current.totalExpense - previous.totalExpense,
    netDelta: current.net - previous.net,
    noSpendBucketCount: noSpendBucketCount,
    risingCategoryId: risingCategoryId,
    risingCategoryDelta: risingCategoryDelta,
  );
}

NetWorthTrend buildNetWorthTrend({
  required AnalyticsPeriod period,
  required bool includeDebts,
  required List<WalletModel> wallets,
  required List<DebtRecordModel> debts,
  required List<TransactionModel> transactions,
  required String languageCode,
}) {
  final range = analyticsRangeFor(period);
  final labels = _buildInitialBuckets(period, range.start, languageCode);
  final assetDeltas = List<double>.filled(labels.length, 0);
  final debtDeltas = List<double>.filled(labels.length, 0);

  var currentAssets = 0.0;
  for (final wallet in wallets) {
    currentAssets += wallet.balance;
  }

  var receivables = 0.0;
  var liabilities = 0.0;
  for (final debt in debts) {
    if (debt.isLent) {
      receivables += debt.remainingAmount;
    } else if (debt.isBorrowed) {
      liabilities += debt.remainingAmount;
    }

    final debtStartIndex = _resolveBucketIndex(
      period: period,
      rangeStart: range.start,
      date: debt.startDate,
    );
    if (debtStartIndex != null &&
        debtStartIndex >= 0 &&
        debtStartIndex < debtDeltas.length) {
      debtDeltas[debtStartIndex] += debt.isLent
          ? debt.totalAmount
          : -debt.totalAmount;
    }

    for (final payment in debt.payments) {
      final paymentIndex = _resolveBucketIndex(
        period: period,
        rangeStart: range.start,
        date: payment.date,
      );
      if (paymentIndex == null ||
          paymentIndex < 0 ||
          paymentIndex >= debtDeltas.length) {
        continue;
      }
      debtDeltas[paymentIndex] += debt.isBorrowed
          ? payment.amount
          : -payment.amount;
    }
  }

  for (final transaction in transactions) {
    if (transaction.isTransfer) {
      continue;
    }
    final index = _resolveBucketIndex(
      period: period,
      rangeStart: range.start,
      date: transaction.date,
    );
    if (index == null || index < 0 || index >= assetDeltas.length) {
      continue;
    }
    assetDeltas[index] += transaction.type == FinanceCatalog.incomeType
        ? transaction.amount
        : -transaction.amount;
  }

  final totalAssetDelta = assetDeltas.fold<double>(
    0,
    (sum, value) => sum + value,
  );
  final currentDebtImpact = receivables - liabilities;
  final totalDebtDelta = debtDeltas.fold<double>(
    0,
    (sum, value) => sum + value,
  );
  final startingAssets = currentAssets - totalAssetDelta;
  final startingDebtImpact = currentDebtImpact - totalDebtDelta;

  var runningAssets = startingAssets;
  var runningDebtImpact = startingDebtImpact;
  final buckets = <NetWorthBucket>[];

  for (var index = 0; index < labels.length; index++) {
    runningAssets += assetDeltas[index];
    runningDebtImpact += debtDeltas[index];
    buckets.add(
      NetWorthBucket(
        index: index,
        label: labels[index].label,
        assets: runningAssets,
        netWorth: includeDebts
            ? runningAssets + runningDebtImpact
            : runningAssets,
      ),
    );
  }

  final currentNetWorth = includeDebts
      ? currentAssets + currentDebtImpact
      : currentAssets;
  final startNetWorth = includeDebts
      ? startingAssets + startingDebtImpact
      : startingAssets;

  return NetWorthTrend(
    period: period,
    includeDebts: includeDebts,
    currentAssets: currentAssets,
    receivables: receivables,
    liabilities: liabilities,
    currentNetWorth: currentNetWorth,
    startNetWorth: startNetWorth,
    buckets: List<NetWorthBucket>.unmodifiable(buckets),
  );
}

List<AnalyticsBucket> _buildInitialBuckets(
  AnalyticsPeriod period,
  DateTime rangeStart,
  String languageCode,
) {
  final locale = LocaleFormatters.localeTag(languageCode);
  switch (period) {
    case AnalyticsPeriod.weekly:
      return List<AnalyticsBucket>.generate(7, (index) {
        final day = rangeStart.add(Duration(days: index));
        return AnalyticsBucket(
          index: index,
          label: LocaleFormatters.localizeDigits(
            DateFormat('E', locale).format(day),
            languageCode,
          ),
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
          label: LocaleFormatters.localizeDigits('${index + 1}', languageCode),
          income: 0,
          expense: 0,
        );
      });
    case AnalyticsPeriod.yearly:
      return List<AnalyticsBucket>.generate(12, (index) {
        final month = DateTime(rangeStart.year, index + 1);
        return AnalyticsBucket(
          index: index,
          label: LocaleFormatters.localizeDigits(
            DateFormat('MMM', locale).format(month),
            languageCode,
          ),
          income: 0,
          expense: 0,
        );
      });
  }
}

bool _isBanglaCode(String languageCode) => languageCode == 'bn';

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
