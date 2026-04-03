import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/locale_formatters.dart';
import '../../l10n/l10n_extension.dart';
import '../../shared/models/category_model.dart';
import '../../shared/models/transaction_model.dart';
import '../../shared/models/wallet_model.dart';
import '../../shared/widgets/premium_card.dart';
import '../wallets/transfer_editor_page.dart';
import 'finance_catalog.dart';
import 'transaction_providers.dart';

Future<void> openTransactionEditorPage(
  BuildContext context, {
  TransactionModel? transaction,
}) async {
  if (transaction?.isTransfer == true) {
    await openTransferEditorPage(context, transaction: transaction);
    return;
  }

  await Navigator.of(context).push<void>(
    MaterialPageRoute<void>(
      builder: (context) => TransactionEditorPage(transaction: transaction),
    ),
  );
}

class TransactionEditorPage extends ConsumerStatefulWidget {
  const TransactionEditorPage({super.key, this.transaction});

  final TransactionModel? transaction;

  @override
  ConsumerState<TransactionEditorPage> createState() =>
      _TransactionEditorPageState();
}

class _TransactionEditorPageState extends ConsumerState<TransactionEditorPage> {
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;

  late String _selectedType;
  String? _selectedCategoryId;
  String? _selectedWalletId;
  late DateTime _selectedDate;
  late bool _isSplitTransaction;
  late List<_SplitLineDraft> _splitLines;

