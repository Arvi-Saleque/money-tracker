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
- Replaced the profile placeholder with a working profile screen for editing name, currency, language, theme, initials-based avatar, and sign out.
- Added `firestore.rules` with owner-only access patterns for user data.
- Switched Android Firebase config to the provided `money-tracker-13285` project and Android package `com.moneytracker.money_tracker`.

### Notes

- Android is now aligned to your provided Firebase project and Google Sign-In web client ID.
- Web and iOS still use the earlier placeholder Firebase app config because matching web/iOS config files were not provided in this turn.
- Firebase Storage and avatar upload were removed to keep the app on the free-friendly Firestore/Auth path.

## Phase 3 - Transactions, Categories & Basic Dashboard

- Added `CategoryModel`, `WalletModel`, and `TransactionModel` plus Firestore-backed services/providers for starter data, wallets, categories, dashboard summary, and transaction CRUD.
- Seeded starter `Cash`, `bKash`, and `Bank` wallets plus bilingual default income/expense categories for every signed-in user through the app bootstrap flow.
- Replaced the mock quick-add flow with a real full-screen add/edit transaction page that supports type selection, amount, wallet, category, date, note, and delete.
- Added custom category creation from inside the transaction flow with template/manual modes, icon selection, color selection, and automatic English/Bangla name pairing.
- Replaced the mock Home tab with a live dashboard showing current wallet balances, total balance, today income/expense, recent transactions, and phase shortcuts.
- Replaced the mock Transactions tab with a real Firestore-backed history list, search, filtering, transaction grouping by day, and tap-to-edit.
- Updated the lightweight Calendar and Reports tabs to read live dashboard totals instead of fixed demo amounts.
- Fixed currency and default Bangla catalog text to use the proper symbols/labels instead of mojibake placeholders.
- Tightened the transaction/category UI with category deletion, clearer selection states, a proper app page layout, and mobile overflow fixes.

### Notes

- Wallet balances now update automatically whenever transactions are added, edited, or deleted.
- Web build verification required clearing stale generated plugin cache left over from the earlier Storage setup, but the current repo no longer depends on Firebase Storage.

## Phase 4 - Transaction History, Search, Filter & Sort

- Added a dedicated history filter model plus a paginated transaction query path so the Transactions tab no longer depends on a single flat recent-transactions stream.
- Rebuilt the Transactions tab into a richer history screen with an expandable search field, type chips, category filter, wallet filter, date-range picker, sort selector, and clear-filters action.
- Added paginated history browsing with automatic load-more behavior and grouped date sections for the currently loaded transaction set.
- Added swipe-to-delete affordances with confirmation, while keeping tap-to-edit on each transaction row.
- Upgraded transaction rows to show a clearer layout with wallet chip, time chip, note preview, and amount emphasis.
- Added `firestore.indexes.json` and wired it into `firebase.json` to prepare the new sort/filter combinations for deployment.

### Notes

- Search is debounced in the UI and currently matches note text plus amount strings.
- Some advanced Firestore filter/sort combinations may still prompt for index creation until the new index config is deployed to your Firebase project.

## Phase 5 - Dashboard Analytics & Reports

- Added `fl_chart` and built a dedicated analytics layer for weekly, monthly, and yearly reporting windows.
- Added live period analytics providers that aggregate income, expense, net balance, averages, peak spending periods, category totals, and time-bucket breakdowns from Firestore transactions.
- Upgraded the Home tab with wallet balance chips, month summary pills, a current-month expense trend chart, top category highlight, and richer live dashboard insight cards.
- Rebuilt the Reports tab into a proper analytics screen with period switching, income-vs-expense bar charts, category breakdown donut charts, and summary cards for totals, averages, peak spending, and top category.
- Added reusable chart widgets and metric cards so later phases can reuse the same visual analytics language.

### Notes

- The current analytics windows are: this week, this month, and this year.
- Weekly and monthly averages are shown as average daily expense, while yearly reports show average monthly expense.

## Phase 6 - Calendar View With Day Details

- Added `table_calendar` and replaced the placeholder calendar tab with a real month/week calendar experience.
- Built a Firestore-backed month calendar provider that loads a single visible-month range query and derives per-day income/expense summaries locally.
- Added green/red activity markers for days with income, expense, or both.
- Added month navigation, month picking, and month/week switching from the calendar header.
- Added a selected-day snapshot card plus a draggable day-detail bottom sheet showing total income, total expense, net, and that day's transaction list.
- Wired calendar transaction rows into the existing edit transaction page so tapping a day entry opens the same edit flow.

