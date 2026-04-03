// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Money Tracker';

  @override
  String get homeTabLabel => 'Home';

  @override
  String get transactionsTabLabel => 'Transactions';

  @override
  String get calendarTabLabel => 'Calendar';

  @override
  String get reportsTabLabel => 'Reports';

  @override
  String get homeTabSubtitle =>
      'Overview of balance, budgets, and recent activity.';

  @override
  String get transactionsTabSubtitle =>
      'Search, filter, and sort your full history.';

  @override
  String get calendarTabSubtitle =>
      'See daily income and expense activity on your calendar.';

  @override
  String get reportsTabSubtitle =>
      'See trends, category share, and deeper analytics.';

  @override
  String get toggleThemeTooltip => 'Toggle theme';

  @override
  String get profileTooltip => 'Profile';

  @override
  String get addAction => 'Add';

  @override
  String get editAction => 'Edit';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get saveChanges => 'Save changes';

  @override
  String get saving => 'Saving...';

  @override
  String get signOut => 'Sign out';

  @override
  String get englishLabel => 'English';

  @override
  String get banglaLabel => 'Bangla';

  @override
  String get lightThemeLabel => 'Sapphire Light';

  @override
  String get darkThemeLabel => 'Sapphire Dark';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileMissing =>
      'No profile found yet. Try reopening the screen.';

  @override
  String get profileUpdated => 'Profile updated successfully.';

  @override
  String get nameLabel => 'Name';

  @override
  String get fullNameLabel => 'Full name';

  @override
  String get nameRequired => 'Name is required.';

  @override
  String get emailLabel => 'Email';

  @override
  String get emailRequired => 'Email is required.';

  @override
  String get emailInvalid => 'Enter a valid email.';

  @override
  String get currencyLabel => 'Currency';

  @override
  String get languageLabel => 'Language';

  @override
  String get themeLabel => 'Theme';

  @override
  String get welcomeBackTitle => 'Welcome back';

  @override
  String get loginSubtitle => 'Sign in to continue tracking your money.';

  @override
  String get passwordLabel => 'Password';

  @override
  String get passwordRequired => 'Password is required.';

  @override
  String get forgotPasswordAction => 'Forgot password?';

  @override
  String get signingIn => 'Signing in...';

  @override
  String get loginAction => 'Login';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get dontHaveAccount => 'Don\'t have an account?';

  @override
  String get signUpAction => 'Sign up';

  @override
  String get createAccountTitle => 'Create account';

  @override
  String get createAccountSubtitle =>
      'Set up your profile and start saving your financial history.';

  @override
  String get confirmPasswordLabel => 'Confirm password';

  @override
  String get passwordTooShort => 'Password must be at least 6 characters.';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match.';

  @override
  String get creatingAccount => 'Creating account...';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get resetPasswordTitle => 'Reset password';

  @override
  String get resetPasswordSubtitle =>
      'Enter your email and we will send you a reset link.';

  @override
  String get sending => 'Sending...';

  @override
  String get sendResetLink => 'Send reset link';

  @override
  String get backToLogin => 'Back to login';

  @override
  String get resetEmailSent => 'Reset email sent. Check your inbox.';

  @override
  String get walletsTitle => 'Wallets';

  @override
  String get walletDetailTitle => 'Wallet detail';

  @override
  String get walletNotFound => 'Wallet not found.';

  @override
  String get walletsTotal => 'Total across wallets';

  @override
  String get yourWalletsTitle => 'Your wallets';

  @override
  String get walletActivityTitle => 'Wallet activity';

  @override
  String get addWalletAction => 'Add wallet';

  @override
  String get noWalletAvailableTitle => 'No wallet available';

  @override
  String get noWalletAvailableSubtitle =>
      'Create a wallet for cash, bank, bKash, Nagad, or savings.';

  @override
  String get noTransactionsHereYet => 'No transactions here yet';

  @override
  String get walletTransactionsSubtitle =>
      'This wallet will show transactions and transfers here.';

  @override
  String get transferAction => 'Transfer';

  @override
  String get deleteWalletTitle => 'Delete wallet';

  @override
  String get walletDeleted => 'Wallet deleted.';

  @override
  String get defaultLabel => 'Default';

  @override
  String get monthViewLabel => 'Month view';

  @override
  String get weekViewLabel => 'Week view';

  @override
  String get selectedDaySnapshot => 'Selected day snapshot';

  @override
  String get openDetailsAction => 'Open details';

  @override
  String get incomeLabel => 'Income';

  @override
  String get expenseLabel => 'Expense';

  @override
  String get netLabel => 'Net';

  @override
  String get authInvalidEmail => 'Please enter a valid email address.';

  @override
  String get authWrongCredentials => 'Email or password is incorrect.';

  @override
  String get authEmailAlreadyInUse => 'This email is already being used.';

  @override
  String get authWeakPassword => 'Password should be at least 6 characters.';

  @override
  String get authNetwork => 'Network error. Please try again.';

  @override
  String get authTooManyRequests =>
      'Too many attempts. Please wait and try again.';

  @override
  String get authGeneric => 'Authentication failed. Please try again.';

  @override
  String get firebaseUnavailable =>
      'Network connection is unavailable right now. Please check your internet and try again.';

  @override
  String get firebasePermissionDenied =>
      'You do not have permission for this action.';

  @override
  String get firebaseNeedsIndex =>
      'This action needs extra Firebase setup, such as a Firestore index.';

  @override
  String get genericError => 'Something went wrong. Please try again.';

  @override
  String get billReminderTitle => 'Bill reminder';

  @override
  String get billRemindersChannelName => 'Bill Reminders';

  @override
  String get billRemindersChannelDescription =>
      'Upcoming recurring bill reminders.';

  @override
  String get openNotificationAction => 'Open notification';

  @override
  String dueTodayBody(Object name) {
    return '$name is due today.';
  }

  @override
  String dueTomorrowBody(Object name) {
    return '$name is due tomorrow.';
  }

  @override
  String dueInDaysBody(Object name, Object days) {
    return '$name is due in $days days.';
  }

  @override
  String deleteWalletPrompt(Object name) {
    return 'Delete \"$name\"? It must have zero balance and no linked transactions.';
  }
}
