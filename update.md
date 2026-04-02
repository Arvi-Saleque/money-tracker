# Update Log

## Phase 1 - Project Initialization & Theme System

- Scaffolded the Flutter app in the current workspace with Android, iOS, web, desktop, and test support.
- Added the Phase 1 package set: Firebase Core/Auth/Firestore/Storage, Riverpod, GoRouter, localization, Google Fonts, and SharedPreferences.
- Created Firebase project `money-tracker-codex-2026` and registered Android, iOS, and web apps.
- Added Android `google-services` setup, downloaded `google-services.json`, and added iOS `GoogleService-Info.plist`.
- Built the Phase 1 architecture: theme constants, `ThemeExtension`-based gradients and premium card styles, router, Firebase bootstrap, persistent theme provider, and placeholder feature routes.
- Added localization scaffolding with `app_en.arb`, `app_bn.arb`, and `l10n.yaml`.
- Replaced the default counter app with a themed Phase 1 home screen that demonstrates routing and theme persistence.
- Upgraded the starter shell into a more app-like UI with a bottom navigation layout, dashboard cards, mock transaction history, calendar preview, reports preview, and a quick-add bottom sheet.

### Notes

- Firebase initialization is enabled for Android, iOS, and web in this phase.
- Windows can still run the shell app locally, but Firebase initialization is intentionally skipped there until desktop support is planned.

## Phase 2 - Authentication & Profile System

- Added Firebase-backed auth services and Riverpod providers for email/password login, sign up, password reset, auth state streaming, Google sign-in, and sign out.
- Replaced the auth placeholder with real login, sign-up, and forgot-password screens.
- Added GoRouter auth guards so logged-out users are redirected to login and signed-in users are redirected into the app shell.
- Added `UserModel` plus Firestore profile creation/sync at `users/{uid}` with defaults for currency, language, theme, and avatar.
- Replaced the profile placeholder with a working profile screen for editing name, currency, language, theme, avatar upload, and sign out.
- Added `firestore.rules` and `storage.rules` with owner-only access patterns for user data and avatars.
- Switched Android Firebase config to the provided `money-tracker-13285` project and Android package `com.moneytracker.money_tracker`.

### Notes

- Android is now aligned to your provided Firebase project and Google Sign-In web client ID.
- Web and iOS still use the earlier placeholder Firebase app config because matching web/iOS config files were not provided in this turn.
