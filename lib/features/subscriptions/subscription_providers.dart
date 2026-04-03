import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/models/category_model.dart';
import '../../shared/models/subscription_model.dart';
import '../../shared/models/wallet_model.dart';
import '../../shared/providers/firebase_providers.dart';
import '../../shared/providers/notification_providers.dart';
import '../profile/profile_providers.dart';
import '../transactions/transaction_providers.dart';
import 'subscription_service.dart';

final subscriptionServiceProvider = Provider<SubscriptionService>((ref) {
  return SubscriptionService(
    firestore: ref.watch(firestoreProvider),
    transactionService: ref.watch(transactionServiceProvider),
    notificationService: ref.watch(appNotificationServiceProvider),
  );
});

final subscriptionsProvider = StreamProvider<List<SubscriptionModel>>((ref) {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) {
    return Stream<List<SubscriptionModel>>.value(const <SubscriptionModel>[]);
  }

  return ref.watch(subscriptionServiceProvider).watchSubscriptions(uid);
});

final subscriptionReminderBootstrapProvider = FutureProvider<void>((ref) async {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) {
    return;
  }

  final subscriptions = await ref
      .read(subscriptionServiceProvider)
      .getSubscriptions(uid);
  await ref
      .read(appNotificationServiceProvider)
      .syncSubscriptionReminders(subscriptions);
});

final upcomingSubscriptionsProvider = Provider<List<SubscriptionModel>>((ref) {
  final subscriptions =
      ref.watch(subscriptionsProvider).asData?.value ??
      const <SubscriptionModel>[];
  final today = DateTime.now();
  final end = DateTime(
    today.year,
    today.month,
    today.day,
  ).add(const Duration(days: 30));

  final result = subscriptions
      .where((subscription) => !subscription.nextDueDate.isAfter(end))
      .toList(growable: false);
  result.sort((a, b) => a.nextDueDate.compareTo(b.nextDueDate));
  return result;
});

final paidThisMonthSubscriptionsProvider = Provider<List<SubscriptionModel>>((
  ref,
) {
  final subscriptions =
      ref.watch(subscriptionsProvider).asData?.value ??
      const <SubscriptionModel>[];
  final now = DateTime.now();
  final start = DateTime(now.year, now.month);
  final end = DateTime(now.year, now.month + 1);
  final result = subscriptions
      .where((subscription) {
        final paidAt = subscription.lastPaidAt;
        return paidAt != null &&
            !paidAt.isBefore(start) &&
            paidAt.isBefore(end);
      })
      .toList(growable: false);
  result.sort((a, b) => b.lastPaidAt!.compareTo(a.lastPaidAt!));
  return result;
});

final dashboardUpcomingBillsProvider = Provider<List<UpcomingBillViewModel>>((
  ref,
) {
  final subscriptions = ref.watch(upcomingSubscriptionsProvider).take(3);
  final categories =
      ref.watch(allCategoriesProvider).asData?.value ?? const <CategoryModel>[];
  final wallets =
      ref.watch(walletsProvider).asData?.value ?? const <WalletModel>[];
  final languageCode =
      ref.watch(currentUserProfileProvider).asData?.value?.language ?? 'en';

  final categoryMap = {
    for (final category in categories) category.id: category,
  };
  final walletMap = {for (final wallet in wallets) wallet.id: wallet};

  return subscriptions
      .map(
        (subscription) => UpcomingBillViewModel(
          subscription: subscription,
          category: categoryMap[subscription.categoryId],
          wallet: walletMap[subscription.walletId],
          languageCode: languageCode,
        ),
      )
      .toList(growable: false);
});

final subscriptionsOverviewProvider = Provider<SubscriptionsOverview>((ref) {
  final upcoming = ref.watch(upcomingSubscriptionsProvider);
  final paidThisMonth = ref.watch(paidThisMonthSubscriptionsProvider);

  final totalDueSoon = upcoming.fold<double>(
    0,
    (sum, subscription) => sum + subscription.amount,
  );
  final totalPaidThisMonth = paidThisMonth.fold<double>(
    0,
    (sum, subscription) => sum + subscription.amount,
  );

  return SubscriptionsOverview(
    dueSoonCount: upcoming.length,
    dueSoonTotal: totalDueSoon,
    paidThisMonthCount: paidThisMonth.length,
    paidThisMonthTotal: totalPaidThisMonth,
  );
});

final subscriptionActionControllerProvider =
    AsyncNotifierProvider<SubscriptionActionController, void>(
      SubscriptionActionController.new,
    );

class SubscriptionActionController extends AsyncNotifier<void> {
  SubscriptionService get _service => ref.read(subscriptionServiceProvider);

  @override
  Future<void> build() async {}

  Future<void> addSubscription(SubscriptionModel subscription) async {
    final uid = _requireUserId();
    state = const AsyncLoading<void>();
    state = await AsyncValue.guard(() async {
      await _service.addSubscription(uid, subscription);
    });
    if (state.hasError) {
      throw state.error!;
    }
  }

  Future<void> updateSubscription(SubscriptionModel subscription) async {
    final uid = _requireUserId();
    state = const AsyncLoading<void>();
    state = await AsyncValue.guard(() async {
      await _service.updateSubscription(uid, subscription);
    });
    if (state.hasError) {
      throw state.error!;
    }
  }

  Future<void> deleteSubscription(String subscriptionId) async {
    final uid = _requireUserId();
    state = const AsyncLoading<void>();
    state = await AsyncValue.guard(() async {
      await _service.deleteSubscription(uid, subscriptionId);
    });
    if (state.hasError) {
      throw state.error!;
    }
  }

  Future<void> markAsPaid(SubscriptionModel subscription) async {
    final uid = _requireUserId();
    state = const AsyncLoading<void>();
    state = await AsyncValue.guard(() async {
      await _service.markAsPaid(uid, subscription);
    });
    if (state.hasError) {
      throw state.error!;
    }
  }

  String _requireUserId() {
    final uid = ref.read(currentUserIdProvider);
    if (uid == null) {
      throw StateError('User is not signed in.');
    }
    return uid;
  }
}

class SubscriptionsOverview {
  const SubscriptionsOverview({
    required this.dueSoonCount,
    required this.dueSoonTotal,
    required this.paidThisMonthCount,
    required this.paidThisMonthTotal,
  });

  final int dueSoonCount;
  final double dueSoonTotal;
  final int paidThisMonthCount;
  final double paidThisMonthTotal;
}

class UpcomingBillViewModel {
  const UpcomingBillViewModel({
    required this.subscription,
    required this.category,
    required this.wallet,
    required this.languageCode,
  });

  final SubscriptionModel subscription;
  final CategoryModel? category;
  final WalletModel? wallet;
  final String languageCode;
}
