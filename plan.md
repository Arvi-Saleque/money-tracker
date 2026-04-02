# Money Tracker App — Complete Development Plan

## Tech Stack

- **Framework:** Flutter (Dart)
- **Backend:** Firebase (Auth, Firestore, Storage)
- **State Management:** Riverpod
- **Navigation:** GoRouter
- **Localization:** flutter_localizations + intl (Bangla + English)
- **Charts:** fl_chart
- **Calendar:** table_calendar
- **Notifications:** flutter_local_notifications
- **Export:** pdf + share_plus
- **Biometric:** local_auth

---

## Firestore Database Structure

```
users/{uid}
  ├── name, email, avatar, currency, language, theme, createdAt
  │
  ├── wallets/{walletId}
  │     └── name, type, balance, icon, color, isDefault, createdAt
  │
  ├── categories/{categoryId}
  │     └── name, nameBn, icon, color, type(income/expense), isDefault, createdAt
  │
  ├── transactions/{transactionId}
  │     └── amount, type(income/expense/transfer), categoryId, walletId,
  │         toWalletId(for transfers), note, date, createdAt
  │
  ├── budgets/{budgetId}
  │     └── categoryId, limit, spent, month, year, createdAt
  │
  ├── goals/{goalId}
  │     └── name, targetAmount, savedAmount, targetDate, icon, color, createdAt
  │
  └── subscriptions/{subscriptionId}
        └── name, amount, categoryId, walletId, frequency, nextDueDate,
            reminderDays, isPaid, createdAt
```

---

## UI Design Direction

### Color Palette

All colors are dynamic via ThemeExtension (Amal Tracker pattern). No hardcoded colors anywhere in widgets.

#### Dark Mode

| Role              | Color Code  |
|-------------------|-------------|
| Background        | `#0F1221`   |
| Card Surface      | `#1A1F38`   |
| Card Surface 2    | `#242A48`   |
| Primary Accent    | `#3D6BE4` (Sapphire Blue) |
| Income Color      | `#2ECC9A` (Muted Emerald) |
| Expense Color     | `#E85D5D` (Soft Coral)    |
| Secondary Text    | `#8B9CB5` (Slate)         |
| Border / Divider  | `#252A45`   |

#### Light Mode

| Role              | Color Code  |
|-------------------|-------------|
| Background        | `#F4F6FB`   |
| Card Surface      | `#FFFFFF`   |
| Card Surface 2    | `#EEF1F8`   |
| Primary Accent    | `#3D6BE4`   |
| Income Color      | `#1EB386`   |
| Expense Color     | `#D64545`   |
| Secondary Text    | `#6B7A99`   |
| Border / Divider  | `#E2E8F0`   |

### Typography

- Latin text: **Poppins**
- Bangla text: **Noto Sans Bengali**
- Sizes: 12 / 14 / 16 / 20 / 24

### Theme Architecture (from Amal Tracker)

- `AppColors` class → all color constants
- `AppTheme.getTheme(String themeName)` → returns full ThemeData
- `GradientColors extends ThemeExtension` → gradient definitions
- `PremiumCardStyle extends ThemeExtension` → card styling
- Widgets access colors only via `Theme.of(context).extension<T>()`
- Adding a new theme = one new case in the switch statement

### Bottom Navigation (5 tabs)

Home | Transactions | ➕ (FAB center) | Calendar | Reports

---

## Final Feature List

### Core Features
1. Email/password + Google sign-in
2. Forgot password flow
3. User profile (name, email, avatar, currency, language, theme)
4. Add / edit / delete income and expense transactions
5. Default expense categories: groceries, transport, food, bills, medical, education, shopping, entertainment, gift, rent, other
6. Default income categories: salary, freelance, business, gift received, other
7. Custom category creation (name, icon, color, type)
8. Paginated transaction list with search, filter, sort

### Dashboard & Analytics
9. Net balance card with wallet summary
10. Today income / expense pills
11. This month area chart (income vs expense trend)
12. Recent transactions list
13. Weekly / monthly / yearly summaries
14. Average daily / weekly / monthly expense
15. Top spending category
16. Monthly trend bar chart
17. Category breakdown donut chart

