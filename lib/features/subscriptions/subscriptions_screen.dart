import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_constants.dart';
import '../../shared/models/category_model.dart';
import '../../shared/models/subscription_model.dart';
import '../../shared/models/wallet_model.dart';
import '../../shared/widgets/premium_card.dart';
import '../dashboard/dashboard_ui_parts.dart';
import '../profile/profile_providers.dart';
import '../transactions/finance_catalog.dart';
import '../transactions/transaction_providers.dart';
import 'subscription_providers.dart';

class SubscriptionsScreen extends ConsumerWidget {
  const SubscriptionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptionsAsync = ref.watch(subscriptionsProvider);
    final upcoming = ref.watch(upcomingSubscriptionsProvider);
    final paidThisMonth = ref.watch(paidThisMonthSubscriptionsProvider);
    final overview = ref.watch(subscriptionsOverviewProvider);
    final profile = ref.watch(currentUserProfileProvider).asData?.value;
    final currency = profile?.currency ?? AppConstants.defaultCurrency;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Bills'),
          bottom: const TabBar(
            tabs: <Tab>[
              Tab(text: 'Upcoming'),
              Tab(text: 'All'),
              Tab(text: 'Paid this month'),
            ],
          ),
        ),
        body: SafeArea(
          child: subscriptionsAsync.when(
            data: (subscriptions) => Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 960),
                      child: _OverviewCard(
                        overview: overview,
                        currency: currency,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: <Widget>[
                      _SubscriptionListView(
                        subscriptions: upcoming,
                        currency: currency,
                        emptyTitle: 'No bill due soon',
                        emptySubtitle:
                            'Add recurring rent, internet, utilities, or any subscription you want to track.',
                      ),
                      _SubscriptionListView(
                        subscriptions: subscriptions,
                        currency: currency,
                        emptyTitle: 'No bill created yet',
                        emptySubtitle:
                            'Create your first recurring bill and the app will keep it organized here.',
                      ),
                      _SubscriptionListView(
                        subscriptions: paidThisMonth,
                        currency: currency,
                        emptyTitle: 'Nothing paid this month',
                        emptySubtitle:
                            'Bills you mark as paid will show up here during the current month.',
                        allowMarkAsPaid: false,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(child: Text(error.toString())),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _openEditor(context),
          icon: const Icon(Icons.add_rounded),
          label: const Text('Add bill'),
        ),
      ),
    );
  }

  Future<void> _openEditor(
    BuildContext context, {
    SubscriptionModel? subscription,
  }) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (context) =>
            SubscriptionEditorPage(subscription: subscription),
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({required this.overview, required this.currency});

  final SubscriptionsOverview overview;
  final String currency;

  @override
  Widget build(BuildContext context) {
    return buildPremiumCard(
      context: context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Recurring bills snapshot',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            'Track upcoming due dates, keep recurring expenses organized, and mark bills as paid in one move.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(
                context,
              ).textTheme.bodyMedium?.color?.withValues(alpha: 0.74),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: <Widget>[
              _MetricTile(
                label: 'Due soon',
                value: '${overview.dueSoonCount}',
                subtitle:
                    '$currency${overview.dueSoonTotal.toStringAsFixed(0)} scheduled',
                color: const Color(0xFFE85D5D),
              ),
              _MetricTile(
                label: 'Paid this month',
                value: '${overview.paidThisMonthCount}',
                subtitle:
                    '$currency${overview.paidThisMonthTotal.toStringAsFixed(0)} cleared',
                color: const Color(0xFF2ECC9A),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
    required this.subtitle,
    required this.color,
  });

  final String label;
  final String value;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(subtitle),
        ],
      ),
    );
  }
}

class _SubscriptionListView extends ConsumerWidget {
  const _SubscriptionListView({
    required this.subscriptions,
    required this.currency,
    required this.emptyTitle,
    required this.emptySubtitle,
    this.allowMarkAsPaid = true,
  });

  final List<SubscriptionModel> subscriptions;
  final String currency;
  final String emptyTitle;
  final String emptySubtitle;
  final bool allowMarkAsPaid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories =
        ref.watch(allCategoriesProvider).asData?.value ??
        const <CategoryModel>[];
    final wallets =
        ref.watch(walletsProvider).asData?.value ?? const <WalletModel>[];
    final languageCode =
        ref.watch(currentUserProfileProvider).asData?.value?.language ?? 'en';
    final categoryMap = {
      for (final category in categories) category.id: category,
    };
    final walletMap = {for (final wallet in wallets) wallet.id: wallet};

