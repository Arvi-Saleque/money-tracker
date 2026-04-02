import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';

class WalletSummary {
  const WalletSummary(this.name, this.balance, this.icon);

  final String name;
  final String balance;
  final IconData icon;
}

class ActionShortcut {
  const ActionShortcut(this.label, this.icon, this.route);

  final String label;
  final IconData icon;
  final String route;
}

class MockTransaction {
  const MockTransaction({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.timeLabel,
    required this.icon,
    required this.isIncome,
    required this.group,
  });

  final String title;
  final String subtitle;
  final String amount;
  final String timeLabel;
  final IconData icon;
  final bool isIncome;
  final String group;
}

const List<WalletSummary> walletSummaries = <WalletSummary>[
  WalletSummary('Cash', '৳12,500', Icons.payments_rounded),
  WalletSummary('bKash', '৳28,430', Icons.phone_android_rounded),
  WalletSummary('Bank', '৳74,300', Icons.account_balance_rounded),
];

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
  ActionShortcut('Auth', Icons.login_rounded, AppConstants.authRoute),
];

const List<MockTransaction> mockTransactions = <MockTransaction>[
  MockTransaction(
    title: 'Salary',
    subtitle: 'Primary bank',
    amount: '৳35,000',
    timeLabel: '09:12 AM',
    icon: Icons.account_balance_wallet_rounded,
    isIncome: true,
    group: 'Today',
  ),
  MockTransaction(
    title: 'Lunch',
    subtitle: 'Food',
    amount: '৳420',
    timeLabel: '01:45 PM',
    icon: Icons.fastfood_rounded,
    isIncome: false,
    group: 'Today',
  ),
  MockTransaction(
    title: 'Internet Bill',
    subtitle: 'Bills',
    amount: '৳1,200',
    timeLabel: '08:30 PM',
    icon: Icons.wifi_rounded,
    isIncome: false,
    group: 'Yesterday',
  ),
  MockTransaction(
    title: 'Freelance Payment',
    subtitle: 'Side income',
    amount: '৳7,500',
    timeLabel: '06:15 PM',
    icon: Icons.work_history_rounded,
    isIncome: true,
    group: 'Yesterday',
  ),
  MockTransaction(
    title: 'Bus Fare',
    subtitle: 'Transport',
    amount: '৳60',
    timeLabel: '10:10 AM',
    icon: Icons.directions_bus_filled_rounded,
    isIncome: false,
    group: 'Yesterday',
  ),
];
