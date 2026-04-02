import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/auth_placeholder_screen.dart';
import '../../features/budgets/budgets_placeholder_screen.dart';
import '../../features/calendar/calendar_placeholder_screen.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/goals/goals_placeholder_screen.dart';
import '../../features/profile/profile_placeholder_screen.dart';
import '../../features/reports/reports_placeholder_screen.dart';
import '../../features/subscriptions/subscriptions_placeholder_screen.dart';
import '../../features/transactions/transactions_placeholder_screen.dart';
import '../../features/wallets/wallets_placeholder_screen.dart';
import '../constants/app_constants.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    routes: <RouteBase>[
      GoRoute(
        path: AppConstants.homeRoute,
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: AppConstants.authRoute,
        builder: (context, state) => const AuthPlaceholderScreen(),
      ),
      GoRoute(
        path: AppConstants.profileRoute,
        builder: (context, state) => const ProfilePlaceholderScreen(),
      ),
      GoRoute(
        path: AppConstants.transactionsRoute,
        builder: (context, state) => const TransactionsPlaceholderScreen(),
      ),
      GoRoute(
        path: AppConstants.calendarRoute,
        builder: (context, state) => const CalendarPlaceholderScreen(),
      ),
      GoRoute(
        path: AppConstants.reportsRoute,
        builder: (context, state) => const ReportsPlaceholderScreen(),
      ),
      GoRoute(
        path: AppConstants.walletsRoute,
        builder: (context, state) => const WalletsPlaceholderScreen(),
      ),
      GoRoute(
        path: AppConstants.budgetsRoute,
        builder: (context, state) => const BudgetsPlaceholderScreen(),
      ),
      GoRoute(
        path: AppConstants.goalsRoute,
        builder: (context, state) => const GoalsPlaceholderScreen(),
      ),
      GoRoute(
        path: AppConstants.subscriptionsRoute,
        builder: (context, state) => const SubscriptionsPlaceholderScreen(),
      ),
    ],
  );
});