    if (subscriptions.isEmpty) {
      return SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 120),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 960),
            child: EmptyFinanceCard(title: emptyTitle, subtitle: emptySubtitle),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 120),
      itemCount: subscriptions.length,
      separatorBuilder: (_, _) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final subscription = subscriptions[index];
        final card = _SubscriptionCard(
          subscription: subscription,
          category: categoryMap[subscription.categoryId],
          wallet: walletMap[subscription.walletId],
          languageCode: languageCode,
          currency: currency,
          allowMarkAsPaid: allowMarkAsPaid,
        );

        final content = Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 960),
            child: card,
          ),
        );

        if (!allowMarkAsPaid) {
          return content;
        }

        return Dismissible(
          key: ValueKey<String>('subscription_${subscription.id}'),
          direction: DismissDirection.endToStart,
          confirmDismiss: (_) async {
            await _markAsPaid(context, ref, subscription);
            return false;
          },
          background: const _PaidSwipeBackground(),
          child: content,
        );
      },
    );
  }

  Future<void> _markAsPaid(
    BuildContext context,
    WidgetRef ref,
    SubscriptionModel subscription,
  ) async {
    try {
      await ref
          .read(subscriptionActionControllerProvider.notifier)
          .markAsPaid(subscription);
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${subscription.name} marked as paid.')),
      );
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

class _SubscriptionCard extends ConsumerWidget {
  const _SubscriptionCard({
    required this.subscription,
    required this.category,
    required this.wallet,
    required this.languageCode,
    required this.currency,
    required this.allowMarkAsPaid,
  });

  final SubscriptionModel subscription;
  final CategoryModel? category;
  final WalletModel? wallet;
  final String languageCode;
  final String currency;
  final bool allowMarkAsPaid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dueBadge = _dueBadge(subscription);

    return buildPremiumInkCard(
      context: context,
      onTap: () => Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (context) =>
              SubscriptionEditorPage(subscription: subscription),
        ),
      ),
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
                  color: Color(
                    category?.colorValue ?? 0xFF3D6BE4,
                  ).withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: Icon(
                  FinanceCatalog.iconForKey(
                    category?.iconKey ?? 'subscriptions',
                  ),
                  color: Color(category?.colorValue ?? 0xFF3D6BE4),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      subscription.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      category?.localizedName(languageCode) ?? 'Category',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.color?.withValues(alpha: 0.72),
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == 'delete') {
                    await _deleteSubscription(context, ref, subscription);
                    return;
                  }
                  if (value == 'paid') {
                    await ref
                        .read(subscriptionActionControllerProvider.notifier)
                        .markAsPaid(subscription);
                    if (!context.mounted) {
                      return;
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${subscription.name} marked as paid.'),
                      ),
                    );
                  }
                },
                itemBuilder: (context) => <PopupMenuEntry<String>>[
                  if (allowMarkAsPaid)
                    const PopupMenuItem<String>(
                      value: 'paid',
                      child: Text('Mark as paid'),
                    ),
                  const PopupMenuItem<String>(
                    value: 'delete',
                    child: Text('Delete'),
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
              _InfoChip(icon: Icons.event_rounded, label: dueBadge.$1),
              _InfoChip(
                icon: Icons.account_balance_wallet_rounded,
                label: wallet?.name ?? 'Wallet',
              ),
              _InfoChip(
                icon: Icons.repeat_rounded,
                label: SubscriptionFrequency.label(subscription.frequency),
              ),
            ],
          ),
          if (subscription.note.trim().isNotEmpty) ...<Widget>[
            const SizedBox(height: 14),
            Text(subscription.note),
          ],
          const SizedBox(height: 16),
          Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Next due',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('d MMM yyyy').format(subscription.nextDueDate),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: dueBadge.$2.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      dueBadge.$1,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: dueBadge.$2,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$currency${subscription.amount.toStringAsFixed(0)}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  (String, Color) _dueBadge(SubscriptionModel item) {
    if (item.daysUntilDue < 0) {
      return ('Overdue ${item.daysUntilDue.abs()}d', const Color(0xFFE85D5D));
    }
    if (item.daysUntilDue == 0) {
      return ('Due today', const Color(0xFFF59E0B));
    }
    if (item.daysUntilDue == 1) {
      return ('Due tomorrow', const Color(0xFF3D6BE4));
    }
    return ('In ${item.daysUntilDue} days', const Color(0xFF2ECC9A));
  }

  Future<void> _deleteSubscription(
    BuildContext context,
    WidgetRef ref,
    SubscriptionModel subscription,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete bill'),
        content: Text('Delete "${subscription.name}"?'),
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
          .read(subscriptionActionControllerProvider.notifier)
          .deleteSubscription(subscription.id);
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Bill deleted.')));
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

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 16),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
    );
  }
}

