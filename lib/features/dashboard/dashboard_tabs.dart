import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/gradient_colors.dart';
import '../../shared/models/category_model.dart';
import '../../shared/models/transaction_model.dart';
import '../../shared/models/wallet_model.dart';
import '../../shared/widgets/premium_card.dart';
import '../profile/profile_providers.dart';
import '../transactions/finance_catalog.dart';
import '../transactions/transaction_editor_sheet.dart';
import '../transactions/transaction_providers.dart';
import 'dashboard_data.dart';
import 'dashboard_ui_parts.dart';

class HomeTab extends ConsumerWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final gradients = theme.extension<GradientColors>()!;
    final isWide = MediaQuery.sizeOf(context).width >= 900;
    final monthLabel = DateFormat('MMMM yyyy').format(DateTime.now());
    final walletsAsync = ref.watch(walletsProvider);
    final recentTransactionsAsync = ref.watch(recentTransactionsProvider);
    final summary = ref.watch(dashboardSummaryProvider);
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
                                'Available balance',
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
                          label: 'Today income',
                          value: _formatCurrency(summary.todayIncome, currency),
                          icon: Icons.arrow_downward_rounded,
                        ),
                        HeroMetric(
                          label: 'Today expense',
                          value: _formatCurrency(
                            summary.todayExpense,
                            currency,
                          ),
                          icon: Icons.arrow_upward_rounded,
                        ),
                        HeroMetric(
                          label: 'Net today',
                          value: _formatCurrency(
                            summary.todayIncome - summary.todayExpense,
                            currency,
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
                  title: 'Your wallet is getting ready',
                  subtitle:
                      'Starter data usually appears right after sign-in. Give it a moment and reopen the screen if needed.',
                  actionLabel: 'Add transaction',
                  onAction: () => showTransactionEditorSheet(context),
                )
              else
                Wrap(
                  spacing: 14,
                  runSpacing: 14,
                  children: wallets
                      .map(
                        (wallet) => SizedBox(
                          width: isWide ? 342 : double.infinity,
                          child: WalletOverviewCard(
                            name: wallet.name,
                            balance: _formatCurrency(wallet.balance, currency),
                            icon: FinanceCatalog.iconForKey(wallet.iconKey),
                            color: Color(wallet.colorValue),
                          ),
                        ),
                      )
                      .toList(),
                ),
              const SizedBox(height: 20),
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
                          ),
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

class TransactionsTab extends ConsumerStatefulWidget {
  const TransactionsTab({super.key});

  @override
  ConsumerState<TransactionsTab> createState() => _TransactionsTabState();
}

class _TransactionsTabState extends ConsumerState<TransactionsTab> {
  String _query = '';
  String _selectedFilter = 'all';

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(transactionsProvider);
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
    final transactions =
        transactionsAsync.asData?.value ?? const <TransactionModel>[];
    final filteredTransactions = transactions.where((transaction) {
      if (_selectedFilter != 'all' && transaction.type != _selectedFilter) {
        return false;
      }
      if (_query.trim().isEmpty) {
        return true;
      }

      final category = categoryMap[transaction.categoryId];
      final wallet = walletMap[transaction.walletId];
      final haystack = <String>[
        category?.localizedName(languageCode) ?? '',
        wallet?.name ?? '',
        transaction.note,
        transaction.amount.toString(),
      ].join(' ').toLowerCase();
      return haystack.contains(_query.trim().toLowerCase());
    }).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
      children: <Widget>[
        buildPremiumCard(
          context: context,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextField(
                onChanged: (value) {
                  setState(() {
                    _query = value;
                  });
                },
                decoration: const InputDecoration(
                  hintText: 'Search by note, wallet, or category',
                  prefixIcon: Icon(Icons.search_rounded),
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: <Widget>[
                  _FilterChip(
                    label: 'All',
                    selected: _selectedFilter == 'all',
                    onTap: () => setState(() => _selectedFilter = 'all'),
                  ),
                  _FilterChip(
                    label: 'Income',
                    selected: _selectedFilter == FinanceCatalog.incomeType,
                    onTap: () => setState(
                      () => _selectedFilter = FinanceCatalog.incomeType,
                    ),
                  ),
                  _FilterChip(
                    label: 'Expense',
                    selected: _selectedFilter == FinanceCatalog.expenseType,
                    onTap: () => setState(
                      () => _selectedFilter = FinanceCatalog.expenseType,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  final summaryText =
                      '${filteredTransactions.length} transaction${filteredTransactions.length == 1 ? '' : 's'}';
                  final button = OutlinedButton.icon(
                    onPressed: () => showTransactionEditorSheet(context),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Add new'),
                  );

                  if (constraints.maxWidth < 340) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          summaryText,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 12),
                        button,
                      ],
                    );
                  }

                  return Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          summaryText,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                      const SizedBox(width: 12),
                      button,
                    ],
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        if (transactionsAsync.isLoading && transactions.isEmpty)
          const Center(child: CircularProgressIndicator())
        else if (filteredTransactions.isEmpty)
          EmptyFinanceCard(
            title: 'No matching transaction',
            subtitle:
                'Add your first entry or adjust the filters to see more history.',
            actionLabel: 'Add transaction',
            onAction: () => showTransactionEditorSheet(context),
          )
        else
          ..._buildTransactionSections(
            context,
            transactions: filteredTransactions,
            categoryMap: categoryMap,
            walletMap: walletMap,
            currency: currency,
            languageCode: languageCode,
          ),
      ],
    );
  }
}

