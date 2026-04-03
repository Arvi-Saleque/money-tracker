import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/locale_formatters.dart';
import '../../core/theme/gradient_colors.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../l10n/l10n_extension.dart';
import '../../shared/models/category_model.dart';
import '../../shared/models/goal_model.dart';
import '../../shared/models/transaction_model.dart';
import '../../shared/models/wallet_model.dart';
import '../../shared/widgets/premium_card.dart';
import '../budgets/budget_providers.dart';
import '../goals/goal_providers.dart';
import 'dashboard_analytics.dart';
import 'dashboard_chart_widgets.dart';
import '../profile/profile_providers.dart';
import '../subscriptions/subscription_providers.dart';
import '../transactions/finance_catalog.dart';
import '../transactions/transaction_editor_sheet.dart';
import '../transactions/transaction_history_models.dart';
import '../transactions/transaction_providers.dart';
import 'dashboard_data.dart';
import 'dashboard_ui_parts.dart';

class HomeTab extends ConsumerWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final gradients = theme.extension<GradientColors>()!;
    final isWide = MediaQuery.sizeOf(context).width >= 900;
    final walletsAsync = ref.watch(walletsProvider);
    final recentTransactionsAsync = ref.watch(recentTransactionsProvider);
    final summary = ref.watch(dashboardSummaryProvider);
    final monthlyAnalyticsAsync = ref.watch(monthlyAnalyticsProvider);
    final budgetOverview = ref.watch(dashboardBudgetOverviewProvider);
    final profile = ref.watch(currentUserProfileProvider).asData?.value;
    final currency = profile?.currency ?? AppConstants.defaultCurrency;
    final languageCode =
        profile?.language ?? Localizations.localeOf(context).languageCode;
    final categories =
        ref.watch(allCategoriesProvider).asData?.value ??
        const <CategoryModel>[];
    final wallets = walletsAsync.asData?.value ?? const <WalletModel>[];
    final recentTransactions =
        recentTransactionsAsync.asData?.value ?? const <TransactionModel>[];
    final categoryMap = {
      for (final category in categories) category.id: category,
    };
    final walletMap = {for (final wallet in wallets) wallet.id: wallet};
    final monthAnalytics = monthlyAnalyticsAsync.asData?.value;
    final topCategory = monthAnalytics?.topCategoryId == null
        ? null
        : categoryMap[monthAnalytics!.topCategoryId!];
    final topCategoryLabel =
        topCategory?.localizedName(languageCode) ?? l10n.noTopCategoryYet;
    final upcomingBills = ref.watch(dashboardUpcomingBillsProvider);
    final topGoal = ref.watch(topActiveGoalProvider);
    final monthLabel = LocaleFormatters.formatDate(
      DateTime.now(),
      'MMMM yyyy',
      languageCode,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              buildPremiumCard(
                context: context,
                gradient: gradients.heroGradient,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                l10n.homeAvailableBalance,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.84),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _formatCurrency(summary.totalBalance, currency),
                                style: theme.textTheme.displaySmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        HeroBadge(monthLabel: monthLabel),
                      ],
                    ),
                    const SizedBox(height: 22),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: <Widget>[
                        HeroMetric(
                          label: l10n.homeTodayIncome,
                          value: _formatCurrency(
                            summary.todayIncome,
                            currency,
                            languageCode,
                          ),
                          icon: Icons.arrow_downward_rounded,
                        ),
                        HeroMetric(
                          label: l10n.homeTodayExpense,
                          value: _formatCurrency(
                            summary.todayExpense,
                            currency,
                            languageCode,
                          ),
                          icon: Icons.arrow_upward_rounded,
                        ),
                        HeroMetric(
                          label: l10n.homeMonthExpense,
                          value: _formatCurrency(
                            monthAnalytics?.totalExpense ?? 0,
                            currency,
                            languageCode,
                          ),
                          icon: Icons.show_chart_rounded,
                        ),
                        HeroMetric(
                          label: l10n.homeNetToday,
                          value: _formatCurrency(
                            summary.todayIncome - summary.todayExpense,
                            currency,
                            languageCode,
                          ),
                          icon: Icons.savings_rounded,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              if (walletsAsync.isLoading && wallets.isEmpty)
                const Center(child: CircularProgressIndicator())
              else if (wallets.isEmpty)
                EmptyFinanceCard(
                  title: l10n.walletReadyTitle,
                  subtitle: l10n.walletReadySubtitle,
                  actionLabel: l10n.addTransactionAction,
                  onAction: () => openTransactionEditorPage(context),
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      l10n.walletBalancesTitle,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 116,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: wallets.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final wallet = wallets[index];
                          return SizedBox(
                            width: 228,
                            child: WalletOverviewCard(
                              name: wallet.name,
                              balance: _formatCurrency(
                                wallet.balance,
                                currency,
                                languageCode,
                              ),
                              icon: FinanceCatalog.iconForKey(wallet.iconKey),
                              color: Color(wallet.colorValue),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              if (budgetOverview.overallBudget != null ||
                  budgetOverview.categoryBudgets.isNotEmpty) ...<Widget>[
                const SizedBox(height: 20),
                _DashboardBudgetCard(
                  overview: budgetOverview,
                  currency: currency,
                ),
              ],
              if (budgetOverview.hasWarnings) ...<Widget>[
                const SizedBox(height: 16),
                _DashboardBudgetAlertCard(
                  overview: budgetOverview,
                  currency: currency,
                ),
              ],
              const SizedBox(height: 20),
              monthlyAnalyticsAsync.when(
                data: (analytics) {
                  return Column(
                    children: <Widget>[
                      if (isWide)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
                              flex: 3,
                              child: ExpenseTrendChartCard(
                                analytics: analytics,
                                title: l10n.expenseTrendTitle,
                                subtitle: l10n.expenseTrendSubtitle,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 2,
                              child: buildPremiumCard(
                                context: context,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      l10n.monthPulseTitle,
                                      style: theme.textTheme.titleLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      l10n.monthPulseSubtitle,
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            color: theme
                                                .textTheme
                                                .bodyMedium
                                                ?.color
                                                ?.withValues(alpha: 0.74),
                                          ),
                                    ),
                                    const SizedBox(height: 18),
                                    Wrap(
                                      spacing: 10,
                                      runSpacing: 10,
                                      children: <Widget>[
                                        _SummaryPill(
                                          label: l10n.monthIncomeLabel,
                                          value: _formatCurrency(
                                            analytics.totalIncome,
                                            currency,
                                            languageCode,
                                          ),
                                          color: const Color(0xFF2ECC9A),
                                        ),
                                        _SummaryPill(
                                          label: l10n.homeMonthExpense,
                                          value: _formatCurrency(
                                            analytics.totalExpense,
                                            currency,
                                            languageCode,
                                          ),
                                          color: const Color(0xFFE85D5D),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    _TopCategoryChip(
                                      label: topCategoryLabel,
                                      amount: _formatCurrency(
                                        analytics.topCategoryAmount,
                                        currency,
                                        languageCode,
                                      ),
                                      color: topCategory == null
                                          ? theme.colorScheme.primary
                                          : Color(topCategory.colorValue),
                                    ),
                                    const SizedBox(height: 18),
                                    Row(
                                      children: <Widget>[
                                        Expanded(
                                          child: AnalyticsMetricCard(
                                            label: analytics
                                                .period
                                                .averageExpenseLabelFor(
                                                  languageCode,
                                                ),
                                            value: _formatCurrency(
                                              analytics.averageExpense,
                                              currency,
                                              languageCode,
                                            ),
                                            toneColor:
                                                theme.colorScheme.primary,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: AnalyticsMetricCard(
                                            label: analytics
                                                .period
                                                .peakExpenseLabelFor(
                                                  languageCode,
                                                ),
                                            value: _formatCurrency(
                                              analytics.peakExpenseAmount,
                                              currency,
                                              languageCode,
                                            ),
                                            highlight:
                                                analytics
                                                    .peakExpenseBucketLabel ??
                                                l10n.waitingForSpending,
                                            toneColor: const Color(0xFFE85D5D),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                      else
                        Column(
                          children: <Widget>[
                            ExpenseTrendChartCard(
                              analytics: analytics,
                              title: l10n.expenseTrendTitle,
                              subtitle: l10n.expenseTrendSubtitle,
                            ),
                            const SizedBox(height: 16),
                            buildPremiumCard(
                              context: context,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    l10n.monthPulseTitle,
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 10,
                                    runSpacing: 10,
                                    children: <Widget>[
                                      _SummaryPill(
                                        label: l10n.monthIncomeLabel,
                                        value: _formatCurrency(
                                          analytics.totalIncome,
                                          currency,
                                          languageCode,
                                        ),
                                        color: const Color(0xFF2ECC9A),
                                      ),
                                      _SummaryPill(
                                        label: l10n.homeMonthExpense,
                                        value: _formatCurrency(
                                          analytics.totalExpense,
                                          currency,
                                          languageCode,
                                        ),
                                        color: const Color(0xFFE85D5D),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  _TopCategoryChip(
                                    label: topCategoryLabel,
                                    amount: _formatCurrency(
                                      analytics.topCategoryAmount,
                                      currency,
                                      languageCode,
                                    ),
                                    color: topCategory == null
                                        ? theme.colorScheme.primary
                                        : Color(topCategory.colorValue),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 20),
                    ],
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (error, _) => Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: EmptyFinanceCard(
                    title: l10n.analyticsLoadingTitle,
                    subtitle: error.toString(),
                  ),
                ),
              ),
              if (isWide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      flex: 3,
                      child: _RecentTransactionsCard(
                        transactions: recentTransactions,
                        categoryMap: categoryMap,
                        walletMap: walletMap,
                        currency: currency,
                        languageCode: languageCode,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: <Widget>[
                          _TodayPulseCard(
                            summary: summary,
                            transactionCount: recentTransactions.length,
                            currency: currency,
                            monthNet: monthAnalytics?.net ?? 0,
                          ),
                          const SizedBox(height: 16),
                          _UpcomingBillsCard(
                            bills: upcomingBills,
                            currency: currency,
                          ),
                          const SizedBox(height: 16),
                          _TopGoalCard(goal: topGoal, currency: currency),
                          const SizedBox(height: 16),
                          const QuickActionsCard(actions: actionShortcuts),
                        ],
                      ),
                    ),
                  ],
                )
              else
                Column(
                  children: <Widget>[
                    _TodayPulseCard(
                      summary: summary,
                      transactionCount: recentTransactions.length,
                      currency: currency,
                      monthNet: monthAnalytics?.net ?? 0,
                    ),
                    const SizedBox(height: 16),
                    _RecentTransactionsCard(
                      transactions: recentTransactions,
                      categoryMap: categoryMap,
                      walletMap: walletMap,
                      currency: currency,
                      languageCode: languageCode,
                    ),
                    const SizedBox(height: 16),
                    _UpcomingBillsCard(
                      bills: upcomingBills,
                      currency: currency,
                    ),
                    const SizedBox(height: 16),
                    _TopGoalCard(goal: topGoal, currency: currency),
                    const SizedBox(height: 16),
                    const QuickActionsCard(actions: actionShortcuts),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UpcomingBillsCard extends StatelessWidget {
  const _UpcomingBillsCard({required this.bills, required this.currency});

  final List<UpcomingBillViewModel> bills;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final languageCode = Localizations.localeOf(context).languageCode;
    return buildPremiumCard(
      context: context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          LayoutBuilder(
            builder: (context, constraints) {
              final title = Text(
                l10n.upcomingBillsTitle,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              );
              final button = TextButton(
                onPressed: () => context.push(AppConstants.subscriptionsRoute),
                child: Text(l10n.openAction),
              );

              if (constraints.maxWidth < 320) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[title, const SizedBox(height: 8), button],
                );
              }

              return Row(
                children: <Widget>[
                  Expanded(child: title),
                  button,
                ],
              );
            },
          ),
          if (bills.isEmpty) ...<Widget>[
            const SizedBox(height: 12),
            Text(l10n.noBillsDueSoon),
          ] else ...<Widget>[
            const SizedBox(height: 12),
            ...bills.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Color(
                          item.category?.colorValue ?? 0xFF3D6BE4,
                        ).withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        FinanceCatalog.iconForKey(
                          item.category?.iconKey ?? 'subscriptions',
                        ),
                        color: Color(item.category?.colorValue ?? 0xFF3D6BE4),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            item.subscription.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _upcomingBillLabel(context, item),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _formatCurrency(
                        item.subscription.amount,
                        currency,
                        languageCode,
                      ),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _upcomingBillLabel(BuildContext context, UpcomingBillViewModel item) {
    final days = item.subscription.daysUntilDue;
    final dueLabel = context.l10n.dueLabel(days);
    final walletName = item.wallet?.name ?? context.l10n.walletFilterLabel(0);
    return '$dueLabel · $walletName';
  }
}

class _TopGoalCard extends StatelessWidget {
  const _TopGoalCard({required this.goal, required this.currency});

  final GoalModel? goal;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final languageCode = Localizations.localeOf(context).languageCode;
    final goalData = goal;

    return buildPremiumCard(
      context: context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          LayoutBuilder(
            builder: (context, constraints) {
              final title = Text(
                l10n.topGoalTitle,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              );
              final button = TextButton(
                onPressed: () => context.push(AppConstants.goalsRoute),
                child: Text(l10n.openAction),
              );

              if (constraints.maxWidth < 320) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[title, const SizedBox(height: 8), button],
                );
              }

              return Row(
                children: <Widget>[
                  Expanded(child: title),
                  button,
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          if (goalData == null)
            Text(l10n.noActiveGoalYet)
          else ...<Widget>[
            Text(
              goalData.name,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: goalData.progress,
                minHeight: 12,
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
                valueColor: AlwaysStoppedAnimation<Color>(
                  Color(goalData.colorValue),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    l10n.goalSavedOf(
                      _formatCurrency(
                        goalData.savedAmount,
                        currency,
                        languageCode,
                      ),
                      _formatCurrency(
                        goalData.targetAmount,
                        currency,
                        languageCode,
                      ),
                    ),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  LocaleFormatters.localizeDigits(
                    '${(goalData.progress * 100).round()}%',
                    languageCode,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(l10n.daysLeftLabel(goalData.daysRemaining)),
          ],
        ],
      ),
    );
  }
}

class TransactionsTab extends ConsumerStatefulWidget {
  const TransactionsTab({super.key});

  @override
  ConsumerState<TransactionsTab> createState() => _TransactionsTabState();
}

class _TransactionsTabState extends ConsumerState<TransactionsTab> {
  late final TextEditingController _searchController;
  late final ScrollController _scrollController;
  Timer? _searchDebounce;
  bool _searchExpanded = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _scrollController = ScrollController()..addListener(_handleScroll);
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final historyState = ref.watch(transactionHistoryControllerProvider);
    final categories =
        ref.watch(allCategoriesProvider).asData?.value ??
        const <CategoryModel>[];
    final wallets =
        ref.watch(walletsProvider).asData?.value ?? const <WalletModel>[];
    final profile = ref.watch(currentUserProfileProvider).asData?.value;
    final currency = profile?.currency ?? AppConstants.defaultCurrency;
    final languageCode =
        profile?.language ?? Localizations.localeOf(context).languageCode;
    final categoryMap = {
      for (final category in categories) category.id: category,
    };
    final walletMap = {for (final wallet in wallets) wallet.id: wallet};
    final transactions = historyState.items;
    final filter = historyState.filter;

    if (_searchController.text != filter.searchQuery) {
      _searchController.value = _searchController.value.copyWith(
        text: filter.searchQuery,
        selection: TextSelection.collapsed(offset: filter.searchQuery.length),
        composing: TextRange.empty,
      );
    }

    return ListView(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
      children: <Widget>[
        _TransactionHistoryHeader(
          searchExpanded: _searchExpanded,
          searchController: _searchController,
          searchValue: filter.searchQuery,
          selectedType: filter.type,
          activeCategoryCount: filter.categoryIds.length,
          activeWalletCount: filter.walletIds.length,
          hasDateRange: filter.startDate != null || filter.endDate != null,
          sortLabel: _sortLabel(context, filter.sort),
          resultCount: transactions.length,
          hasAnyFilter: filter.hasActiveFilters,
          onToggleSearch: _toggleSearch,
          onSearchChanged: _handleSearchChanged,
          onTypeSelected: (value) {
            ref
                .read(transactionHistoryControllerProvider.notifier)
                .setType(value);
          },
          onOpenCategoryFilter: () =>
              _openCategoryFilterSheet(categories, languageCode),
          onOpenWalletFilter: () => _openWalletFilterSheet(wallets),
          onPickDateRange: _pickDateRange,
          onPickSort: _pickSort,
          onClearFilters: () {
            setState(() {
              _searchExpanded = false;
            });
            _searchController.clear();
            ref
                .read(transactionHistoryControllerProvider.notifier)
                .clearFilters();
          },
          onAddNew: () => _openEditor(),
        ),
        const SizedBox(height: 18),
        if (historyState.errorMessage != null) ...<Widget>[
          buildPremiumCard(
            context: context,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  l10n.historyNeedsAttention,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(historyState.errorMessage!),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: <Widget>[
                    ElevatedButton(
                      onPressed: () => ref
                          .read(transactionHistoryControllerProvider.notifier)
                          .refresh(),
                      child: Text(l10n.retryAction),
                    ),
                    OutlinedButton(
                      onPressed: () => ref
                          .read(transactionHistoryControllerProvider.notifier)
                          .clearError(),
                      child: Text(l10n.dismissAction),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
        ],
        if (historyState.isInitialLoading && transactions.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 40),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (transactions.isEmpty)
          EmptyFinanceCard(
            title: l10n.transactionEmptyTitle(filter.hasActiveFilters),
            subtitle: l10n.transactionEmptySubtitle(filter.hasActiveFilters),
            actionLabel: l10n.addTransactionAction,
            onAction: _openEditor,
          )
        else
          ..._buildTransactionSections(
            context,
            transactions: transactions,
            categoryMap: categoryMap,
            walletMap: walletMap,
            currency: currency,
            languageCode: languageCode,
            onOpenTransaction: _openEditor,
            onDeleteTransaction: _deleteTransaction,
          ),
        if (transactions.isNotEmpty) ...<Widget>[
          const SizedBox(height: 6),
          if (historyState.isLoadingMore)
            const Center(child: CircularProgressIndicator())
          else if (historyState.hasMore)
            Center(
              child: OutlinedButton.icon(
                onPressed: () => ref
                    .read(transactionHistoryControllerProvider.notifier)
                    .loadMore(),
                icon: const Icon(Icons.expand_more_rounded),
                label: Text(l10n.loadMoreAction),
              ),
            )
          else
            Center(
              child: Text(
                l10n.endOfHistoryLabel,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                ),
              ),
            ),
        ],
      ],
    );
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) {
      return;
    }

    final threshold = _scrollController.position.maxScrollExtent - 320;
    if (_scrollController.position.pixels >= threshold) {
      ref.read(transactionHistoryControllerProvider.notifier).loadMore();
    }
  }

  void _toggleSearch() {
    setState(() {
      _searchExpanded = !_searchExpanded;
    });

    if (!_searchExpanded) {
      _searchDebounce?.cancel();
      _searchController.clear();
      ref
          .read(transactionHistoryControllerProvider.notifier)
          .setSearchQuery('');
    }
  }

  void _handleSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      ref
          .read(transactionHistoryControllerProvider.notifier)
          .setSearchQuery(value);
    });
  }

  Future<void> _openEditor([TransactionModel? transaction]) async {
    await openTransactionEditorPage(context, transaction: transaction);
    if (!mounted) {
      return;
    }
    await ref.read(transactionHistoryControllerProvider.notifier).refresh();
  }

  Future<void> _deleteTransaction(TransactionModel transaction) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(context.l10n.deleteTransactionTitle),
          content: Text(context.l10n.deleteTransactionPrompt),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(context.l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(context.l10n.delete),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    try {
      await ref
          .read(transactionHistoryControllerProvider.notifier)
          .deleteTransaction(transaction);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(content: Text(context.l10n.transactionDeleted)),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  Future<void> _pickDateRange() async {
    final filter = ref.read(transactionHistoryControllerProvider).filter;
    final now = DateTime.now();
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 1),
      initialDateRange: filter.startDate != null && filter.endDate != null
          ? DateTimeRange(start: filter.startDate!, end: filter.endDate!)
          : null,
    );

    if (range == null) {
      return;
    }

    await ref
        .read(transactionHistoryControllerProvider.notifier)
        .setDateRange(startDate: range.start, endDate: range.end);
  }

  Future<void> _pickSort() async {
    final selected = await showModalBottomSheet<TransactionHistorySort>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        final currentSort = ref
            .read(transactionHistoryControllerProvider)
            .filter
            .sort;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  context.l10n.sortTransactionsTitle,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 16),
                ...TransactionHistorySort.values.map((sort) {
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(_sortLabel(context, sort)),
                    trailing: currentSort == sort
                        ? Icon(
                            Icons.check_circle_rounded,
                            color: Theme.of(context).colorScheme.primary,
                          )
                        : null,
                    onTap: () => Navigator.of(context).pop(sort),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );

    if (selected == null) {
      return;
    }

    await ref
        .read(transactionHistoryControllerProvider.notifier)
        .setSort(selected);
  }

  Future<void> _openCategoryFilterSheet(
    List<CategoryModel> categories,
    String languageCode,
  ) async {
    final initialSelection = ref
        .read(transactionHistoryControllerProvider)
        .filter
        .categoryIds;
    final nextSelection = initialSelection.toSet();

    final applied = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      context.l10n.filterByCategoryTitle,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Flexible(
                      child: SingleChildScrollView(
                        child: Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: categories.map((category) {
                            final isSelected = nextSelection.contains(
                              category.id,
                            );
                            return FilterChip(
                              selected: isSelected,
                              avatar: Icon(
                                FinanceCatalog.iconForKey(category.iconKey),
                                size: 16,
                                color: Color(category.colorValue),
                              ),
                              label: Text(category.localizedName(languageCode)),
                              onSelected: (_) {
                                setModalState(() {
                                  if (isSelected) {
                                    nextSelection.remove(category.id);
                                  } else {
                                    nextSelection.add(category.id);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: <Widget>[
                        Expanded(
                            child: OutlinedButton(
                            onPressed: () {
                              nextSelection.clear();
                              Navigator.of(context).pop(true);
                            },
                            child: Text(context.l10n.clearAction),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: Text(context.l10n.applyAction),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (applied == true) {
      await ref
          .read(transactionHistoryControllerProvider.notifier)
          .setCategoryIds(nextSelection);
    }
  }

  Future<void> _openWalletFilterSheet(List<WalletModel> wallets) async {
    final initialSelection = ref
        .read(transactionHistoryControllerProvider)
        .filter
        .walletIds;
    final nextSelection = initialSelection.toSet();

    final applied = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      context.l10n.filterByWalletTitle,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Flexible(
                      child: SingleChildScrollView(
                        child: Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: wallets.map((wallet) {
                            final isSelected = nextSelection.contains(
                              wallet.id,
                            );
                            return FilterChip(
                              selected: isSelected,
                              avatar: Icon(
                                FinanceCatalog.iconForKey(wallet.iconKey),
                                size: 16,
                                color: Color(wallet.colorValue),
                              ),
                              label: Text(wallet.name),
                              onSelected: (_) {
                                setModalState(() {
                                  if (isSelected) {
                                    nextSelection.remove(wallet.id);
                                  } else {
                                    nextSelection.add(wallet.id);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: <Widget>[
                        Expanded(
                            child: OutlinedButton(
                            onPressed: () {
                              nextSelection.clear();
                              Navigator.of(context).pop(true);
                            },
                            child: Text(context.l10n.clearAction),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: Text(context.l10n.applyAction),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (applied == true) {
      await ref
          .read(transactionHistoryControllerProvider.notifier)
          .setWalletIds(nextSelection);
    }
  }
}

class ReportsTab extends ConsumerStatefulWidget {
  const ReportsTab({super.key});

  @override
  ConsumerState<ReportsTab> createState() => _ReportsTabState();
}

class _ReportsTabState extends ConsumerState<ReportsTab> {
  AnalyticsPeriod _period = AnalyticsPeriod.monthly;

  @override
  Widget build(BuildContext context) {
    final currency =
        ref.watch(currentUserProfileProvider).asData?.value?.currency ??
        AppConstants.defaultCurrency;
    final categories =
        ref.watch(allCategoriesProvider).asData?.value ??
        const <CategoryModel>[];
    final languageCode =
        ref.watch(currentUserProfileProvider).asData?.value?.language ??
        Localizations.localeOf(context).languageCode;
    final analyticsAsync = ref.watch(periodAnalyticsProvider(_period));
    final isWide = MediaQuery.sizeOf(context).width >= 960;

    return analyticsAsync.when(
      data: (analytics) {
        final categoryMap = {
          for (final category in categories) category.id: category,
        };
        final breakdown = _buildBreakdownItems(
          analytics: analytics,
          categoryMap: categoryMap,
          languageCode: languageCode,
        );
        final topCategory = analytics.topCategoryId == null
            ? null
            : categoryMap[analytics.topCategoryId!];

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
          children: <Widget>[
            buildPremiumCard(
              context: context,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    context.l10n.reportTitle,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: AnalyticsPeriod.values.map((period) {
                      return _FilterChip(
                        label: period.labelFor(languageCode),
                        selected: _period == period,
                        onTap: () {
                          setState(() {
                            _period = period;
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            if (isWide)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    flex: 3,
                    child: IncomeExpenseBarChartCard(
                      analytics: analytics,
                      title: context.l10n.reportsIncomeVsExpenseTitle,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: CategoryBreakdownChartCard(
                      items: breakdown,
                      title: context.l10n.reportsCategoryBreakdownTitle,
                    ),
                  ),
                ],
              )
            else ...<Widget>[
              IncomeExpenseBarChartCard(
                analytics: analytics,
                title: context.l10n.reportsIncomeVsExpenseTitle,
              ),
              const SizedBox(height: 16),
              CategoryBreakdownChartCard(
                items: breakdown,
                title: context.l10n.reportsCategoryBreakdownTitle,
              ),
            ],
            const SizedBox(height: 18),
            Wrap(
              spacing: 14,
              runSpacing: 14,
              children: <Widget>[
                SizedBox(
                  width: isWide ? 250 : double.infinity,
                  child: AnalyticsMetricCard(
                    label: context.l10n.totalIncomeLabel,
                    value: _formatCurrency(
                      analytics.totalIncome,
                      currency,
                      languageCode,
                    ),
                    toneColor: const Color(0xFF2ECC9A),
                  ),
                ),
                SizedBox(
                  width: isWide ? 250 : double.infinity,
                  child: AnalyticsMetricCard(
                    label: context.l10n.totalExpenseLabel,
                    value: _formatCurrency(
                      analytics.totalExpense,
                      currency,
                      languageCode,
                    ),
                    toneColor: const Color(0xFFE85D5D),
                  ),
                ),
                SizedBox(
                  width: isWide ? 250 : double.infinity,
                  child: AnalyticsMetricCard(
                    label: context.l10n.netBalanceLabel,
                    value: _formatCurrency(analytics.net, currency, languageCode),
                    toneColor: Theme.of(context).colorScheme.primary,
                  ),
                ),
                SizedBox(
                  width: isWide ? 250 : double.infinity,
                  child: AnalyticsMetricCard(
                    label: analytics.period.averageExpenseLabelFor(
                      languageCode,
                    ),
                    value: _formatCurrency(
                      analytics.averageExpense,
                      currency,
                      languageCode,
                    ),
                    toneColor: const Color(0xFFED8F41),
                  ),
                ),
                SizedBox(
                  width: isWide ? 250 : double.infinity,
                  child: AnalyticsMetricCard(
                    label: analytics.period.peakExpenseLabelFor(languageCode),
                    value: _formatCurrency(
                      analytics.peakExpenseAmount,
                      currency,
                      languageCode,
                    ),
                    highlight:
                        analytics.peakExpenseBucketLabel ??
                        context.l10n.waitingForSpending,
                    toneColor: const Color(0xFFE85D5D),
                  ),
                ),
                SizedBox(
                  width: isWide ? 250 : double.infinity,
                  child: AnalyticsMetricCard(
                    label: context.l10n.topCategoryLabel,
                    value: _formatCurrency(
                      analytics.topCategoryAmount,
                      currency,
                      languageCode,
                    ),
                    highlight:
                        topCategory?.localizedName(languageCode) ??
                        context.l10n.noTopCategoryYet,
                    toneColor: topCategory == null
                        ? Theme.of(context).colorScheme.primary
                        : Color(topCategory.colorValue),
                  ),
                ),
              ],
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
        children: <Widget>[
          EmptyFinanceCard(
            title: context.l10n.reportsLoadingTitle,
            subtitle: error.toString(),
          ),
        ],
      ),
    );
  }
}

class _TransactionHistoryHeader extends StatelessWidget {
  const _TransactionHistoryHeader({
    required this.searchExpanded,
    required this.searchController,
    required this.searchValue,
    required this.selectedType,
    required this.activeCategoryCount,
    required this.activeWalletCount,
    required this.hasDateRange,
    required this.sortLabel,
    required this.resultCount,
    required this.hasAnyFilter,
    required this.onToggleSearch,
    required this.onSearchChanged,
    required this.onTypeSelected,
    required this.onOpenCategoryFilter,
    required this.onOpenWalletFilter,
    required this.onPickDateRange,
    required this.onPickSort,
    required this.onClearFilters,
    required this.onAddNew,
  });

  final bool searchExpanded;
  final TextEditingController searchController;
  final String searchValue;
  final String selectedType;
  final int activeCategoryCount;
  final int activeWalletCount;
  final bool hasDateRange;
  final String sortLabel;
  final int resultCount;
  final bool hasAnyFilter;
  final VoidCallback onToggleSearch;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onTypeSelected;
  final VoidCallback onOpenCategoryFilter;
  final VoidCallback onOpenWalletFilter;
  final VoidCallback onPickDateRange;
  final VoidCallback onPickSort;
  final VoidCallback onClearFilters;
  final VoidCallback onAddNew;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return buildPremiumCard(
      context: context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          LayoutBuilder(
            builder: (context, constraints) {
              final titleBlock = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    l10n.transactionHistoryTitle,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.resultCountLabel(resultCount),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color?.withValues(
                        alpha: 0.72,
                      ),
                    ),
                  ),
                ],
              );

              final actions = Wrap(
                spacing: 10,
                runSpacing: 10,
                children: <Widget>[
                  IconButton.filledTonal(
                    onPressed: onToggleSearch,
                    icon: Icon(
                      searchExpanded || searchValue.trim().isNotEmpty
                          ? Icons.close_rounded
                          : Icons.search_rounded,
                    ),
                  ),
                  FilledButton.tonalIcon(
                    onPressed: onAddNew,
                    icon: const Icon(Icons.add_rounded),
                    label: Text(l10n.addAction),
                  ),
                ],
              );

              if (constraints.maxWidth < 420) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    titleBlock,
                    const SizedBox(height: 14),
                    actions,
                  ],
                );
              }

              return Row(
                children: <Widget>[
                  Expanded(child: titleBlock),
                  const SizedBox(width: 12),
                  actions,
                ],
              );
            },
          ),
          if (searchExpanded || searchValue.trim().isNotEmpty) ...<Widget>[
            const SizedBox(height: 16),
            TextField(
              controller: searchController,
              onChanged: onSearchChanged,
              decoration: InputDecoration(
                hintText: l10n.searchNoteAmountHint,
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: searchValue.trim().isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          searchController.clear();
                          onSearchChanged('');
                        },
                        icon: const Icon(Icons.close_rounded),
                      ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: <Widget>[
              _FilterChip(
                label: l10n.allLabel,
                selected: selectedType == TransactionHistoryFilter.allTypes,
                onTap: () => onTypeSelected(TransactionHistoryFilter.allTypes),
              ),
              _FilterChip(
                label: l10n.incomeTypeLabel,
                selected: selectedType == FinanceCatalog.incomeType,
                onTap: () => onTypeSelected(FinanceCatalog.incomeType),
              ),
              _FilterChip(
                label: l10n.expenseTypeLabel,
                selected: selectedType == FinanceCatalog.expenseType,
                onTap: () => onTypeSelected(FinanceCatalog.expenseType),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: <Widget>[
              _HistoryFilterPill(
                label: l10n.categoryFilterLabel(activeCategoryCount),
                icon: Icons.category_rounded,
                active: activeCategoryCount > 0,
                onTap: onOpenCategoryFilter,
              ),
              _HistoryFilterPill(
                label: l10n.walletFilterLabel(activeWalletCount),
                icon: Icons.account_balance_wallet_outlined,
                active: activeWalletCount > 0,
                onTap: onOpenWalletFilter,
              ),
              _HistoryFilterPill(
                label: hasDateRange ? l10n.dateRangeSetLabel : l10n.dateRangeLabel,
                icon: Icons.date_range_rounded,
                active: hasDateRange,
                onTap: onPickDateRange,
              ),
              _HistoryFilterPill(
                label: sortLabel,
                icon: Icons.swap_vert_rounded,
                active: sortLabel != _sortLabel(context, TransactionHistorySort.latest),
                onTap: onPickSort,
              ),
              if (hasAnyFilter)
                _HistoryFilterPill(
                  label: l10n.clearAction,
                  icon: Icons.restart_alt_rounded,
                  active: true,
                  onTap: onClearFilters,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryPill extends StatelessWidget {
  const _SummaryPill({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _TopCategoryChip extends StatelessWidget {
  const _TopCategoryChip({
    required this.label,
    required this.amount,
    required this.color,
  });

  final String label;
  final String amount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.16)),
      ),
      child: Row(
        children: <Widget>[
          CircleAvatar(
            radius: 18,
            backgroundColor: color.withValues(alpha: 0.18),
            foregroundColor: color,
            child: const Icon(Icons.workspace_premium_rounded, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  context.l10n.topSpendingCategoryTitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withValues(
                      alpha: 0.72,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: theme.textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

List<CategoryBreakdownViewData> _buildBreakdownItems({
  required PeriodAnalytics analytics,
  required Map<String, CategoryModel> categoryMap,
  required String languageCode,
}) {
  const palette = <Color>[
    Color(0xFF3D6BE4),
    Color(0xFFE85D5D),
    Color(0xFF2ECC9A),
    Color(0xFFF5A623),
    Color(0xFF845EF7),
    Color(0xFF4DABF7),
  ];

  if (analytics.expenseByCategory.isEmpty) {
    return const <CategoryBreakdownViewData>[];
  }

  final topFive = analytics.expenseByCategory.take(5).toList(growable: false);
  final remainingAmount = analytics.expenseByCategory
      .skip(5)
      .fold<double>(0, (sum, item) => sum + item.amount);
  final items = <CategoryBreakdownViewData>[];

  for (var index = 0; index < topFive.length; index++) {
    final slice = topFive[index];
    final category = categoryMap[slice.categoryId];
    items.add(
      CategoryBreakdownViewData(
        label: category?.localizedName(languageCode) ??
            (languageCode == 'bn' ? 'ক্যাটাগরি' : 'Category'),
        amount: slice.amount,
        color: category == null
            ? palette[index % palette.length]
            : Color(category.colorValue),
      ),
    );
  }

  if (remainingAmount > 0) {
    items.add(
      CategoryBreakdownViewData(
        label: languageCode == 'bn' ? 'অন্যান্য' : 'Other',
        amount: 0,
        color: Color(0xFF8B93A6),
      ),
    );
    items[items.length - 1] = CategoryBreakdownViewData(
      label: languageCode == 'bn' ? 'অন্যান্য' : 'Other',
      amount: remainingAmount,
      color: const Color(0xFF8B93A6),
    );
  }

  return items;
}

class _HistoryFilterPill extends StatelessWidget {
  const _HistoryFilterPill({
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: active
              ? theme.colorScheme.primary.withValues(alpha: 0.12)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: active ? theme.colorScheme.primary : theme.dividerColor,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              icon,
              size: 18,
              color: active
                  ? theme.colorScheme.primary
                  : theme.textTheme.bodyMedium?.color,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: active
                    ? theme.colorScheme.primary
                    : theme.textTheme.bodyMedium?.color,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeleteBackground extends StatelessWidget {
  const _DeleteBackground({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Icon(Icons.delete_outline_rounded, color: color),
    );
  }
}

class _HistoryTransactionTile extends StatelessWidget {
  const _HistoryTransactionTile({
    required this.title,
    required this.note,
    required this.walletName,
    required this.timeLabel,
    required this.amount,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String note;
  final String? walletName;
  final String timeLabel;
  final String amount;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            CircleAvatar(
              radius: 22,
              backgroundColor: color.withValues(alpha: 0.14),
              foregroundColor: color,
              child: Icon(icon),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (note.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 4),
                    Text(
                      note,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withValues(
                          alpha: 0.78,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: <Widget>[
                      if (walletName != null && walletName!.trim().isNotEmpty)
                        _HistoryMetaChip(
                          label: walletName!,
                          icon: Icons.account_balance_wallet_outlined,
                        ),
                      _HistoryMetaChip(
                        label: timeLabel,
                        icon: Icons.schedule_rounded,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              amount,
              style: theme.textTheme.titleMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryMetaChip extends StatelessWidget {
  const _HistoryMetaChip({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.84),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            icon,
            size: 14,
            color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.74),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

List<Widget> _buildTransactionSections(
  BuildContext context, {
  required List<TransactionModel> transactions,
  required Map<String, CategoryModel> categoryMap,
  required Map<String, WalletModel> walletMap,
  required String currency,
  required String languageCode,
  required Future<void> Function(TransactionModel transaction)
  onOpenTransaction,
  required Future<void> Function(TransactionModel transaction)
  onDeleteTransaction,
}) {
  final grouped = <String, List<TransactionModel>>{};

  for (final transaction in transactions) {
    final label = _groupLabelForDate(
      transaction.date,
      languageCode: languageCode,
      l10n: context.l10n,
    );
    grouped.putIfAbsent(label, () => <TransactionModel>[]);
    grouped[label]!.add(transaction);
  }

  return grouped.entries.map((entry) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: buildPremiumCard(
        context: context,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              entry.key,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            ...entry.value.map((transaction) {
              final category = categoryMap[transaction.categoryId];
              final wallet = walletMap[transaction.walletId];
              final otherWallet = transaction.transferWalletId == null
                  ? null
                  : walletMap[transaction.transferWalletId!];
              final color = FinanceCatalog.transactionColor(transaction);

              return Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Dismissible(
                  key: ValueKey<String>(transaction.id),
                  direction: DismissDirection.endToStart,
                  confirmDismiss: (_) async {
                    await onDeleteTransaction(transaction);
                    return false;
                  },
                  background: const SizedBox.shrink(),
                  secondaryBackground: _DeleteBackground(color: color),
                  child: _HistoryTransactionTile(
                    title: FinanceCatalog.transactionTitle(
                      transaction,
                      category: category,
                      otherWallet: otherWallet,
                      languageCode: languageCode,
                    ),
                    note: transaction.note.trim(),
                    walletName: wallet?.name,
                    timeLabel: LocaleFormatters.formatDate(
                      transaction.date,
                      'hh:mm a',
                      languageCode,
                    ),
                    amount:
                        '${transaction.type == FinanceCatalog.incomeType ? '+' : '-'}${_formatCurrency(transaction.amount, currency, languageCode)}',
                    icon: FinanceCatalog.iconForKey(
                      category?.iconKey ?? 'category',
                    ),
                    color: color,
                    onTap: () => onOpenTransaction(transaction),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }).toList();
}

String _buildSubtitle({
  required TransactionModel transaction,
  required WalletModel? wallet,
  required String languageCode,
  required AppLocalizations l10n,
}) {
  final pieces = <String>[];
  if (wallet != null) {
    pieces.add(wallet.name);
  }
  if (transaction.isTransfer) {
    pieces.add(l10n.transferLabel);
  }
  if (transaction.note.trim().isNotEmpty) {
    pieces.add(transaction.note.trim());
  }
  pieces.add(
    LocaleFormatters.formatDate(transaction.date, 'hh:mm a', languageCode),
  );
  return pieces.join('  •  ');
}

String _groupLabelForDate(
  DateTime date, {
  required String languageCode,
  required AppLocalizations l10n,
}) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final itemDay = DateTime(date.year, date.month, date.day);
  final difference = today.difference(itemDay).inDays;

  if (difference == 0) {
    return l10n.todayLabel;
  }
  if (difference == 1) {
    return l10n.yesterdayLabel;
  }
  if (difference > 1 && difference < 7) {
    return LocaleFormatters.formatDate(date, 'EEEE', languageCode);
  }
  return LocaleFormatters.formatDate(date, 'dd MMM yyyy', languageCode);
}

String _formatCurrency(
  double amount,
  String currency, [
  String languageCode = 'en',
]) {
  return LocaleFormatters.formatCurrency(amount, currency, languageCode);
}

String _sortLabel(BuildContext context, TransactionHistorySort sort) {
  final l10n = context.l10n;
  switch (sort) {
    case TransactionHistorySort.latest:
      return l10n.isBangla ? 'সর্বশেষ' : 'Latest';
    case TransactionHistorySort.oldest:
      return l10n.isBangla ? 'পুরোনো আগে' : 'Oldest';
    case TransactionHistorySort.highestAmount:
      return l10n.isBangla ? 'সর্বোচ্চ পরিমাণ' : 'Highest amount';
    case TransactionHistorySort.lowestAmount:
      return l10n.isBangla ? 'সর্বনিম্ন পরিমাণ' : 'Lowest amount';
  }
}

class _DashboardBudgetCard extends StatelessWidget {
  const _DashboardBudgetCard({required this.overview, required this.currency});

  final BudgetOverview overview;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final languageCode = Localizations.localeOf(context).languageCode;
    final overall = overview.overallBudget;
    final spent = overall?.spent ?? overview.totalCategorySpent;
    final limit = overall?.limit ?? overview.totalCategoryLimit;
    final progress = limit <= 0 ? 0.0 : (spent / limit).clamp(0, 1).toDouble();

    return buildPremiumCard(
      context: context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            l10n.budgetPulseTitle,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            overall == null
                ? (l10n.isBangla
                      ? 'এই মাসের ক্যাটাগরি বাজেটের মোট খরচ ট্র্যাক করা হচ্ছে।'
                      : 'Tracking category budget totals for this month.')
                : (l10n.isBangla
                      ? 'খরচ বদলালে আপনার মোট মাসিক সীমা স্বয়ংক্রিয়ভাবে আপডেট হবে।'
                      : 'Your overall monthly limit updates automatically as expenses change.'),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(
                context,
              ).textTheme.bodyMedium?.color?.withValues(alpha: 0.74),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: <Widget>[
              Expanded(
                child: _MiniStatTile(
                  label: l10n.spentLabel,
                  value: _formatCurrency(spent, currency, languageCode),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MiniStatTile(
                  label: l10n.limitLabel,
                  value: limit <= 0
                      ? l10n.notSetLabel
                      : _formatCurrency(limit, currency, languageCode),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MiniStatTile(
                  label: l10n.activeBudgetsLabel,
                  value: LocaleFormatters.formatNumber(
                    overview.categoryBudgets.length,
                    languageCode,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ProgressBarRow(label: l10n.monthlyProgressLabel, value: progress),
        ],
      ),
    );
  }
}

class _DashboardBudgetAlertCard extends StatelessWidget {
  const _DashboardBudgetAlertCard({
    required this.overview,
    required this.currency,
  });

  final BudgetOverview overview;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final languageCode = Localizations.localeOf(context).languageCode;
    final exceeded = overview.exceededBudgets.take(2).toList(growable: false);
    final near = overview.nearLimitBudgets.take(2).toList(growable: false);

    return buildPremiumCard(
      context: context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            l10n.budgetAlertsTitle(exceeded.isNotEmpty),
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          ...exceeded.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                l10n.categoryExceededLabel(
                  item.category?.localizedName(languageCode) ??
                      l10n.categoryFilterLabel(0),
                  _formatCurrency(
                    item.budget.spent - item.budget.limit,
                    currency,
                    languageCode,
                  ),
                ),
              ),
            ),
          ),
          ...near.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                l10n.categoryNearLimitLabel(
                  item.category?.localizedName(languageCode) ??
                      l10n.categoryFilterLabel(0),
                  (item.budget.progress * 100).round(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentTransactionsCard extends StatelessWidget {
  const _RecentTransactionsCard({
    required this.transactions,
    required this.categoryMap,
    required this.walletMap,
    required this.currency,
    required this.languageCode,
  });

  final List<TransactionModel> transactions;
  final Map<String, CategoryModel> categoryMap;
  final Map<String, WalletModel> walletMap;
  final String currency;
  final String languageCode;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return buildPremiumCard(
      context: context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          LayoutBuilder(
            builder: (context, constraints) {
              final title = Text(
                l10n.recentTransactionsTitle,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              );
              final button = TextButton(
                onPressed: () => openTransactionEditorPage(context),
                child: Text(l10n.addNewAction),
              );

              if (constraints.maxWidth < 320) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[title, const SizedBox(height: 8), button],
                );
              }

              return Row(
                children: <Widget>[
                  Expanded(child: title),
                  const SizedBox(width: 12),
                  button,
                ],
              );
            },
          ),
          if (transactions.isEmpty) ...<Widget>[
            const SizedBox(height: 8),
            EmptyFinanceCard(
              title: l10n.noTransactionsYetTitle,
              subtitle: l10n.noTransactionsYetSubtitle,
              actionLabel: l10n.addTransactionAction,
              onAction: () => openTransactionEditorPage(context),
            ),
          ] else
            ...transactions.take(5).map((transaction) {
              final category = categoryMap[transaction.categoryId];
              final wallet = walletMap[transaction.walletId];
              final otherWallet = transaction.transferWalletId == null
                  ? null
                  : walletMap[transaction.transferWalletId!];
              final color = FinanceCatalog.transactionColor(transaction);

              return Padding(
                padding: const EdgeInsets.only(top: 12),
                child: FinanceTransactionTile(
                  title: FinanceCatalog.transactionTitle(
                    transaction,
                    category: category,
                    otherWallet: otherWallet,
                    languageCode: languageCode,
                  ),
                  subtitle: _buildSubtitle(
                    transaction: transaction,
                    wallet: wallet,
                    languageCode: languageCode,
                    l10n: l10n,
                  ),
                  amount:
                      '${transaction.type == FinanceCatalog.incomeType ? '+' : '-'}${_formatCurrency(transaction.amount, currency, languageCode)}',
                  icon: FinanceCatalog.transactionIcon(
                    transaction,
                    category: category,
                  ),
                  color: color,
                  onTap: () => openTransactionEditorPage(
                    context,
                    transaction: transaction,
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _TodayPulseCard extends StatelessWidget {
  const _TodayPulseCard({
    required this.summary,
    required this.transactionCount,
    required this.currency,
    required this.monthNet,
  });

  final DashboardSummary summary;
  final int transactionCount;
  final String currency;
  final double monthNet;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final languageCode = Localizations.localeOf(context).languageCode;
    final theme = Theme.of(context);
    final net = summary.todayIncome - summary.todayExpense;

    return buildPremiumCard(
      context: context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            l10n.todaysPulseTitle,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.homeLiveSubtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.74),
            ),
          ),
          const SizedBox(height: 18),
          ProgressBarRow(
            label: l10n.incomeVsExpenseLabel,
            value: summary.todayIncome == 0 && summary.todayExpense == 0
                ? 0
                : (summary.todayExpense /
                          (summary.todayIncome + summary.todayExpense))
                      .clamp(0, 1)
                      .toDouble(),
          ),
          const SizedBox(height: 16),
          Row(
            children: <Widget>[
              Expanded(
                child: _MiniStatTile(
                  label: l10n.todayNetLabel,
                  value: _formatCurrency(net, currency, languageCode),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MiniStatTile(
                  label: l10n.monthNetLabel,
                  value: _formatCurrency(monthNet, currency, languageCode),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MiniStatTile(
                  label: l10n.recentItemsLabel,
                  value: LocaleFormatters.formatNumber(
                    transactionCount,
                    languageCode,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStatTile extends StatelessWidget {
  const _MiniStatTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.56),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.72),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? theme.colorScheme.primary.withValues(alpha: 0.14)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? theme.colorScheme.primary : theme.dividerColor,
          ),
        ),
        child: Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: selected
                ? theme.colorScheme.primary
                : theme.textTheme.bodyMedium?.color,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
