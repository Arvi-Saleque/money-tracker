import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_constants.dart';
import '../../shared/models/budget_model.dart';
import '../../shared/widgets/premium_card.dart';
import '../profile/profile_providers.dart';
import '../transactions/finance_catalog.dart';
import '../transactions/transaction_providers.dart';
import 'budget_providers.dart';

class BudgetsScreen extends ConsumerWidget {
  const BudgetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMonth = ref.watch(budgetMonthProvider);
    final budgetsAsync = ref.watch(currentMonthBudgetsProvider);
    final overview = ref.watch(budgetOverviewProvider);
    final profile = ref.watch(currentUserProfileProvider).asData?.value;
    final currency = profile?.currency ?? AppConstants.defaultCurrency;

    return Scaffold(
      appBar: AppBar(title: const Text('Budgets')),
      body: SafeArea(
        child: budgetsAsync.when(
          data: (_) => SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 920),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _MonthHeader(selectedMonth: selectedMonth),
                    const SizedBox(height: 16),
                    _OverallBudgetCard(overview: overview, currency: currency),
                    if (overview.hasWarnings) ...<Widget>[
                      const SizedBox(height: 16),
                      _BudgetWarningCard(
                        overview: overview,
                        currency: currency,
                      ),
                    ],
                    const SizedBox(height: 20),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            'Category budgets',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                        FilledButton.icon(
                          onPressed: () => _openBudgetEditor(context),
                          icon: const Icon(Icons.add_rounded),
                          label: const Text('Add budget'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (overview.categoryBudgets.isEmpty)
                      _EmptyBudgetCard(onAdd: () => _openBudgetEditor(context))
                    else
                      ...overview.categoryBudgets.map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _BudgetTile(
                            item: item,
                            currency: currency,
                            onTap: () =>
                                _openBudgetEditor(context, budget: item.budget),
                            onDelete: () =>
                                _deleteBudget(context, ref, item.budget),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text(error.toString())),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openBudgetEditor(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add budget'),
      ),
    );
  }

  Future<void> _openBudgetEditor(
    BuildContext context, {
    BudgetModel? budget,
  }) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (context) => BudgetEditorPage(budget: budget),
      ),
    );
  }

  Future<void> _deleteBudget(
    BuildContext context,
    WidgetRef ref,
    BudgetModel budget,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete budget'),
        content: const Text('Delete this budget limit?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    try {
      await ref
          .read(budgetActionControllerProvider.notifier)
          .deleteBudget(budget.id);
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Budget deleted.')));
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }
}

class BudgetEditorPage extends ConsumerStatefulWidget {
  const BudgetEditorPage({super.key, this.budget});

  final BudgetModel? budget;

  @override
  ConsumerState<BudgetEditorPage> createState() => _BudgetEditorPageState();
}

class _BudgetEditorPageState extends ConsumerState<BudgetEditorPage> {
  late final TextEditingController _limitController;
  late DateTime _selectedMonth;
  String _selectedCategoryId = BudgetModel.overallCategoryId;

  bool get _isEditing => widget.budget != null;

  @override
  void initState() {
    super.initState();
    final budget = widget.budget;
    _limitController = TextEditingController(
      text: budget == null ? '' : _trimZeroes(budget.limit),
    );
    _selectedMonth = budget == null
        ? DateTime.now()
        : DateTime(budget.year, budget.month);
    _selectedCategoryId = budget?.categoryId ?? BudgetModel.overallCategoryId;
  }

