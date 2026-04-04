import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../l10n/l10n_extension.dart';
import '../../shared/providers/theme_provider.dart';
import '../transactions/transaction_editor_sheet.dart';
import 'dashboard_calendar_tab.dart';
import 'dashboard_tabs.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final currentTheme = ref.watch(themeProvider);
    final themeController = ref.read(themeProvider.notifier);
    final tabs = <_ShellTab>[
      _ShellTab(
        title: localizations.appTitle,
        subtitle: localizations.homeTabSubtitle,
        icon: Icons.home_rounded,
        selectedIcon: Icons.home_filled,
        child: const HomeTab(),
      ),
      _ShellTab(
        title: localizations.transactionsTabLabel,
        subtitle: localizations.transactionsTabSubtitle,
        icon: Icons.receipt_long_outlined,
        selectedIcon: Icons.receipt_long_rounded,
        child: const TransactionsTab(),
      ),
      _ShellTab(
        title: localizations.calendarTabLabel,
        subtitle: localizations.calendarTabSubtitle,
        icon: Icons.calendar_month_outlined,
        selectedIcon: Icons.calendar_month_rounded,
        child: const CalendarTabView(),
      ),
      _ShellTab(
        title: localizations.reportsTabLabel,
        subtitle: localizations.reportsTabSubtitle,
        icon: Icons.bar_chart_outlined,
        selectedIcon: Icons.bar_chart_rounded,
        child: const ReportsTab(),
      ),
    ];
    final activeTab = tabs[_currentIndex];
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 78,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(activeTab.title),
            const SizedBox(height: 4),
            Text(
              activeTab.subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withValues(
                  alpha: 0.68,
                ),
              ),
            ),
          ],
        ),
        actions: <Widget>[
          if (_currentIndex == 0)
            IconButton(
              tooltip: context.l10n.toggleThemeTooltip,
              onPressed: themeController.toggleTheme,
              icon: Icon(
                AppConstants.isDarkThemeName(currentTheme)
                    ? Icons.light_mode_rounded
                    : Icons.dark_mode_rounded,
              ),
            ),
          if (_currentIndex == 3)
            IconButton(
              tooltip: context.l10n.exportFromReportsTooltip,
              onPressed: () => context.push(AppConstants.exportRoute),
              icon: const Icon(Icons.ios_share_rounded),
            ),
          IconButton(
            tooltip: context.l10n.profileTooltip,
            onPressed: () => context.push(AppConstants.profileRoute),
            icon: const Icon(Icons.person_outline_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 240),
          child: KeyedSubtree(
            key: ValueKey<int>(_currentIndex),
            child: activeTab.child,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => openTransactionEditorPage(context),
        icon: const Icon(Icons.add_rounded),
        label: Text(context.l10n.addAction),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _AppBottomBar(
        currentIndex: _currentIndex,
        tabs: tabs,
        onSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

class _AppBottomBar extends StatelessWidget {
  const _AppBottomBar({
    required this.currentIndex,
    required this.tabs,
    required this.onSelected,
  });

  final int currentIndex;
  final List<_ShellTab> tabs;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      child: Row(
        children: <Widget>[
          Expanded(
            child: _BottomBarItem(
              label: context.l10n.homeTabLabel,
              icon: currentIndex == 0 ? tabs[0].selectedIcon : tabs[0].icon,
              selected: currentIndex == 0,
              onTap: () => onSelected(0),
            ),
          ),
          Expanded(
            child: _BottomBarItem(
              label: context.l10n.transactionsTabLabel,
              icon: currentIndex == 1 ? tabs[1].selectedIcon : tabs[1].icon,
              selected: currentIndex == 1,
              onTap: () => onSelected(1),
            ),
          ),
          const SizedBox(width: 72),
          Expanded(
            child: _BottomBarItem(
              label: context.l10n.calendarTabLabel,
              icon: currentIndex == 2 ? tabs[2].selectedIcon : tabs[2].icon,
              selected: currentIndex == 2,
              onTap: () => onSelected(2),
            ),
          ),
          Expanded(
            child: _BottomBarItem(
              label: context.l10n.reportsTabLabel,
              icon: currentIndex == 3 ? tabs[3].selectedIcon : tabs[3].icon,
              selected: currentIndex == 3,
              onTap: () => onSelected(3),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomBarItem extends StatelessWidget {
  const _BottomBarItem({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              icon,
              size: 20,
              color: selected
                  ? theme.colorScheme.primary
                  : theme.textTheme.bodySmall?.color?.withValues(alpha: 0.62),
            ),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: selected
                    ? theme.colorScheme.primary
                    : theme.textTheme.bodySmall?.color?.withValues(alpha: 0.62),
                fontSize: 10,
                height: 1,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _ShellTab {
  const _ShellTab({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selectedIcon,
    required this.child,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final IconData selectedIcon;
  final Widget child;
}
