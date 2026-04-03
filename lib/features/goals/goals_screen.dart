import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/locale_formatters.dart';
import '../../l10n/l10n_extension.dart';
import '../../shared/models/goal_model.dart';
import '../../shared/models/wallet_model.dart';
import '../../shared/widgets/premium_card.dart';
import '../dashboard/dashboard_ui_parts.dart';
import '../profile/profile_providers.dart';
import '../transactions/finance_catalog.dart';
import '../transactions/transaction_providers.dart';
import 'goal_providers.dart';

class GoalsScreen extends ConsumerStatefulWidget {
  const GoalsScreen({super.key});

  @override
  ConsumerState<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends ConsumerState<GoalsScreen> {
  bool _showCompleted = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final goalsAsync = ref.watch(goalsProvider);
    final activeGoals = ref.watch(activeGoalsProvider);
    final completedGoals = ref.watch(completedGoalsProvider);
    final topGoal = ref.watch(topActiveGoalProvider);
    final profile = ref.watch(currentUserProfileProvider).asData?.value;
    final currency = profile?.currency ?? AppConstants.defaultCurrency;
    final languageCode =
        profile?.language ?? Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.goalsTitleText)),
      body: SafeArea(
        child: goalsAsync.when(
          data: (_) => SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 980),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _GoalsHeroCard(
                      topGoal: topGoal,
                      currency: currency,
                      languageCode: languageCode,
                    ),
                    const SizedBox(height: 20),
                    _SectionHeader(
                      title: l10n.activeGoalsTitle,
                      actionLabel: l10n.addGoalAction,
                      onAction: () => _openEditor(context),
                    ),
                    const SizedBox(height: 12),
                    if (activeGoals.isEmpty)
                      EmptyFinanceCard(
                        title: l10n.noActiveGoalTitle,
                        subtitle: l10n.noActiveGoalSubtitle,
                        actionLabel: l10n.addGoalAction,
                        onAction: () => _openEditor(context),
                      )
                    else
                      ...activeGoals.map(
                        (goal) => Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _GoalTile(
                            goal: goal,
                            currency: currency,
                            languageCode: languageCode,
                            onTap: () => _openEditor(context, goal: goal),
                            onContribute: () =>
                                _openContributionPage(context, goal),
                            onDelete: () => _deleteGoal(context, goal.id),
                          ),
                        ),
                      ),
                    if (completedGoals.isNotEmpty) ...<Widget>[
                      const SizedBox(height: 16),
                      buildPremiumCard(
                        context: context,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            InkWell(
                              borderRadius: BorderRadius.circular(18),
                              onTap: () {
                                setState(() {
                                  _showCompleted = !_showCompleted;
                                });
                              },
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Text(
                                      l10n.completedGoalsTitle(
                                        completedGoals.length,
                                      ),
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                  ),
                                  Icon(
                                    _showCompleted
                                        ? Icons.expand_less_rounded
                                        : Icons.expand_more_rounded,
                                  ),
                                ],
                              ),
                            ),
                            if (_showCompleted) ...<Widget>[
                              const SizedBox(height: 16),
                              ...completedGoals.map(
                                (goal) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _GoalTile(
                                    goal: goal,
                                    currency: currency,
                                    languageCode: languageCode,
                                    onTap: () =>
                                        _openEditor(context, goal: goal),
                                    onContribute: null,
                                    onDelete: () =>
                                        _deleteGoal(context, goal.id),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
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
        onPressed: () => _openEditor(context),
        icon: const Icon(Icons.add_rounded),
        label: Text(l10n.addGoalAction),
      ),
    );
  }

  Future<void> _openEditor(BuildContext context, {GoalModel? goal}) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (context) => GoalEditorPage(goal: goal)),
    );
  }

  Future<void> _openContributionPage(
    BuildContext context,
    GoalModel goal,
  ) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (context) => GoalContributionPage(goal: goal),
      ),
    );
  }

  Future<void> _deleteGoal(BuildContext context, String goalId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.deleteGoalTitle),
        content: Text(context.l10n.deleteSavingsGoalPrompt),
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
      ),
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    try {
      await ref.read(goalActionControllerProvider.notifier).deleteGoal(goalId);
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.goalDeleted)));
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

class _GoalsHeroCard extends StatelessWidget {
  const _GoalsHeroCard({
    required this.topGoal,
    required this.currency,
    required this.languageCode,
  });