  @override
  void dispose() {
    _limitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(
      categoriesByTypeProvider(FinanceCatalog.expenseType),
    );
    final actionState = ref.watch(budgetActionControllerProvider);
    final isBusy = actionState.isLoading;
    final categoryItems = <DropdownMenuItem<String>>[
      const DropdownMenuItem<String>(
        value: BudgetModel.overallCategoryId,
        child: Text('Overall spending'),
      ),
      ...categories.map(
        (category) => DropdownMenuItem<String>(
          value: category.id,
          child: Text(category.name),
        ),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit budget' : 'Add budget')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  buildPremiumCard(
                    context: context,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          _selectedCategoryId == BudgetModel.overallCategoryId
                              ? 'Overall spending budget'
                              : 'Category budget',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Budgets update their spent amount automatically whenever related expenses change.',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.color
                                    ?.withValues(alpha: 0.74),
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedCategoryId,
                    decoration: const InputDecoration(labelText: 'Budget type'),
                    items: categoryItems,
                    onChanged: isBusy
                        ? null
                        : (value) {
                            if (value == null) {
                              return;
                            }
                            setState(() {
                              _selectedCategoryId = value;
                            });
                          },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _limitController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Budget limit',
                      hintText: '0.00',
                      prefixText: '\u09F3 ',
                    ),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: isBusy ? null : _pickMonth,
                    icon: const Icon(Icons.calendar_month_rounded),
                    label: Text(DateFormat('MMMM yyyy').format(_selectedMonth)),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: OutlinedButton(
                          onPressed: isBusy
                              ? null
                              : () => Navigator.of(context).pop(),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: isBusy ? null : _saveBudget,
                          child: Text(
                            _isEditing ? 'Update budget' : 'Create budget',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickMonth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime(DateTime.now().year + 2, 12),
      initialDatePickerMode: DatePickerMode.year,
    );
    if (picked == null || !mounted) {
      return;
    }
    setState(() {
      _selectedMonth = DateTime(picked.year, picked.month);
    });
  }

  Future<void> _saveBudget() async {
    final limit = double.tryParse(_limitController.text.replaceAll(',', ''));
    if (limit == null || limit <= 0) {
      _showMessage('Enter a valid budget limit.');
      return;
    }

    final budget = BudgetModel(
      id: widget.budget?.id ?? '',
      categoryId: _selectedCategoryId,
      limit: limit,
      spent: widget.budget?.spent ?? 0,
      month: _selectedMonth.month,
      year: _selectedMonth.year,
      createdAt: widget.budget?.createdAt ?? DateTime.now(),
    );

    try {
      await ref
          .read(budgetActionControllerProvider.notifier)
          .saveBudget(budget);
      if (!mounted) {
        return;
      }

      ref.read(budgetMonthProvider.notifier).setMonth(_selectedMonth);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing ? 'Budget updated.' : 'Budget created.'),
        ),
      );
    } catch (error) {
      _showMessage(error.toString());
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  static String _trimZeroes(double value) {
    final text = value.toStringAsFixed(2);
    if (text.endsWith('.00')) {
      return text.substring(0, text.length - 3);
    }
    if (text.endsWith('0')) {
      return text.substring(0, text.length - 1);
    }
    return text;
  }
}

class _MonthHeader extends ConsumerWidget {
  const _MonthHeader({required this.selectedMonth});

  final DateTime selectedMonth;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            DateFormat('MMMM yyyy').format(selectedMonth),
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        IconButton(
          onPressed: () => ref.read(budgetMonthProvider.notifier).moveBy(-1),
          icon: const Icon(Icons.chevron_left_rounded),
        ),
        IconButton(
          onPressed: () => ref.read(budgetMonthProvider.notifier).moveBy(1),
          icon: const Icon(Icons.chevron_right_rounded),
        ),
      ],
    );
  }
}

class _OverallBudgetCard extends StatelessWidget {
  const _OverallBudgetCard({required this.overview, required this.currency});

  final BudgetOverview overview;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final overallBudget = overview.overallBudget;
    final limit = overallBudget?.limit ?? overview.totalCategoryLimit;
    final spent = overallBudget?.spent ?? overview.totalCategorySpent;
    final progress = limit <= 0 ? 0.0 : (spent / limit).clamp(0, 1).toDouble();
    final hasExplicitOverall = overallBudget != null;

