import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';
import '../../shared/providers/shared_preferences_provider.dart';

class AppLockState {
  const AppLockState({
    required this.enabled,
    required this.hasPin,
    required this.isLocked,
  });

  final bool enabled;
  final bool hasPin;
  final bool isLocked;

  AppLockState copyWith({bool? enabled, bool? hasPin, bool? isLocked}) {
    return AppLockState(
      enabled: enabled ?? this.enabled,
      hasPin: hasPin ?? this.hasPin,
      isLocked: isLocked ?? this.isLocked,
    );
  }
}

final appLockProvider = NotifierProvider<AppLockController, AppLockState>(
  AppLockController.new,
);

class AppLockController extends Notifier<AppLockState> {
  @override
  AppLockState build() {
    final enabled =
        _preferences.getBool(AppConstants.appLockEnabledPreferenceKey) ?? false;
    final pin = _preferences.getString(AppConstants.appLockPinPreferenceKey);
    final hasPin = pin != null && pin.isNotEmpty;

    return AppLockState(
      enabled: enabled && hasPin,
      hasPin: hasPin,
      isLocked: enabled && hasPin,
    );
  }

  Future<void> setPin(String pin) async {
    await _preferences.setString(AppConstants.appLockPinPreferenceKey, pin);
    await _preferences.setBool(AppConstants.appLockEnabledPreferenceKey, true);
    state = const AppLockState(enabled: true, hasPin: true, isLocked: false);
  }

  Future<void> disable() async {
    await _preferences.remove(AppConstants.appLockPinPreferenceKey);
    await _preferences.setBool(AppConstants.appLockEnabledPreferenceKey, false);
    state = const AppLockState(enabled: false, hasPin: false, isLocked: false);
  }

  void lock() {
    if (!state.enabled || !state.hasPin) {
      return;
    }
    state = state.copyWith(isLocked: true);
  }

  void unlockWithoutPrompt() {
    state = state.copyWith(isLocked: false);
  }

  bool verifyPin(String pin) {
    final storedPin = _preferences.getString(
      AppConstants.appLockPinPreferenceKey,
    );
    final matches = storedPin != null && storedPin == pin;
    if (matches) {
      state = state.copyWith(isLocked: false);
    }
    return matches;
  }

  String? get currentPin =>
      _preferences.getString(AppConstants.appLockPinPreferenceKey);

  bool get isEnabled =>
      _preferences.getBool(AppConstants.appLockEnabledPreferenceKey) ?? false;

  SharedPreferences get _preferences => ref.read(sharedPreferencesProvider);
}