  final GoalModel? topGoal;
  final String currency;
  final String languageCode;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return buildPremiumCard(
      context: context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            l10n.savingsGoalsTitle,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(l10n.savingsGoalsSubtitle(topGoal?.name)),
          if (topGoal != null) ...<Widget>[
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: topGoal!.progress,
                minHeight: 12,
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
                valueColor: AlwaysStoppedAnimation<Color>(
                  Color(topGoal!.colorValue),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              l10n.goalSavedOf(
                LocaleFormatters.formatCurrency(
                  topGoal!.savedAmount,
                  currency,
                  languageCode,
                ),
                LocaleFormatters.formatCurrency(
                  topGoal!.targetAmount,
                  currency,
                  languageCode,
                ),
              ),
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.actionLabel,
    required this.onAction,
  });

  final String title;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final titleWidget = Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        );
        final button = FilledButton.icon(
          onPressed: onAction,
          icon: const Icon(Icons.add_rounded),
          label: Text(actionLabel),
        );

        if (constraints.maxWidth < 420) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[titleWidget, const SizedBox(height: 10), button],
          );
        }

        return Row(
          children: <Widget>[
            Expanded(child: titleWidget),
            button,
          ],
        );
      },
    );
  }
}

class _GoalTile extends StatelessWidget {
  const _GoalTile({
    required this.goal,
    required this.currency,
    required this.languageCode,
    required this.onTap,
    required this.onDelete,
    this.onContribute,
  });

  final GoalModel goal;
  final String currency;
  final String languageCode;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback? onContribute;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final color = Color(goal.colorValue);
    final daysLabel = goal.isCompleted
        ? l10n.completedStatus
        : l10n.daysLeftLabel(goal.daysRemaining);

    return buildPremiumInkCard(
      context: context,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: Icon(
                  FinanceCatalog.iconForKey(goal.iconKey),
                  color: color,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      goal.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(daysLabel),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'delete') {
                    onDelete();
                  } else if (value == 'contribute') {
                    onContribute?.call();
                  }
                },
                itemBuilder: (context) => <PopupMenuEntry<String>>[
                  if (onContribute != null)
                    PopupMenuItem<String>(
                      value: 'contribute',
                      child: Text(l10n.contributeAction),
                    ),
                  PopupMenuItem<String>(
                    value: 'delete',
                    child: Text(l10n.delete),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: goal.progress,
              minHeight: 12,
              backgroundColor: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  l10n.goalSavedOf(
                    LocaleFormatters.formatCurrency(
                      goal.savedAmount,
                      currency,
                      languageCode,
                    ),
                    LocaleFormatters.formatCurrency(
                      goal.targetAmount,
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
                  '${(goal.progress * 100).round()}%',
                  languageCode,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            l10n.goalTargetSummary(
              LocaleFormatters.formatCurrency(
                goal.targetAmount,
                currency,
                languageCode,
              ),
              LocaleFormatters.formatDate(
                goal.targetDate,
                'd MMM yyyy',
                languageCode,
              ),
            ),
          ),
          if (goal.note.trim().isNotEmpty) ...<Widget>[
            const SizedBox(height: 10),
            Text(goal.note),
          ],
          if (onContribute != null) ...<Widget>[
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onContribute,
              icon: const Icon(Icons.savings_rounded),
              label: Text(l10n.contributeAction),
            ),
          ],
        ],
      ),
    );
  }
}

class GoalEditorPage extends ConsumerStatefulWidget {
  const GoalEditorPage({super.key, this.goal});

  final GoalModel? goal;

  @override
  ConsumerState<GoalEditorPage> createState() => _GoalEditorPageState();
}

class _GoalEditorPageState extends ConsumerState<GoalEditorPage> {
  late final TextEditingController _nameController;
  late final TextEditingController _targetAmountController;
  late final TextEditingController _noteController;
  late DateTime _targetDate;
  late String _selectedIconKey;
  late int _selectedColorValue;

  bool get _isEditing => widget.goal != null;

