import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/locale_formatters.dart';
import '../../l10n/l10n_extension.dart';
import '../../shared/models/debt_record_model.dart';
import '../../shared/widgets/premium_card.dart';
import '../dashboard/dashboard_ui_parts.dart';
import '../profile/profile_providers.dart';
import 'debt_providers.dart';

class DebtsScreen extends ConsumerStatefulWidget {
  const DebtsScreen({super.key});

  @override
  ConsumerState<DebtsScreen> createState() => _DebtsScreenState();
}

class _DebtsScreenState extends ConsumerState<DebtsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final debtsAsync = ref.watch(debtsProvider);
    final borrowed = ref.watch(borrowedDebtsProvider);
    final lent = ref.watch(lentDebtsProvider);
    final overview = ref.watch(debtOverviewProvider);
    final profile = ref.watch(currentUserProfileProvider).asData?.value;
    final currency = profile?.currency ?? AppConstants.defaultCurrency;
    final languageCode =
        profile?.language ?? Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.debtsTitleText)),
      body: SafeArea(
        child: debtsAsync.when(
          data: (_) => Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1040),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _DebtHeroCard(
                      overview: overview,
                      currency: currency,
                      languageCode: languageCode,
                    ),
                    const SizedBox(height: 18),
                    TabBar(
                      controller: _tabController,
                      tabs: <Widget>[
                        Tab(text: l10n.borrowedTabLabel),
                        Tab(text: l10n.lentTabLabel),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: <Widget>[
                          _DebtListTab(
                            debts: borrowed,
                            emptyTitle: l10n.noBorrowedDebtTitle,
                            emptySubtitle: l10n.noBorrowedDebtSubtitle,
                            currency: currency,
                            languageCode: languageCode,
                            onEdit: (debt) => _openEditor(context, debt: debt),
                            onDelete: (debt) => _deleteDebt(context, debt),
                            onRecordPayment: (debt) =>
                                _openPaymentPage(context, debt),
                          ),
                          _DebtListTab(
                            debts: lent,
                            emptyTitle: l10n.noLentDebtTitle,
                            emptySubtitle: l10n.noLentDebtSubtitle,
                            currency: currency,
                            languageCode: languageCode,
                            onEdit: (debt) => _openEditor(context, debt: debt),
                            onDelete: (debt) => _deleteDebt(context, debt),
                            onRecordPayment: (debt) =>
                                _openPaymentPage(context, debt),
                          ),
                        ],
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
        onPressed: () => _openEditor(context),
        icon: const Icon(Icons.add_rounded),
        label: Text(l10n.addDebtAction),
      ),
    );
  }

  Future<void> _openEditor(
    BuildContext context, {
    DebtRecordModel? debt,
  }) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (context) => DebtEditorPage(debt: debt)),
    );
  }

  Future<void> _openPaymentPage(
    BuildContext context,
    DebtRecordModel debt,
  ) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (context) => DebtPaymentPage(debt: debt),
      ),
    );
  }

  Future<void> _deleteDebt(BuildContext context, DebtRecordModel debt) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.deleteDebtTitle),
        content: Text(context.l10n.deleteNamedDebtPrompt(debt.personName)),
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
      await ref.read(debtActionControllerProvider.notifier).deleteDebt(debt.id);
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.debtDeleted)));
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

class _DebtHeroCard extends StatelessWidget {
  const _DebtHeroCard({
    required this.overview,
    required this.currency,
    required this.languageCode,
  });