### Notes

- Month data is cached naturally through the provider family key for each visible month during the app session.
- The calendar currently uses month and week views with day details; a more advanced month picker and cross-month week caching can still be refined later if needed.

## Phase 7 - Multi-Wallet System

- Expanded starter wallet bootstrapping so users now get Cash, Bank, bKash, Nagad, and Savings wallets automatically.
- Added richer wallet and transaction metadata to support linked transfer entries, safer profile value normalization, and transfer-aware UI rendering.
- Built a real Wallets screen with total balance overview, responsive wallet cards, add/edit wallet flow, wallet detail pages, and guarded delete behavior.
- Added a dedicated transfer page for moving money between wallets, including linked transfer creation, editing, and deletion with paired balance updates.
- Upgraded wallet services and controllers to support wallet CRUD, default-wallet switching, transfer pair management, and wallet-specific transaction streams.
- Wired transfers into the existing app flow so tapping a transfer opens the transfer editor instead of the regular transaction editor.
- Updated dashboard, calendar, and history surfaces so transfer entries render with clear labels/icons while analytics and income-expense summaries ignore transfer-only movements.

### Notes

- Wallet balances continue to stay transaction-driven: normal transactions and transfers both update wallet balances in Firestore through batch writes.
- Transfer history is stored as two linked entries so both source and destination wallets retain a visible audit trail.

## Phase 8 - Budget System

- Added `BudgetModel` plus a new Firestore-backed budget service and providers for monthly budget state.
- Replaced the budget placeholder route with a real budget management screen, including month navigation, overall spending limits, per-category budgets, add/edit flow, and delete actions.
- Budget creation now backfills `spent` from existing expense history for the selected month, so budgets stay accurate even when created after transactions already exist.
- Integrated expense transaction add/edit/delete flows with budget spent updates for both category budgets and the optional overall monthly budget.
- Added Home dashboard budget cards that show current-month budget progress plus warning/alert messaging when limits approach or exceed thresholds.
- Kept dashboard budget state separate from the Budgets screen month picker so the home screen always reflects the actual current month.
- Fixed the Wallets screen card overflow and reverted the Android predictive back flag after it caused navigation hangs on device.

### Notes

- Budget spent tracking ignores transfer entries and only reacts to real expense transactions.
- Overall budget tracking is optional and uses a reserved internal budget category id under the hood.

## Phase 9 - Recurring Transactions & Bills

- Added `SubscriptionModel` plus a new Firestore-backed subscription service and providers for recurring bill state, upcoming due items, paid-this-month history, and dashboard bill summaries.
- Replaced the subscriptions placeholder route with a real Bills screen that has `Upcoming`, `All`, and `Paid this month` tabs, recurring bill cards, swipe-to-mark-paid, delete actions, and a full-screen add/edit bill flow.
- Marking a bill as paid now creates a real expense transaction, updates wallet balance and budget usage through the existing transaction pipeline, stores the last-paid timestamp, and automatically advances the next due date by the selected frequency.
- Added Home dashboard integration with a live `Upcoming bills` card showing the next three due items alongside wallet and transaction insights.
- Added local notification support with app bootstrap, bill reminder scheduling/canceling, notification tap routing back into the Bills screen, Android boot receivers, and Gradle desugaring needed for scheduled reminders.

### Notes

- Bill reminders currently schedule one local notification per recurring bill using the selected reminder window and the device's local timezone.
- The reminder schedule is resynced on app startup for the signed-in user so existing bills continue to notify after reinstall/restart.

## Phase 10 - Savings Goals

- Added `GoalModel` plus a new Firestore-backed goal service and providers for active goals, completed goals, top-goal dashboard state, and atomic contribution flows.
- Replaced the goals placeholder route with a real Goals screen that shows active goals, progress bars, saved-vs-target amounts, target dates, collapsed completed goals, and full add/edit/delete management.
- Added a full-screen contribution flow that lets users contribute from a selected wallet, creates a real expense transaction, and updates the goal's saved amount in the same batch write.
- Added goal completion handling so fully funded goals move into the completed section and show a simple completion dialog the first time they are finished.
- Added Home dashboard integration with a live `Top goal` card so the most important active savings target is visible alongside budgets and bills.
- Added a dedicated default expense category for savings-goal contributions so these entries stay readable in transaction history and analytics.