  @override
  void initState() {
    super.initState();
    final goal = widget.goal;
    _nameController = TextEditingController(text: goal?.name ?? '');
    _targetAmountController = TextEditingController(
      text: goal == null ? '' : _trimZeroes(goal.targetAmount),
    );
    _noteController = TextEditingController(text: goal?.note ?? '');
    _targetDate =
        goal?.targetDate ?? DateTime.now().add(const Duration(days: 90));
    _selectedIconKey = goal?.iconKey ?? 'savings';
    _selectedColorValue = goal?.colorValue ?? FinanceCatalog.colorChoices.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _targetAmountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final languageCode = Localizations.localeOf(context).languageCode;
    final actionState = ref.watch(goalActionControllerProvider);
    final isBusy = actionState.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.goalEditorTitle(_isEditing)),
        actions: <Widget>[
          if (_isEditing)
            TextButton(
              onPressed: isBusy ? null : _deleteGoal,
              child: Text(l10n.delete),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  buildPremiumCard(
                    context: context,
                    child: Row(
                      children: <Widget>[
                        Container(
                          width: 54,
                          height: 54,
                          decoration: BoxDecoration(
                            color: Color(
                              _selectedColorValue,
                            ).withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            FinanceCatalog.iconForKey(_selectedIconKey),
                            color: Color(_selectedColorValue),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            l10n.goalHeaderSubtitle(_isEditing),
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _nameController,
                    enabled: !isBusy,
                    decoration: InputDecoration(
                      labelText: l10n.goalNameLabel,
                      hintText: l10n.goalNameHint,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _targetAmountController,
                    enabled: !isBusy,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: l10n.targetAmountLabel,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.targetDateLabel),
                    subtitle: Text(
                      LocaleFormatters.formatDate(
                        _targetDate,
                        'EEEE, d MMM yyyy',
                        languageCode,
                      ),
                    ),
                    trailing: OutlinedButton(
                      onPressed: isBusy ? null : _pickTargetDate,
                      child: Text(l10n.changeAction),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    l10n.iconLabel,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: FinanceCatalog.categoryIcons
                        .take(12)
                        .map((option) {
                          final selected = _selectedIconKey == option.key;
                          return InkWell(
                            borderRadius: BorderRadius.circular(18),
                            onTap: isBusy
                                ? null
                                : () {
                                    setState(() {
                                      _selectedIconKey = option.key;
                                    });
                                  },
                            child: Container(
                              width: 54,
                              height: 54,
                              decoration: BoxDecoration(
                                color: selected
                                    ? Color(
                                        _selectedColorValue,
                                      ).withValues(alpha: 0.14)
                                    : Theme.of(context)
                                          .colorScheme
                                          .surfaceContainerHighest
                                          .withValues(alpha: 0.55),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: selected
                                      ? Color(_selectedColorValue)
                                      : Colors.transparent,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Icon(
                                option.icon,
                                color: selected
                                    ? Color(_selectedColorValue)
                                    : Theme.of(context).iconTheme.color,
                              ),
                            ),
                          );
                        })
                        .toList(growable: false),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    l10n.colorLabel,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: FinanceCatalog.colorChoices
                        .map((colorValue) {
                          final selected = _selectedColorValue == colorValue;
                          return InkWell(
                            borderRadius: BorderRadius.circular(999),
                            onTap: isBusy
                                ? null
                                : () {
                                    setState(() {
                                      _selectedColorValue = colorValue;
                                    });
                                  },
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Color(colorValue),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: selected
                                      ? Colors.white
                                      : Colors.transparent,
                                  width: 2,
                                ),
                                boxShadow: <BoxShadow>[
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.08),
                                    blurRadius: 12,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                            ),
                          );
                        })
                        .toList(growable: false),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _noteController,
                    enabled: !isBusy,
                    minLines: 3,
                    maxLines: 5,
                    decoration: InputDecoration(
                      labelText: l10n.isBangla ? 'নোট' : 'Note',
                      hintText: l10n.isBangla
                          ? 'ঐচ্ছিক নোট লিখুন কেন এই লক্ষ্যটি গুরুত্বপূর্ণ।'
                          : 'Optional reminder about why this goal matters.',
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: isBusy ? null : _saveGoal,
                      icon: isBusy
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.flag_rounded),
                      label: Text(
                        _isEditing
                            ? l10n.saveGoalAction
                            : l10n.createGoalAction,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickTargetDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _targetDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked == null) {
      return;
    }
    setState(() {
      _targetDate = picked;
    });
  }

  Future<void> _saveGoal() async {
    final l10n = context.l10n;
    final name = _nameController.text.trim();
    final targetAmount = double.tryParse(_targetAmountController.text.trim());

    if (name.isEmpty) {
      _showMessage(l10n.enterGoalNameError);
      return;
    }
    if (targetAmount == null || targetAmount <= 0) {
      _showMessage(l10n.enterTargetAmountError);
      return;
    }

    final base = widget.goal;
    final savedAmount = base?.savedAmount ?? 0;
    final completedAt = savedAmount >= targetAmount
        ? (base?.completedAt ?? DateTime.now())
        : null;
    final goal = GoalModel(
      id: base?.id ?? '',
      name: name,
      targetAmount: targetAmount,
      savedAmount: savedAmount,
      targetDate: _targetDate,
      iconKey: _selectedIconKey,
      colorValue: _selectedColorValue,
      note: _noteController.text.trim(),
      createdAt: base?.createdAt ?? DateTime.now(),
      completedAt: completedAt,
    );

    try {
      final controller = ref.read(goalActionControllerProvider.notifier);
      if (_isEditing) {
        await controller.updateGoal(goal);
      } else {
        await controller.addGoal(goal);
      }

      if (!mounted) {
        return;
      }
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_isEditing ? l10n.goalUpdated : l10n.goalCreated)),
      );
    } catch (error) {
      _showMessage(error.toString());
    }
  }

  Future<void> _deleteGoal() async {
    final goal = widget.goal;
    if (goal == null) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.deleteGoalTitle),
        content: Text(context.l10n.deleteNamedGoalPrompt(goal.name)),
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
      ),
    );

    if (confirmed != true || !mounted) {
      return;
    }

    try {
      await ref.read(goalActionControllerProvider.notifier).deleteGoal(goal.id);
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.goalDeleted)));
    } catch (error) {
      _showMessage(error.toString());
    }
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class GoalContributionPage extends ConsumerStatefulWidget {
  const GoalContributionPage({super.key, required this.goal});

  final GoalModel goal;

  @override
  ConsumerState<GoalContributionPage> createState() =>
      _GoalContributionPageState();
}