### Calendar View
18. Monthly calendar grid with color dot indicators per day
19. Tap date → day detail panel with transaction list
20. Day total income + total expense
21. Week view option

### Multi-Wallet System
22. Wallet types: Cash, Bank, bKash/Nagad, Savings
23. Each transaction linked to a wallet
24. Transfer between wallets
25. Wallet balance overview screen

### Budget System
26. Monthly budget per category (limit + spent)
27. Overall monthly spending limit
28. Budget progress bars on dashboard
29. Warning at 80% threshold + exceeded alert

### Recurring Transactions & Bills
30. Recurring types: daily, weekly, monthly, yearly
31. Bill/subscription tracking (name, amount, due date, paid/unpaid)
32. Reminder notifications before due date

### Savings Goals
33. Goal: name, target amount, saved amount, target date, icon
34. Contribute to goal from transaction screen
35. Progress percentage bar + goal list screen

### Localization
36. Full Bangla + English support (all strings, dates, numbers)
37. Language toggle in settings
38. Currency symbol ৳ (BDT) by default, user can change

### Export & Backup
39. Export CSV (all or filtered)
40. Export PDF monthly/yearly summary
41. Share via share_plus

### Advanced (V2+)
42. Debt / loan tracker
43. Split transactions
44. Smart spending insights
45. Shared family wallet
46. Receipt photo upload
47. Biometric / PIN lock
48. Net worth view
49. Dark mode + multiple themes
50. Short onboarding walkthrough (2-3 screens)

---

## Phases — Detailed Breakdown

---

### Phase 1 — Project Initialization & Theme System

**Goal:** Create project, connect Firebase, set up architecture, build full theme system.

**Tasks:**
1. Run `flutter create money_tracker`
2. Add all core dependencies to `pubspec.yaml`:
   - `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_storage`
   - `flutter_riverpod`, `riverpod_annotation`
   - `go_router`
   - `flutter_localizations`, `intl`
   - `google_fonts`
   - `shared_preferences`
3. Create Firebase project (Android + iOS config)
4. Set up folder structure:
   ```
   lib/
   ├── core/
   │   ├── theme/
   │   │   ├── app_colors.dart         → all color constants
   │   │   ├── app_theme.dart          → ThemeData builder + getTheme()
   │   │   ├── gradient_colors.dart    → ThemeExtension for gradients
   │   │   └── premium_card_style.dart → ThemeExtension for cards
   │   ├── router/
   │   │   └── app_router.dart         → GoRouter config
   │   ├── constants/
   │   │   └── app_constants.dart
   │   └── utils/
   │       └── helpers.dart
   ├── features/
   │   ├── auth/
   │   ├── profile/
   │   ├── dashboard/
   │   ├── transactions/
   │   ├── calendar/
   │   ├── reports/
   │   ├── wallets/
   │   ├── budgets/
   │   ├── goals/
   │   └── subscriptions/
   ├── shared/
   │   ├── widgets/
   │   ├── models/
   │   ├── providers/
   │   └── services/
   ├── l10n/
   │   ├── app_en.arb
   │   └── app_bn.arb
   └── main.dart
   ```
5. Build complete theme system following Amal Tracker pattern:
   - `AppColors` with all Sapphire palette colors (dark + light)
   - `AppTheme` with `getTheme('sapphire_dark')` / `getTheme('sapphire_light')`
   - `GradientColors` ThemeExtension
   - `PremiumCardStyle` ThemeExtension
   - `buildPremiumCard()` / `buildPremiumInkCard()` helper functions
   - Theme provider with Riverpod (persisted to SharedPreferences)
6. Set up basic localization scaffolding (ARB files with app name only)
7. Set up GoRouter with placeholder routes
8. Create `update.md` at project root
9. Push commit: "Phase 1: Project init, Firebase, theme system, folder structure"

**What you have after Phase 1:**
- App runs, shows a blank themed screen
- Firebase connected
- Full theme system ready (any widget can access colors dynamically)
- Router ready, localization scaffolding ready
- Clean folder structure for all future features

---

### Phase 2 — Authentication & Profile System

**Goal:** Users can sign up, log in, reset password, and manage their profile.