class _PaidSwipeBackground extends StatelessWidget {
  const _PaidSwipeBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF2ECC9A).withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(28),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      alignment: Alignment.centerRight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: const <Widget>[
          Icon(Icons.check_circle_outline_rounded, color: Color(0xFF2ECC9A)),
          SizedBox(width: 8),
          Text('Mark as paid'),
        ],
      ),
    );
  }
}

class SubscriptionEditorPage extends ConsumerStatefulWidget {
  const SubscriptionEditorPage({super.key, this.subscription});

  final SubscriptionModel? subscription;

  @override
  ConsumerState<SubscriptionEditorPage> createState() =>
      _SubscriptionEditorPageState();
}

class _SubscriptionEditorPageState
    extends ConsumerState<SubscriptionEditorPage> {
  late final TextEditingController _nameController;
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;
  late DateTime _nextDueDate;
  late int _reminderDaysBefore;
  late String _frequency;
  String _selectedCategoryId = '';
  String _selectedWalletId = '';

  bool get _isEditing => widget.subscription != null;

  @override
  void initState() {
    super.initState();
    final subscription = widget.subscription;
    _nameController = TextEditingController(text: subscription?.name ?? '');
    _amountController = TextEditingController(
      text: subscription == null ? '' : _trimZeroes(subscription.amount),
    );
    _noteController = TextEditingController(text: subscription?.note ?? '');
    _nextDueDate = subscription?.nextDueDate ?? DateTime.now();
    _reminderDaysBefore = subscription?.reminderDaysBefore ?? 2;
    _frequency = subscription?.frequency ?? SubscriptionFrequency.monthly;
    _selectedCategoryId = subscription?.categoryId ?? '';
    _selectedWalletId = subscription?.walletId ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(
      categoriesByTypeProvider(FinanceCatalog.expenseType),
    );
    final wallets =
        ref.watch(walletsProvider).asData?.value ?? const <WalletModel>[];
    final actionState = ref.watch(subscriptionActionControllerProvider);
    final isBusy = actionState.isLoading;

    if (!_isEditing && _selectedCategoryId.isEmpty && categories.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _selectedCategoryId = categories.first.id;
          });
        }
      });
    }
    if (!_isEditing && _selectedWalletId.isEmpty && wallets.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _selectedWalletId = wallets.first.id;
          });
        }
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit bill' : 'Add bill'),
        actions: <Widget>[
          if (_isEditing)
            TextButton(
              onPressed: isBusy ? null : _deleteSubscription,
              child: const Text('Delete'),
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
              child: categories.isEmpty || wallets.isEmpty
                  ? const EmptyFinanceCard(
                      title: 'Bills need categories and wallets',
                      subtitle:
                          'Make sure the starter finance data has loaded, then open this page again.',
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        buildPremiumCard(
                          context: context,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                _isEditing
                                    ? 'Update recurring bill'
                                    : 'Create recurring bill',
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'When you mark this bill as paid, the app creates a real expense transaction and moves the next due date forward automatically.',
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
                        TextField(
                          controller: _nameController,
                          enabled: !isBusy,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: 'Bill name',
                            hintText: 'Internet, Rent, Netflix, Electricity',
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _amountController,
                          enabled: !isBusy,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Amount',
                          ),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedCategoryId.isEmpty
                              ? categories.first.id
                              : _selectedCategoryId,
                          decoration: const InputDecoration(
                            labelText: 'Expense category',
                          ),
                          items: categories
                              .map(
                                (category) => DropdownMenuItem<String>(
                                  value: category.id,
                                  child: Text(category.name),
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
                                    _selectedCategoryId = value;
                                  });
                                },
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedWalletId.isEmpty
                              ? wallets.first.id
                              : _selectedWalletId,
                          decoration: const InputDecoration(
                            labelText: 'Wallet',
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
                        const SizedBox(height: 20),
                        Text(
                          'Frequency',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: SubscriptionFrequency.values
                              .map(
                                (frequency) => ChoiceChip(
                                  label: Text(
                                    SubscriptionFrequency.label(frequency),
                                  ),
                                  selected: _frequency == frequency,
                                  onSelected: isBusy
                                      ? null
                                      : (_) {
                                          setState(() {
                                            _frequency = frequency;
                                          });
                                        },
                                ),
                              )
                              .toList(growable: false),
                        ),
                        const SizedBox(height: 20),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Next due date'),
                          subtitle: Text(
                            DateFormat('EEEE, d MMM yyyy').format(_nextDueDate),
                          ),
                          trailing: OutlinedButton(
                            onPressed: isBusy ? null : _pickNextDueDate,
                            child: const Text('Change'),
                          ),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<int>(
                          initialValue: _reminderDaysBefore,
                          decoration: const InputDecoration(
                            labelText: 'Reminder',
                          ),
                          items: const <DropdownMenuItem<int>>[
                            DropdownMenuItem<int>(
                              value: 0,
                              child: Text('Same day'),
                            ),
                            DropdownMenuItem<int>(
                              value: 1,
                              child: Text('1 day before'),
                            ),
                            DropdownMenuItem<int>(
                              value: 2,
                              child: Text('2 days before'),
                            ),
                            DropdownMenuItem<int>(
                              value: 3,
                              child: Text('3 days before'),
                            ),
                            DropdownMenuItem<int>(
                              value: 7,
                              child: Text('7 days before'),
                            ),
                          ],
                          onChanged: isBusy
                              ? null
                              : (value) {
                                  if (value == null) {
                                    return;
                                  }
                                  setState(() {
                                    _reminderDaysBefore = value;
                                  });
                                },
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _noteController,
                          enabled: !isBusy,
                          minLines: 3,
                          maxLines: 5,
                          decoration: const InputDecoration(
                            labelText: 'Note',
                            hintText:
                                'Optional details like provider, package, or account information.',
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: isBusy ? null : _saveSubscription,
                            icon: isBusy
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.check_rounded),
                            label: Text(
                              _isEditing ? 'Save bill' : 'Create bill',
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

  Future<void> _pickNextDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _nextDueDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked == null) {
      return;
    }
    setState(() {
      _nextDueDate = picked;
    });
  }

  Future<void> _saveSubscription() async {
    final name = _nameController.text.trim();
    final amount = double.tryParse(_amountController.text.trim());

    if (name.isEmpty) {
      _showMessage('Please enter a bill name.');
      return;
    }
    if (amount == null || amount <= 0) {
      _showMessage('Please enter a valid amount.');
      return;
    }
    if (_selectedCategoryId.isEmpty || _selectedWalletId.isEmpty) {
      _showMessage('Please choose a category and wallet.');
      return;
    }

    final base = widget.subscription;
    final subscription = SubscriptionModel(
      id: base?.id ?? '',
      name: name,
      amount: amount,
      categoryId: _selectedCategoryId,
      walletId: _selectedWalletId,
      frequency: _frequency,
      nextDueDate: _nextDueDate,
      reminderDaysBefore: _reminderDaysBefore,
      isPaid: false,
      note: _noteController.text.trim(),
      createdAt: base?.createdAt ?? DateTime.now(),
      lastPaidAt: base?.lastPaidAt,
    );

    try {
      final controller = ref.read(
        subscriptionActionControllerProvider.notifier,
      );
      if (_isEditing) {
        await controller.updateSubscription(subscription);
      } else {
        await controller.addSubscription(subscription);
      }

      if (!mounted) {
        return;
      }
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing
                ? 'Bill updated successfully.'
                : 'Bill created successfully.',
          ),
        ),
      );
    } catch (error) {
      _showMessage(error.toString());
    }
  }

  Future<void> _deleteSubscription() async {
    final subscription = widget.subscription;
    if (subscription == null) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete bill'),
        content: Text('Delete "${subscription.name}"?'),
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

    if (confirmed != true || !mounted) {
      return;
    }

    try {
      await ref
          .read(subscriptionActionControllerProvider.notifier)
          .deleteSubscription(subscription.id);
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Bill deleted.')));
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
