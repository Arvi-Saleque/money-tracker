import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../shared/widgets/premium_card.dart';
import 'dashboard_data.dart';

class HeroBadge extends StatelessWidget {
  const HeroBadge({super.key, required this.monthLabel});

  final String monthLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            monthLabel,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.82),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '+8.2%',
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class HeroMetric extends StatelessWidget {
  const HeroMetric({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, color: Colors.white),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.82),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class WalletSummaryCard extends StatelessWidget {
  const WalletSummaryCard({super.key, required this.wallet});

  final WalletSummary wallet;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return buildPremiumCard(
      context: context,
      child: Row(
        children: <Widget>[
          CircleAvatar(
            radius: 24,
            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.12),
            foregroundColor: theme.colorScheme.primary,
            child: Icon(wallet.icon),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  wallet.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(wallet.balance, style: theme.textTheme.bodyLarge),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RecentTransactionsCard extends StatelessWidget {
  const RecentTransactionsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return buildPremiumCard(
      context: context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Recent transactions',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          ...mockTransactions
              .take(4)
              .map(
                (transaction) => Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: TransactionTile(transaction: transaction),
                ),
              ),
        ],
      ),
    );
  }
}

class BudgetSnapshotCard extends StatelessWidget {
  const BudgetSnapshotCard({super.key, required this.onThemeToggle});

  final Future<void> Function() onThemeToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return buildPremiumCard(
      context: context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Budget snapshot',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'March spending is at 63% of the planned monthly budget.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.74),
            ),
          ),
          const SizedBox(height: 16),
          const ProgressBarRow(label: 'Overall', value: 0.63),
          const SizedBox(height: 12),
          const ProgressBarRow(label: 'Food', value: 0.78),
          const SizedBox(height: 12),
          const ProgressBarRow(label: 'Transport', value: 0.44),
          const SizedBox(height: 18),
          OutlinedButton.icon(
            onPressed: onThemeToggle,
            icon: const Icon(Icons.palette_outlined),
            label: const Text('Try theme switch'),
          ),
        ],
      ),
    );
  }
}

class QuickActionsCard extends StatelessWidget {
  const QuickActionsCard({super.key, required this.actions});

  final List<ActionShortcut> actions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return buildPremiumCard(
      context: context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Shortcuts',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: actions
                .map(
                  (action) => SizedBox(
                    width: 124,
                    child: buildPremiumInkCard(
                      context: context,
                      onTap: () => context.push(action.route),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 16,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Icon(action.icon, color: theme.colorScheme.primary),
                          const SizedBox(height: 12),
                          Text(
                            action.label,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class TransactionTile extends StatelessWidget {
  const TransactionTile({super.key, required this.transaction});

  final MockTransaction transaction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final amountColor = transaction.isIncome
        ? const Color(0xFF2ECC9A)
        : const Color(0xFFE85D5D);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        children: <Widget>[
          CircleAvatar(
            radius: 22,
            backgroundColor: amountColor.withValues(alpha: 0.14),
            foregroundColor: amountColor,
            child: Icon(transaction.icon),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  transaction.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${transaction.subtitle}  •  ${transaction.timeLabel}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withValues(
                      alpha: 0.72,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${transaction.isIncome ? '+' : '-'}${transaction.amount}',
            style: theme.textTheme.titleMedium?.copyWith(
              color: amountColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class ReportMetricCard extends StatelessWidget {
  const ReportMetricCard(this.label, this.value, {super.key});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return buildPremiumCard(
      context: context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.74),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class ProgressBarRow extends StatelessWidget {
  const ProgressBarRow({super.key, required this.label, required this.value});

  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Text(label),
            const Spacer(),
            Text('${(value * 100).round()}%'),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 10,
            backgroundColor: theme.dividerColor,
          ),
        ),
      ],
    );
  }
}

class InsightTile extends StatelessWidget {
  const InsightTile({super.key, required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          CircleAvatar(
            radius: 20,
            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.12),
            foregroundColor: theme.colorScheme.primary,
            child: const Icon(Icons.insights_rounded),
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
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodyMedium?.color?.withValues(
                      alpha: 0.74,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MiniPill extends StatelessWidget {
  const MiniPill({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelLarge?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class CalendarDayTile extends StatelessWidget {
  const CalendarDayTile({
    super.key,
    required this.day,
    required this.dotColor,
    required this.isSelected,
  });

  final int day;
  final Color? dotColor;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: isSelected
            ? theme.colorScheme.primary.withValues(alpha: 0.16)
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isSelected ? theme.colorScheme.primary : theme.dividerColor,
        ),
      ),
      child: Stack(
        children: <Widget>[
          Center(
            child: Text(
              '$day',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (dotColor != null)
            Positioned(
              bottom: 8,
              right: 0,
              left: 0,
              child: Center(
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class SectionLabel extends StatelessWidget {
  const SectionLabel(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
    );
  }
}

class ChoicePreviewChip extends StatelessWidget {
  const ChoicePreviewChip({
    super.key,
    required this.label,
    this.selected = false,
  });

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Chip(
      label: Text(label),
      backgroundColor: selected
          ? theme.colorScheme.primary.withValues(alpha: 0.14)
          : theme.chipTheme.backgroundColor,
      side: BorderSide(
        color: selected ? theme.colorScheme.primary : theme.dividerColor,
      ),
      labelStyle: theme.textTheme.bodyMedium?.copyWith(
        color: selected
            ? theme.colorScheme.primary
            : theme.textTheme.bodyMedium?.color,
        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
      ),
    );
  }
}

class CategoryPreviewChip extends StatelessWidget {
  const CategoryPreviewChip({
    super.key,
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }
}

class DaySummaryRow extends StatelessWidget {
  const DaySummaryRow({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Text(label),
        const Spacer(),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

List<Widget> buildTransactionSections(
  BuildContext context,
  List<MockTransaction> transactions,
) {
  final grouped = <String, List<MockTransaction>>{};

  for (final transaction in transactions) {
    grouped.putIfAbsent(transaction.group, () => <MockTransaction>[]);
    grouped[transaction.group]!.add(transaction);
  }

  return grouped.entries
      .map(
        (entry) => Padding(
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
                ...entry.value.map(
                  (transaction) => Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: TransactionTile(transaction: transaction),
                  ),
                ),
              ],
            ),
          ),
        ),
      )
      .toList();
}