**Tasks:**
1. Build `AuthService` class:
   - `signUpWithEmail(email, password)`
   - `signInWithEmail(email, password)`
   - `signInWithGoogle()`
   - `signOut()`
   - `resetPassword(email)`
   - `getCurrentUser()`
2. Build auth state provider (Riverpod):
   - `authStateProvider` → streams `User?` from Firebase
   - `authControllerProvider` → handles sign in/up/out actions
3. Build screens:
   - **Login Screen:** email + password fields, "Login" button, "Sign up" link, "Forgot password" link, Google sign-in button
   - **Sign Up Screen:** name + email + password + confirm password, "Sign Up" button
   - **Forgot Password Screen:** email field, "Send Reset Link" button
4. Build `UserModel`:
   - Fields: uid, name, email, avatarUrl, currency (default ৳), language (default en), theme (default sapphire_dark), createdAt
5. On first sign-up → create Firestore document at `users/{uid}` with default values
6. Build **Profile Screen:**
   - Display name (editable)
   - Email (read-only)
   - Avatar (tap to pick from gallery → upload to Firebase Storage, fallback = initials avatar)
   - Currency selector
   - Language toggle (EN / BN)
   - Theme selector
   - Sign out button
7. Integrate GoRouter:
   - Unauthenticated → login screen
   - Authenticated → dashboard (placeholder)
   - Redirect guards
8. Firestore security rules:
   - `users/{uid}` → only owner can read/write
   - All subcollections → only owner can read/write
9. Update `update.md`
10. Push commit: "Phase 2: Auth + Profile system"

**What you have after Phase 2:**
- Full authentication flow (email + Google + password reset)
- Profile page with avatar, language, theme, currency
- Firestore user document created automatically
- Route guards (logged out → login, logged in → home)

---

### Phase 3 — Core Transaction System (MVP)

**Goal:** Users can add, edit, delete income and expense transactions with categories.

**Tasks:**
1. Build `TransactionModel`:
   - Fields: id, amount, type (income/expense), categoryId, walletId, note, date, createdAt
2. Build `CategoryModel`:
   - Fields: id, name, nameBn, icon, color, type (income/expense), isDefault, createdAt
3. Build `TransactionService`:
   - `addTransaction()`
   - `updateTransaction()`
   - `deleteTransaction()`
   - `getTransactions(filters)` with pagination
4. Build `CategoryService`:
   - `getCategories(type)`
   - `addCategory()`
   - `updateCategory()`
   - `deleteCategory()`
5. Seed default categories on first sign-up:
   - Expense: Groceries, Transport, Food, Bills, Medical, Education, Shopping, Entertainment, Gift, Rent, Other
   - Income: Salary, Freelance, Business, Gift Received, Other
   - Each with icon + color + Bangla name
6. Create single default "Cash" wallet for user on sign-up
7. Build **Add/Edit Transaction Bottom Sheet:**
   - Income / Expense toggle (pill selector)
   - Amount field (large, centered, numeric keyboard)
   - Category grid (scrollable, icon + label)
   - Date picker (defaults to today)
   - Note field (optional)
   - Save button
8. Build **Custom Category Creation Dialog:**
   - Name field (English + Bangla)
   - Icon picker (grid of finance-related icons)
   - Color picker (preset color palette)
   - Type selector (income / expense)
9. Build basic **Dashboard Screen** (Home tab):
   - Greeting + date at top
   - Net balance card
   - Today income / expense pills
   - Recent transactions list (last 10)
   - FAB → opens Add Transaction sheet
10. Build bottom navigation bar with 5 tabs (Home active, others placeholder)
11. Update `update.md`
12. Push commit: "Phase 3: Transactions, categories, basic dashboard"

**What you have after Phase 3:**
- Can add income and expense with categories
- Can create custom categories
- Dashboard shows balance and recent transactions
- Bottom nav bar structure in place
- This is the MVP — the app is usable

---

### Phase 4 — Transaction History & Search

**Goal:** Users can browse, search, filter, and sort their full transaction history.

**Tasks:**
1. Build **Transactions Screen** (Transactions tab):
   - Paginated list grouped by date
   - Each item: category icon, title, amount (green/red), wallet chip, time
   - Swipe left to delete (with confirmation)
   - Tap to edit (opens edit bottom sheet)
