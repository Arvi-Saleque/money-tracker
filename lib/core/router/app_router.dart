import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/auth_providers.dart';
import '../../features/auth/forgot_password_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/sign_up_screen.dart';
import '../../features/budgets/budgets_screen.dart';
import '../../features/calendar/calendar_placeholder_screen.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/goals/goals_placeholder_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/reports/reports_placeholder_screen.dart';
import '../../features/subscriptions/subscriptions_screen.dart';
import '../../features/transactions/transactions_placeholder_screen.dart';
import '../../features/wallets/wallets_screen.dart';
import '../constants/app_constants.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppConstants.homeRoute,
    refreshListenable: ref.watch(authRefreshListenableProvider),
    redirect: (context, state) {
      final user = ref.read(authServiceProvider).getCurrentUser();
      final isAuthenticated = user != null;
      final isAuthRoute = state.matchedLocation.startsWith(
        AppConstants.authRoute,
      );

      if (!isAuthenticated && !isAuthRoute) {
        return AppConstants.authRoute;
      }

      if (isAuthenticated &&
          (state.matchedLocation == AppConstants.authRoute ||
              state.matchedLocation == AppConstants.signUpRoute ||
              state.matchedLocation == AppConstants.forgotPasswordRoute)) {
        return AppConstants.homeRoute;
      }

      return null;
    },
    routes: <RouteBase>[
      GoRoute(
        path: AppConstants.homeRoute,
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: AppConstants.authRoute,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppConstants.signUpRoute,
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: AppConstants.forgotPasswordRoute,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppConstants.profileRoute,
        builder: (context, state) => const ProfileScreen(),
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
        builder: (context, state) => const WalletsScreen(),
      ),
      GoRoute(
        path: AppConstants.budgetsRoute,
        builder: (context, state) => const BudgetsScreen(),
      ),
      GoRoute(
        path: AppConstants.goalsRoute,
        builder: (context, state) => const GoalsPlaceholderScreen(),
      ),
      GoRoute(
        path: AppConstants.subscriptionsRoute,
        builder: (context, state) => const SubscriptionsScreen(),
      ),
    ],
  );
});
