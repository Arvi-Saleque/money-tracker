import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/gradient_colors.dart';
import '../../l10n/l10n_extension.dart';
import '../../shared/widgets/premium_card.dart';
import 'onboarding_providers.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  late final PageController _pageController;
  int _pageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final gradients = theme.extension<GradientColors>()!;
    final pages = <_OnboardingPageData>[
      _OnboardingPageData(
        icon: Icons.account_balance_wallet_rounded,
        title: l10n.onboardingWalletsTitle,
        subtitle: l10n.onboardingWalletsSubtitle,
        accent: const Color(0xFF3D6BE4),
      ),
      _OnboardingPageData(
        icon: Icons.receipt_long_rounded,
        title: l10n.onboardingTransactionsTitle,
        subtitle: l10n.onboardingTransactionsSubtitle,
        accent: const Color(0xFF2ECC9A),
      ),
      _OnboardingPageData(
        icon: Icons.insights_rounded,
        title: l10n.onboardingReportsTitle,
        subtitle: l10n.onboardingReportsSubtitle,
        accent: const Color(0xFFED8F41),
      ),
    ];

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: <Color>[
              theme.scaffoldBackgroundColor,
              gradients.heroGradient.colors.last.withValues(alpha: 0.18),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        l10n.onboardingEyebrow,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: _finish,
                      child: Text(l10n.skipAction),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: pages.length,
                    onPageChanged: (value) {
                      setState(() {
                        _pageIndex = value;
                      });
                    },
                    itemBuilder: (context, index) {
                      final page = pages[index];
                      return Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 700),
                          child: buildPremiumCard(
                            context: context,
                            gradient: LinearGradient(
                              colors: <Color>[
                                page.accent.withValues(alpha: 0.22),
                                theme.colorScheme.surface,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 12,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                    width: 72,
                                    height: 72,
                                    decoration: BoxDecoration(
                                      color: page.accent.withValues(
                                        alpha: 0.16,
                                      ),
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                    child: Icon(
                                      page.icon,
                                      size: 36,
                                      color: page.accent,
                                    ),
                                  ),
                                  const SizedBox(height: 28),
                                  Text(
                                    page.title,
                                    style: theme.textTheme.headlineMedium
                                        ?.copyWith(fontWeight: FontWeight.w800),
                                  ),
                                  const SizedBox(height: 14),
                                  Text(
                                    page.subtitle,
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(
                                          color: theme
                                              .textTheme
                                              .bodyMedium
                                              ?.color
                                              ?.withValues(alpha: 0.8),
                                          height: 1.5,
                                        ),
                                  ),
                                  const Spacer(),
                                  Wrap(
                                    spacing: 10,
                                    runSpacing: 10,
                                    children: <Widget>[
                                      _OnboardingHintChip(
                                        icon: Icons.bolt_rounded,
                                        label: l10n.onboardingHintQuick,
                                      ),
                                      _OnboardingHintChip(
                                        icon: Icons.lock_clock_rounded,
                                        label: l10n.onboardingHintTrack,
                                      ),
                                      _OnboardingHintChip(
                                        icon: Icons.auto_graph_rounded,
                                        label: l10n.onboardingHintGrow,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List<Widget>.generate(
                    pages.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      width: _pageIndex == index ? 28 : 10,
                      height: 10,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: _pageIndex == index
                            ? theme.colorScheme.primary
                            : theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: <Widget>[
                    if (_pageIndex > 0)
                      OutlinedButton.icon(
                        onPressed: _goBack,
                        icon: const Icon(Icons.arrow_back_rounded),
                        label: Text(l10n.backAction),
                      )
                    else
                      const SizedBox(width: 1),
                    const Spacer(),
                    FilledButton.icon(
                      onPressed: _pageIndex == pages.length - 1
                          ? _finish
                          : _goNext,
                      icon: Icon(
                        _pageIndex == pages.length - 1
                            ? Icons.check_rounded
                            : Icons.arrow_forward_rounded,
                      ),
                      label: Text(
                        _pageIndex == pages.length - 1
                            ? l10n.getStartedAction
                            : l10n.nextAction,
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

  Future<void> _finish() async {
    await ref.read(onboardingSeenProvider.notifier).complete();
    if (!mounted) {
      return;
    }
    context.go(AppConstants.homeRoute);
  }

  void _goNext() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }

  void _goBack() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }
}

class _OnboardingPageData {
  const _OnboardingPageData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accent,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;
}

class _OnboardingHintChip extends StatelessWidget {
  const _OnboardingHintChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 16),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
