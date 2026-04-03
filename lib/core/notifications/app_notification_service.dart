import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:go_router/go_router.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../shared/models/subscription_model.dart';
import '../constants/app_constants.dart';
import '../../l10n/generated/app_localizations.dart';
import '../router/app_router.dart';

class AppNotificationService {
  AppNotificationService._();

  static final AppNotificationService instance = AppNotificationService._();

  static const AndroidNotificationChannel _subscriptionChannel =
      AndroidNotificationChannel(
        'subscription_reminders',
        'Bill Reminders',
        description: 'Upcoming recurring bill reminders.',
        importance: Importance.max,
      );

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;
  String? _pendingRoute;

  Future<void> initialize() async {
    if (_isInitialized || kIsWeb) {
      return;
    }

    tz.initializeTimeZones();
    await _configureLocalTimezone();

    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
      macOS: DarwinInitializationSettings(),
      linux: LinuxInitializationSettings(
        defaultActionName: 'Open notification',
      ),
      windows: WindowsInitializationSettings(
        appName: AppConstants.appName,
        appUserModelId: 'com.moneytracker.money_tracker',
        guid: '1df903db-f786-4dca-9488-3f1b66e96d7d',
      ),
    );

    await _plugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: _handleNotificationResponse,
    );

    final androidImplementation = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidImplementation?.createNotificationChannel(
      _subscriptionChannel,
    );
    await androidImplementation?.requestNotificationsPermission();

    final darwinImplementation = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    await darwinImplementation?.requestPermissions(
      alert: true,
      badge: false,
      sound: true,
    );
    final macOsImplementation = _plugin
        .resolvePlatformSpecificImplementation<
          MacOSFlutterLocalNotificationsPlugin
        >();
    await macOsImplementation?.requestPermissions(
      alert: true,
      badge: false,
      sound: true,
    );

    final launchDetails = await _plugin.getNotificationAppLaunchDetails();
    if (launchDetails?.didNotificationLaunchApp ?? false) {
      _pendingRoute =
          launchDetails?.notificationResponse?.payload ??
          AppConstants.subscriptionsRoute;
    }

    _isInitialized = true;
  }

  void processPendingNavigation() {
    if (_pendingRoute == null) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = rootNavigatorKey.currentContext;
      final route = _pendingRoute;
      if (context == null || route == null) {
        return;
      }
      _pendingRoute = null;
      context.go(route);
    });
  }

  Future<void> scheduleSubscriptionReminder(
    SubscriptionModel subscription,
  ) async {
    if (!_isInitialized || kIsWeb) {
      return;
    }

    final scheduledDate = _reminderDate(subscription);
    final now = tz.TZDateTime.now(tz.local);
    if (!scheduledDate.isAfter(now)) {
      await cancelSubscriptionReminder(subscription.id);
      return;
    }

    await _plugin.zonedSchedule(
      id: _notificationIdForSubscription(subscription.id),
      title: _localizations.billReminderTitle,
      body: _buildReminderBody(subscription),
      scheduledDate: scheduledDate,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'subscription_reminders',
          'Bill Reminders',
          channelDescription: 'Upcoming recurring bill reminders.',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
        macOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: AppConstants.subscriptionsRoute,
    );
  }

  Future<void> cancelSubscriptionReminder(String subscriptionId) async {
    if (!_isInitialized || kIsWeb) {
      return;
    }
    await _plugin.cancel(id: _notificationIdForSubscription(subscriptionId));
  }

  Future<void> syncSubscriptionReminders(
    List<SubscriptionModel> subscriptions,
  ) async {
    if (!_isInitialized || kIsWeb) {
      return;
    }

    for (final subscription in subscriptions) {
      await scheduleSubscriptionReminder(subscription);
    }
  }

  Future<void> _handleNotificationResponse(
    NotificationResponse response,
  ) async {
    _pendingRoute = response.payload?.isNotEmpty == true
        ? response.payload
        : AppConstants.subscriptionsRoute;
    processPendingNavigation();
  }

  Future<void> _configureLocalTimezone() async {
    if (kIsWeb || defaultTargetPlatform == TargetPlatform.linux) {
      return;
    }
    if (defaultTargetPlatform == TargetPlatform.windows) {
      tz.setLocalLocation(tz.UTC);
      return;
    }

    final timezoneInfo = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timezoneInfo.identifier));
  }

  tz.TZDateTime _reminderDate(SubscriptionModel subscription) {
    final reminderBase = DateTime(
      subscription.nextDueDate.year,
      subscription.nextDueDate.month,
      subscription.nextDueDate.day,
      9,
    ).subtract(Duration(days: subscription.reminderDaysBefore));
    return tz.TZDateTime.from(reminderBase, tz.local);
  }

  String _buildReminderBody(SubscriptionModel subscription) {
    final days = subscription.reminderDaysBefore;
    if (days <= 0) {
      return _localizations.dueTodayBody(subscription.name);
    }
    if (days == 1) {
      return _localizations.dueTomorrowBody(subscription.name);
    }
    return _localizations.dueInDaysBody(subscription.name, '$days');
  }

  int _notificationIdForSubscription(String subscriptionId) {
    return subscriptionId.hashCode & 0x7fffffff;
  }

  AppLocalizations get _localizations {
    final context = rootNavigatorKey.currentContext;
    if (context != null) {
      return AppLocalizations.of(context);
    }

    final languageCode = AppConstants.normalizeLanguageCode(
      PlatformDispatcher.instance.locale.languageCode,
    );
    return lookupAppLocalizations(Locale(languageCode));
  }
}
