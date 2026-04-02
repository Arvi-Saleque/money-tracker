import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/gradient_colors.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../shared/providers/theme_provider.dart';
import '../../shared/widgets/premium_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final gradients = theme.extension<GradientColors>()!;
    final selectedTheme = ref.watch(themeProvider);
    final themeController = ref.read(themeProvider.notifier);
    final localizations = AppLocalizations.of(context);

    final quickLinks = <_QuickLink>[
      const _QuickLink('Auth', Icons.login_rounded, AppConstants.authRoute),
      const _QuickLink(
        'Transactions',
        Icons.receipt_long_rounded,
        AppConstants.transactionsRoute,
      ),
      const _QuickLink(
        'Calendar',
        Icons.calendar_month_rounded,
        AppConstants.calendarRoute,
      ),
      const _QuickLink(
        'Reports',
        Icons.bar_chart_rounded,
        AppConstants.reportsRoute,
      ),
      const _QuickLink(
        'Wallets',
        Icons.account_balance_wallet_rounded,
        AppConstants.walletsRoute,
      ),
      const _QuickLink(
        'Budgets',
        Icons.track_changes_rounded,
        AppConstants.budgetsRoute,
      ),
      const _QuickLink('Goals', Icons.flag_rounded, AppConstants.goalsRoute),
      const _QuickLink(
        'Bills',
        Icons.notifications_active_rounded,
        AppConstants.subscriptionsRoute,
      ),
      const _QuickLink(
        'Profile',
        Icons.person_outline_rounded,
        AppConstants.profileRoute,
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(localizations.appTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                buildPremiumCard(
                  context: context,
                  gradient: gradients.heroGradient,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        localizations.appTitle,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Phase 1 foundation is ready with Firebase, Riverpod, GoRouter, and a reusable theme system.',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: Colors.white.withValues(alpha: 0.92),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: const <Widget>[
                          _HeroStatChip(label: 'Themes', value: '2 ready'),
                          _HeroStatChip(
                            label: 'Routes',
                            value: '9 placeholders',
                          ),
                          _HeroStatChip(label: 'Firebase', value: 'Connected'),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                buildPremiumCard(
                  context: context,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Theme system',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Theme changes persist with SharedPreferences and flow through ThemeExtension-based colors.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.textTheme.bodyMedium?.color?.withValues(
                            alpha: 0.78,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      SegmentedButton<String>(
                        segments: AppConstants.availableThemes
                            .map(
                              (themeName) => ButtonSegment<String>(
                                value: themeName,
                                label: Text(AppConstants.themeLabel(themeName)),
                              ),
                            )
                            .toList(),
                        selected: <String>{selectedTheme},
                        onSelectionChanged: (selection) {
                          themeController.setTheme(selection.first);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Feature placeholders',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 14,
                  runSpacing: 14,
                  children: quickLinks
                      .map(
                        (link) => SizedBox(
                          width: 220,
                          child: buildPremiumInkCard(
                            context: context,
                            onTap: () => context.go(link.route),
                            child: Row(
                              children: <Widget>[
                                Icon(
                                  link.icon,
                                  color: theme.colorScheme.primary,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    link.label,
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                ),
                                const Icon(Icons.arrow_forward_rounded),
                              ],
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
      ),
    );
  }
}

class _QuickLink {
  const _QuickLink(this.label, this.icon, this.route);

  final String label;
  final IconData icon;
  final String route;
}

class _HeroStatChip extends StatelessWidget {
  const _HeroStatChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Text(
        '$label: $value',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