2. Build **Filter System:**
   - Filter chips bar at top: All | Income | Expense
   - Category filter (multi-select bottom sheet)
   - Date range filter (start date — end date picker)
   - Wallet filter (when multi-wallet exists)
3. Build **Search:**
   - Search icon in app bar → expands search field
   - Search by note text or amount
   - Results update as user types (debounced 300ms)
4. Build **Sort Options:**
   - Sort by: Latest (default), Oldest, Highest amount, Lowest amount
   - Dropdown or bottom sheet selector
5. Firestore query optimization:
   - Composite indexes for date + type queries
   - Pagination with `startAfterDocument`
6. Update `update.md`
7. Push commit: "Phase 4: Transaction history, search, filter, sort"

**What you have after Phase 4:**
- Full transaction browsing with infinite scroll
- Can search by note or amount
- Can filter by type, category, date range
- Can sort by date or amount
- Edit and delete from list

---

### Phase 5 — Dashboard & Analytics

**Goal:** Dashboard shows meaningful financial insights with charts.

**Tasks:**
1. Enhance **Dashboard Screen:**
   - Large balance card with subtle gradient
   - Wallet chips row (horizontal scroll, shows each wallet balance)
   - Income ↑ / Expense ↓ summary pills (today + this month)
   - This month area chart: daily expense trend line
   - Top spending category chip
   - Recent transactions list
2. Build **Reports Screen** (Reports tab):
   - Period tabs: This Week | This Month | This Year
   - Section: Income vs Expense bar chart
   - Section: Category breakdown donut chart (top 5 + "Other")
   - Section: Summary cards:
     - Total income
     - Total expense
     - Net balance
     - Average daily expense
     - Average weekly expense
     - Average monthly expense (for yearly view)
     - Highest spending day
     - Top spending category with amount
3. Build analytics providers:
   - `weeklyAnalyticsProvider` → aggregates 7 days
   - `monthlyAnalyticsProvider` → aggregates current month
   - `yearlyAnalyticsProvider` → aggregates current year
   - Each returns: totalIncome, totalExpense, net, averages, topCategory, dailyBreakdown
4. Charts (using fl_chart):
   - Area chart: X = days, Y = expense amount, filled area with gradient
   - Bar chart: X = months or days, Y = income (green) + expense (red) side-by-side
   - Donut chart: segments by category, legend below
   - All chart colors from ThemeExtension (dynamic)
5. Update `update.md`
6. Push commit: "Phase 5: Dashboard analytics, charts, reports"

**What you have after Phase 5:**
- Dashboard is informative and visually complete
- Reports screen with weekly / monthly / yearly views
- Bar charts, donut charts, area charts
- Average expenses, top categories, trends

---

### Phase 6 — Calendar View

**Goal:** Users can view transactions on a calendar and see day-wise details.

**Tasks:**
1. Build **Calendar Screen** (Calendar tab):
   - Monthly calendar grid using `table_calendar`
   - Dot markers on dates:
     - Green dot = income exists on that day
     - Red dot = expense exists on that day
     - Both dots = both income and expense
   - Navigation: swipe left/right for months, tap month header for month picker
2. Build **Day Detail Panel:**
   - Tapping a date slides up a bottom panel
   - Shows: selected date, total income, total expense, net for that day
   - Transaction list for that day (same style as history list)
   - Tap a transaction to edit
3. Data loading:
   - Load transaction summaries for visible month (single Firestore query)
   - Cache per month to avoid re-fetching
4. Week view option:
   - Toggle between month view and week view
   - Week view shows 7 days in a row with daily totals
5. Update `update.md`
6. Push commit: "Phase 6: Calendar view with day details"

**What you have after Phase 6:**
- Calendar with color-coded days
- Tap any day to see what happened financially
- Month and week views
- All 5 bottom nav tabs are now functional

---

### Phase 7 — Multi-Wallet System

**Goal:** Users can manage multiple wallets and transfer between them.

**Tasks:**
1. Build `WalletModel`:
   - Fields: id, name, type (cash/bank/bkash/nagad/savings), balance, icon, color, isDefault, createdAt
