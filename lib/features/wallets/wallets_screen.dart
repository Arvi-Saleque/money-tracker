import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/locale_formatters.dart';
import '../../l10n/l10n_extension.dart';
import '../../shared/models/category_model.dart';
import '../../shared/models/transaction_model.dart';
import '../../shared/models/wallet_model.dart';
import '../../shared/widgets/premium_card.dart';
import '../dashboard/dashboard_ui_parts.dart';
import '../profile/profile_providers.dart';
import '../transactions/finance_catalog.dart';
import '../transactions/transaction_editor_sheet.dart';
import '../transactions/transaction_providers.dart';
import 'transfer_editor_page.dart';

class WalletsScreen extends ConsumerWidget {
  const WalletsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final walletsAsync = ref.watch(walletsProvider);
    final profile = ref.watch(currentUserProfileProvider).asData?.value;
    final currency = profile?.currency ?? AppConstants.defaultCurrency;
    final languageCode =
        profile?.language ?? Localizations.localeOf(context).languageCode;
    final wallets = walletsAsync.asData?.value ?? const <WalletModel>[];
    final total = wallets.fold<double>(
      0,
      (sum, wallet) => sum + wallet.balance,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.walletsTitle),
        actions: <Widget>[
          IconButton(
            onPressed: () => openTransferEditorPage(context),
            icon: const Icon(Icons.swap_horiz_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: walletsAsync.when(
          data: (_) => SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 980),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    buildPremiumCard(
                      context: context,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(l10n.walletsTotal),
                          const SizedBox(height: 8),
                          Text(
                            formatWalletCurrency(
                              total,
                              currency,
                              languageCode: languageCode,
                            ),
                            style: Theme.of(context).textTheme.displaySmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final title = Text(
                          l10n.yourWalletsTitle,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                        );
                        final button = FilledButton.icon(
                          onPressed: () => _openWalletEditor(context),
                          icon: const Icon(Icons.add_rounded),
                          label: Text(l10n.addWalletAction),
                        );

                        if (constraints.maxWidth < 420) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              title,
                              const SizedBox(height: 10),
                              button,
                            ],
                          );
                        }

                        return Row(
                          children: <Widget>[
                            Expanded(child: title),
                            const SizedBox(width: 12),
                            button,
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    if (wallets.isEmpty)
                      EmptyFinanceCard(
                        title: l10n.noWalletAvailableTitle,
                        subtitle: l10n.noWalletAvailableSubtitle,
                        actionLabel: l10n.addWalletAction,
                        onAction: () => _openWalletEditor(context),
                      )
                    else
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final crossAxisCount = constraints.maxWidth > 880
                              ? 3
                              : constraints.maxWidth > 580
                              ? 2
                              : 1;

                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  mainAxisSpacing: 14,
                                  crossAxisSpacing: 14,
                                  mainAxisExtent: crossAxisCount == 1
                                      ? 244
                                      : 236,
                                ),
                            itemCount: wallets.length,
                            itemBuilder: (context, index) {
                              final wallet = wallets[index];
                              return _WalletCard(
                                wallet: wallet,
                                currency: currency,
                                onTap: () => _openWalletDetail(context, wallet),
                                onEdit: () =>
                                    _openWalletEditor(context, wallet: wallet),
                                onTransfer: () => openTransferEditorPage(
                                  context,
                                  initialFromWalletId: wallet.id,
                                ),
                                onDelete: () =>
                                    _deleteWallet(context, ref, wallet),
                              );
                            },
                          );
                        },
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
        onPressed: () => openTransferEditorPage(context),
        icon: const Icon(Icons.swap_horiz_rounded),
        label: Text(l10n.transferAction),
      ),
    );
  }

  Future<void> _openWalletEditor(
    BuildContext context, {
    WalletModel? wallet,
  }) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (context) => WalletEditorPage(wallet: wallet),
      ),
    );
  }

  Future<void> _openWalletDetail(
    BuildContext context,
    WalletModel wallet,
  ) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (context) => WalletDetailScreen(walletId: wallet.id),
      ),
    );
  }

  Future<void> _deleteWallet(
    BuildContext context,
    WidgetRef ref,
    WalletModel wallet,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.deleteWalletTitle),
        content: Text(context.l10n.deleteWalletPrompt(wallet.name)),
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
      await ref
          .read(walletActionControllerProvider.notifier)
          .deleteWallet(wallet);
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.walletDeleted)));
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