class CalendarTab extends ConsumerWidget {
  const CalendarTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final days = List<int>.generate(30, (index) => index + 1);
    final todaySummary = ref.watch(dashboardSummaryProvider);
    final currency =
        ref.watch(currentUserProfileProvider).asData?.value?.currency ??
        AppConstants.defaultCurrency;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
      children: <Widget>[
        buildPremiumCard(
          context: context,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text(
                    DateFormat('MMMM yyyy').format(now),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  const MiniPill(label: 'Month View'),
                ],
              ),
              const SizedBox(height: 18),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1,
                ),
                itemCount: days.length,
                itemBuilder: (context, index) {
                  final day = days[index];
                  final hasActivity = day == now.day;

                  return CalendarDayTile(
                    day: day,
                    dotColor: hasActivity ? theme.colorScheme.primary : null,
                    isSelected: day == now.day,
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        buildPremiumCard(
          context: context,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Selected Day Snapshot',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 14),
              DaySummaryRow(
                label: 'Income',
                value: _formatCurrency(todaySummary.todayIncome, currency),
              ),
              const SizedBox(height: 10),
              DaySummaryRow(
                label: 'Expense',
                value: _formatCurrency(todaySummary.todayExpense, currency),
              ),
              const SizedBox(height: 10),
              DaySummaryRow(
                label: 'Net',
                value: _formatCurrency(
                  todaySummary.todayIncome - todaySummary.todayExpense,
                  currency,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ReportsTab extends ConsumerWidget {
  const ReportsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(dashboardSummaryProvider);
    final currency =
        ref.watch(currentUserProfileProvider).asData?.value?.currency ??
        AppConstants.defaultCurrency;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
      children: <Widget>[
        Wrap(
          spacing: 14,
          runSpacing: 14,
          children: <Widget>[
            SizedBox(
              width: 260,
              child: ReportMetricCard(
                'Balance',
                _formatCurrency(summary.totalBalance, currency),
              ),
            ),
            SizedBox(
              width: 260,
              child: ReportMetricCard(
                'Today income',
                _formatCurrency(summary.todayIncome, currency),
              ),
            ),
            SizedBox(
              width: 260,
              child: ReportMetricCard(
                'Today expense',
                _formatCurrency(summary.todayExpense, currency),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        buildPremiumCard(
          context: context,
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Phase 3 progress',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 18),
              ProgressBarRow(label: 'Transactions', value: 0.92),
              SizedBox(height: 14),
              ProgressBarRow(label: 'Categories', value: 0.88),
              SizedBox(height: 14),
              ProgressBarRow(label: 'Dashboard', value: 0.81),
              SizedBox(height: 14),
              ProgressBarRow(label: 'Reports', value: 0.35),
            ],
          ),
        ),
        const SizedBox(height: 18),
        buildPremiumCard(
          context: context,
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Insights',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 14),
              InsightTile(
                title: 'Transactions are now live',
                subtitle:
                    'You can add, edit, delete, and categorize real entries from the app shell.',
              ),
              SizedBox(height: 12),
              InsightTile(
                title: 'Wallet balance updates automatically',
                subtitle:
                    'Every transaction now changes the selected wallet balance in Firestore.',
              ),
              SizedBox(height: 12),
              InsightTile(
                title: 'Reports deepen in later phases',
                subtitle:
                    'This tab is still a light preview until charts and analytics arrive in Phase 5.',
              ),
            ],
          ),
        ),
      ],
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
}) {
  final grouped = <String, List<TransactionModel>>{};

  for (final transaction in transactions) {
    final label = _groupLabelForDate(transaction.date);
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
              final color = transaction.type == FinanceCatalog.incomeType
                  ? const Color(0xFF2ECC9A)
                  : const Color(0xFFE85D5D);

              return Padding(
                padding: const EdgeInsets.only(top: 12),
                child: FinanceTransactionTile(
                  title: category?.localizedName(languageCode) ?? 'Category',
                  subtitle: _buildSubtitle(
                    transaction: transaction,
                    wallet: wallet,
                  ),
                  amount:
                      '${transaction.type == FinanceCatalog.incomeType ? '+' : '-'}${_formatCurrency(transaction.amount, currency)}',
                  icon: FinanceCatalog.iconForKey(
                    category?.iconKey ?? 'category',
                  ),
                  color: color,
                  onTap: () {
                    showTransactionEditorSheet(
                      context,
                      transaction: transaction,
                    );
                  },
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
}) {
  final pieces = <String>[];
  if (wallet != null) {
    pieces.add(wallet.name);
  }
  if (transaction.note.trim().isNotEmpty) {
    pieces.add(transaction.note.trim());
  }
  pieces.add(DateFormat('hh:mm a').format(transaction.date));
  return pieces.join('  •  ');
}

String _groupLabelForDate(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final itemDay = DateTime(date.year, date.month, date.day);
  final difference = today.difference(itemDay).inDays;

  if (difference == 0) {
    return 'Today';
  }
  if (difference == 1) {
    return 'Yesterday';
  }
  if (difference > 1 && difference < 7) {
    return DateFormat('EEEE').format(date);
  }
  return DateFormat('dd MMM yyyy').format(date);
}

String _formatCurrency(double amount, String currency) {
  return NumberFormat.currency(
    locale: 'en_US',
    symbol: currency,
    decimalDigits: 0,
  ).format(amount);
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
    final theme = Theme.of(context);

    return buildPremiumCard(
      context: context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          LayoutBuilder(
            builder: (context, constraints) {
              final title = Text(
                'Recent transactions',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              );
              final button = TextButton(
                onPressed: () => showTransactionEditorSheet(context),
                child: const Text('Add new'),
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
              title: 'No transactions yet',
              subtitle:
                  'Use the add button to save your first expense or income entry.',
              actionLabel: 'Add transaction',
              onAction: () => showTransactionEditorSheet(context),
            ),
          ] else
            ...transactions.take(5).map((transaction) {
              final category = categoryMap[transaction.categoryId];
              final wallet = walletMap[transaction.walletId];
              final color = transaction.type == FinanceCatalog.incomeType
                  ? const Color(0xFF2ECC9A)
                  : const Color(0xFFE85D5D);

              return Padding(
                padding: const EdgeInsets.only(top: 12),
                child: FinanceTransactionTile(
                  title: category?.localizedName(languageCode) ?? 'Category',
                  subtitle: _buildSubtitle(
                    transaction: transaction,
                    wallet: wallet,
                  ),
                  amount:
                      '${transaction.type == FinanceCatalog.incomeType ? '+' : '-'}${_formatCurrency(transaction.amount, currency)}',
                  icon: FinanceCatalog.iconForKey(
                    category?.iconKey ?? 'category',
                  ),
                  color: color,
                  onTap: () => showTransactionEditorSheet(
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
  });

  final DashboardSummary summary;
  final int transactionCount;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final net = summary.todayIncome - summary.todayExpense;

    return buildPremiumCard(
      context: context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Today\'s pulse',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your home screen now reflects live transaction data from Firestore.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.74),
            ),
          ),
          const SizedBox(height: 18),
          ProgressBarRow(
            label: 'Income vs expense',
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
                  label: 'Net',
                  value: _formatCurrency(net, currency),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MiniStatTile(
                  label: 'Recent items',
                  value: '$transactionCount',
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
