import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/theme/gradient_colors.dart';
import '../../shared/widgets/premium_card.dart';
import 'dashboard_data.dart';
import 'dashboard_ui_parts.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key, required this.onThemeToggle});

  final Future<void> Function() onThemeToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gradients = theme.extension<GradientColors>()!;
    final isWide = MediaQuery.sizeOf(context).width >= 900;
    final monthLabel = DateFormat('MMMM yyyy').format(DateTime.now());

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
                                '৳115,230',
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
                    const Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: <Widget>[
                        HeroMetric(
                          label: 'Income',
                          value: '৳42,500',
                          icon: Icons.arrow_downward_rounded,
                        ),
                        HeroMetric(
                          label: 'Expense',
                          value: '৳18,900',
                          icon: Icons.arrow_upward_rounded,
                        ),
                        HeroMetric(
                          label: 'Saved',
                          value: '৳23,600',
                          icon: Icons.savings_rounded,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 14,
                runSpacing: 14,
                children: walletSummaries
                    .map(
                      (wallet) => SizedBox(
                        width: isWide ? 342 : double.infinity,
                        child: WalletSummaryCard(wallet: wallet),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 20),
              if (isWide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Expanded(flex: 3, child: RecentTransactionsCard()),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: <Widget>[
                          BudgetSnapshotCard(onThemeToggle: onThemeToggle),
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
                    BudgetSnapshotCard(onThemeToggle: onThemeToggle),
                    const SizedBox(height: 16),
                    const RecentTransactionsCard(),
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

class TransactionsTab extends StatelessWidget {
  const TransactionsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
      children: <Widget>[
        buildPremiumCard(
          context: context,
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search notes, amount, or category',
                  prefixIcon: Icon(Icons.search_rounded),
                  suffixIcon: Icon(Icons.tune_rounded),
                ),
              ),
              SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: <Widget>[
                  ChoicePreviewChip(label: 'All', selected: true),
                  ChoicePreviewChip(label: 'Income'),
                  ChoicePreviewChip(label: 'Expense'),
                  ChoicePreviewChip(label: 'This month'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        ...buildTransactionSections(context, mockTransactions),
      ],
    );
  }
}

class CalendarTab extends StatelessWidget {
  const CalendarTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final days = List<int>.generate(30, (index) => index + 1);
    final highlightedDays = <int, Color>{
      2: const Color(0xFFE85D5D),
      4: const Color(0xFF2ECC9A),
      7: const Color(0xFFE85D5D),
      12: const Color(0xFF2ECC9A),
      18: const Color(0xFFE85D5D),
      24: const Color(0xFFE85D5D),
      28: const Color(0xFF2ECC9A),
    };

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
                  final dotColor = highlightedDays[day];
                  final isSelected = day == now.day;

                  return CalendarDayTile(
                    day: day,
                    dotColor: dotColor,
                    isSelected: isSelected,
                  );
                },
              ),
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
                'Selected Day Snapshot',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 14),
              DaySummaryRow(label: 'Income', value: '৳3,200'),
              SizedBox(height: 10),
              DaySummaryRow(label: 'Expense', value: '৳1,650'),
              SizedBox(height: 10),
              DaySummaryRow(label: 'Net', value: '৳1,550'),
            ],
          ),
        ),
      ],
    );
  }
}

class ReportsTab extends StatelessWidget {
  const ReportsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
      children: <Widget>[
        Wrap(
          spacing: 14,
          runSpacing: 14,
          children: const <Widget>[
            SizedBox(width: 260, child: ReportMetricCard('Income', '৳42,500')),
            SizedBox(width: 260, child: ReportMetricCard('Expense', '৳18,900')),
            SizedBox(width: 260, child: ReportMetricCard('Savings', '৳23,600')),
          ],
        ),
        const SizedBox(height: 18),
        buildPremiumCard(
          context: context,
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Monthly spending trend',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 18),
              ProgressBarRow(label: 'Food', value: 0.86),
              SizedBox(height: 14),
              ProgressBarRow(label: 'Transport', value: 0.48),
              SizedBox(height: 14),
              ProgressBarRow(label: 'Bills', value: 0.64),
              SizedBox(height: 14),
              ProgressBarRow(label: 'Shopping', value: 0.33),
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
                title: 'Food spending is the highest this month',
                subtitle:
                    'Roughly 34% of expenses are going to food and dining.',
              ),
              SizedBox(height: 12),
              InsightTile(
                title: 'Savings pace is healthy',
                subtitle:
                    'This mock dashboard shows stronger saving than last month.',
              ),
              SizedBox(height: 12),
              InsightTile(
                title: 'Bills week is coming',
                subtitle:
                    'Internet, rent, and utilities cluster late in the month.',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

Future<void> showQuickAddSheet(BuildContext context) async {
  final theme = Theme.of(context);

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      final viewInsets = MediaQuery.viewInsetsOf(context);

      return Padding(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + viewInsets.bottom),
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: theme.dividerColor),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Center(
                  child: Container(
                    width: 54,
                    height: 5,
                    decoration: BoxDecoration(
                      color: theme.dividerColor,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                Text(
                  'Quick Add Transaction',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'This is a preview sheet for the real transaction flow coming in Phase 3.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodyMedium?.color?.withValues(
                      alpha: 0.74,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const SectionLabel('Type'),
                const SizedBox(height: 10),
                const Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: <Widget>[
                    ChoicePreviewChip(label: 'Expense', selected: true),
                    ChoicePreviewChip(label: 'Income'),
                    ChoicePreviewChip(label: 'Transfer'),
                  ],
                ),
                const SizedBox(height: 18),
                const SectionLabel('Amount'),
                const SizedBox(height: 10),
                const TextField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    prefixText: '৳ ',
                    hintText: '0.00',
                  ),
                ),
                const SizedBox(height: 18),
                const SectionLabel('Category'),
                const SizedBox(height: 10),
                const Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: <Widget>[
                    CategoryPreviewChip(
                      icon: Icons.fastfood_rounded,
                      label: 'Food',
                    ),
                    CategoryPreviewChip(
                      icon: Icons.directions_bus_filled_rounded,
                      label: 'Transport',
                    ),
                    CategoryPreviewChip(
                      icon: Icons.shopping_bag_rounded,
                      label: 'Shopping',
                    ),
                    CategoryPreviewChip(
                      icon: Icons.receipt_long_rounded,
                      label: 'Bills',
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                const TextField(
                  decoration: InputDecoration(hintText: 'Note (optional)'),
                ),
                const SizedBox(height: 22),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Close'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Demo only for now. Real transaction saving comes in Phase 3.',
                              ),
                            ),
                          );
                        },
                        child: const Text('Save'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