  final DebtOverview overview;
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
            l10n.debtTrackerHeroTitle,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(l10n.debtTrackerHeroSubtitle),
          const SizedBox(height: 18),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: <Widget>[
              _DebtMetricTile(
                label: l10n.totalOwedLabel,
                value: LocaleFormatters.formatCurrency(
                  overview.borrowedOutstanding,
                  currency,
                  languageCode,
                ),
              ),
              _DebtMetricTile(
                label: l10n.totalReceivableLabel,
                value: LocaleFormatters.formatCurrency(
                  overview.lentOutstanding,
                  currency,
                  languageCode,
                ),
              ),
              _DebtMetricTile(
                label: l10n.dueSoonLabel,
                value: LocaleFormatters.formatNumber(
                  overview.dueSoonCount,
                  languageCode,
                ),
              ),
              _DebtMetricTile(
                label: l10n.overdueLabel,
                value: LocaleFormatters.formatNumber(
                  overview.overdueCount,
                  languageCode,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DebtMetricTile extends StatelessWidget {
  const _DebtMetricTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      child: buildPremiumCard(
        context: context,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
      ),
    );
  }
}

class _DebtInfoPill extends StatelessWidget {
  const _DebtInfoPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.38),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label),
          const SizedBox(height: 2),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

String _trimZeroes(double value) {
  final whole = value.toInt();
  return value == whole ? '$whole' : value.toString();
}

class _DebtListTab extends StatelessWidget {
  const _DebtListTab({
    required this.debts,
    required this.emptyTitle,
    required this.emptySubtitle,
    required this.currency,
    required this.languageCode,
    required this.onEdit,
    required this.onDelete,
    required this.onRecordPayment,
  });

  final List<DebtRecordModel> debts;
  final String emptyTitle;
  final String emptySubtitle;
  final String currency;
  final String languageCode;
  final ValueChanged<DebtRecordModel> onEdit;
  final ValueChanged<DebtRecordModel> onDelete;
  final ValueChanged<DebtRecordModel> onRecordPayment;

