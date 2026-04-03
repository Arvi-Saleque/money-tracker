import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../shared/models/transaction_model.dart';
import '../../shared/models/wallet_model.dart';
import '../transactions/finance_catalog.dart';
import '../transactions/transaction_providers.dart';

Future<void> openTransferEditorPage(
  BuildContext context, {
  TransactionModel? transaction,
  String? initialFromWalletId,
}) async {
  await Navigator.of(context).push<void>(
    MaterialPageRoute<void>(
      builder: (context) => TransferEditorPage(
        transaction: transaction,
        initialFromWalletId: initialFromWalletId,
      ),
    ),
  );
}

class TransferEditorPage extends ConsumerStatefulWidget {
  const TransferEditorPage({
    super.key,
    this.transaction,
    this.initialFromWalletId,
  });

  final TransactionModel? transaction;
  final String? initialFromWalletId;

  @override
  ConsumerState<TransferEditorPage> createState() => _TransferEditorPageState();
}

class _TransferEditorPageState extends ConsumerState<TransferEditorPage> {
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;

  String? _fromWalletId;
  String? _toWalletId;
  late DateTime _selectedDate;
  TransactionModel? _baseTransaction;
  TransactionModel? _linkedTransaction;
  bool _isLoadingPair = false;

  bool get _isEditing => widget.transaction != null;