### Notes

- Goal contributions currently use the reserved `Savings Goal` expense category under the hood and include the goal name in the transaction note.
- Editing a goal recalculates completion state from the current saved amount and target amount so completed/archive state stays consistent after target changes.

## Phase 11 - Localization Foundations and Core Bilingual UI

- Expanded the ARB localization files well beyond the original app-name scaffold and added shared localization extensions for theme labels, language labels, and reusable app strings.
- Updated the app bootstrap to use localized titles plus locale-aware theme typography, so English surfaces use Poppins while Bangla surfaces use Noto Sans Bengali.
- Localized the primary auth flow, profile screen, dashboard shell labels, wallet screen actions, selected calendar labels, and bill reminder notification text.
- Added reusable locale formatting helpers for currency, dates, and Bengali-digit conversion, then wired them into wallet and calendar surfaces.
- Updated widget tests to run with localization delegates so test coverage reflects the real app setup.

### Notes

- The app now switches both text and typography when the saved profile language changes, and major shell/profile/auth/wallet/calendar strings respond immediately.
- Several deeper dashboard, budget, goal, subscription, and transaction-detail labels still have room for a second localization sweep, but the localization architecture and the most user-visible flows are now in place and working.

## Localization Follow-up - Full Bangla Sweep

- Completed a second-pass localization sweep across the most-used finance surfaces so Bangla mode now updates Home, Reports, Transaction History, Add/Edit Transaction, Calendar day details, Wallet editor/detail screens, and Transfer flows more consistently.
- Centralized many finance-specific Bangla/English helper strings in `l10n_extension.dart` so dashboard cards, filters, dialogs, and transactional forms can stay in sync without duplicating text logic.
- Switched more screens from raw `DateFormat`/`NumberFormat` calls to locale-aware helpers so Bangla mode also affects dates, counts, chart buckets, and currency formatting instead of only swapping a few labels.
- Re-ran `flutter analyze`, `flutter test`, `flutter build apk --debug`, and `flutter build web` after the sweep to confirm the broader localization pass still compiles and ships cleanly.

## Phase 12 - Export & Backup

- Added a dedicated export feature with `ExportService`, export providers, and a full Export screen for generating CSV transaction exports and monthly or yearly PDF summaries.
- Implemented CSV export with transaction-history-style filters for type, category, wallet, and date range, plus save/share flows using `share_plus`.
- Implemented styled PDF reports with Sapphire-colored tables, summary totals, category breakdown, period breakdown, and recent transaction sections for both monthly and yearly report modes.
- Wired export access into both the profile/settings area and the Reports tab app bar so users can reach export actions from the two planned entry points.
- Added platform-aware export file saving so mobile/desktop builds save files locally while web builds still support in-memory sharing/download-style flows without `dart:io` crashes.
- Localized export labels and PDF content for English and Bangla, including Bangla-friendly fonts in generated PDFs via `printing` font helpers.

### Notes

- CSV exports include the filtered transaction rows with localized category names and localized column headers.
- PDF exports currently require at least one transaction in the selected range and surface a friendly message when no data exists to export.

## Phase 13A - Debt & Loan Tracker

- Added `DebtRecordModel` and `DebtPaymentModel` plus a Firestore-backed debt service and Riverpod providers for live debt lists, borrowed/lent tabs, payment recording, and dashboard overview totals.
- Replaced the placeholder debt shortcut with a real `DebtsScreen` that includes separate `Borrowed` and `Lent` tabs, a summary hero card, overdue state, installment hints, payment history, and full add/edit/delete flows.
- Added a dedicated debt editor page with person name, borrowed-vs-lent mode, amount, start date, due date, installments, and optional notes so debt records can be maintained cleanly.
- Added a payment-recording page that appends payment history, updates remaining balances atomically in Firestore, and automatically marks debts as settled when the remaining amount reaches zero.
- Added a live debt snapshot card to the Home tab so outstanding borrowed/receivable totals, overdue items, and due-soon follow-ups are visible alongside budgets, bills, and goals.

### Notes

- Debt records are currently informational and do not change wallet balances automatically when they are created or paid; they track obligations and repayments separately from the wallet transaction ledger.
- Payments are stored inside each debt document so the full repayment history remains visible without a second collection.
