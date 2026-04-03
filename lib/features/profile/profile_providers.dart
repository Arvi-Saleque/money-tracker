import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../shared/models/user_model.dart';
import '../../shared/providers/firebase_providers.dart';
import '../../shared/providers/locale_provider.dart';
import '../../shared/providers/theme_provider.dart';
import '../auth/auth_providers.dart';
import 'profile_service.dart';

final profileServiceProvider = Provider<ProfileService>((ref) {
  return ProfileService(firestore: ref.watch(firestoreProvider));
});

final currentUserProfileProvider = StreamProvider<UserModel?>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) {
    return Stream<UserModel?>.value(null);
  }

  return ref.watch(profileServiceProvider).watchUserProfile(user.uid);
});

final profileControllerProvider =
    AsyncNotifierProvider<ProfileController, void>(ProfileController.new);

final profilePreferencesSyncProvider = FutureProvider<void>((ref) async {
  final user = ref.watch(authStateProvider).value;
  if (user == null) {
    return;
  }

  final profile = await ref
      .read(profileServiceProvider)
      .getUserProfile(user.uid);
  if (profile == null) {
    return;
  }

  final safeTheme = AppConstants.normalizeThemeName(profile.theme);
  final safeLanguage = AppConstants.normalizeLanguageCode(profile.language);
  final currentTheme = ref.read(themeProvider);
  if (safeTheme != currentTheme) {
    await ref.read(themeProvider.notifier).setTheme(safeTheme);
  }

  final currentLocale = ref.read(localeProvider);
  if (safeLanguage != currentLocale.languageCode) {
    await ref.read(localeProvider.notifier).setLocaleCode(safeLanguage);
  }
});

class ProfileController extends AsyncNotifier<void> {
  ProfileService get _service => ref.read(profileServiceProvider);

  @override
  FutureOr<void> build() {}

  Future<void> saveProfile({
    required UserModel currentProfile,
    required String name,
    required String currency,
    required String language,
    required String themeName,
  }) async {
    state = const AsyncLoading<void>();
    state = await AsyncValue.guard(() async {
      final updated = currentProfile.copyWith(
        name: name.trim(),
        currency: currency,
        language: language,
        theme: themeName,
      );

      await _service.updateUserProfile(updated);
      await ref.read(themeProvider.notifier).setTheme(themeName);
      await ref.read(localeProvider.notifier).setLocaleCode(language);
    });

    if (state.hasError) {
      throw state.error!;
    }
  }
}
