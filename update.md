# Update Log

## Phase 1 - Project Initialization & Theme System

- Scaffolded the Flutter app in the current workspace with Android, iOS, web, desktop, and test support.
- Added the Phase 1 package set: Firebase Core/Auth/Firestore/Storage, Riverpod, GoRouter, localization, Google Fonts, and SharedPreferences.
- Created Firebase project `money-tracker-codex-2026` and registered Android, iOS, and web apps.
- Added Android `google-services` setup, downloaded `google-services.json`, and added iOS `GoogleService-Info.plist`.
- Built the Phase 1 architecture: theme constants, `ThemeExtension`-based gradients and premium card styles, router, Firebase bootstrap, persistent theme provider, and placeholder feature routes.
- Added localization scaffolding with `app_en.arb`, `app_bn.arb`, and `l10n.yaml`.
- Replaced the default counter app with a themed Phase 1 home screen that demonstrates routing and theme persistence.

### Notes

- Firebase initialization is enabled for Android, iOS, and web in this phase.
- Windows can still run the shell app locally, but Firebase initialization is intentionally skipped there until desktop support is planned.