    return buildPremiumCard(
      context: context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            hasExplicitOverall
                ? 'Overall monthly limit'
                : 'Category budget total',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 12,
            children: <Widget>[
              _BudgetMetric(
                label: 'Spent',
                value: _formatCurrency(spent, currency),
              ),
              _BudgetMetric(
                label: 'Limit',
                value: limit <= 0
                    ? 'Not set'
                    : _formatCurrency(limit, currency),
              ),
              _BudgetMetric(
                label: 'Remaining',
                value: limit <= 0
                    ? '--'
                    : _formatCurrency(
                        (limit - spent).clamp(0, double.infinity),
                        currency,
                      ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          LinearProgressIndicator(
            value: progress,
            minHeight: 10,
            borderRadius: BorderRadius.circular(999),
          ),
        ],
      ),
    );
  }
}

class _BudgetWarningCard extends StatelessWidget {
  const _BudgetWarningCard({required this.overview, required this.currency});

  final BudgetOverview overview;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final exceeded = overview.exceededBudgets.take(2).toList(growable: false);
    final near = overview.nearLimitBudgets.take(2).toList(growable: false);

    return buildPremiumCard(
      context: context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            overview.exceededBudgets.isNotEmpty
                ? 'Budget alert'
                : 'Budget warning',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          ...exceeded.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                '${item.category?.name ?? 'Category'} exceeded by ${_formatCurrency(item.budget.spent - item.budget.limit, currency)}.',
              ),
            ),
          ),
          ...near.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                '${item.category?.name ?? 'Category'} reached ${(item.budget.progress * 100).round()}% of its limit.',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BudgetTile extends StatelessWidget {
  const _BudgetTile({
    required this.item,
    required this.currency,
    required this.onTap,
    required this.onDelete,
  });

  final BudgetViewItem item;
  final String currency;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final budget = item.budget;
    final category = item.category;
    final ratio = budget.progress;
    final tone = ratio >= 1
        ? const Color(0xFFE85D5D)
        : ratio >= 0.8
        ? const Color(0xFFF59E0B)
        : const Color(0xFF2ECC9A);

    return buildPremiumInkCard(
      context: context,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              CircleAvatar(
                radius: 22,
                backgroundColor: tone.withValues(alpha: 0.14),
                foregroundColor: tone,
                child: Icon(
                  budget.isOverall
                      ? Icons.track_changes_rounded
                      : FinanceCatalog.iconForKey(
                          category?.iconKey ?? 'category',
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      budget.isOverall
                          ? 'Overall spending'
                          : category?.name ?? 'Category',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_formatCurrency(budget.spent, currency)} of ${_formatCurrency(budget.limit, currency)}',
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'delete') {
                    onDelete();
                  }
                },
                itemBuilder: (context) => const <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(value: 'delete', child: Text('Delete')),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          LinearProgressIndicator(
            value: ratio.clamp(0, 1).toDouble(),
            minHeight: 10,
            color: tone,
            borderRadius: BorderRadius.circular(999),
          ),
          const SizedBox(height: 10),
          Row(
            children: <Widget>[
              Text('${(ratio * 100).round()}% used'),
              const Spacer(),
              Text(
                ratio >= 1
                    ? 'Exceeded'
                    : ratio >= 0.8
                    ? 'Warning'
                    : 'On track',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: tone,
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

class _EmptyBudgetCard extends StatelessWidget {
  const _EmptyBudgetCard({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return buildPremiumCard(
      context: context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'No budgets yet',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          const Text(
            'Set an overall or category budget for this month to start tracking spending progress.',
          ),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: onAdd, child: const Text('Add budget')),
        ],
      ),
    );
  }
}

class _BudgetMetric extends StatelessWidget {
  const _BudgetMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.56),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label),
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

String _formatCurrency(double amount, String currency) {
  return NumberFormat.currency(
    locale: 'en_US',
    symbol: currency,
    decimalDigits: 0,
  ).format(amount);
}
