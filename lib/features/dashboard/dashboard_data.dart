import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';

class ActionShortcut {
  const ActionShortcut(this.label, this.icon, this.route);

  final String label;
  final IconData icon;
  final String route;
}

const List<ActionShortcut> actionShortcuts = <ActionShortcut>[
  ActionShortcut(
    'Profile',
    Icons.person_outline_rounded,
    AppConstants.profileRoute,
  ),
  ActionShortcut(
    'Wallets',
    Icons.account_balance_wallet_rounded,
    AppConstants.walletsRoute,
  ),
  ActionShortcut(
    'Budgets',
    Icons.track_changes_rounded,
    AppConstants.budgetsRoute,
  ),
  ActionShortcut('Goals', Icons.flag_rounded, AppConstants.goalsRoute),
  ActionShortcut(
    'Bills',
    Icons.notifications_active_rounded,
    AppConstants.subscriptionsRoute,
  ),
];
