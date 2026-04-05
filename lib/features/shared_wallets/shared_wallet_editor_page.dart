import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/l10n_extension.dart';
import '../../shared/widgets/premium_card.dart';
import '../transactions/finance_catalog.dart';
import 'shared_wallet_helpers.dart';
import 'shared_wallet_providers.dart';

Future<void> openCreateSharedWalletPage(BuildContext context) async {
  await Navigator.of(context).push<void>(
    MaterialPageRoute<void>(
      builder: (context) => const SharedWalletEditorPage(),
    ),
  );
}

class SharedWalletEditorPage extends ConsumerStatefulWidget {
  const SharedWalletEditorPage({super.key});

  @override
  ConsumerState<SharedWalletEditorPage> createState() =>
      _SharedWalletEditorPageState();
}

class _SharedWalletEditorPageState
    extends ConsumerState<SharedWalletEditorPage> {
  late final TextEditingController _nameController;
  late String _selectedType;
  late String _selectedIconKey;
  late int _selectedColorValue;

  @override
  void initState() {
    super.initState();
    final meta = FinanceCatalog.walletTypes.first;
    _nameController = TextEditingController();
    _selectedType = meta.type;
    _selectedIconKey = meta.iconKey;
    _selectedColorValue = meta.colorValue;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isBusy = ref.watch(sharedWalletActionControllerProvider).isLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          sharedWalletText(
            context,
            'Create shared wallet',
            'শেয়ার্ড ওয়ালেট তৈরি করুন',
          ),
        ),
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
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: Color(
                            _selectedColorValue,
                          ).withValues(alpha: 0.14),
                          foregroundColor: Color(_selectedColorValue),
                          child: Icon(
                            FinanceCatalog.iconForKey(_selectedIconKey),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            _nameController.text.trim().isEmpty
                                ? sharedWalletText(
                                    context,
                                    'Family wallet preview',
                                    'পারিবারিক ওয়ালেট প্রিভিউ',
                                  )
                                : _nameController.text.trim(),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _nameController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      labelText: sharedWalletText(
                        context,
                        'Wallet name',
                        'ওয়ালেটের নাম',
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedType,
                    decoration: InputDecoration(
                      labelText: sharedWalletText(
                        context,
                        'Wallet type',
                        'ওয়ালেটের ধরন',
                      ),
                    ),
                    items: FinanceCatalog.walletTypes
                        .map(
                          (type) => DropdownMenuItem<String>(
                            value: type.type,
                            child: Text(context.l10n.walletTypeName(type.type)),
                          ),
                        )
                        .toList(),
                    onChanged: isBusy
                        ? null
                        : (value) {
                            if (value == null) {
                              return;
                            }
                            final selected = FinanceCatalog.walletTypeFor(
                              value,
                            );
                            setState(() {
                              _selectedType = value;
                              _selectedIconKey = selected.iconKey;
                              _selectedColorValue = selected.colorValue;
                            });
                          },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    sharedWalletText(context, 'Choose icon', 'আইকন বেছে নিন'),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 5,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                        ),
                    itemCount: FinanceCatalog.categoryIcons.length,
                    itemBuilder: (context, index) {
                      final option = FinanceCatalog.categoryIcons[index];
                      final selected = option.key == _selectedIconKey;
                      return InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: isBusy
                            ? null
                            : () =>
                                  setState(() => _selectedIconKey = option.key),
                        child: Container(
                          decoration: BoxDecoration(
                            color: selected
                                ? theme.colorScheme.primary.withValues(
                                    alpha: 0.14,
                                  )
                                : theme.colorScheme.surface,
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
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: FinanceCatalog.colorChoices.map((colorValue) {
                      final selected = colorValue == _selectedColorValue;
                      return InkWell(
                        borderRadius: BorderRadius.circular(999),
                        onTap: isBusy
                            ? null
                            : () => setState(
                                () => _selectedColorValue = colorValue,
                              ),
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
                              'Create shared wallet',
                              'শেয়ার্ড ওয়ালেট তৈরি করুন',
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

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty) {
      _showMessage(
        sharedWalletText(
          context,
          'Please enter a wallet name.',
          'একটি ওয়ালেটের নাম লিখুন।',
        ),
      );
      return;
    }

    try {
      await ref
          .read(sharedWalletActionControllerProvider.notifier)
          .createSharedWallet(
            name: _nameController.text.trim(),
            type: _selectedType,
            iconKey: _selectedIconKey,
            colorValue: _selectedColorValue,
          );
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop();
      _showMessage(
        sharedWalletText(
          context,
          'Shared wallet created.',
          'শেয়ার্ড ওয়ালেট তৈরি হয়েছে।',
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
}