2. Build `WalletService`:
   - `addWallet()`
   - `updateWallet()`
   - `deleteWallet()` (only if balance = 0 and no transactions linked)
   - `getWallets()`
   - `transferBetweenWallets(fromId, toId, amount)`
3. Build **Wallets Screen:**
   - Grid or list of all wallets with balance
   - Total balance across all wallets card at top
   - Tap wallet → wallet detail (transactions filtered to that wallet)
   - Add wallet button
4. Build **Add/Edit Wallet Dialog:**
   - Name field
   - Type selector (Cash, Bank, bKash, Nagad, Savings)
   - Initial balance
   - Icon + color picker
5. Build **Transfer Bottom Sheet:**
   - From wallet dropdown
   - To wallet dropdown
   - Amount field
   - Note field
   - Creates two linked transactions (expense from source, income to destination)
6. Update Add Transaction sheet:
   - Add wallet selector dropdown
   - Default to user's default wallet
7. Update dashboard:
   - Wallet chips show individual balances
   - Total balance sums all wallets
8. Wallet balance auto-updates:
   - On transaction add/edit/delete → update wallet balance in Firestore (batch write)
9. Update `update.md`
10. Push commit: "Phase 7: Multi-wallet system with transfers"

**What you have after Phase 7:**
- Multiple wallets (Cash, Bank, bKash, etc.)
- Transfer money between wallets
- Each transaction tied to a wallet
- Dashboard shows wallet-level balances

---

### Phase 8 — Budget System

**Goal:** Users can set spending limits per category and see progress.

**Tasks:**
1. Build `BudgetModel`:
   - Fields: id, categoryId, limit, spent, month, year, createdAt
2. Build `BudgetService`:
   - `addBudget(categoryId, limit, month, year)`
   - `updateBudget()`
   - `deleteBudget()`
   - `getBudgets(month, year)`
   - `updateBudgetSpent()` → called when expense transaction added/edited/deleted
3. Build **Budget Screen** (accessible from Reports or Settings):
   - Month selector at top
   - Overall monthly limit card with total spent / limit progress bar
   - Per-category budget cards:
     - Category icon + name
     - Spent / Limit text
     - Progress bar (green < 60%, yellow 60-80%, red > 80%)
     - Percentage badge
   - Add budget FAB → opens Add Budget dialog
4. Build **Add/Edit Budget Dialog:**
   - Category dropdown (only expense categories)
   - Limit amount field
   - Month/year selector
5. Build notification/alert system:
   - At 80% of budget → yellow warning banner on dashboard
   - At 100% exceeded → red alert card on dashboard
   - In-app notification (not push notification at this phase)
6. Dashboard integration:
   - Budget summary card showing most-used budgets and their status
7. Auto-update `spent` field:
   - When expense added → find matching budget for that category + month → increment spent
   - When expense deleted → decrement spent
   - When expense edited → adjust spent accordingly
   - Use Firestore batch writes for consistency
8. Update `update.md`
9. Push commit: "Phase 8: Budget system with progress tracking"

**What you have after Phase 8:**
- Monthly budgets per category
- Visual progress bars
- Warnings when approaching or exceeding limits
- Budget status on dashboard

---

### Phase 9 — Recurring Transactions & Bills

**Goal:** Users can track subscriptions, recurring bills, and get reminders.

**Tasks:**
1. Build `SubscriptionModel`:
   - Fields: id, name, amount, categoryId, walletId, frequency (daily/weekly/monthly/yearly), nextDueDate, reminderDaysBefore, isPaid, note, createdAt
2. Build `SubscriptionService`:
   - `addSubscription()`
   - `updateSubscription()`
   - `deleteSubscription()`
   - `getSubscriptions()`
   - `markAsPaid(id)` → creates actual transaction + advances nextDueDate
   - `getUpcomingDue(days)` → subscriptions due within N days
3. Build **Subscriptions Screen:**
   - Tabs: Upcoming | All | Paid This Month
   - Each card: name, amount, category icon, next due date, days remaining badge
   - Swipe to mark as paid
   - Tap to edit
   - Add subscription FAB
4. Build **Add/Edit Subscription Sheet:**
   - Name field
   - Amount field
   - Category selector
   - Wallet selector
   - Frequency: daily / weekly / monthly / yearly radio
   - Start date / next due date
   - Reminder: X days before (1, 2, 3, 7)
   - Note field
