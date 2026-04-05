import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/locale_formatters.dart';
import '../../l10n/l10n_extension.dart';
import 'shared_wallet_helpers.dart';
import 'shared_wallet_providers.dart';

class SharedWalletEntryEditorPage extends ConsumerStatefulWidget {
  const SharedWalletEntryEditorPage({super.key, required this.walletId});

  final String walletId;

  @override
  ConsumerState<SharedWalletEntryEditorPage> createState() =>
      _SharedWalletEntryEditorPageState();
}

class _SharedWalletEntryEditorPageState
    extends ConsumerState<SharedWalletEntryEditorPage> {
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;
  String _type = 'expense';
  DateTime _date = DateTime.now();

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
    final isBusy = ref.watch(sharedWalletActionControllerProvider).isLoading;
    final languageCode = Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          sharedWalletText(
            context,
            'Add shared entry',
            'শেয়ার্ড এন্ট্রি যোগ করুন',
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: <Widget>[
                      _EntryTypeChip(
                        label: sharedWalletText(context, 'Expense', 'খরচ'),
                        selected: _type == 'expense',
                        color: const Color(0xFFE85D5D),
                        onTap: () => setState(() => _type = 'expense'),
                      ),
                      _EntryTypeChip(
                        label: sharedWalletText(context, 'Income', 'আয়'),
                        selected: _type == 'income',
                        color: const Color(0xFF2ECC9A),
                        onTap: () => setState(() => _type = 'income'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.done,
                    onEditingComplete: () {
                      _applyEvaluatedAmount();
                      FocusScope.of(context).unfocus();
                    },
                    onTapOutside: (_) => _applyEvaluatedAmount(),
                    decoration: InputDecoration(
                      labelText: sharedWalletText(context, 'Amount', 'পরিমাণ'),
                      hintText: '0.00',
                      prefixText: '\u09F3 ',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _noteController,
                    minLines: 2,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: sharedWalletText(context, 'Note', 'নোট'),
                      hintText: sharedWalletText(
                        context,
                        'Dinner, utilities, contribution, etc.',
                        'রাতের খাবার, বিল, অবদান ইত্যাদি',
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: isBusy ? null : _pickDate,
                    icon: const Icon(Icons.calendar_today_rounded),
                    label: Text(
                      LocaleFormatters.formatDate(
                        _date,
                        'dd MMM yyyy',
                        languageCode,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: OutlinedButton(
                          onPressed: isBusy
                              ? null
                              : () => Navigator.of(context).pop(),
                          child: Text(context.l10n.cancel),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: isBusy ? null : _save,
                          child: Text(
                            sharedWalletText(
                              context,
                              'Save entry',
                              'এন্ট্রি সংরক্ষণ করুন',
                            ),
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

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked == null || !mounted) {
      return;
    }
    setState(() {
      _date = picked;
    });
  }

  Future<void> _save() async {
    _applyEvaluatedAmount();
    final amount = _evaluateAmount(_amountController.text);
    if (amount == null || amount <= 0) {
      _showMessage(
        sharedWalletText(
          context,
          'Please enter a valid amount.',
          'সঠিক পরিমাণ লিখুন।',
        ),
      );
      return;
    }

    try {
      await ref
          .read(sharedWalletActionControllerProvider.notifier)
          .addEntry(
            walletId: widget.walletId,
            amount: amount,
            type: _type,
            note: _noteController.text,
            date: _date,
          );
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop();
      _showMessage(
        sharedWalletText(
          context,
          'Shared entry saved.',
          'শেয়ার্ড এন্ট্রি সংরক্ষণ হয়েছে।',
        ),
      );
    } catch (error) {
      _showMessage(error.toString());
    }
  }

  double? _evaluateAmount(String raw) {
    final normalized = raw
        .replaceAll(',', '')
        .replaceAll('\u09F3', '')
        .replaceAll(' ', '')
        .trim();
    if (normalized.isEmpty) {
      return null;
    }
    final direct = double.tryParse(normalized);
    if (direct != null) {
      return direct;
    }
    const expressionPattern = r'^\d+(?:\.\d+)?(?:[+\-*/]\d+(?:\.\d+)?)*$';
    if (!RegExp(expressionPattern).hasMatch(normalized)) {
      return null;
    }
    final numbers = normalized
        .split(RegExp(r'[+\-*/]'))
        .map(double.parse)
        .toList(growable: true);
    final operators = normalized
        .split(RegExp(r'\d+(?:\.\d+)?'))
        .where((part) => part.isNotEmpty)
        .join()
        .split('')
        .toList(growable: true);

    for (var index = 0; index < operators.length;) {
      final operator = operators[index];
      if (operator != '*' && operator != '/') {
        index++;
        continue;
      }
      final left = numbers[index];
      final right = numbers[index + 1];
      if (operator == '/' && right == 0) {
        return null;
      }
      numbers[index] = operator == '*' ? left * right : left / right;
      numbers.removeAt(index + 1);
      operators.removeAt(index);
    }

    var total = numbers.first;
    for (var index = 0; index < operators.length; index++) {
      final right = numbers[index + 1];
      total = operators[index] == '+' ? total + right : total - right;
    }
    return total;
  }

  void _applyEvaluatedAmount() {
    final value = _evaluateAmount(_amountController.text);
    if (value == null) {
      return;
    }
    final nextText = _trimZeroes(value);
    _amountController.value = _amountController.value.copyWith(
      text: nextText,
      selection: TextSelection.collapsed(offset: nextText.length),
      composing: TextRange.empty,
    );
  }

  String _trimZeroes(double value) {
    final text = value.toStringAsFixed(2);
    if (text.endsWith('.00')) {
      return text.substring(0, text.length - 3);
    }
    if (text.endsWith('0')) {
      return text.substring(0, text.length - 1);
    }
    return text;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _EntryTypeChip extends StatelessWidget {
  const _EntryTypeChip({
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
