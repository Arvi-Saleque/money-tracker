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
    final allCategoriesAsync = ref.watch(allCategoriesProvider);
    final categories = ref.watch(categoriesByTypeProvider(_selectedType));
    final transactionState = ref.watch(transactionActionControllerProvider);
    final categoryState = ref.watch(categoryActionControllerProvider);
    final theme = Theme.of(context);
    final viewInsets = MediaQuery.viewInsetsOf(context);

    final wallets = walletsAsync.asData?.value ?? const <WalletModel>[];
    _syncSelections(wallets, categories);

    final isBusy = transactionState.isLoading || categoryState.isLoading;
    final allCategories =
        allCategoriesAsync.asData?.value ?? const <CategoryModel>[];
    final hasData = wallets.isNotEmpty && categories.isNotEmpty;
    final isLoadingCategories =
        allCategoriesAsync.isLoading && allCategories.isEmpty;

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
                _TopSummaryCard(
                  type: _selectedType,
                  selectedDate: _selectedDate,
                  walletName: wallets
                      .cast<WalletModel?>()
                      .firstWhere(
                        (wallet) => wallet?.id == _selectedWalletId,
                        orElse: () => null,
                      )
                      ?.name,
                ),
                const SizedBox(height: 18),
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
                            child: Row(
                              children: <Widget>[
                                Icon(
                                  FinanceCatalog.iconForKey(wallet.iconKey),
                                  size: 18,
                                  color: Color(wallet.colorValue),
                                ),
                                const SizedBox(width: 10),
                                Text(wallet.name),
                              ],
                            ),
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
                    FilledButton.tonalIcon(
                      onPressed: isBusy
                          ? null
                          : () => _openCategoryDialog(allCategories),
                      icon: const Icon(Icons.add_circle_outline_rounded),
                      label: const Text('New category'),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (isLoadingCategories)
                  const Center(child: CircularProgressIndicator())
                else if (categories.isEmpty)
                  _InlineInfoCard(
                    title: 'No category available',
                    subtitle:
                        'Starter categories are still syncing. You can also create one right now.',
                  )
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: 1.08,
                        ),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      return _CategoryChoiceCard(
                        category: category,
                        selected: category.id == _selectedCategoryId,
                        onTap: () {
                          setState(() {
                            _selectedCategoryId = category.id;
                          });
                        },
                      );
                    },
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
      nextWalletId =
          wallets
              .cast<WalletModel?>()
              .firstWhere(
                (wallet) => wallet?.isDefault == true,
                orElse: () => null,
              )
              ?.id ??
          wallets.first.id;
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

  Future<void> _openCategoryDialog(
    List<CategoryModel> existingCategories,
  ) async {
    final category = await showDialog<CategoryModel>(
      context: context,
      builder: (context) => _CategoryEditorDialog(
        initialType: _selectedType,
        existingCategories: existingCategories,
      ),
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
  const _CategoryEditorDialog({
    required this.initialType,
    required this.existingCategories,
  });

  final String initialType;
  final List<CategoryModel> existingCategories;

  @override
  ConsumerState<_CategoryEditorDialog> createState() =>
      _CategoryEditorDialogState();
}

class _CategoryEditorDialogState extends ConsumerState<_CategoryEditorDialog> {
  late final TextEditingController _nameController;
  _CategoryCreationMode _creationMode = _CategoryCreationMode.template;
  String _selectedIconKey = FinanceCatalog.categoryIcons.first.key;
  int _selectedColorValue = FinanceCatalog.colorChoices.first;
  FinanceCategoryTemplate? _selectedTemplate;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _selectedTemplate = FinanceCatalog.templatesForType(
      widget.initialType,
    ).first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(categoryActionControllerProvider);
    final isIncome = widget.initialType == FinanceCatalog.incomeType;
    final typeLabel = isIncome ? 'Income' : 'Expense';
    final accent = isIncome ? const Color(0xFF2ECC9A) : const Color(0xFFE85D5D);
    final templates = FinanceCatalog.templatesForType(widget.initialType);

    return AlertDialog(
      backgroundColor: theme.colorScheme.surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      title: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              'Create $typeLabel category',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          _TypeBadge(label: typeLabel, color: accent),
        ],
      ),
      content: SizedBox(
        width: 560,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'The new category will be selected automatically after you save it.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodyMedium?.color?.withValues(
                    alpha: 0.72,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              DropdownButtonFormField<_CategoryCreationMode>(
                initialValue: _creationMode,
                decoration: const InputDecoration(
                  labelText: 'Create with',
                  prefixIcon: Icon(Icons.auto_awesome_mosaic_outlined),
                ),
                items: const <DropdownMenuItem<_CategoryCreationMode>>[
                  DropdownMenuItem(
                    value: _CategoryCreationMode.template,
                    child: Text('Template'),
                  ),
                  DropdownMenuItem(
                    value: _CategoryCreationMode.manual,
                    child: Text('Manual'),
                  ),
                ],
                onChanged: state.isLoading
                    ? null
                    : (value) {
                        if (value == null) {
                          return;
                        }
                        setState(() {
                          _creationMode = value;
                        });
                      },
              ),
              const SizedBox(height: 18),
              if (_creationMode == _CategoryCreationMode.template)
                _buildTemplateSection(context, templates)
              else
                _buildManualSection(context),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: state.isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          onPressed: state.isLoading ? null : _submit,
          icon: state.isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.check_rounded),
          label: Text(
            _creationMode == _CategoryCreationMode.template
                ? 'Use template'
                : 'Create category',
          ),
        ),
      ],
    );
  }

  Widget _buildTemplateSection(
    BuildContext context,
    List<FinanceCategoryTemplate> templates,
  ) {
    final template = _selectedTemplate;
    final existingIds = widget.existingCategories
        .map((category) => category.id)
        .toSet();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        DropdownButtonFormField<String>(
          initialValue: template?.id,
          decoration: const InputDecoration(
            labelText: 'Template',
            prefixIcon: Icon(Icons.bolt_outlined),
          ),
          items: templates
              .map(
                (item) => DropdownMenuItem<String>(
                  value: item.id,
                  child: Text(item.name),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value == null) {
              return;
            }
            setState(() {
              _selectedTemplate = templates.firstWhere(
                (template) => template.id == value,
              );
            });
          },
        ),
        if (template != null) ...<Widget>[
          const SizedBox(height: 16),
          _PreviewCard(
            iconKey: template.iconKey,
            colorValue: template.colorValue,
            title: template.name,
            subtitle: template.nameBn,
          ),
          const SizedBox(height: 12),
          _InlineInfoCard(
            title: existingIds.contains(template.id)
                ? 'Already available'
                : 'Quick create',
            subtitle: existingIds.contains(template.id)
                ? 'This template already exists. Saving will just select it.'
                : 'This template is ready to create instantly for faster entry.',
          ),
        ],
      ],
    );
  }

  Widget _buildManualSection(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        TextField(
          controller: _nameController,
          onChanged: (_) {
            setState(() {});
          },
          decoration: const InputDecoration(
            labelText: 'Category name',
            hintText: 'Write in English or Bangla',
            helperText:
                'We will fill the opposite language automatically when possible.',
            prefixIcon: Icon(Icons.edit_outlined),
          ),
        ),
        const SizedBox(height: 18),
        _PreviewCard(
          iconKey: _selectedIconKey,
          colorValue: _selectedColorValue,
          title: _nameController.text.trim().isEmpty
              ? 'Category preview'
              : _nameController.text.trim(),
          subtitle: 'Manual category',
        ),
        const SizedBox(height: 18),
        Text(
          'Choose icon',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1,
          ),
          itemCount: FinanceCatalog.categoryIcons.length,
          itemBuilder: (context, index) {
            final option = FinanceCatalog.categoryIcons[index];
            final selected = option.key == _selectedIconKey;

            return InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () {
                setState(() {
                  _selectedIconKey = option.key;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                decoration: BoxDecoration(
                  color: selected
                      ? theme.colorScheme.primary.withValues(alpha: 0.14)
                      : theme.colorScheme.surfaceContainerHighest.withValues(
                          alpha: 0.32,
                        ),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: selected
                        ? theme.colorScheme.primary
                        : theme.dividerColor,
                  ),
                ),
                child: Icon(option.icon),
              ),
            );
          },
        ),
        const SizedBox(height: 18),
        Text(
          'Choose color',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: FinanceCatalog.colorChoices.map((colorValue) {
            final selected = colorValue == _selectedColorValue;

            return InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: () {
                setState(() {
                  _selectedColorValue = colorValue;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Color(colorValue),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected
                        ? theme.colorScheme.onSurface
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    try {
      final controller = ref.read(categoryActionControllerProvider.notifier);
      final CategoryModel category;

      if (_creationMode == _CategoryCreationMode.template) {
        if (_selectedTemplate == null) {
          _showMessage('Choose a template first.');
          return;
        }
        category = await controller.createFromTemplate(
          template: _selectedTemplate!,
          existingCategories: widget.existingCategories,
        );
      } else {
        if (_nameController.text.trim().isEmpty) {
          _showMessage('Write a category name in English or Bangla.');
          return;
        }
        category = await controller.createManual(
          inputName: _nameController.text,
          iconKey: _selectedIconKey,
          colorValue: _selectedColorValue,
          type: widget.initialType,
        );
      }

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

enum _CategoryCreationMode { manual, template }

class _TopSummaryCard extends StatelessWidget {
  const _TopSummaryCard({
    required this.type,
    required this.selectedDate,
    required this.walletName,
  });

  final String type;
  final DateTime selectedDate;
  final String? walletName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = type == FinanceCatalog.incomeType
        ? const Color(0xFF2ECC9A)
        : const Color(0xFFE85D5D);
    final label = type == FinanceCatalog.incomeType ? 'Income' : 'Expense';

    return buildPremiumCard(
      context: context,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: <Widget>[
          CircleAvatar(
            radius: 24,
            backgroundColor: accent.withValues(alpha: 0.14),
            foregroundColor: accent,
            child: Icon(
              type == FinanceCatalog.incomeType
                  ? Icons.arrow_downward_rounded
                  : Icons.arrow_upward_rounded,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '$label transaction',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${DateFormat('dd MMM yyyy').format(selectedDate)}${walletName == null ? '' : '  |  $walletName'}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withValues(
                      alpha: 0.72,
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

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({
    required this.iconKey,
    required this.colorValue,
    required this.title,
    required this.subtitle,
  });

  final String iconKey;
  final int colorValue;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = Color(colorValue);

    return buildPremiumCard(
      context: context,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: <Widget>[
          CircleAvatar(
            radius: 24,
            backgroundColor: accent.withValues(alpha: 0.14),
            foregroundColor: accent,
            child: Icon(FinanceCatalog.iconForKey(iconKey)),
          ),
          const SizedBox(width: 14),
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
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withValues(
                      alpha: 0.72,
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

class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
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

    return buildPremiumInkCard(
      context: context,
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          CircleAvatar(
            radius: 18,
            backgroundColor: accent.withValues(alpha: 0.14),
            foregroundColor: accent,
            child: Icon(FinanceCatalog.iconForKey(category.iconKey), size: 18),
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