  @override
  void initState() {
    super.initState();
    final transaction = widget.transaction;
    _amountController = TextEditingController(
      text: transaction == null ? '' : _trimZeroes(transaction.amount),
    );
    _noteController = TextEditingController(text: transaction?.note ?? '');
    _selectedDate = transaction?.date ?? DateTime.now();
    _baseTransaction = transaction;

    if (transaction != null) {
      if (transaction.type == FinanceCatalog.expenseType) {
        _fromWalletId = transaction.walletId;
        _toWalletId = transaction.transferWalletId;
      } else {
        _fromWalletId = transaction.transferWalletId;
        _toWalletId = transaction.walletId;
      }
      _loadLinkedTransfer();
    } else {
      _fromWalletId = widget.initialFromWalletId;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wallets =
        ref.watch(walletsProvider).asData?.value ?? const <WalletModel>[];
    final state = ref.watch(transferActionControllerProvider);
    final isBusy = state.isLoading || _isLoadingPair;
    final theme = Theme.of(context);

    if (wallets.isNotEmpty) {
      _syncWalletSelections(wallets);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit transfer' : 'Transfer money'),
      ),
      body: SafeArea(
        child: wallets.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.08,
                            ),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: theme.colorScheme.primary.withValues(
                                alpha: 0.18,
                              ),
                            ),
                          ),
                          child: Row(
                            children: <Widget>[
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: theme.colorScheme.primary
                                    .withValues(alpha: 0.14),
                                foregroundColor: theme.colorScheme.primary,
                                child: const Icon(Icons.swap_horiz_rounded),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      _isEditing
                                          ? 'Update wallet transfer'
                                          : 'Move money between wallets',
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Transfers update both wallet balances together and stay linked in history.',
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: theme
                                                .textTheme
                                                .bodySmall
                                                ?.color
                                                ?.withValues(alpha: 0.74),
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        DropdownButtonFormField<String>(
                          initialValue: _fromWalletId,
                          decoration: const InputDecoration(
                            labelText: 'From wallet',
                            prefixIcon: Icon(Icons.call_made_rounded),
                          ),
                          items: wallets
                              .map(
                                (wallet) => DropdownMenuItem<String>(
                                  value: wallet.id,
                                  child: Text(wallet.name),
                                ),
                              )
                              .toList(),
                          onChanged: isBusy
                              ? null
                              : (value) =>
                                    setState(() => _fromWalletId = value),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          initialValue: _toWalletId,
                          decoration: const InputDecoration(
                            labelText: 'To wallet',
                            prefixIcon: Icon(Icons.call_received_rounded),
                          ),
                          items: wallets
                              .map(
                                (wallet) => DropdownMenuItem<String>(
                                  value: wallet.id,
                                  child: Text(wallet.name),
                                ),
                              )
                              .toList(),
                          onChanged: isBusy
                              ? null
                              : (value) => setState(() => _toWalletId = value),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _amountController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Amount',
                            hintText: '0.00',
                            prefixText: '\u09F3 ',
                          ),
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: isBusy ? null : _pickDate,
                          icon: const Icon(Icons.calendar_today_rounded),
                          label: Text(
                            DateFormat('dd MMM yyyy').format(_selectedDate),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _noteController,
                          minLines: 2,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            labelText: 'Note',
                            hintText: 'Optional transfer note',
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: <Widget>[
                            if (_isEditing) ...<Widget>[
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: isBusy ? null : _deleteTransfer,
                                  icon: const Icon(
                                    Icons.delete_outline_rounded,
                                  ),
                                  label: const Text('Delete'),
                                ),
                              ),
                              const SizedBox(width: 12),
                            ],
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
                              child: ElevatedButton.icon(
                                onPressed: isBusy ? null : _saveTransfer,
                                icon: isBusy
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(Icons.swap_horiz_rounded),
                                label: Text(_isEditing ? 'Update' : 'Transfer'),
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

  Future<void> _loadLinkedTransfer() async {
    final transaction = widget.transaction;
    if (transaction == null) {
      return;
    }

    setState(() {
      _isLoadingPair = true;
    });

    try {
      final pair = await ref
          .read(transferActionControllerProvider.notifier)
          .loadTransferPair(transaction);
      if (!mounted) {
        return;
      }
      setState(() {
        _baseTransaction = pair.$1;
        _linkedTransaction = pair.$2;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingPair = false;
        });
      }
    }
  }

  void _syncWalletSelections(List<WalletModel> wallets) {
    final ids = wallets.map((wallet) => wallet.id).toSet();
    String? nextFrom = _fromWalletId;
    String? nextTo = _toWalletId;

    if (!ids.contains(nextFrom)) {
      nextFrom = wallets
          .firstWhere((wallet) => wallet.isDefault, orElse: () => wallets.first)
          .id;
    }
    if (!ids.contains(nextTo) || nextTo == nextFrom) {
      nextTo = wallets
          .firstWhere(
            (wallet) => wallet.id != nextFrom,
            orElse: () => wallets.first,
          )
          .id;
    }

    if (nextFrom == _fromWalletId && nextTo == _toWalletId) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _fromWalletId = nextFrom;
        _toWalletId = nextTo;
      });
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked == null || !mounted) {
      return;
    }
    setState(() {
      _selectedDate = picked;
    });
  }

  Future<void> _saveTransfer() async {
    final amount = double.tryParse(_amountController.text.replaceAll(',', ''));
    if (amount == null || amount <= 0) {
      _showMessage('Enter a valid transfer amount.');
      return;
    }
    if (_fromWalletId == null || _toWalletId == null) {
      _showMessage('Choose both wallets for this transfer.');
      return;
    }
    if (_fromWalletId == _toWalletId) {
      _showMessage('From and to wallets must be different.');
      return;
    }

    try {
      final controller = ref.read(transferActionControllerProvider.notifier);
      if (_isEditing) {
        if (_baseTransaction == null || _linkedTransaction == null) {
          _showMessage('Transfer details are still loading. Try again.');
          return;
        }
        await controller.updateTransfer(
          baseTransaction: _baseTransaction!,
          linkedTransaction: _linkedTransaction!,
          fromWalletId: _fromWalletId!,
          toWalletId: _toWalletId!,
          amount: amount,
          note: _noteController.text.trim(),
          date: _selectedDate,
        );
      } else {
        await controller.createTransfer(
          fromWalletId: _fromWalletId!,
          toWalletId: _toWalletId!,
          amount: amount,
          note: _noteController.text.trim(),
          date: _selectedDate,
        );
      }

      if (!mounted) {
        return;
      }
      Navigator.of(context).pop();
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(
          content: Text(
            _isEditing ? 'Transfer updated.' : 'Transfer completed.',
          ),
        ),
      );
    } catch (error) {
      _showMessage(error.toString());
    }
  }

  Future<void> _deleteTransfer() async {
    if (_baseTransaction == null) {
      return;
    }

    try {
      await ref
          .read(transferActionControllerProvider.notifier)
          .deleteTransfer(
            baseTransaction: _baseTransaction!,
            linkedTransaction: _linkedTransaction,
          );
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop();
      ScaffoldMessenger.maybeOf(
        context,
      )?.showSnackBar(const SnackBar(content: Text('Transfer deleted.')));
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