class _GoalContributionPageState extends ConsumerState<GoalContributionPage> {
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;
  String? _selectedWalletId;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    _noteController = TextEditingController();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final wallets =
        ref.watch(walletsProvider).asData?.value ?? const <WalletModel>[];
    final actionState = ref.watch(goalActionControllerProvider);
    final profile = ref.watch(currentUserProfileProvider).asData?.value;
    final currency = profile?.currency ?? AppConstants.defaultCurrency;
    final languageCode =
        profile?.language ?? Localizations.localeOf(context).languageCode;
    final isBusy = actionState.isLoading;

    if (_selectedWalletId == null && wallets.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _selectedWalletId = wallets
                .firstWhere(
                  (wallet) => wallet.isDefault,
                  orElse: () => wallets.first,
                )
                .id;
          });
        }
      });
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.contributeToGoalTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  buildPremiumCard(
                    context: context,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          widget.goal.name,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.contributionSavedOf(
                            LocaleFormatters.formatCurrency(
                              widget.goal.savedAmount,
                              currency,
                              languageCode,
                            ),
                            LocaleFormatters.formatCurrency(
                              widget.goal.targetAmount,
                              currency,
                              languageCode,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            value: widget.goal.progress,
                            minHeight: 12,
                            backgroundColor: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest
                                .withValues(alpha: 0.6),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(widget.goal.colorValue),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _amountController,
                    enabled: !isBusy,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: l10n.contributionAmountLabel,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (wallets.isEmpty)
                    EmptyFinanceCard(
                      title: l10n.isBangla
                          ? 'কোনো ওয়ালেট নেই'
                          : 'No wallet available',
                      subtitle: l10n.noWalletForGoalSubtitle,
                    )
                  else
                    DropdownButtonFormField<String>(
                      initialValue: _selectedWalletId ?? wallets.first.id,
                      decoration: InputDecoration(
                        labelText: l10n.sourceWalletLabel,
                      ),
                      items: wallets
                          .map(
                            (wallet) => DropdownMenuItem<String>(
                              value: wallet.id,
                              child: Text(wallet.name),
                            ),
                          )
                          .toList(growable: false),
                      onChanged: isBusy
                          ? null
                          : (value) {
                              if (value == null) {
                                return;
                              }
                              setState(() {
                                _selectedWalletId = value;
                              });
                            },
                    ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _noteController,
                    enabled: !isBusy,
                    minLines: 2,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: l10n.isBangla ? 'নোট' : 'Note',
                      hintText: l10n.contributionNoteHint,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: isBusy ? null : _submitContribution,
                      icon: isBusy
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.savings_rounded),
                      label: Text(l10n.addContributionAction),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submitContribution() async {
    final l10n = context.l10n;
    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      _showMessage(l10n.validContributionAmountError);
      return;
    }
    if (_selectedWalletId == null) {
      _showMessage(l10n.chooseSourceWalletError);
      return;
    }

    try {
      final result = await ref
          .read(goalActionControllerProvider.notifier)
          .contributeToGoal(
            goal: widget.goal,
            amount: amount,
            walletId: _selectedWalletId!,
            note: _noteController.text.trim(),
          );

      if (!mounted) {
        return;
      }
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.justCompleted
                ? l10n.goalCompletedMessage(widget.goal.name)
                : l10n.contributionAdded,
          ),
        ),
      );
      if (result.justCompleted) {
        await showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l10n.goalCompletedTitleText),
            content: Text(l10n.goalCompletedDialog(widget.goal.name)),
            actions: <Widget>[
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.greatAction),
              ),
            ],
          ),
        );
      }
    } catch (error) {
      _showMessage(error.toString());
    }
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

String _trimZeroes(double value) {
  final whole = value.toInt();
  return value == whole ? '$whole' : value.toString();
}
