import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../shared/models/category_model.dart';
import '../../shared/models/transaction_model.dart';
import '../../shared/models/wallet_model.dart';
import '../../shared/widgets/premium_card.dart';
import 'finance_catalog.dart';
import 'transaction_providers.dart';

Future<void> showTransactionEditorSheet(
  BuildContext context, {
  TransactionModel? transaction,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => TransactionEditorSheet(transaction: transaction),
  );
}

class TransactionEditorSheet extends ConsumerStatefulWidget {
  const TransactionEditorSheet({super.key, this.transaction});

  final TransactionModel? transaction;

  @override
  ConsumerState<TransactionEditorSheet> createState() =>
      _TransactionEditorSheetState();
}

class _TransactionEditorSheetState
    extends ConsumerState<TransactionEditorSheet> {
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;

  late String _selectedType;
  String? _selectedCategoryId;
  String? _selectedWalletId;
  late DateTime _selectedDate;

  bool get _isEditing => widget.transaction != null;

  @override
  void initState() {
    super.initState();
    final transaction = widget.transaction;
    _amountController = TextEditingController(
      text: transaction == null ? '' : _trimZeroes(transaction.amount),
    );
    _noteController = TextEditingController(text: transaction?.note ?? '');
    _selectedType = transaction?.type ?? FinanceCatalog.expenseType;
    _selectedCategoryId = transaction?.categoryId;
    _selectedWalletId = transaction?.walletId;
    _selectedDate = transaction?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final walletsAsync = ref.watch(walletsProvider);
    final categoriesAsync = ref.watch(categoriesByTypeProvider(_selectedType));
    final transactionState = ref.watch(transactionActionControllerProvider);
    final categoryState = ref.watch(categoryActionControllerProvider);
    final theme = Theme.of(context);
    final viewInsets = MediaQuery.viewInsetsOf(context);

    final wallets = walletsAsync.asData?.value ?? const <WalletModel>[];
    final categories = categoriesAsync.asData?.value ?? const <CategoryModel>[];
    _syncSelections(wallets, categories);

    final isBusy = transactionState.isLoading || categoryState.isLoading;
    final hasData = wallets.isNotEmpty && categories.isNotEmpty;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: theme.dividerColor),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Center(
                  child: Container(
                    width: 56,
                    height: 5,
                    decoration: BoxDecoration(
                      color: theme.dividerColor,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  _isEditing ? 'Edit transaction' : 'Add transaction',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Track income and expenses with categories, wallets, and notes.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodyMedium?.color?.withValues(
                      alpha: 0.72,
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                _SectionTitle('Type'),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: <Widget>[
                    _TypeChip(
                      label: 'Expense',
                      selected: _selectedType == FinanceCatalog.expenseType,
                      color: const Color(0xFFE85D5D),
                      onTap: () {
                        setState(() {
                          _selectedType = FinanceCatalog.expenseType;
                          _selectedCategoryId = null;
                        });
                      },
                    ),
                    _TypeChip(
                      label: 'Income',
                      selected: _selectedType == FinanceCatalog.incomeType,
                      color: const Color(0xFF2ECC9A),
                      onTap: () {
                        setState(() {
                          _selectedType = FinanceCatalog.incomeType;
                          _selectedCategoryId = null;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _SectionTitle('Amount'),
                const SizedBox(height: 10),
                TextField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    hintText: '0.00',
                    prefixText: '\u09F3 ',
                  ),
                ),
                const SizedBox(height: 18),
                _SectionTitle('Wallet'),
                const SizedBox(height: 10),
                if (walletsAsync.isLoading && wallets.isEmpty)
                  const Center(child: CircularProgressIndicator())
                else if (wallets.isEmpty)
                  _InlineInfoCard(
                    title: 'No wallet yet',
                    subtitle:
                        'Starter data is still loading. Reopen this sheet in a moment.',
                  )
                else
                  DropdownButtonFormField<String>(
                    initialValue: _selectedWalletId,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.account_balance_wallet_outlined),
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
                        : (value) {
                            setState(() {
                              _selectedWalletId = value;
                            });
                          },
                  ),
                const SizedBox(height: 18),
                Row(
                  children: <Widget>[
                    const Expanded(child: _SectionTitle('Category')),
                    TextButton.icon(
                      onPressed: isBusy ? null : _openCategoryDialog,
                      icon: const Icon(Icons.add_circle_outline_rounded),
                      label: const Text('New category'),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (categoriesAsync.isLoading && categories.isEmpty)
                  const Center(child: CircularProgressIndicator())
                else if (categories.isEmpty)
                  _InlineInfoCard(
                    title: 'No category available',
                    subtitle: 'Create one and it will appear here right away.',
                  )
                else
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: categories
                        .map(
                          (category) => _CategoryChoiceCard(
                            category: category,
                            selected: category.id == _selectedCategoryId,
                            onTap: () {
                              setState(() {
                                _selectedCategoryId = category.id;
                              });
                            },
                          ),
                        )
                        .toList(),
                  ),
                const SizedBox(height: 18),
                Row(
                  children: <Widget>[
                    const Expanded(child: _SectionTitle('Date')),
                    OutlinedButton.icon(
                      onPressed: isBusy ? null : _pickDate,
                      icon: const Icon(Icons.calendar_today_rounded),
                      label: Text(
                        DateFormat('dd MMM yyyy').format(_selectedDate),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _SectionTitle('Note'),
                const SizedBox(height: 10),
                TextField(
                  controller: _noteController,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: 'Optional note about this transaction',
                  ),
                ),
                if (!hasData) ...<Widget>[
                  const SizedBox(height: 16),
                  Text(
                    'You can still stay here while starter data finishes syncing.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                Row(
                  children: <Widget>[
                    if (_isEditing) ...<Widget>[
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: isBusy ? null : _deleteTransaction,
                          icon: const Icon(Icons.delete_outline_rounded),
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
                      child: ElevatedButton(
                        onPressed: isBusy || !hasData ? null : _saveTransaction,
                        child: Text(_isEditing ? 'Update' : 'Save'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _syncSelections(
    List<WalletModel> wallets,
    List<CategoryModel> categories,
  ) {
    String? nextWalletId = _selectedWalletId;
    if (wallets.isNotEmpty &&
        wallets.every((wallet) => wallet.id != nextWalletId)) {
      nextWalletId = wallets.first.id;
    }

    String? nextCategoryId = _selectedCategoryId;
    if (categories.isNotEmpty &&
        categories.every((category) => category.id != nextCategoryId)) {
      nextCategoryId = categories.first.id;
    }

    if (nextWalletId == _selectedWalletId &&
        nextCategoryId == _selectedCategoryId) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _selectedWalletId = nextWalletId;
        _selectedCategoryId = nextCategoryId;
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

  Future<void> _openCategoryDialog() async {
    final category = await showDialog<CategoryModel>(
      context: context,
      builder: (context) => _CategoryEditorDialog(initialType: _selectedType),
    );

    if (category == null || !mounted) {
      return;
    }

    setState(() {
      _selectedType = category.type;
      _selectedCategoryId = category.id;
    });
  }

  Future<void> _saveTransaction() async {
    final amount = double.tryParse(_amountController.text.replaceAll(',', ''));
    if (amount == null || amount <= 0) {
      _showMessage('Enter a valid amount greater than 0.');
      return;
    }
    if (_selectedWalletId == null) {
      _showMessage('Choose a wallet before saving.');
      return;
    }
    if (_selectedCategoryId == null) {
      _showMessage('Choose a category before saving.');
      return;
    }

    final nextTransaction = TransactionModel(
      id: widget.transaction?.id ?? '',
      amount: amount,
      type: _selectedType,
      categoryId: _selectedCategoryId!,
      walletId: _selectedWalletId!,
      note: _noteController.text.trim(),
      date: _selectedDate,
      createdAt: widget.transaction?.createdAt ?? DateTime.now(),
    );

    try {
      final controller = ref.read(transactionActionControllerProvider.notifier);
      if (_isEditing) {
        await controller.updateTransaction(
          previous: widget.transaction!,
          next: nextTransaction,
        );
      } else {
        await controller.add(nextTransaction);
      }

      if (!mounted) {
        return;
      }
      Navigator.of(context).pop();
      _showGlobalMessage(
        _isEditing ? 'Transaction updated.' : 'Transaction saved.',
      );
    } catch (error) {
      _showMessage(error.toString());
    }
  }

  Future<void> _deleteTransaction() async {
    final transaction = widget.transaction;
    if (transaction == null) {
      return;
    }

    try {
      await ref
          .read(transactionActionControllerProvider.notifier)
          .delete(transaction);
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop();
      _showGlobalMessage('Transaction deleted.');
    } catch (error) {
      _showMessage(error.toString());
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showGlobalMessage(String message) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger?.showSnackBar(SnackBar(content: Text(message)));
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

class _CategoryEditorDialog extends ConsumerStatefulWidget {
  const _CategoryEditorDialog({required this.initialType});

  final String initialType;

  @override
  ConsumerState<_CategoryEditorDialog> createState() =>
      _CategoryEditorDialogState();
}

class _CategoryEditorDialogState extends ConsumerState<_CategoryEditorDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _nameBnController;

  late String _selectedType;
  String _selectedIconKey = FinanceCatalog.categoryIcons.first.key;
  int _selectedColorValue = FinanceCatalog.colorChoices.first;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _nameBnController = TextEditingController();
    _selectedType = widget.initialType;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameBnController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(categoryActionControllerProvider);

    return AlertDialog(
      backgroundColor: theme.colorScheme.surface,
      title: const Text('Create category'),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: <Widget>[
                  _TypeChip(
                    label: 'Expense',
                    selected: _selectedType == FinanceCatalog.expenseType,
                    color: const Color(0xFFE85D5D),
                    onTap: () {
                      setState(() {
                        _selectedType = FinanceCatalog.expenseType;
                      });
                    },
                  ),
                  _TypeChip(
                    label: 'Income',
                    selected: _selectedType == FinanceCatalog.incomeType,
                    color: const Color(0xFF2ECC9A),
                    onTap: () {
                      setState(() {
                        _selectedType = FinanceCatalog.incomeType;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Category name (English)',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _nameBnController,
                decoration: const InputDecoration(
                  labelText: 'Category name (Bangla)',
                ),
              ),
              const SizedBox(height: 18),
              const _SectionTitle('Pick an icon'),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: FinanceCatalog.categoryIcons
                    .map(
                      (option) => InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          setState(() {
                            _selectedIconKey = option.key;
                          });
                        },
                        child: Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: option.key == _selectedIconKey
                                ? theme.colorScheme.primary.withValues(
                                    alpha: 0.16,
                                  )
                                : theme.colorScheme.surfaceContainerHighest
                                      .withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: option.key == _selectedIconKey
                                  ? theme.colorScheme.primary
                                  : theme.dividerColor,
                            ),
                          ),
                          child: Icon(option.icon),
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 18),
              const _SectionTitle('Pick a color'),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: FinanceCatalog.colorChoices
                    .map(
                      (colorValue) => InkWell(
                        borderRadius: BorderRadius.circular(999),
                        onTap: () {
                          setState(() {
                            _selectedColorValue = colorValue;
                          });
                        },
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: Color(colorValue),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: colorValue == _selectedColorValue
                                  ? theme.colorScheme.onSurface
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: state.isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: state.isLoading ? null : _submit,
          child: const Text('Save'),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (_nameController.text.trim().isEmpty) {
      _showMessage('Enter an English name for the category.');
      return;
    }
    if (_nameBnController.text.trim().isEmpty) {
      _showMessage('Enter a Bangla name for the category.');
      return;
    }

    try {
      final category = await ref
          .read(categoryActionControllerProvider.notifier)
          .create(
            name: _nameController.text,
            nameBn: _nameBnController.text,
            iconKey: _selectedIconKey,
            colorValue: _selectedColorValue,
            type: _selectedType,
          );

      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(category);
    } catch (error) {
      _showMessage(error.toString());
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? color.withValues(alpha: 0.14)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: selected ? color : theme.dividerColor),
        ),
        child: Text(
          label,
          style: theme.textTheme.titleSmall?.copyWith(
            color: selected ? color : theme.textTheme.bodyLarge?.color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _CategoryChoiceCard extends StatelessWidget {
  const _CategoryChoiceCard({
    required this.category,
    required this.selected,
    required this.onTap,
  });

  final CategoryModel category;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = Color(category.colorValue);

    return SizedBox(
      width: 108,
      child: buildPremiumInkCard(
        context: context,
        onTap: onTap,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            CircleAvatar(
              radius: 18,
              backgroundColor: accent.withValues(alpha: 0.14),
              foregroundColor: accent,
              child: Icon(
                FinanceCatalog.iconForKey(category.iconKey),
                size: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              category.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: selected ? theme.colorScheme.primary : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.label);

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

class _InlineInfoCard extends StatelessWidget {
  const _InlineInfoCard({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return buildPremiumCard(
      context: context,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.74),
            ),
          ),
        ],
      ),
    );
  }
}