  bool get _isEditing => widget.transaction != null;
  double get _splitTotal => _splitLines.fold<double>(
    0,
    (sum, line) => sum + _parseAmount(line.amountController.text),
  );

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
    _isSplitTransaction = transaction?.isSplit ?? false;
    _splitLines = _buildInitialSplitLines(transaction);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    for (final line in _splitLines) {
      line.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
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

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 74,
        leading: IconButton(
          onPressed: isBusy ? null : () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(l10n.transactionEditorTitle(_isEditing)),
            const SizedBox(height: 2),
            Text(
              l10n.transactionEditorSubtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withValues(
                  alpha: 0.68,
                ),
              ),
            ),
          ],
        ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: isBusy
                    ? SizedBox(
                        key: const ValueKey<String>('busy'),
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: theme.colorScheme.primary,
                        ),
                      )
                    : Container(
                        key: const ValueKey<String>('idle'),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.1,
                          ),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          l10n.formBadge,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 28 + viewInsets.bottom),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
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
              _buildFormContent(
                context,
                wallets: wallets,
                allCategories: allCategories,
                categories: categories,
                walletsAsync: walletsAsync,
                isBusy: isBusy,
                isLoadingCategories: isLoadingCategories,
                hasData: hasData,
              ),
            ],
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
        nextCategoryId == _selectedCategoryId &&
        !_needsSplitRepair(categories)) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _selectedWalletId = nextWalletId;
        _selectedCategoryId = nextCategoryId;
        _repairSplitLines(categories);
      });
    });
  }

  Widget _buildFormContent(
    BuildContext context, {
    required List<WalletModel> wallets,
    required List<CategoryModel> allCategories,
    required List<CategoryModel> categories,
    required AsyncValue<List<WalletModel>> walletsAsync,
    required bool isBusy,
    required bool isLoadingCategories,
    required bool hasData,
  }) {
    final l10n = context.l10n;
    final languageCode = Localizations.localeOf(context).languageCode;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _SectionTitle(l10n.typeLabel),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: <Widget>[
            _TypeChip(
              label: l10n.expenseTypeLabel,
              selected: _selectedType == FinanceCatalog.expenseType,
              color: const Color(0xFFE85D5D),
              onTap: () {
                setState(() {
                  _selectedType = FinanceCatalog.expenseType;
                  _selectedCategoryId = null;
                  for (final line in _splitLines) {
                    line.categoryId = null;
                  }
                });
              },
            ),
            _TypeChip(
              label: l10n.incomeTypeLabel,
              selected: _selectedType == FinanceCatalog.incomeType,
              color: const Color(0xFF2ECC9A),
              onTap: () {
                setState(() {
                  _selectedType = FinanceCatalog.incomeType;
                  _selectedCategoryId = null;
                  for (final line in _splitLines) {
                    line.categoryId = null;
                  }
                });
              },
            ),
          ],
        ),
        if (_selectedType != FinanceCatalog.transferType) ...<Widget>[
          const SizedBox(height: 16),
          buildPremiumCard(
            context: context,
            padding: const EdgeInsets.all(14),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        l10n.splitTransactionLabel,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.splitTransactionHint,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color?.withValues(
                            alpha: 0.74,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Switch.adaptive(
                  value: _isSplitTransaction,
                  onChanged: isBusy
                      ? null
                      : (value) => _toggleSplitMode(value, categories),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 18),
        _SectionTitle(l10n.amountFieldLabel),
        const SizedBox(height: 10),
        TextField(
          controller: _amountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            hintText: '0.00',
            prefixText: '\u09F3 ',
          ),
        ),
        const SizedBox(height: 18),
        _SectionTitle(l10n.walletFieldLabel),
        const SizedBox(height: 10),
        if (walletsAsync.isLoading && wallets.isEmpty)
          const Center(child: CircularProgressIndicator())
        else if (wallets.isEmpty)
          _InlineInfoCard(
            title: l10n.noWalletYetTitle,
            subtitle: l10n.noWalletYetSubtitle,
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
        if (_isSplitTransaction)
          _buildSplitSection(
            context,
            allCategories: allCategories,
            categories: categories,
            isBusy: isBusy,
            isLoadingCategories: isLoadingCategories,
          )
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(child: _SectionTitle(l10n.categoryFieldLabel)),
                  FilledButton.tonalIcon(
                    onPressed: isBusy
                        ? null
                        : () => _openCategoryDialog(allCategories),
                    icon: const Icon(Icons.add_circle_outline_rounded),
                    label: Text(l10n.newCategoryAction),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (isLoadingCategories)
                const Center(child: CircularProgressIndicator())
              else if (categories.isEmpty)
                _InlineInfoCard(
                  title: l10n.noCategoryAvailableTitle,
                  subtitle: l10n.noCategoryAvailableSubtitle,
                )
              else
                LayoutBuilder(
                  builder: (context, constraints) {
                    final crossAxisCount = constraints.maxWidth < 340
                        ? 3
                        : constraints.maxWidth < 480
                        ? 4
                        : 5;

                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        childAspectRatio: constraints.maxWidth < 360
                            ? 0.98
                            : 1.08,
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
                          onDelete: () => _deleteCategory(category),
                        );
                      },
                    );
                  },
                ),
            ],
          ),
        const SizedBox(height: 18),
        Row(
          children: <Widget>[
            Expanded(child: _SectionTitle(l10n.dateFieldLabel)),
            OutlinedButton.icon(
              onPressed: isBusy ? null : _pickDate,
              icon: const Icon(Icons.calendar_today_rounded),
              label: Text(
                LocaleFormatters.formatDate(
                  _selectedDate,
                  'dd MMM yyyy',
                  languageCode,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        _SectionTitle(l10n.noteFieldLabel),
        const SizedBox(height: 10),
        TextField(
          controller: _noteController,
          minLines: 2,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: l10n.optionalTransactionNoteHint,
          ),
        ),
        if (!hasData) ...<Widget>[
          const SizedBox(height: 16),
          Text(
            l10n.starterDataSyncingHint,
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
                  label: Text(l10n.delete),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: OutlinedButton(
                onPressed: isBusy ? null : () => Navigator.of(context).pop(),
                child: Text(l10n.cancel),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: isBusy || !hasData ? null : _saveTransaction,
                child: Text(
                  _isEditing
                      ? l10n.updateTransactionAction
                      : l10n.saveTransactionAction,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSplitSection(
    BuildContext context, {
    required List<CategoryModel> allCategories,
    required List<CategoryModel> categories,
    required bool isBusy,
    required bool isLoadingCategories,
  }) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(child: _SectionTitle(l10n.splitLinesTitle)),
            FilledButton.tonalIcon(
              onPressed: isBusy || categories.isEmpty
                  ? null
                  : () {
                      setState(() {
                        _splitLines.add(_createSplitLine(categories));
                      });
                    },
              icon: const Icon(Icons.add_rounded),
              label: Text(l10n.addSplitLineAction),
            ),
            const SizedBox(width: 8),
            FilledButton.tonalIcon(
              onPressed: isBusy
                  ? null
                  : () => _openCategoryDialog(allCategories),
              icon: const Icon(Icons.add_circle_outline_rounded),
              label: Text(l10n.newCategoryAction),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (isLoadingCategories)
          const Center(child: CircularProgressIndicator())
        else if (categories.isEmpty)
          _InlineInfoCard(
            title: l10n.noCategoryAvailableTitle,
            subtitle: l10n.noCategoryAvailableSubtitle,
          )
        else
          buildPremiumCard(
            context: context,
            padding: const EdgeInsets.all(14),
            child: Column(
              children: <Widget>[
                for (
                  var index = 0;
                  index < _splitLines.length;
                  index++
                ) ...<Widget>[
                  _SplitLineCard(
                    title: l10n.splitLineTitle(index),
                    line: _splitLines[index],
                    categories: categories,
                    onCategoryChanged: (value) {
                      setState(() {
                        _splitLines[index].categoryId = value;
                      });
                    },
                    onRemove: _splitLines.length <= 2
                        ? null
                        : () {
                            setState(() {
                              final line = _splitLines.removeAt(index);
                              line.dispose();
                            });
                          },
                  ),
                  if (index != _splitLines.length - 1)
                    const SizedBox(height: 12),
                ],
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.34,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          l10n.splitTotalLabel,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Text(
                        '\u09F3 ${_trimZeroes(_splitTotal)}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  List<_SplitLineDraft> _buildInitialSplitLines(TransactionModel? transaction) {
    final sourceItems = transaction?.normalizedSplitItems ?? const [];
    if (sourceItems.isEmpty) {
      return <_SplitLineDraft>[_SplitLineDraft(), _SplitLineDraft()];
    }

    final seeded = sourceItems
        .map(
          (item) => _SplitLineDraft(
            categoryId: item.categoryId,
            amountText: _trimZeroes(item.amount),
          ),
        )
        .toList(growable: true);
    if (seeded.length == 1) {
      seeded.add(_SplitLineDraft());
    }
    return seeded;
  }

  void _toggleSplitMode(bool value, List<CategoryModel> categories) {
    if (_isSplitTransaction == value) {
      return;
    }

    setState(() {
      _isSplitTransaction = value;
      if (value) {
        for (final line in _splitLines) {
          line.dispose();
        }
        final baseCategoryId = _selectedCategoryId;
        final baseAmount = _amountController.text.trim();
        _splitLines = <_SplitLineDraft>[
          _SplitLineDraft(categoryId: baseCategoryId, amountText: baseAmount),
          _createSplitLine(categories),
        ];
        _repairSplitLines(categories);
      } else {
        if (_splitLines.isNotEmpty) {
          _selectedCategoryId =
              _splitLines.first.categoryId ?? _selectedCategoryId;
        }
      }
    });
  }

  _SplitLineDraft _createSplitLine(List<CategoryModel> categories) {
    final selectedIds = _splitLines
        .map((line) => line.categoryId)
        .whereType<String>()
        .toSet();
    final nextCategory = categories.cast<CategoryModel?>().firstWhere(
      (category) => category != null && !selectedIds.contains(category.id),
      orElse: () => categories.isEmpty ? null : categories.first,
    );
    return _SplitLineDraft(categoryId: nextCategory?.id);
  }

  bool _needsSplitRepair(List<CategoryModel> categories) {
    if (!_isSplitTransaction || categories.isEmpty) {
      return false;
    }
    return _splitLines.any(
      (line) =>
          line.categoryId == null ||
          categories.every((category) => category.id != line.categoryId),
    );
  }

  void _repairSplitLines(List<CategoryModel> categories) {
    if (!_isSplitTransaction || categories.isEmpty) {
      return;
    }
    for (final line in _splitLines) {
      if (line.categoryId == null ||
          categories.every((category) => category.id != line.categoryId)) {
        line.categoryId = categories.first.id;
      }
    }
  }

  double _parseAmount(String raw) {
    return double.tryParse(raw.replaceAll(',', '').trim()) ?? 0;
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
      if (_isSplitTransaction) {
        final targetLine = _splitLines.cast<_SplitLineDraft?>().firstWhere(
          (line) => line?.categoryId == null,
          orElse: () => _splitLines.isEmpty ? null : _splitLines.last,
        );
        targetLine?.categoryId = category.id;
      } else {
        _selectedCategoryId = category.id;
      }
    });
  }

  Future<void> _saveTransaction() async {
    final amount = double.tryParse(_amountController.text.replaceAll(',', ''));
    if (amount == null || amount <= 0) {
      _showMessage(context.l10n.validAmountError);
      return;
    }
    if (_selectedWalletId == null) {
      _showMessage(context.l10n.chooseWalletError);
      return;
    }

    var nextCategoryId = _selectedCategoryId;
    var splitItems = const <TransactionSplitItem>[];

    if (_isSplitTransaction) {
      if (_splitLines.length < 2) {
        _showMessage(context.l10n.splitNeedsTwoLinesError);
        return;
      }

      final items = <TransactionSplitItem>[];
      for (final line in _splitLines) {
        if (line.categoryId == null || line.categoryId!.trim().isEmpty) {
          _showMessage(context.l10n.splitLineCategoryError);
          return;
        }
        final lineAmount = _parseAmount(line.amountController.text);
        if (lineAmount <= 0) {
          _showMessage(context.l10n.splitLineAmountError);
          return;
        }
        items.add(
          TransactionSplitItem(
            categoryId: line.categoryId!,
            amount: lineAmount,
          ),
        );
      }

      final splitTotal = items.fold<double>(
        0,
        (sum, item) => sum + item.amount,
      );
      if ((splitTotal - amount).abs() > 0.009) {
        _showMessage(context.l10n.splitTotalMismatchError);
        return;
      }

      splitItems = items;
      nextCategoryId = items.first.categoryId;
    } else {
      if (_selectedCategoryId == null) {
        _showMessage(context.l10n.chooseCategoryError);
        return;
      }
      nextCategoryId = _selectedCategoryId;
    }

    final nextTransaction = TransactionModel(
      id: widget.transaction?.id ?? '',
      amount: amount,
      type: _selectedType,
      categoryId: nextCategoryId!,
      walletId: _selectedWalletId!,
      isTransfer: false,
      note: _noteController.text.trim(),
      date: _selectedDate,
      createdAt: widget.transaction?.createdAt ?? DateTime.now(),
      splitItems: splitItems,
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
        _isEditing
            ? context.l10n.transactionUpdated
            : context.l10n.transactionSaved,
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
      _showGlobalMessage(context.l10n.transactionDeleted);
    } catch (error) {
      _showMessage(error.toString());
    }
  }

  Future<void> _deleteCategory(CategoryModel category) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(context.l10n.deleteCategoryTitle),
          content: Text(context.l10n.deleteCategoryPrompt(category.name)),
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
          .read(categoryActionControllerProvider.notifier)
          .deleteCategory(category);
      if (!mounted) {
        return;
      }
      if (_selectedCategoryId == category.id) {
        setState(() {
          _selectedCategoryId = null;
        });
      }
      setState(() {
        for (final line in _splitLines) {
          if (line.categoryId == category.id) {
            line.categoryId = null;
          }
        }
      });
      _showMessage(context.l10n.categoryDeleted);
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

class _SplitLineDraft {
  _SplitLineDraft({this.categoryId, String amountText = ''})
    : amountController = TextEditingController(text: amountText);

  String? categoryId;
  final TextEditingController amountController;

  void dispose() {
    amountController.dispose();
  }
}

class _SplitLineCard extends StatelessWidget {
  const _SplitLineCard({
    required this.title,
    required this.line,
    required this.categories,
    required this.onCategoryChanged,
    this.onRemove,
  });

  final String title;
  final _SplitLineDraft line;
  final List<CategoryModel> categories;
  final ValueChanged<String?> onCategoryChanged;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.26,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (onRemove != null)
                IconButton(
                  onPressed: onRemove,
                  icon: const Icon(Icons.delete_outline_rounded),
                  tooltip: l10n.delete,
                ),
            ],
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: line.categoryId,
            decoration: InputDecoration(labelText: l10n.splitLineCategoryLabel),
            items: categories
                .map(
                  (category) => DropdownMenuItem<String>(
                    value: category.id,
                    child: Text(category.name),
                  ),
                )
                .toList(),
            onChanged: onCategoryChanged,
          ),
          const SizedBox(height: 10),
          TextField(
            controller: line.amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: l10n.splitLineAmountLabel,
              prefixText: '\u09F3 ',
            ),
          ),
        ],
      ),
    );
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
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final state = ref.watch(categoryActionControllerProvider);
    final isIncome = widget.initialType == FinanceCatalog.incomeType;
    final typeLabel = isIncome ? l10n.incomeTypeLabel : l10n.expenseTypeLabel;
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
              l10n.createCategoryTitle(typeLabel),
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
                l10n.categoryAutoSelectHint,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodyMedium?.color?.withValues(
                    alpha: 0.72,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              DropdownButtonFormField<_CategoryCreationMode>(
                initialValue: _creationMode,
                decoration: InputDecoration(
                  labelText: l10n.createWithLabel,
                  prefixIcon: Icon(Icons.auto_awesome_mosaic_outlined),
                ),
                items: <DropdownMenuItem<_CategoryCreationMode>>[
                  DropdownMenuItem(
                    value: _CategoryCreationMode.template,
                    child: Text(l10n.templateLabel),
                  ),
                  DropdownMenuItem(
                    value: _CategoryCreationMode.manual,
                    child: Text(l10n.manualLabel),
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
          child: Text(l10n.cancel),
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
                ? l10n.useTemplateAction
                : l10n.createCategoryAction,
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
          decoration: InputDecoration(
            labelText: context.l10n.categoryTemplateLabel,
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
                ? context.l10n.alreadyAvailableTitle
                : context.l10n.quickCreateTitle,
            subtitle: existingIds.contains(template.id)
                ? context.l10n.templateExistsSubtitle
                : context.l10n.templateReadySubtitle,
          ),
        ],
      ],
    );
  }

  Widget _buildManualSection(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        TextField(
          controller: _nameController,
          onChanged: (_) {
            setState(() {});
          },
          decoration: InputDecoration(
            labelText: l10n.categoryNameLabel,
            hintText: l10n.categoryNameHint,
            helperText: l10n.categoryNameHelper,
            prefixIcon: Icon(Icons.edit_outlined),
          ),
        ),
        const SizedBox(height: 18),
        _PreviewCard(
          iconKey: _selectedIconKey,
          colorValue: _selectedColorValue,
          title: _nameController.text.trim().isEmpty
              ? l10n.categoryPreviewTitle
              : _nameController.text.trim(),
          subtitle: l10n.manualCategorySubtitle,
        ),
        const SizedBox(height: 18),
        Text(
          l10n.chooseIconLabel,
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
          l10n.chooseColorLabel,
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
          _showMessage(context.l10n.chooseTemplateFirstError);
          return;
        }
        category = await controller.createFromTemplate(
          template: _selectedTemplate!,
          existingCategories: widget.existingCategories,
        );
      } else {
        if (_nameController.text.trim().isEmpty) {
          _showMessage(context.l10n.writeCategoryNameError);
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
    final l10n = context.l10n;
    final languageCode = Localizations.localeOf(context).languageCode;
    final theme = Theme.of(context);
    final accent = type == FinanceCatalog.incomeType
        ? const Color(0xFF2ECC9A)
        : const Color(0xFFE85D5D);
    final label = type == FinanceCatalog.incomeType
        ? l10n.incomeTypeLabel
        : l10n.expenseTypeLabel;

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
                  '$label ${l10n.isBangla ? 'লেনদেন' : 'transaction'}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${LocaleFormatters.formatDate(selectedDate, 'dd MMM yyyy', languageCode)}${walletName == null ? '' : '  |  $walletName'}',
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
    this.onDelete,
  });

  final CategoryModel category;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = Color(category.colorValue);
    final selectedBackground = accent.withValues(alpha: 0.14);
    final selectedBorder = accent.withValues(alpha: 0.8);
    final defaultBorder = theme.dividerColor.withValues(alpha: 0.55);

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 84;

        return Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: onTap,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 170),
                    curve: Curves.easeOut,
                    padding: EdgeInsets.symmetric(
                      horizontal: compact ? 6 : 8,
                      vertical: compact ? 8 : 10,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? selectedBackground
                          : theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: selected ? selectedBorder : defaultBorder,
                        width: selected ? 1.5 : 1,
                      ),
                      boxShadow: selected
                          ? <BoxShadow>[
                              BoxShadow(
                                color: accent.withValues(alpha: 0.14),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              ),
                            ]
                          : const <BoxShadow>[],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        CircleAvatar(
                          radius: compact ? 13 : 15,
                          backgroundColor: accent.withValues(
                            alpha: selected ? 0.22 : 0.14,
                          ),
                          foregroundColor: accent,
                          child: Icon(
                            FinanceCatalog.iconForKey(category.iconKey),
                            size: compact ? 14 : 16,
                          ),
                        ),
                        SizedBox(height: compact ? 4 : 6),
                        Flexible(
                          child: Text(
                            category.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontSize: compact ? 10.5 : 11.5,
                              height: 1.05,
                              fontWeight: FontWeight.w700,
                              color: selected
                                  ? accent
                                  : theme.textTheme.bodyMedium?.color,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (onDelete != null)
              Positioned(
                top: -4,
                right: -4,
                child: InkWell(
                  borderRadius: BorderRadius.circular(999),
                  onTap: onDelete,
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.error,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.colorScheme.surface,
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      size: 14,
                      color: theme.colorScheme.onError,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
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
