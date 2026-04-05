import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../shared/providers/shared_preferences_provider.dart';
import '../auth/auth_providers.dart';

final onboardingSeenProvider = NotifierProvider<OnboardingController, bool>(
  OnboardingController.new,
);

class OnboardingController extends Notifier<bool> {
  @override
  bool build() {
    ref.listen(authStateProvider, (previous, next) {
      state = _readSeenState();
    });
    return _readSeenState();
  }

  Future<void> complete() async {
    final user = ref.read(authServiceProvider).getCurrentUser();
    if (user == null) {
      state = true;
      return;
    }

    final key = '${AppConstants.onboardingSeenPrefix}${user.uid}';
    await ref.read(sharedPreferencesProvider).setBool(key, true);
    state = true;
  }

  bool _readSeenState() {
    final user = ref.read(authServiceProvider).getCurrentUser();
    if (user == null) {
      return true;
    }

    final key = '${AppConstants.onboardingSeenPrefix}${user.uid}';
    return ref.read(sharedPreferencesProvider).getBool(key) ?? false;
  }
}
