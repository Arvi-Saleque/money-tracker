import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/locale_formatters.dart';
import '../../l10n/l10n_extension.dart';
import '../../shared/models/shared_wallet_entry_model.dart';
import '../../shared/models/shared_wallet_model.dart';
import '../../shared/widgets/premium_card.dart';
import '../dashboard/dashboard_ui_parts.dart';
import '../profile/profile_providers.dart';
import '../transactions/finance_catalog.dart';
import '../transactions/transaction_providers.dart';
import '../wallets/wallets_screen.dart';
import 'shared_wallet_entry_editor_page.dart';
import 'shared_wallet_helpers.dart';
import 'shared_wallet_providers.dart';

Future<void> openSharedWalletDetailScreen(
  BuildContext context, {
  required String walletId,
}) async {
  await Navigator.of(context).push<void>(
    MaterialPageRoute<void>(
      builder: (context) => SharedWalletDetailScreen(walletId: walletId),
    ),
  );
}

class SharedWalletDetailScreen extends ConsumerWidget {
  const SharedWalletDetailScreen({super.key, required this.walletId});

  final String walletId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wallets =
        ref.watch(sharedWalletsProvider).asData?.value ??
        const <SharedWalletModel>[];
    final wallet = wallets.cast<SharedWalletModel?>().firstWhere(
      (item) => item?.id == walletId,
      orElse: () => null,
    );
    final entries =
        ref.watch(sharedWalletEntriesProvider(walletId)).asData?.value ??
        const <SharedWalletEntryModel>[];
    final profile = ref.watch(currentUserProfileProvider).asData?.value;
    final uid = ref.watch(currentUserIdProvider);
    final currency = profile?.currency ?? AppConstants.defaultCurrency;
    final languageCode =
        profile?.language ?? Localizations.localeOf(context).languageCode;

    if (wallet == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            sharedWalletText(context, 'Shared wallet', 'শেয়ার্ড ওয়ালেট'),
          ),
        ),
        body: Center(
          child: Text(
            sharedWalletText(
              context,
              'This shared wallet is not available anymore.',
              'এই শেয়ার্ড ওয়ালেটটি আর পাওয়া যাচ্ছে না।',
            ),
          ),
        ),
      );
    }

    final isOwner = uid != null && wallet.isOwner(uid);

    return Scaffold(
      appBar: AppBar(
        title: Text(wallet.name),
        actions: <Widget>[
          if (isOwner)
            IconButton(
              onPressed: () => _openInviteDialog(context, ref, wallet),
              icon: const Icon(Icons.person_add_alt_1_rounded),
              tooltip: sharedWalletText(
                context,
                'Invite member',
                'সদস্য যোগ করুন',
              ),
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
                                  MiniPill(
                                    label: sharedWalletText(
                                      context,
                                      '${wallet.memberIds.length} members',
                                      '${wallet.memberIds.length} জন সদস্য',
                                    ),
                                  ),
                                  if (isOwner)
                                    MiniPill(
                                      label: sharedWalletText(
                                        context,
                                        'Owner',
                                        'মালিক',
                                      ),
                                    ),
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
                    sharedWalletText(context, 'Members', 'সদস্যরা'),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  buildPremiumCard(
                    context: context,
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: wallet.memberIds.map((memberId) {
                        final memberName =
                            wallet.memberNames[memberId]?.trim().isNotEmpty ==
                                true
                            ? wallet.memberNames[memberId]!
                            : sharedWalletText(context, 'Member', 'সদস্য');
                        return MiniPill(
                          label: wallet.roleFor(memberId) == 'owner'
                              ? '$memberName • ${sharedWalletText(context, 'Owner', 'মালিক')}'
                              : memberName,
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    sharedWalletText(
                      context,
                      'Shared activity',
                      'শেয়ার্ড এন্ট্রি',
                    ),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (entries.isEmpty)
                    EmptyFinanceCard(
                      title: sharedWalletText(
                        context,
                        'No shared entries yet',
                        'এখনও কোনো শেয়ার্ড এন্ট্রি নেই',
                      ),
                      subtitle: sharedWalletText(
                        context,
                        'Add income or expense entries for this shared wallet here.',
                        'এই শেয়ার্ড ওয়ালেটের জন্য এখান থেকে আয় বা খরচ যোগ করুন।',
                      ),
                    )
                  else
                    ...entries.map((entry) {
                      final isIncome = entry.type == 'income';
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: FinanceTransactionTile(
                          title: entry.note.trim().isEmpty
                              ? sharedWalletText(
                                  context,
                                  isIncome ? 'Shared income' : 'Shared expense',
                                  isIncome ? 'শেয়ার্ড আয়' : 'শেয়ার্ড খরচ',
                                )
                              : entry.note.trim(),
                          subtitle: [
                            entry.createdByName,
                            LocaleFormatters.formatDate(
                              entry.date,
                              'dd MMM yyyy  •  hh:mm a',
                              languageCode,
                            ),
                          ].join('  •  '),
                          amount:
                              '${isIncome ? '+' : '-'}${formatWalletCurrency(entry.amount, currency, languageCode: languageCode)}',
                          icon: isIncome
                              ? Icons.south_west_rounded
                              : Icons.north_east_rounded,
                          color: isIncome
                              ? const Color(0xFF2ECC9A)
                              : const Color(0xFFE85D5D),
                        ),
                      );
                    }),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push<void>(
          MaterialPageRoute<void>(
            builder: (context) =>
                SharedWalletEntryEditorPage(walletId: wallet.id),
          ),
        ),
        icon: const Icon(Icons.add_rounded),
        label: Text(sharedWalletText(context, 'Add entry', 'এন্ট্রি যোগ করুন')),
      ),
    );
  }

  Future<void> _openInviteDialog(
    BuildContext context,
    WidgetRef ref,
    SharedWalletModel wallet,
  ) async {
    final controller = TextEditingController();
    final email = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          sharedWalletText(context, 'Invite member', 'সদস্য যোগ করুন'),
        ),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: sharedWalletText(
              context,
              'Member email',
              'সদস্যের ইমেইল',
            ),
            hintText: 'name@example.com',
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: Text(
              sharedWalletText(context, 'Send invite', 'আমন্ত্রণ পাঠান'),
            ),
          ),
        ],
      ),
    );
    controller.dispose();

    if (email == null || email.trim().isEmpty) {
      return;
    }

    try {
      await ref
          .read(sharedWalletActionControllerProvider.notifier)
          .inviteMember(wallet: wallet, email: email);
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            sharedWalletText(
              context,
              'Invitation sent.',
              'আমন্ত্রণ পাঠানো হয়েছে।',
            ),
          ),
        ),
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
