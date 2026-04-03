import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/notifications/app_notification_service.dart';
import '../../shared/models/subscription_model.dart';
import '../../shared/models/transaction_model.dart';
import '../transactions/finance_catalog.dart';
import '../transactions/transaction_service.dart';

class SubscriptionService {
  SubscriptionService({
    required FirebaseFirestore firestore,
    required TransactionService transactionService,
    required AppNotificationService notificationService,
  }) : _firestore = firestore,
       _transactionService = transactionService,
       _notificationService = notificationService;

  final FirebaseFirestore _firestore;
  final TransactionService _transactionService;
  final AppNotificationService _notificationService;

  CollectionReference<Map<String, dynamic>> _subscriptionsRef(String uid) {
    return _firestore.collection('users').doc(uid).collection('subscriptions');
  }

  Stream<List<SubscriptionModel>> watchSubscriptions(String uid) {
    return _subscriptionsRef(uid)
        .orderBy('nextDueDate')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map(SubscriptionModel.fromDocument).toList(),
        );
  }

  Future<List<SubscriptionModel>> getSubscriptions(String uid) async {
    final snapshot = await _subscriptionsRef(uid).orderBy('nextDueDate').get();
    return snapshot.docs.map(SubscriptionModel.fromDocument).toList();
  }

  Future<List<SubscriptionModel>> getUpcomingDue(String uid, int days) async {
    final subscriptions = await getSubscriptions(uid);
    final endDate = DateTime.now().add(Duration(days: days));
    return subscriptions
        .where((subscription) => !subscription.nextDueDate.isAfter(endDate))
        .toList(growable: false);
  }

  Future<SubscriptionModel> addSubscription(
    String uid,
    SubscriptionModel subscription,
  ) async {
    final docRef = _subscriptionsRef(uid).doc();
    final nextSubscription = subscription.copyWith(
      id: docRef.id,
      isPaid: false,
    );
    await docRef.set(nextSubscription.toMap());
    await _notificationService.scheduleSubscriptionReminder(nextSubscription);
    return nextSubscription;
  }

  Future<void> updateSubscription(
    String uid,
    SubscriptionModel subscription,
  ) async {
    await _subscriptionsRef(uid).doc(subscription.id).set(subscription.toMap());
    await _notificationService.scheduleSubscriptionReminder(subscription);
  }

  Future<void> deleteSubscription(String uid, String subscriptionId) async {
    await _subscriptionsRef(uid).doc(subscriptionId).delete();
    await _notificationService.cancelSubscriptionReminder(subscriptionId);
  }

  Future<void> markAsPaid(String uid, SubscriptionModel subscription) async {
    final paidAt = DateTime.now();
    final transaction = TransactionModel(
      id: '',
      amount: subscription.amount,
      type: FinanceCatalog.expenseType,
      categoryId: subscription.categoryId,
      walletId: subscription.walletId,
      isTransfer: false,
      note: subscription.note.trim().isEmpty
          ? subscription.name
          : '${subscription.name} - ${subscription.note.trim()}',
      date: paidAt,
      createdAt: paidAt,
    );

    final nextDueDate = _advanceDueDate(
      from: subscription.nextDueDate,
      frequency: subscription.frequency,
    );
    final updatedSubscription = subscription.copyWith(
      nextDueDate: nextDueDate,
      isPaid: false,
      lastPaidAt: paidAt,
    );

    final batch = _firestore.batch();
    await _transactionService.stageAddTransaction(batch, uid, transaction);
    batch.set(
      _subscriptionsRef(uid).doc(subscription.id),
      updatedSubscription.toMap(),
    );
    await batch.commit();
    await _notificationService.scheduleSubscriptionReminder(
      updatedSubscription,
    );
  }

  DateTime _advanceDueDate({
    required DateTime from,
    required String frequency,
  }) {
    switch (frequency) {
      case SubscriptionFrequency.daily:
        return from.add(const Duration(days: 1));
      case SubscriptionFrequency.weekly:
        return from.add(const Duration(days: 7));
      case SubscriptionFrequency.yearly:
        return DateTime(
          from.year + 1,
          from.month,
          _safeDay(from.year + 1, from.month, from.day),
        );
      case SubscriptionFrequency.monthly:
      default:
        final nextMonth = from.month == 12 ? 1 : from.month + 1;
        final nextYear = from.month == 12 ? from.year + 1 : from.year;
        return DateTime(
          nextYear,
          nextMonth,
          _safeDay(nextYear, nextMonth, from.day),
        );
    }
  }

  int _safeDay(int year, int month, int day) {
    final lastDay = DateTime(year, month + 1, 0).day;
    return day.clamp(1, lastDay);
  }
}