5. Notification system:
   - Set up `flutter_local_notifications`
   - Schedule local notification X days before due date
   - Notification text: "৳500 Internet bill due in 2 days"
   - Tap notification → opens app to subscriptions screen
6. Auto-advance:
   - When marked as paid, nextDueDate advances based on frequency
   - Monthly: +1 month, Weekly: +7 days, etc.
7. Dashboard integration:
   - "Upcoming bills" section showing next 3 due items
8. Update `update.md`
9. Push commit: "Phase 9: Recurring transactions, bills, reminders"

**What you have after Phase 9:**
- Track all recurring expenses (rent, internet, subscriptions)
- Get reminded before due dates
- Mark as paid creates real transaction
- Upcoming bills visible on dashboard

---

### Phase 10 — Savings Goals

**Goal:** Users can set savings goals and track progress toward them.

**Tasks:**
1. Build `GoalModel`:
   - Fields: id, name, targetAmount, savedAmount, targetDate, icon, color, note, createdAt
2. Build `GoalService`:
   - `addGoal()`
   - `updateGoal()`
   - `deleteGoal()`
   - `getGoals()`
   - `contributeToGoal(goalId, amount)` → increases savedAmount
3. Build **Goals Screen:**
   - Goal cards in a list/grid:
     - Goal name + icon
     - Progress bar (savedAmount / targetAmount)
     - Percentage text
     - Target date with "X days remaining"
     - Saved amount / Target amount text
   - Completed goals section (collapsed by default)
   - Add goal FAB
4. Build **Add/Edit Goal Dialog:**
   - Name field
   - Target amount field
   - Target date picker
   - Icon picker
   - Color picker
   - Note field (optional)
5. Build **Contribute to Goal Sheet:**
   - Amount field
   - Source wallet selector
   - Creates: expense transaction (from wallet) + updates goal savedAmount
   - Or: transfer from wallet to savings goal (logical)
6. Goal completion:
   - When savedAmount >= targetAmount → mark as completed
   - Show celebration animation (confetti or simple checkmark)
7. Dashboard integration:
   - Top active goal card with progress bar
8. Update `update.md`
9. Push commit: "Phase 10: Savings goals with progress tracking"

**What you have after Phase 10:**
- Create savings goals with deadlines
- Contribute money toward goals
- Visual progress tracking
- Completed goals archive

---

### Phase 11 — Full Localization (Bangla + English)

**Goal:** Every string in the app is available in both Bangla and English.

**Tasks:**
1. Complete `app_en.arb` with ALL strings:
   - Screen titles, button labels, field hints, error messages
   - Category names, wallet type names
   - Date format strings, number format strings
   - Analytics labels, chart labels
   - Notification texts
   - Settings labels
2. Complete `app_bn.arb` with Bangla translations for all strings
3. Number formatting:
   - English: 1,234.56
   - Bangla: ১,২৩৪.৫৬ (Bengali digits)
   - Currency: ৳ symbol for both
4. Date formatting:
   - English: "March 31, 2026"
   - Bangla: "৩১ মার্চ, ২০২৬"
   - Day names: Saturday → শনিবার, etc.
   - Month names: January → জানুয়ারি, etc.
5. Language switching:
   - Toggle in Settings (saved to Firestore user profile)
   - App rebuilds with new locale instantly
   - Persisted across sessions
6. Font handling:
   - English text → Poppins
   - Bangla text → Noto Sans Bengali
   - Auto-select based on current locale
7. Review every screen for:
   - Hardcoded strings (replace with localization keys)
   - Text overflow issues with Bangla (longer text)
   - RTL considerations (Bangla is LTR so minimal changes)
8. Update `update.md`
9. Push commit: "Phase 11: Full Bangla + English localization"

**What you have after Phase 11:**
- Complete Bangla and English support
- All text, dates, numbers properly localized
- Language switch in settings
- Proper fonts for both languages

---

### Phase 12 — Export & Backup

**Goal:** Users can export their financial data as CSV or PDF.

**Tasks:**
1. Build **Export Service:**
   - `exportCSV(filters)` → generates CSV file of transactions
   - `exportPDF(month, year)` → generates styled PDF summary report
