# Money Tracker

A polished, Bangla-first personal finance app built with Flutter, Riverpod, and Firebase.

Money Tracker is designed to feel practical from day one: fast transaction entry, multiple wallets, budgets, recurring bills, savings goals, analytics, exports, debt tracking, and shared/family wallet support, all inside a bilingual English/Bangla experience.

## Highlights

- Bangla-first UX with bilingual English/Bangla support
- Firebase Authentication with email/password and Google sign-in
- Firestore-backed finance data with wallet, budget, goal, and bill management
- Rich dashboard with smart insights, reports, calendar, and net worth
- Split transactions, debt/loan tracking, export to CSV/PDF
- Shared/family wallet foundation with invite-based collaboration
- PIN lock, onboarding, and multiple app themes

## Feature Set

### Core Finance

- Add, edit, delete income and expense transactions
- Support for split transactions across multiple categories
- Search, filter, and sort transaction history
- Calendar-based day view of financial activity
- Reports with charts, summaries, and insights

### Wallets

- Multiple wallet types: Cash, Bank, bKash, Nagad, Savings
- Wallet transfers with linked transaction history
- Wallet detail screens with activity history
- Shared/family wallets with member invitations

### Planning

- Monthly overall and category budgets
- Recurring bills and reminders
- Savings goals with contribution tracking
- Debt and loan tracker for borrowed/lent money

### Insights

- Dashboard summary cards
- Smart comparative insights
- Net worth tracking
- Weekly, monthly, and yearly reporting

### Productivity & Safety

- Export to CSV and PDF
- English/Bangla localization
- Theme switching with multiple palettes
- PIN-based app lock
- First-run onboarding flow

## Tech Stack

- `Flutter`
- `Dart`
- `Firebase Core`
- `Firebase Auth`
- `Cloud Firestore`
- `Riverpod`
- `GoRouter`
- `fl_chart`
- `table_calendar`
- `flutter_local_notifications`
- `pdf`
- `printing`
- `share_plus`

## Architecture

The app follows a feature-first Flutter structure with Riverpod-managed state and Firebase-backed persistence.

Main areas include:

- `lib/features/auth`
- `lib/features/dashboard`
- `lib/features/transactions`
- `lib/features/wallets`
- `lib/features/budgets`
- `lib/features/goals`
- `lib/features/subscriptions`
- `lib/features/debts`
- `lib/features/shared_wallets`
- `lib/features/profile`
- `lib/core`
- `lib/shared`
- `lib/l10n`

## Current Status

This project is beyond MVP and already includes the major roadmap phases:

- Foundation and Firebase setup
- Authentication and profile management
- Real dashboard and transaction flow
- Transaction history, reports, and calendar
- Multi-wallet system and transfers
- Budgets, recurring bills, and savings goals
- Full Bangla/English app localization
- Export and backup flow
- Advanced features:
  - debt/loan tracker
  - split transactions
  - smart insights
  - net worth
  - PIN lock
  - multiple themes
  - onboarding
  - shared/family wallet foundation

Development progress is tracked in [update.md](D:\work\app development\money tracker codex\update.md).

## Getting Started

### Prerequisites

- Flutter SDK
- Dart SDK
- Firebase project
- Android Studio or VS Code

### Install Dependencies

```powershell
flutter pub get
```

### Run the App

```powershell
flutter run
```

### Useful Commands

```powershell
flutter analyze
flutter test
flutter build apk --debug
flutter build web
```

## Firebase Setup

This repository follows the safer open-source setup: real Firebase project files stay local and are not meant to be committed.

Typical setup includes:

- add your own `google-services.json` to `android/app`
- add your own `GoogleService-Info.plist` to `ios/Runner` if you use iOS
- configure Firebase Auth providers
- create a Firestore database
- publish Firestore rules
- deploy required Firestore indexes when using advanced filters/reports
- provide web Firebase values through `--dart-define` when running or building for web

Relevant config files:

- [firebase.json](D:\work\app development\money tracker codex\firebase.json)
- [firestore.rules](D:\work\app development\money tracker codex\firestore.rules)
- [firestore.indexes.json](D:\work\app development\money tracker codex\firestore.indexes.json)
- [lib/firebase_options.dart](D:\work\app development\money tracker codex\lib\firebase_options.dart)

Example web run:

```powershell
flutter run -d chrome `
  --dart-define=FIREBASE_WEB_API_KEY=your_key `
  --dart-define=FIREBASE_WEB_APP_ID=your_app_id `
  --dart-define=FIREBASE_MESSAGING_SENDER_ID=your_sender_id `
  --dart-define=FIREBASE_PROJECT_ID=your_project_id `
  --dart-define=FIREBASE_AUTH_DOMAIN=your_project.firebaseapp.com `
  --dart-define=FIREBASE_STORAGE_BUCKET=your_project.firebasestorage.app
```

## Localization

Money Tracker is designed for bilingual usage.

- English and Bangla are both supported
- Bangla uses localized labels, formatting, and typography
- Language preference is saved per user profile

Localization files:

- [app_en.arb](D:\work\app development\money tracker codex\lib\l10n\app_en.arb)
- [app_bn.arb](D:\work\app development\money tracker codex\lib\l10n\app_bn.arb)

## Notable Screens

- Dashboard
- Transaction Editor
- Transaction History
- Wallets
- Budgets
- Bills
- Goals
- Debts & Loans
- Reports
- Calendar
- Export
- Shared Wallets
- Profile

## Roadmap Direction

The original roadmap has largely been implemented. Future polish can focus on:

- stronger shared-wallet permissions and collaboration rules
- biometric unlock on top of PIN lock
- deeper export/report refinement
- broader device/platform polish

## Why This Project Stands Out

Most personal finance sample apps stop at simple income/expense CRUD. This project goes further with a production-style structure, bilingual UX, richer finance workflows, and thoughtful user features like budgets, goals, recurring bills, debt tracking, shared wallets, exports, and lock protection.

## License

This repository currently does not define a license file.
