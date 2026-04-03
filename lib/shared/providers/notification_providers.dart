import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/notifications/app_notification_service.dart';

final appNotificationServiceProvider = Provider<AppNotificationService>((ref) {
  return AppNotificationService.instance;
});
