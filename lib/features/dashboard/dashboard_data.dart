import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../l10n/l10n_extension.dart';

class ActionShortcut {
  const ActionShortcut(this._label, this.icon, this.route);

  final String _label;
  final IconData icon;
  final String route;

  String label(AppLocalizations l10n) {
    switch (route) {
      case AppConstants.profileRoute:
        return l10n.profileTitle;
      case AppConstants.walletsRoute:
        return l10n.walletsTitle;
      case AppConstants.budgetsRoute:
        return l10n.budgetsTitleText;
      case AppConstants.goalsRoute:
        return l10n.goalsTitleText;
      case AppConstants.subscriptionsRoute:
        return l10n.billsTitleText;
      case AppConstants.debtsRoute:
        return l10n.debtsTitleText;
      default:
        return _label;
    }
  }
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
  ActionShortcut('Debts', Icons.handshake_outlined, AppConstants.debtsRoute),
];
