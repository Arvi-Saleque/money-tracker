import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../shared/providers/shared_preferences_provider.dart';
import '../auth/auth_providers.dart';

final onboardingSeenProvider = Provider<bool>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) {
    return true;
  }
  final key = '${AppConstants.onboardingSeenPrefix}${user.uid}';
  return ref.watch(sharedPreferencesProvider).getBool(key) ?? false;
});

final onboardingControllerProvider = Provider<OnboardingController>(
  (ref) => OnboardingController(ref),
);

class OnboardingController {
  const OnboardingController(this._ref);

  final Ref _ref;

  Future<void> complete() async {
    final user = _ref.read(authStateProvider).value;
    if (user == null) {
      return;
    }
    final key = '${AppConstants.onboardingSeenPrefix}${user.uid}';
    await _ref.read(sharedPreferencesProvider).setBool(key, true);
  }
}