2. CSV Export:
   - Columns: Date, Type, Category, Amount, Wallet, Note
   - Filters: date range, category, type (same as transaction history filters)
   - Save to device downloads folder
   - Share option via `share_plus`
3. PDF Export:
   - Monthly summary report layout:
     - Header: "Money Tracker — March 2026"
     - Summary: total income, total expense, net balance
     - Category breakdown table
     - Top spending categories
     - Daily breakdown table
   - Yearly summary report:
     - Month-by-month income vs expense table
     - Yearly totals
   - Styled with app colors (Sapphire theme in PDF)
4. Export access:
   - Settings screen → Export Data section
   - Reports screen → Export button in app bar
5. Update `update.md`
6. Push commit: "Phase 12: CSV and PDF export"

**What you have after Phase 12:**
- Export all transactions as CSV
- Export monthly/yearly PDF reports
- Share exports via any app

---

### Phase 13 — Advanced Features (V2)

**Goal:** Polish and add premium-level features.

**Tasks (pick and implement one by one):**

#### 13a. Debt / Loan Tracker
- Track money borrowed and lent
- Fields: person name, amount, date, due date, type (borrowed/lent), installments
- Installment tracking with partial payments
- Separate screen with borrowed vs lent tabs

#### 13b. Split Transactions
- One transaction → multiple categories
- Example: ৳500 grocery shopping = ৳300 food + ৳200 household
- Split editor UI in add transaction sheet

#### 13c. Smart Spending Insights
- Compare this month vs last month
- "You spent 18% more on food this month"
- "Your transport spending decreased by ৳200"
- Show on dashboard as insight cards

#### 13d. Receipt Photo Upload
- Camera / gallery option in add transaction
- Upload to Firebase Storage
- Thumbnail in transaction detail
- View full image on tap

#### 13e. Biometric / PIN Lock
- App lock toggle in settings
- PIN setup (4-6 digits)
- Fingerprint / Face ID via `local_auth`
- Lock on app open and app resume

#### 13f. Onboarding Walkthrough
- 2-3 screen onboarding on first launch
- Screen 1: "Track your money" — app overview
- Screen 2: "Set your language" — EN / BN toggle
- Screen 3: "Choose your style" — theme selection
- Then → Sign up / Login

#### 13g. Dark Mode + Multiple Themes
- Since theme system is dynamic from Phase 1:
- Add themes: Sapphire Dark, Sapphire Light, Ocean, Forest, Rose
- Theme preview cards in settings
- One tap to switch

#### 13h. Net Worth View
- Total assets (all wallet balances + goal savings)
- Total liabilities (all debts/loans)
- Net worth = assets − liabilities
- Simple card on dashboard or separate screen

**Each sub-feature = separate commit and update.md entry.**

---

## Summary of Phases

| Phase | Name | Key Deliverable |
|-------|------|-----------------|
| 1 | Project Init & Theme | Flutter project, Firebase, theme system, folder structure |
| 2 | Auth & Profile | Login, sign up, Google auth, profile page |
| 3 | Core Transactions | Add/edit/delete income & expense, categories, basic dashboard |
| 4 | History & Search | Transaction list, search, filter, sort |
| 5 | Dashboard & Analytics | Charts, reports, weekly/monthly/yearly summaries |
| 6 | Calendar View | Calendar with day details, color indicators |
| 7 | Multi-Wallet | Multiple wallets, transfers, wallet overview |
| 8 | Budget System | Category budgets, progress bars, alerts |
| 9 | Recurring & Bills | Subscriptions, reminders, auto-advance |
| 10 | Savings Goals | Goals, progress tracking, contributions |
| 11 | Localization | Full Bangla + English, dates, numbers |
| 12 | Export & Backup | CSV + PDF export, share |
| 13 | Advanced (V2) | Debt tracker, insights, biometric, themes, etc. |

---

## Rules Throughout Development

1. **No hardcoded colors** — everything via ThemeExtension
2. **No hardcoded strings** — everything via localization (start from Phase 3)
3. **update.md** updated after every phase
4. **Git push** after every phase — small, shippable increments
5. **Firestore security rules** — user can only access their own data
6. **Each phase is independently functional** — app works after every phase