  @override
  Widget build(BuildContext context) {
    final active = debts
        .where((debt) => !debt.isSettled)
        .toList(growable: false);
    final settled = debts
        .where((debt) => debt.isSettled)
        .toList(growable: false);

    if (active.isEmpty && settled.isEmpty) {
      return SingleChildScrollView(
        child: EmptyFinanceCard(title: emptyTitle, subtitle: emptySubtitle),
      );
    }

    return ListView(
      children: <Widget>[
        if (active.isNotEmpty)
          ...active.map(
            (debt) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _DebtTile(
                debt: debt,
                currency: currency,
                languageCode: languageCode,
                onEdit: () => onEdit(debt),
                onDelete: () => onDelete(debt),
                onRecordPayment: () => onRecordPayment(debt),
              ),
            ),
          ),
        if (settled.isNotEmpty) ...<Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 6, bottom: 12),
            child: Text(
              context.l10n.settledDebtsTitle(settled.length),
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          ...settled.map(
            (debt) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _DebtTile(
                debt: debt,
                currency: currency,
                languageCode: languageCode,
                onEdit: () => onEdit(debt),
                onDelete: () => onDelete(debt),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _DebtTile extends StatelessWidget {
  const _DebtTile({
    required this.debt,
    required this.currency,
    required this.languageCode,
    required this.onEdit,
    required this.onDelete,
    this.onRecordPayment,
  });

  final DebtRecordModel debt;
  final String currency;
  final String languageCode;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onRecordPayment;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final dueDateLabel = LocaleFormatters.formatDate(
      debt.dueDate,
      'd MMM yyyy',
      languageCode,
    );
    final statusColor = debt.isSettled
        ? const Color(0xFF2ECC9A)
        : debt.isOverdue
        ? const Color(0xFFE85D5D)
        : Theme.of(context).colorScheme.primary;
    final statusLabel = debt.isSettled
        ? l10n.settledLabel
        : debt.isOverdue
        ? l10n.overdueLabel
        : l10n.remainingLabel;

    return buildPremiumInkCard(
      context: context,
      onTap: onEdit,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: Icon(
                  debt.isBorrowed
                      ? Icons.call_received_rounded
                      : Icons.call_made_rounded,
                  color: statusColor,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      debt.personName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      debt.isBorrowed
                          ? l10n.debtBorrowedTypeLabel
                          : l10n.debtLentTypeLabel,
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    onEdit();
                  } else if (value == 'delete') {
                    onDelete();
                  }
                },
                itemBuilder: (context) => <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(
                    value: 'edit',
                    child: Text(context.l10n.editAction),
                  ),
                  PopupMenuItem<String>(
                    value: 'delete',
                    child: Text(context.l10n.delete),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: <Widget>[
              _DebtInfoPill(
                label: l10n.remainingLabel,
                value: LocaleFormatters.formatCurrency(
                  debt.remainingAmount,
                  currency,
                  languageCode,
                ),
              ),
              _DebtInfoPill(
                label: l10n.paidLabel,
                value: LocaleFormatters.formatCurrency(
                  debt.paidAmount,
                  currency,
                  languageCode,
                ),
              ),
              _DebtInfoPill(
                label: l10n.installmentsLabel,
                value: LocaleFormatters.localizeDigits(
                  '${debt.installments}',
                  languageCode,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: debt.progress,
              minHeight: 10,
              backgroundColor: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: <Widget>[
              Expanded(
                child: Text(l10n.debtDueDateLabelWithValue(dueDateLabel)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  statusLabel,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            l10n.installmentPlanLabel(
              LocaleFormatters.formatCurrency(
                debt.installmentAmount,
                currency,
                languageCode,
              ),
              LocaleFormatters.localizeDigits(
                '${debt.installments}',
                languageCode,
              ),
            ),
          ),
          if (debt.note.trim().isNotEmpty) ...<Widget>[
            const SizedBox(height: 8),
            Text(debt.note),
          ],
          if (onRecordPayment != null) ...<Widget>[
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRecordPayment,
              icon: const Icon(Icons.payments_rounded),
              label: Text(l10n.recordPaymentAction),
            ),
          ],
          if (debt.payments.isNotEmpty) ...<Widget>[
            const SizedBox(height: 16),
            Text(
              context.l10n.paymentHistoryTitle,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            ...debt.payments
                .take(3)
                .map(
                  (payment) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            LocaleFormatters.formatDate(
                              payment.date,
                              'd MMM yyyy',
                              languageCode,
                            ),
                          ),
                        ),
                        Text(
                          LocaleFormatters.formatCurrency(
                            payment.amount,
                            currency,
                            languageCode,
                          ),
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
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
}

class DebtEditorPage extends ConsumerStatefulWidget {
  const DebtEditorPage({super.key, this.debt});

  final DebtRecordModel? debt;

  @override
  ConsumerState<DebtEditorPage> createState() => _DebtEditorPageState();
}

class _DebtEditorPageState extends ConsumerState<DebtEditorPage> {
  late final TextEditingController _personController;
  late final TextEditingController _amountController;
  late final TextEditingController _installmentsController;
  late final TextEditingController _noteController;
  late DateTime _startDate;
  late DateTime _dueDate;
  late String _type;

  bool get _isEditing => widget.debt != null;

  @override
  void initState() {
    super.initState();
    final debt = widget.debt;
    _personController = TextEditingController(text: debt?.personName ?? '');
    _amountController = TextEditingController(
      text: debt == null ? '' : _trimZeroes(debt.totalAmount),
    );
    _installmentsController = TextEditingController(
      text: '${debt?.installments ?? 1}',
    );
    _noteController = TextEditingController(text: debt?.note ?? '');
    _startDate = debt?.startDate ?? DateTime.now();
    _dueDate = debt?.dueDate ?? DateTime.now().add(const Duration(days: 30));
    _type = debt?.type ?? DebtRecordModel.borrowedType;
  }

  @override
  void dispose() {
    _personController.dispose();
    _amountController.dispose();
    _installmentsController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final actionState = ref.watch(debtActionControllerProvider);
    final profile = ref.watch(currentUserProfileProvider).asData?.value;
    final currency = profile?.currency ?? AppConstants.defaultCurrency;
    final languageCode =
        profile?.language ?? Localizations.localeOf(context).languageCode;
    final isBusy = actionState.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.debtEditorTitle(_isEditing)),
        actions: <Widget>[
          if (_isEditing)
            TextButton(
              onPressed: isBusy ? null : _deleteDebt,
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          _type == DebtRecordModel.borrowedType
                              ? l10n.debtBorrowedHeroTitle
                              : l10n.debtLentHeroTitle,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _type == DebtRecordModel.borrowedType
                              ? l10n.debtBorrowedHeroSubtitle
                              : l10n.debtLentHeroSubtitle,
                        ),
                        if (_isEditing && widget.debt != null) ...<Widget>[
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: <Widget>[
                              _DebtInfoPill(
                                label: l10n.paidLabel,
                                value: LocaleFormatters.formatCurrency(
                                  widget.debt!.paidAmount,
                                  currency,
                                  languageCode,
                                ),
                              ),
                              _DebtInfoPill(
                                label: l10n.remainingLabel,
                                value: LocaleFormatters.formatCurrency(
                                  widget.debt!.remainingAmount,
                                  currency,
                                  languageCode,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  SegmentedButton<String>(
                    segments: <ButtonSegment<String>>[
                      ButtonSegment<String>(
                        value: DebtRecordModel.borrowedType,
                        label: Text(l10n.borrowedTabLabel),
                        icon: const Icon(Icons.call_received_rounded),
                      ),
                      ButtonSegment<String>(
                        value: DebtRecordModel.lentType,
                        label: Text(l10n.lentTabLabel),
                        icon: const Icon(Icons.call_made_rounded),
                      ),
                    ],
                    selected: <String>{_type},
                    onSelectionChanged: isBusy
                        ? null
                        : (selection) {
                            setState(() {
                              _type = selection.first;
                            });
                          },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _personController,
                    enabled: !isBusy,
                    decoration: InputDecoration(
                      labelText: l10n.debtPersonNameLabel,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _amountController,
                    enabled: !isBusy,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: l10n.debtAmountLabel,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _installmentsController,
                    enabled: !isBusy,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: l10n.installmentsLabel,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.debtStartDateLabel),
                    subtitle: Text(
                      LocaleFormatters.formatDate(
                        _startDate,
                        'EEEE, d MMM yyyy',
                        languageCode,
                      ),
                    ),
                    trailing: OutlinedButton(
                      onPressed: isBusy ? null : () => _pickDate(isStart: true),
                      child: Text(l10n.changeAction),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.debtDueDateLabel),
                    subtitle: Text(
                      LocaleFormatters.formatDate(
                        _dueDate,
                        'EEEE, d MMM yyyy',
                        languageCode,
                      ),
                    ),
                    trailing: OutlinedButton(
                      onPressed: isBusy
                          ? null
                          : () => _pickDate(isStart: false),
                      child: Text(l10n.changeAction),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _noteController,
                    enabled: !isBusy,
                    minLines: 3,
                    maxLines: 5,
                    decoration: InputDecoration(
                      labelText: l10n.noteFieldLabel,
                      hintText: l10n.debtNoteHint,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: isBusy ? null : _saveDebt,
                      icon: isBusy
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.handshake_rounded),
                      label: Text(
                        _isEditing ? l10n.updateAction : l10n.addDebtAction,
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

  Future<void> _pickDate({required bool isStart}) async {
    final initialDate = isStart ? _startDate : _dueDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked == null) {
      return;
    }
    setState(() {
      if (isStart) {
        _startDate = picked;
        if (_dueDate.isBefore(_startDate)) {
          _dueDate = _startDate;
        }
      } else {
        _dueDate = picked;
      }
    });
  }

  Future<void> _saveDebt() async {
    final l10n = context.l10n;
    final personName = _personController.text.trim();
    final amount = double.tryParse(_amountController.text.trim());
    final installments = int.tryParse(_installmentsController.text.trim()) ?? 0;

    if (personName.isEmpty) {
      _showMessage(l10n.debtNameRequiredError);
      return;
    }
    if (amount == null || amount <= 0) {
      _showMessage(l10n.validDebtAmountError);
      return;
    }
    if (installments <= 0) {
      _showMessage(l10n.validInstallmentsError);
      return;
    }
    if (_dueDate.isBefore(_startDate)) {
      _showMessage(l10n.debtDueDateAfterStartError);
      return;
    }
    if (_isEditing &&
        widget.debt != null &&
        amount + 0.009 < widget.debt!.paidAmount) {
      _showMessage(
        l10n.debtAmountLowerThanPaidError(_trimZeroes(widget.debt!.paidAmount)),
      );
      return;
    }

    final base = widget.debt;
    final debt = DebtRecordModel(
      id: base?.id ?? '',
      personName: personName,
      type: _type,
      totalAmount: amount,
      paidAmount: base?.paidAmount ?? 0,
      startDate: _startDate,
      dueDate: _dueDate,
      installments: installments,
      note: _noteController.text.trim(),
      payments: base?.payments ?? const <DebtPaymentModel>[],
      createdAt: base?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
      closedAt: base?.closedAt,
    );

    try {
      await ref.read(debtActionControllerProvider.notifier).saveDebt(debt);
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing ? l10n.debtUpdated : l10n.debtCreated),
        ),
      );
    } catch (error) {
      _showMessage(error.toString());
    }
  }

  Future<void> _deleteDebt() async {
    final debt = widget.debt;
    if (debt == null) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.deleteDebtTitle),
        content: Text(context.l10n.deleteNamedDebtPrompt(debt.personName)),
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
      await ref.read(debtActionControllerProvider.notifier).deleteDebt(debt.id);
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.debtDeleted)));
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

class DebtPaymentPage extends ConsumerStatefulWidget {
  const DebtPaymentPage({super.key, required this.debt});

  final DebtRecordModel debt;

  @override
  ConsumerState<DebtPaymentPage> createState() => _DebtPaymentPageState();
}

class _DebtPaymentPageState extends ConsumerState<DebtPaymentPage> {
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;
  late DateTime _paymentDate;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    _noteController = TextEditingController();
    _paymentDate = DateTime.now();
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
    final actionState = ref.watch(debtActionControllerProvider);
    final profile = ref.watch(currentUserProfileProvider).asData?.value;
    final currency = profile?.currency ?? AppConstants.defaultCurrency;
    final languageCode =
        profile?.language ?? Localizations.localeOf(context).languageCode;
    final isBusy = actionState.isLoading;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.paymentEditorTitle)),
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
                          widget.debt.personName,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: <Widget>[
                            _DebtInfoPill(
                              label: l10n.remainingLabel,
                              value: LocaleFormatters.formatCurrency(
                                widget.debt.remainingAmount,
                                currency,
                                languageCode,
                              ),
                            ),
                            _DebtInfoPill(
                              label: l10n.paidLabel,
                              value: LocaleFormatters.formatCurrency(
                                widget.debt.paidAmount,
                                currency,
                                languageCode,
                              ),
                            ),
                          ],
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
                      labelText: l10n.paymentAmountLabel,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.paymentDateLabel),
                    subtitle: Text(
                      LocaleFormatters.formatDate(
                        _paymentDate,
                        'EEEE, d MMM yyyy',
                        languageCode,
                      ),
                    ),
                    trailing: OutlinedButton(
                      onPressed: isBusy ? null : _pickDate,
                      child: Text(l10n.changeAction),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _noteController,
                    enabled: !isBusy,
                    minLines: 2,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: l10n.noteFieldLabel,
                      hintText: l10n.paymentNoteHint,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: isBusy ? null : _savePayment,
                      icon: isBusy
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.payments_rounded),
                      label: Text(l10n.recordPaymentAction),
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

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _paymentDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked == null) {
      return;
    }
    setState(() {
      _paymentDate = picked;
    });
  }

  Future<void> _savePayment() async {
    final l10n = context.l10n;
    final amount = double.tryParse(_amountController.text.trim());

    if (amount == null || amount <= 0) {
      _showMessage(l10n.validPaymentAmountError);
      return;
    }
    if (amount - widget.debt.remainingAmount > 0.009) {
      _showMessage(l10n.paymentExceedsRemainingError);
      return;
    }

    try {
      await ref
          .read(debtActionControllerProvider.notifier)
          .addPayment(
            debtId: widget.debt.id,
            amount: amount,
            date: _paymentDate,
            note: _noteController.text.trim(),
          );

      if (!mounted) {
        return;
      }
      Navigator.of(context).pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.paymentAdded)));
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