class WalletDetailScreen extends ConsumerWidget {
  const WalletDetailScreen({super.key, required this.walletId});

  final String walletId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wallets =
        ref.watch(walletsProvider).asData?.value ?? const <WalletModel>[];
    final wallet = wallets.cast<WalletModel?>().firstWhere(
      (item) => item?.id == walletId,
      orElse: () => null,
    );
    final transactions =
        ref.watch(walletTransactionsProvider(walletId)).asData?.value ??
        const <TransactionModel>[];
    final categories =
        ref.watch(allCategoriesProvider).asData?.value ??
        const <CategoryModel>[];
    final categoryMap = {
      for (final category in categories) category.id: category,
    };
    final walletMap = {for (final item in wallets) item.id: item};
    final profile = ref.watch(currentUserProfileProvider).asData?.value;
    final currency = profile?.currency ?? AppConstants.defaultCurrency;
    final languageCode =
        profile?.language ?? Localizations.localeOf(context).languageCode;

    if (wallet == null) {
      return Scaffold(
        appBar: AppBar(title: Text(context.l10n.walletDetailTitle)),
        body: Center(child: Text(context.l10n.walletNotFound)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(wallet.name),
        actions: <Widget>[
          IconButton(
            onPressed: () =>
                openTransferEditorPage(context, initialFromWalletId: wallet.id),
            icon: const Icon(Icons.swap_horiz_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 860),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  buildPremiumCard(
                    context: context,
                    child: Row(
                      children: <Widget>[
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: Color(
                            wallet.colorValue,
                          ).withValues(alpha: 0.14),
                          foregroundColor: Color(wallet.colorValue),
                          child: Icon(
                            FinanceCatalog.iconForKey(wallet.iconKey),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                wallet.name,
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: <Widget>[
                                  MiniPill(
                                    label: context.l10n.walletTypeName(
                                      wallet.type,
                                    ),
                                  ),
                                  if (wallet.isDefault)
                                    MiniPill(label: context.l10n.defaultLabel),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Text(
                          formatWalletCurrency(
                            wallet.balance,
                            currency,
                            languageCode: languageCode,
                          ),
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    context.l10n.walletActivityTitle,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (transactions.isEmpty)
                    EmptyFinanceCard(
                      title: context.l10n.noTransactionsHereYet,
                      subtitle: context.l10n.walletTransactionsSubtitle,
                    )
                  else
                    ...transactions.take(50).map((transaction) {
                      final category = categoryMap[transaction.categoryId];
                      final otherWallet = transaction.transferWalletId == null
                          ? null
                          : walletMap[transaction.transferWalletId!];

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: FinanceTransactionTile(
                          title: FinanceCatalog.transactionTitle(
                            transaction,
                            category: category,
                            otherWallet: otherWallet,
                            languageCode: languageCode,
                          ),
                          subtitle: [
                            if (transaction.note.trim().isNotEmpty)
                              transaction.note.trim(),
                            LocaleFormatters.formatDate(
                              transaction.date,
                              'dd MMM yyyy  •  hh:mm a',
                              languageCode,
                            ),
                          ].join('  '),
                          amount:
                              '${transaction.type == FinanceCatalog.incomeType ? '+' : '-'}${formatWalletCurrency(transaction.amount, currency, languageCode: languageCode)}',
                          icon: FinanceCatalog.transactionIcon(
                            transaction,
                            category: category,
                          ),
                          color: FinanceCatalog.transactionColor(transaction),
                          onTap: () {
                            if (transaction.isTransfer) {
                              openTransferEditorPage(
                                context,
                                transaction: transaction,
                              );
                            } else {
                              openTransactionEditorPage(
                                context,
                                transaction: transaction,
                              );
                            }
                          },
                        ),
                      );
                    }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class WalletEditorPage extends ConsumerStatefulWidget {
  const WalletEditorPage({super.key, this.wallet});

  final WalletModel? wallet;

  @override
  ConsumerState<WalletEditorPage> createState() => _WalletEditorPageState();
}

String formatWalletCurrency(
  double amount,
  String currency, {
  String languageCode = 'en',
}) {
  return LocaleFormatters.formatCurrency(amount, currency, languageCode);
}

class _WalletEditorPageState extends ConsumerState<WalletEditorPage> {
  late final TextEditingController _nameController;
  late final TextEditingController _balanceController;
  late String _selectedType;
  late String _selectedIconKey;
  late int _selectedColorValue;
  late bool _isDefault;

  bool get _isEditing => widget.wallet != null;

  @override
  void initState() {
    super.initState();
    final wallet = widget.wallet;
    final typeMeta = wallet == null
        ? FinanceCatalog.walletTypes.first
        : FinanceCatalog.walletTypeFor(wallet.type);
    _nameController = TextEditingController(text: wallet?.name ?? '');
    _balanceController = TextEditingController(
      text: wallet == null ? '' : _trimZeroes(wallet.balance),
    );
    _selectedType = wallet?.type ?? typeMeta.type;
    _selectedIconKey = wallet?.iconKey ?? typeMeta.iconKey;
    _selectedColorValue = wallet?.colorValue ?? typeMeta.colorValue;
    _isDefault = wallet?.isDefault ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(walletActionControllerProvider);
    final isBusy = state.isLoading;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.walletEditorTitle(_isEditing))),
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                _nameController.text.trim().isEmpty
                                    ? context.l10n.walletPreviewTitle
                                    : _nameController.text.trim(),
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                context.l10n.walletTypeName(_selectedType),
                              ),
                            ],
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
                      labelText: context.l10n.walletNameFieldLabel,
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedType,
                    decoration: InputDecoration(
                      labelText: context.l10n.walletTypeFieldLabel,
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
                  if (_isEditing)
                    TextFormField(
                      initialValue: _trimZeroes(widget.wallet!.balance),
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: context.l10n.currentBalanceFieldLabel,
                        helperText: context.l10n.currentBalanceFieldHint,
                      ),
                    )
                  else
                    TextField(
                      controller: _balanceController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        labelText: context.l10n.initialBalanceFieldLabel,
                        hintText: '0.00',
                        prefixText: '\u09F3 ',
                      ),
                    ),
                  const SizedBox(height: 16),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    value: _isDefault,
                    title: Text(context.l10n.setAsDefaultWalletLabel),
                    onChanged: isBusy
                        ? null
                        : (value) => setState(() => _isDefault = value),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    context.l10n.chooseIconLabel,
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
                          onPressed: isBusy ? null : _saveWallet,
                          child: Text(
                            _isEditing
                                ? context.l10n.updateWalletAction
                                : context.l10n.createWalletAction,
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

  Future<void> _saveWallet() async {
    if (_nameController.text.trim().isEmpty) {
      _showMessage(context.l10n.walletNameRequired);
      return;
    }

    final initialBalance = _isEditing
        ? widget.wallet!.balance
        : double.tryParse(_balanceController.text.replaceAll(',', '')) ?? 0;

    final wallet = WalletModel(
      id: widget.wallet?.id ?? '',
      name: _nameController.text.trim(),
      type: _selectedType,
      balance: initialBalance,
      iconKey: _selectedIconKey,
      colorValue: _selectedColorValue,
      isDefault: _isDefault,
      createdAt: widget.wallet?.createdAt ?? DateTime.now(),
    );

    try {
      final controller = ref.read(walletActionControllerProvider.notifier);
      if (_isEditing) {
        await controller.updateWallet(wallet);
      } else {
        await controller.addWallet(wallet);
      }
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing ? context.l10n.walletUpdated : context.l10n.walletCreated,
          ),
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

class _WalletCard extends StatelessWidget {
  const _WalletCard({
    required this.wallet,
    required this.currency,
    required this.onTap,
    required this.onEdit,
    required this.onTransfer,
    required this.onDelete,
  });

  final WalletModel wallet;
  final String currency;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onTransfer;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return buildPremiumInkCard(
      context: context,
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            children: <Widget>[
              CircleAvatar(
                radius: 22,
                backgroundColor: Color(
                  wallet.colorValue,
                ).withValues(alpha: 0.14),
                foregroundColor: Color(wallet.colorValue),
                child: Icon(FinanceCatalog.iconForKey(wallet.iconKey)),
              ),
              const Spacer(),
              PopupMenuButton<String>(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                onSelected: (value) {
                  if (value == 'edit') {
                    onEdit();
                  } else if (value == 'transfer') {
                    onTransfer();
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
                    value: 'transfer',
                    child: Text(context.l10n.transferAction),
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
          Text(
            wallet.name,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: <Widget>[
              MiniPill(label: context.l10n.walletTypeName(wallet.type)),
                if (wallet.isDefault)
                  MiniPill(label: context.l10n.defaultLabel),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            formatWalletCurrency(wallet.balance, currency),
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
