import 'package:flutter/widgets.dart';

import '../core/constants/app_constants.dart';
import 'generated/app_localizations.dart';

extension AppL10nBuildContextX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

extension AppL10nX on AppLocalizations {
  bool get isBangla => localeName.startsWith('bn');

  String themeName(String themeName) {
    switch (themeName) {
      case AppConstants.sapphireLightTheme:
        return lightThemeLabel;
      case AppConstants.sapphireDarkTheme:
      default:
        return darkThemeLabel;
    }
  }

  String languageName(String languageCode) {
    switch (languageCode) {
      case 'bn':
        return banglaLabel;
      case 'en':
      default:
        return englishLabel;
    }
  }

  String get openAction => isBangla ? 'à¦–à§à¦²à§à¦¨' : 'Open';
  String get retryAction =>
      isBangla ? 'à¦†à¦¬à¦¾à¦° à¦šà§‡à¦·à§à¦Ÿà¦¾ à¦•à¦°à§à¦¨' : 'Retry';
  String get dismissAction =>
      isBangla ? 'à¦¬à¦¨à§à¦§ à¦•à¦°à§à¦¨' : 'Dismiss';
  String get clearAction => isBangla ? 'à¦®à§à¦›à§à¦¨' : 'Clear';
  String get applyAction =>
      isBangla ? 'à¦ªà§à¦°à§Ÿà§‹à¦— à¦•à¦°à§à¦¨' : 'Apply';
  String get addAction => isBangla ? 'à¦¯à§‹à¦— à¦•à¦°à§à¦¨' : 'Add';
  String get addTransactionAction => isBangla
      ? 'à¦²à§‡à¦¨à¦¦à§‡à¦¨ à¦¯à§‹à¦— à¦•à¦°à§à¦¨'
      : 'Add transaction';
  String get addNewAction =>
      isBangla ? 'à¦¨à¦¤à§à¦¨ à¦¯à§‹à¦— à¦•à¦°à§à¦¨' : 'Add new';
  String get editAction => isBangla ? 'à¦¸à¦®à§à¦ªà¦¾à¦¦à¦¨à¦¾' : 'Edit';
  String get saveAction =>
      isBangla ? 'à¦¸à¦‚à¦°à¦•à§à¦·à¦£ à¦•à¦°à§à¦¨' : 'Save';
  String get updateAction =>
      isBangla ? 'à¦†à¦ªà¦¡à§‡à¦Ÿ à¦•à¦°à§à¦¨' : 'Update';
  String get allLabel => isBangla ? 'à¦¸à¦¬' : 'All';
  String get otherLabel => isBangla ? 'à¦…à¦¨à§à¦¯à¦¾à¦¨à§à¦¯' : 'Other';
  String get liveLabel => isBangla ? 'à¦²à¦¾à¦‡à¦­' : 'Live';
  String get shortcutsLabel => isBangla ? 'à¦¶à¦°à§à¦Ÿà¦•à¦¾à¦Ÿ' : 'Shortcuts';
  String get todayLabel => isBangla ? 'à¦†à¦œ' : 'Today';
  String get yesterdayLabel => isBangla ? 'à¦—à¦¤à¦•à¦¾à¦²' : 'Yesterday';
  String get transferLabel =>
      isBangla ? 'à¦Ÿà§à¦°à¦¾à¦¨à§à¦¸à¦«à¦¾à¦°' : 'Transfer';
  String get incomeTypeLabel => isBangla ? 'à¦†à§Ÿ' : 'Income';
  String get expenseTypeLabel => isBangla ? 'à¦¬à§à¦¯à§Ÿ' : 'Expense';

  String get homeAvailableBalance =>
      isBangla ? 'à¦®à§‹à¦Ÿ à¦¬à§à¦¯à¦¾à¦²à§‡à¦¨à§à¦¸' : 'Available balance';
  String get homeTodayIncome =>
      isBangla ? 'à¦†à¦œà¦•à§‡à¦° à¦†à§Ÿ' : 'Today income';
  String get homeTodayExpense =>
      isBangla ? 'à¦†à¦œà¦•à§‡à¦° à¦¬à§à¦¯à§Ÿ' : 'Today expense';
  String get homeMonthExpense =>
      isBangla ? 'à¦®à¦¾à¦¸à§‡à¦° à¦¬à§à¦¯à§Ÿ' : 'Month expense';
  String get homeNetToday =>
      isBangla ? 'à¦†à¦œà¦•à§‡à¦° à¦¨à§‡à¦Ÿ' : 'Net today';
  String get walletReadyTitle => isBangla
      ? 'à¦†à¦ªà¦¨à¦¾à¦° à¦“à§Ÿà¦¾à¦²à§‡à¦Ÿ à¦ªà§à¦°à¦¸à§à¦¤à§à¦¤ à¦¹à¦šà§à¦›à§‡'
      : 'Your wallet is getting ready';
  String get walletReadySubtitle => isBangla
      ? 'à¦¸à¦¾à¦‡à¦¨ à¦‡à¦¨ à¦•à¦°à¦¾à¦° à¦ªà¦° à¦¸à§à¦Ÿà¦¾à¦°à§à¦Ÿà¦¾à¦° à¦¡à¦¾à¦Ÿà¦¾ à¦†à¦¸à¦¤à§‡ à¦à¦•à¦Ÿà§ à¦¸à¦®à§Ÿ à¦²à¦¾à¦—à§‡à¥¤ à¦à¦•à¦Ÿà§ à¦ªà¦°à§‡ à¦†à¦¬à¦¾à¦° à¦¦à§‡à¦–à§à¦¨à¥¤'
      : 'Starter data usually appears right after sign-in. Give it a moment and reopen the screen if needed.';
  String get walletBalancesTitle => isBangla
      ? 'à¦“à§Ÿà¦¾à¦²à§‡à¦Ÿ à¦¬à§à¦¯à¦¾à¦²à§‡à¦¨à§à¦¸'
      : 'Wallet balances';
  String get expenseTrendTitle =>
      isBangla ? 'à¦¬à§à¦¯à§Ÿà§‡à¦° à¦Ÿà§à¦°à§‡à¦¨à§à¦¡' : 'Expense trend';
  String get expenseTrendSubtitle => isBangla
      ? 'à¦šà¦²à¦¤à¦¿ à¦®à¦¾à¦¸à§‡ à¦ªà§à¦°à¦¤à¦¿à¦¦à¦¿à¦¨à§‡à¦° à¦¬à§à¦¯à§Ÿà§‡à¦° à¦ªà¦°à¦¿à¦¬à¦°à§à¦¤à¦¨à¥¤'
      : 'Daily expense movement for the current month.';
  String get monthPulseTitle => isBangla
      ? 'à¦à¦‡ à¦®à¦¾à¦¸à§‡à¦° à¦…à¦¬à¦¸à§à¦¥à¦¾'
      : 'This month pulse';
  String get monthPulseSubtitle => isBangla
      ? 'à¦²à¦¾à¦‡à¦­ à¦¬à§à¦¯à¦¾à¦²à§‡à¦¨à§à¦¸ à¦†à¦° à¦•à§à¦¯à¦¾à¦Ÿà¦¾à¦—à¦°à¦¿à¦° à¦Ÿà§à¦°à§‡à¦¨à§à¦¡ à¦à¦•à¦¸à¦¾à¦¥à§‡ à¦¦à§‡à¦–à§à¦¨à¥¤'
      : 'Your dashboard now blends live balances with category trends.';
  String get monthIncomeLabel =>
      isBangla ? 'à¦®à¦¾à¦¸à§‡à¦° à¦†à§Ÿ' : 'Month income';
  String get waitingForSpending => isBangla
      ? 'à¦–à¦°à¦š à¦¶à§à¦°à§ à¦¹à¦²à§‡ à¦à¦–à¦¾à¦¨à§‡ à¦¦à§‡à¦–à¦¾ à¦¯à¦¾à¦¬à§‡'
      : 'Waiting for spending';
  String get analyticsLoadingTitle => isBangla
      ? 'à¦…à§à¦¯à¦¾à¦¨à¦¾à¦²à¦¿à¦Ÿà¦¿à¦•à§à¦¸ à¦ªà§à¦°à¦¸à§à¦¤à§à¦¤ à¦¹à¦šà§à¦›à§‡'
      : 'Analytics are catching up';
  String get upcomingBillsTitle =>
      isBangla ? 'à¦†à¦¸à¦¨à§à¦¨ à¦¬à¦¿à¦²' : 'Upcoming bills';
  String get noBillsDueSoon => isBangla
      ? 'à¦¶à¦¿à¦—à¦—à¦¿à¦° à¦•à§‹à¦¨à§‹ à¦¬à¦¿à¦² à¦¬à¦¾à¦•à¦¿ à¦¨à§‡à¦‡à¥¤ à¦à¦•à¦Ÿà¦¿ à¦°à¦¿à¦•à¦¾à¦°à¦¿à¦‚ à¦¬à¦¿à¦² à¦¯à§‹à¦— à¦•à¦°à¦²à§‡ à¦à¦–à¦¾à¦¨à§‡ à¦¦à§‡à¦–à¦¾ à¦¯à¦¾à¦¬à§‡à¥¤'
      : 'Nothing is due soon. Add a recurring bill and it will show up here.';

  String dueLabel(int days) {
    if (days < 0) {
      return isBangla
          ? '${days.abs()} à¦¦à¦¿à¦¨ à¦“à¦­à¦¾à¦°à¦¡à¦¿à¦‰'
          : 'Overdue ${days.abs()}d';
    }
    if (days == 0) {
      return isBangla ? 'à¦†à¦œ à¦¦à¦¿à¦¤à§‡ à¦¹à¦¬à§‡' : 'Due today';
    }
    if (days == 1) {
      return isBangla
          ? 'à¦†à¦—à¦¾à¦®à§€à¦•à¦¾à¦² à¦¦à¦¿à¦¤à§‡ à¦¹à¦¬à§‡'
          : 'Due tomorrow';
    }
    return isBangla ? '$days à¦¦à¦¿à¦¨à§‡à¦° à¦®à¦§à§à¦¯à§‡' : 'In $days days';
  }

  String dueWithWallet(int days, String walletName) =>
      '${dueLabel(days)} â€¢ $walletName';

  String get topGoalTitle =>
      isBangla ? 'à¦¸à§‡à¦°à¦¾ à¦²à¦•à§à¦·à§à¦¯' : 'Top goal';
  String get noActiveGoalYet => isBangla
      ? 'à¦à¦–à¦¨à¦“ à¦•à§‹à¦¨à§‹ à¦¸à¦•à§à¦°à¦¿à§Ÿ à¦¸à§‡à¦­à¦¿à¦‚à¦¸ à¦²à¦•à§à¦·à§à¦¯ à¦¨à§‡à¦‡à¥¤ à¦à¦•à¦Ÿà¦¿ à¦¬à¦¾à¦¨à¦¾à¦²à§‡ à¦à¦–à¦¾à¦¨à§‡ à¦…à¦—à§à¦°à¦—à¦¤à¦¿ à¦¦à§‡à¦–à¦¾ à¦¯à¦¾à¦¬à§‡à¥¤'
      : 'No active savings goal yet. Create one to see progress here.';

  String daysLeftLabel(int days) {
    if (days < 0) {
      return isBangla
          ? '${days.abs()} à¦¦à¦¿à¦¨ à¦²à¦•à§à¦·à§à¦¯ à¦¸à¦®à§Ÿà§‡à¦° à¦ªà¦°à§‡'
          : 'Past target by ${days.abs()} days';
    }
    return isBangla ? '$days à¦¦à¦¿à¦¨ à¦¬à¦¾à¦•à¦¿' : '$days days left';
  }

  String get historyNeedsAttention => isBangla
      ? 'à¦¹à¦¿à¦¸à§à¦Ÿà¦°à¦¿ à¦²à§‹à¦¡ à¦•à¦°à¦¤à§‡ à¦¸à¦®à¦¸à§à¦¯à¦¾ à¦¹à§Ÿà§‡à¦›à§‡'
      : 'History needs attention';
  String transactionEmptyTitle(bool hasSearch) => hasSearch
      ? (isBangla
            ? 'à¦®à¦¿à¦² à¦ªà¦¾à¦“à§Ÿà¦¾ à¦¯à¦¾à§Ÿà¦¨à¦¿'
            : 'No matching transaction')
      : (isBangla
            ? 'à¦à¦–à¦¨à¦“ à¦•à§‹à¦¨à§‹ à¦²à§‡à¦¨à¦¦à§‡à¦¨ à¦¨à§‡à¦‡'
            : 'No transaction yet');
  String transactionEmptySubtitle(bool hasSearch) => hasSearch
      ? (isBangla
            ? 'à¦¸à¦¾à¦°à§à¦š, à¦¸à¦¾à¦œà¦¾à¦¨à§‹ à¦¬à¦¾ à¦«à¦¿à¦²à§à¦Ÿà¦¾à¦° à¦¬à¦¦à¦²à§‡ à¦†à¦¬à¦¾à¦° à¦šà§‡à¦·à§à¦Ÿà¦¾ à¦•à¦°à§à¦¨à¥¤'
            : 'Try changing the search, sort, or filters to widen the result.')
      : (isBangla
            ? 'à¦ªà§à¦°à¦¥à¦® à¦†à§Ÿ à¦¬à¦¾ à¦¬à§à¦¯à§Ÿà§‡à¦° à¦à¦¨à§à¦Ÿà§à¦°à¦¿ à¦¯à§‹à¦— à¦•à¦°à§à¦¨, à¦¤à¦¾à¦°à¦ªà¦° à¦¹à¦¿à¦¸à§à¦Ÿà¦°à¦¿ à¦¤à§ˆà¦°à¦¿ à¦¹à¦¬à§‡à¥¤'
            : 'Add your first entry and your full history will start building here.');
  String get loadMoreAction =>
      isBangla ? 'à¦†à¦°à¦“ à¦¦à§‡à¦–à§à¦¨' : 'Load more';
  String get endOfHistoryLabel => isBangla
      ? 'à¦†à¦ªà¦¨à¦¾à¦° à¦¹à¦¿à¦¸à§à¦Ÿà¦°à¦¿à¦° à¦¶à§‡à¦· à¦ªà§à¦°à¦¾à¦¨à§à¦¤à§‡ à¦ªà§Œà¦à¦›à§‡ à¦—à§‡à¦›à§‡à¦¨à¥¤'
      : 'You\'ve reached the end of your history.';
  String get deleteTransactionTitle =>
      isBangla ? 'à¦²à§‡à¦¨à¦¦à§‡à¦¨ à¦®à§à¦›à§à¦¨' : 'Delete transaction';
  String get deleteTransactionPrompt => isBangla
      ? 'à¦à¦Ÿà¦¿ à¦®à§à¦›à§‡ à¦—à§‡à¦²à§‡ à¦“à§Ÿà¦¾à¦²à§‡à¦Ÿ à¦¬à§à¦¯à¦¾à¦²à§‡à¦¨à§à¦¸à¦“ à¦¸à¦¾à¦¥à§‡ à¦¸à¦¾à¦¥à§‡ à¦†à¦ªà¦¡à§‡à¦Ÿ à¦¹à¦¬à§‡à¥¤'
      : 'This will remove the transaction and update the wallet balance immediately.';
  String get transactionDeleted => isBangla
      ? 'à¦²à§‡à¦¨à¦¦à§‡à¦¨ à¦®à§à¦›à§‡ à¦«à§‡à¦²à¦¾ à¦¹à§Ÿà§‡à¦›à§‡à¥¤'
      : 'Transaction deleted.';
  String get sortTransactionsTitle =>
      isBangla ? 'à¦²à§‡à¦¨à¦¦à§‡à¦¨ à¦¸à¦¾à¦œà¦¾à¦¨' : 'Sort transactions';
  String get filterByCategoryTitle => isBangla
      ? 'à¦•à§à¦¯à¦¾à¦Ÿà¦¾à¦—à¦°à¦¿ à¦¦à¦¿à§Ÿà§‡ à¦«à¦¿à¦²à§à¦Ÿà¦¾à¦°'
      : 'Filter by category';
  String get filterByWalletTitle => isBangla
      ? 'à¦“à§Ÿà¦¾à¦²à§‡à¦Ÿ à¦¦à¦¿à§Ÿà§‡ à¦«à¦¿à¦²à§à¦Ÿà¦¾à¦°'
      : 'Filter by wallet';
  String get transactionHistoryTitle => isBangla
      ? 'à¦²à§‡à¦¨à¦¦à§‡à¦¨à§‡à¦° à¦¹à¦¿à¦¸à§à¦Ÿà¦°à¦¿'
      : 'Transaction history';
  String resultCountLabel(int count) => isBangla
      ? 'à¦¬à¦°à§à¦¤à¦®à¦¾à¦¨ à¦­à¦¿à¦‰à¦¤à§‡ $countà¦Ÿà¦¿ à¦«à¦²à¦¾à¦«à¦²'
      : '$count result${count == 1 ? '' : 's'} in the current view';
  String get searchNoteAmountHint => isBangla
      ? 'à¦¨à§‹à¦Ÿ à¦¬à¦¾ à¦ªà¦°à¦¿à¦®à¦¾à¦£ à¦¦à¦¿à§Ÿà§‡ à¦–à§à¦à¦œà§à¦¨'
      : 'Search by note or amount';
  String categoryFilterLabel(int count) => count == 0
      ? (isBangla ? 'à¦•à§à¦¯à¦¾à¦Ÿà¦¾à¦—à¦°à¦¿' : 'Category')
      : (isBangla
            ? 'à¦•à§à¦¯à¦¾à¦Ÿà¦¾à¦—à¦°à¦¿ ($count)'
            : 'Category ($count)');
  String walletFilterLabel(int count) => count == 0
      ? (isBangla ? 'à¦“à§Ÿà¦¾à¦²à§‡à¦Ÿ' : 'Wallet')
      : (isBangla ? 'à¦“à§Ÿà¦¾à¦²à§‡à¦Ÿ ($count)' : 'Wallet ($count)');
  String get dateRangeLabel =>
      isBangla ? 'à¦¤à¦¾à¦°à¦¿à¦– à¦¸à§€à¦®à¦¾' : 'Date range';
  String get dateRangeSetLabel =>
      isBangla ? 'à¦¤à¦¾à¦°à¦¿à¦– à¦¸à§€à¦®à¦¾ à¦¸à§‡à¦Ÿ' : 'Date range set';
  String get topSpendingCategoryTitle => isBangla
      ? 'à¦¸à¦¬à¦šà§‡à§Ÿà§‡ à¦¬à§‡à¦¶à¦¿ à¦–à¦°à¦šà§‡à¦° à¦•à§à¦¯à¦¾à¦Ÿà¦¾à¦—à¦°à¦¿'
      : 'Top spending category';
  String get reportsIncomeVsExpenseTitle =>
      isBangla ? 'à¦†à§Ÿ à¦¬à¦¨à¦¾à¦® à¦¬à§à¦¯à§Ÿ' : 'Income vs expense';
  String get reportsCategoryBreakdownTitle => isBangla
      ? 'à¦•à§à¦¯à¦¾à¦Ÿà¦¾à¦—à¦°à¦¿ à¦¬à¦¿à¦¶à§à¦²à§‡à¦·à¦£'
      : 'Category breakdown';
  String get totalIncomeLabel => isBangla ? 'à¦®à§‹à¦Ÿ à¦†à§Ÿ' : 'Total income';
  String get reportTitle => isBangla
      ? 'à¦†à¦°à§à¦¥à¦¿à¦• à¦°à¦¿à¦ªà§‹à¦°à§à¦Ÿ'
      : 'Financial report';
  String get totalExpenseLabel =>
      isBangla ? 'à¦®à§‹à¦Ÿ à¦¬à§à¦¯à§Ÿ' : 'Total expense';
  String get netBalanceLabel =>
      isBangla ? 'à¦¨à§‡à¦Ÿ à¦¬à§à¦¯à¦¾à¦²à§‡à¦¨à§à¦¸' : 'Net balance';
  String get topCategoryLabel =>
      isBangla ? 'à¦¸à§‡à¦°à¦¾ à¦•à§à¦¯à¦¾à¦Ÿà¦¾à¦—à¦°à¦¿' : 'Top category';
  String get reportsLoadingTitle => isBangla
      ? 'à¦°à¦¿à¦ªà§‹à¦°à§à¦Ÿ à¦²à§‹à¦¡ à¦¹à¦šà§à¦›à§‡'
      : 'Reports are loading';
  String get noTopCategoryYet => isBangla
      ? 'à¦à¦–à¦¨à¦“ à¦¸à§‡à¦°à¦¾ à¦•à§à¦¯à¦¾à¦Ÿà¦¾à¦—à¦°à¦¿ à¦¨à§‡à¦‡'
      : 'No top category yet';

  String analyticsPeriodLabel(String key) {
    switch (key) {
      case 'weekly':
        return isBangla ? 'à¦à¦‡ à¦¸à¦ªà§à¦¤à¦¾à¦¹' : 'This Week';
      case 'monthly':
        return isBangla ? 'à¦à¦‡ à¦®à¦¾à¦¸' : 'This Month';
      case 'yearly':
        return isBangla ? 'à¦à¦‡ à¦¬à¦›à¦°' : 'This Year';
      default:
        return key;
    }
  }

  String averageExpenseLabel(String key) {
    if (key == 'yearly') {
      return isBangla
          ? 'à¦—à§œ à¦®à¦¾à¦¸à¦¿à¦• à¦¬à§à¦¯à§Ÿ'
          : 'Avg monthly expense';
    }
    return isBangla
        ? 'à¦—à§œ à¦¦à§ˆà¦¨à¦¿à¦• à¦¬à§à¦¯à§Ÿ'
        : 'Avg daily expense';
  }

  String peakExpenseLabel(String key) {
    if (key == 'yearly') {
      return isBangla
          ? 'à¦¸à¦°à§à¦¬à§‹à¦šà§à¦š à¦¬à§à¦¯à§Ÿà§‡à¦° à¦®à¦¾à¦¸'
          : 'Highest spending month';
    }
    return isBangla
        ? 'à¦¸à¦°à§à¦¬à§‹à¦šà§à¦š à¦¬à§à¦¯à§Ÿà§‡à¦° à¦¦à¦¿à¦¨'
        : 'Highest spending day';
  }

  String get budgetPulseTitle =>
      isBangla ? 'à¦¬à¦¾à¦œà§‡à¦Ÿ à¦…à¦¬à¦¸à§à¦¥à¦¾' : 'Budget pulse';
  String get spentLabel => isBangla ? 'à¦–à¦°à¦š' : 'Spent';
  String get limitLabel => isBangla ? 'à¦¸à§€à¦®à¦¾' : 'Limit';
  String get activeBudgetsLabel =>
      isBangla ? 'à¦¸à¦•à§à¦°à¦¿à§Ÿ à¦¬à¦¾à¦œà§‡à¦Ÿ' : 'Active budgets';
  String get monthlyProgressLabel =>
      isBangla ? 'à¦®à¦¾à¦¸à¦¿à¦• à¦…à¦—à§à¦°à¦—à¦¤à¦¿' : 'Monthly progress';
  String get notSetLabel => isBangla ? 'à¦¸à§‡à¦Ÿ à¦¨à§Ÿ' : 'Not set';
  String budgetAlertsTitle(bool hasExceeded) => hasExceeded
      ? (isBangla ? 'à¦¬à¦¾à¦œà§‡à¦Ÿ à¦¸à¦¤à¦°à§à¦•à¦¤à¦¾' : 'Budget alerts')
      : (isBangla
            ? 'à¦¬à¦¾à¦œà§‡à¦Ÿ à¦¸à¦¤à¦°à§à¦•à¦¬à¦¾à¦°à§à¦¤à¦¾'
            : 'Budget warnings');
  String categoryExceededLabel(String category, String amount) => isBangla
      ? '$category à¦¸à§€à¦®à¦¾à¦° $amount à¦¬à§‡à¦¶à¦¿ à¦¹à§Ÿà§‡ à¦—à§‡à¦›à§‡à¥¤'
      : '$category exceeded by $amount.';
  String categoryNearLimitLabel(String category, int percent) => isBangla
      ? '$category à¦¤à¦¾à¦° à¦¸à§€à¦®à¦¾à¦° $percent% à¦ à¦ªà§Œà¦à¦›à§‡à¦›à§‡à¥¤'
      : '$category is at $percent% of its limit.';
  String get recentTransactionsTitle => isBangla
      ? 'à¦¸à¦¾à¦®à§à¦ªà§à¦°à¦¤à¦¿à¦• à¦²à§‡à¦¨à¦¦à§‡à¦¨'
      : 'Recent transactions';
  String get noTransactionsYetTitle => isBangla
      ? 'à¦à¦–à¦¨à¦“ à¦•à§‹à¦¨à§‹ à¦²à§‡à¦¨à¦¦à§‡à¦¨ à¦¨à§‡à¦‡'
      : 'No transactions yet';
  String get noTransactionsYetSubtitle => isBangla
      ? 'à¦…à§à¦¯à¦¾à¦¡ à¦¬à¦¾à¦Ÿà¦¨ à¦¬à§à¦¯à¦¬à¦¹à¦¾à¦° à¦•à¦°à§‡ à¦ªà§à¦°à¦¥à¦® à¦†à§Ÿ à¦¬à¦¾ à¦¬à§à¦¯à§Ÿà§‡à¦° à¦à¦¨à§à¦Ÿà§à¦°à¦¿ à¦¦à¦¿à¦¨à¥¤'
      : 'Use the add button to save your first expense or income entry.';
  String get todaysPulseTitle =>
      isBangla ? 'à¦†à¦œà¦•à§‡à¦° à¦¸à¦¾à¦°à¦¾à¦‚à¦¶' : 'Today\'s pulse';
  String get homeLiveSubtitle => isBangla
      ? 'à¦¹à§‹à¦® à¦¸à§à¦•à§à¦°à¦¿à¦¨ à¦à¦–à¦¨ Firestore-à¦à¦° à¦²à¦¾à¦‡à¦­ à¦²à§‡à¦¨à¦¦à§‡à¦¨ à¦¦à§‡à¦–à¦¾à§Ÿà¥¤'
      : 'Your home screen now reflects live transaction data from Firestore.';
  String get incomeVsExpenseLabel =>
      isBangla ? 'à¦†à§Ÿ à¦¬à¦¨à¦¾à¦® à¦¬à§à¦¯à§Ÿ' : 'Income vs expense';
  String get todayNetLabel =>
      isBangla ? 'à¦†à¦œà¦•à§‡à¦° à¦¨à§‡à¦Ÿ' : 'Today net';
  String get monthNetLabel =>
      isBangla ? 'à¦®à¦¾à¦¸à§‡à¦° à¦¨à§‡à¦Ÿ' : 'Month net';
  String get recentItemsLabel => isBangla
      ? 'à¦¸à¦¾à¦®à§à¦ªà§à¦°à¦¤à¦¿à¦• à¦†à¦‡à¦Ÿà§‡à¦®'
      : 'Recent items';

  String transactionEditorTitle(bool isEditing) => isEditing
      ? (isBangla
            ? 'à¦²à§‡à¦¨à¦¦à§‡à¦¨ à¦¸à¦®à§à¦ªà¦¾à¦¦à¦¨à¦¾'
            : 'Edit transaction')
      : (isBangla
            ? 'à¦²à§‡à¦¨à¦¦à§‡à¦¨ à¦¯à§‹à¦— à¦•à¦°à§à¦¨'
            : 'Add transaction');
  String get transactionEditorSubtitle => isBangla
      ? 'à¦à¦•à¦Ÿà¦¿ à¦²à§‡à¦¨à¦¦à§‡à¦¨ à¦¤à§ˆà¦°à¦¿ à¦•à¦°à§à¦¨ à¦¬à¦¾ à¦†à¦ªà¦¡à§‡à¦Ÿ à¦•à¦°à§à¦¨'
      : 'Create or update a transaction';
  String get formBadge => isBangla ? 'à¦«à¦°à§à¦®' : 'Form';
  String get typeLabel => isBangla ? 'à¦§à¦°à¦¨' : 'Type';
  String get amountFieldLabel => isBangla ? 'à¦ªà¦°à¦¿à¦®à¦¾à¦£' : 'Amount';
  String get walletFieldLabel => isBangla ? 'à¦“à§Ÿà¦¾à¦²à§‡à¦Ÿ' : 'Wallet';
  String get categoryFieldLabel =>
      isBangla ? 'à¦•à§à¦¯à¦¾à¦Ÿà¦¾à¦—à¦°à¦¿' : 'Category';
  String get newCategoryAction =>
      isBangla ? 'à¦¨à¦¤à§à¦¨ à¦•à§à¦¯à¦¾à¦Ÿà¦¾à¦—à¦°à¦¿' : 'New category';
  String get dateFieldLabel => isBangla ? 'à¦¤à¦¾à¦°à¦¿à¦–' : 'Date';
  String get noteFieldLabel => isBangla ? 'à¦¨à§‹à¦Ÿ' : 'Note';
  String get optionalTransactionNoteHint => isBangla
      ? 'à¦à¦‡ à¦²à§‡à¦¨à¦¦à§‡à¦¨ à¦¸à¦®à§à¦ªà¦°à§à¦•à§‡ à¦à¦šà§à¦›à¦¿à¦• à¦¨à§‹à¦Ÿ'
      : 'Optional note about this transaction';
  String get noWalletYetTitle => isBangla
      ? 'à¦à¦–à¦¨à¦“ à¦•à§‹à¦¨à§‹ à¦“à§Ÿà¦¾à¦²à§‡à¦Ÿ à¦¨à§‡à¦‡'
      : 'No wallet yet';
  String get noWalletYetSubtitle => isBangla
      ? 'à¦¸à§à¦Ÿà¦¾à¦°à§à¦Ÿà¦¾à¦° à¦¡à¦¾à¦Ÿà¦¾ à¦à¦–à¦¨à¦“ à¦²à§‹à¦¡ à¦¹à¦šà§à¦›à§‡à¥¤ à¦à¦•à¦Ÿà§ à¦ªà¦°à§‡ à¦†à¦¬à¦¾à¦° à¦–à§à¦²à§à¦¨à¥¤'
      : 'Starter data is still loading. Reopen this sheet in a moment.';
  String get noCategoryAvailableTitle => isBangla
      ? 'à¦•à§‹à¦¨à§‹ à¦•à§à¦¯à¦¾à¦Ÿà¦¾à¦—à¦°à¦¿ à¦¨à§‡à¦‡'
      : 'No category available';
  String get noCategoryAvailableSubtitle => isBangla
      ? 'à¦¸à§à¦Ÿà¦¾à¦°à§à¦Ÿà¦¾à¦° à¦•à§à¦¯à¦¾à¦Ÿà¦¾à¦—à¦°à¦¿ à¦à¦–à¦¨à¦“ à¦¸à¦¿à¦™à§à¦• à¦¹à¦šà§à¦›à§‡à¥¤ à¦šà¦¾à¦‡à¦²à§‡ à¦à¦–à¦¨à¦‡ à¦à¦•à¦Ÿà¦¿ à¦¬à¦¾à¦¨à¦¾à¦¤à§‡ à¦ªà¦¾à¦°à§‡à¦¨à¥¤'
      : 'Starter categories are still syncing. You can also create one right now.';
  String get starterDataSyncingHint => isBangla
      ? 'à¦¸à§à¦Ÿà¦¾à¦°à§à¦Ÿà¦¾à¦° à¦¡à¦¾à¦Ÿà¦¾ à¦¸à¦¿à¦™à§à¦• à¦¶à§‡à¦· à¦¨à¦¾ à¦¹à¦²à§‡à¦“ à¦†à¦ªà¦¨à¦¿ à¦à¦–à¦¾à¦¨à§‡ à¦¥à¦¾à¦•à¦¤à§‡ à¦ªà¦¾à¦°à§‡à¦¨à¥¤'
      : 'You can still stay here while starter data finishes syncing.';
  String get saveTransactionAction =>
      isBangla ? 'à¦¸à¦‚à¦°à¦•à§à¦·à¦£ à¦•à¦°à§à¦¨' : 'Save';
  String get updateTransactionAction =>
      isBangla ? 'à¦†à¦ªà¦¡à§‡à¦Ÿ à¦•à¦°à§à¦¨' : 'Update';
  String get validAmountError => isBangla
      ? 'à§¦ à¦à¦° à¦¬à§‡à¦¶à¦¿ à¦à¦•à¦Ÿà¦¿ à¦¸à¦ à¦¿à¦• à¦ªà¦°à¦¿à¦®à¦¾à¦£ à¦¦à¦¿à¦¨à¥¤'
      : 'Enter a valid amount greater than 0.';
  String get chooseWalletError => isBangla
      ? 'à¦¸à¦‚à¦°à¦•à§à¦·à¦£à§‡à¦° à¦†à¦—à§‡ à¦à¦•à¦Ÿà¦¿ à¦“à§Ÿà¦¾à¦²à§‡à¦Ÿ à¦¬à§‡à¦›à§‡ à¦¨à¦¿à¦¨à¥¤'
      : 'Choose a wallet before saving.';
  String get chooseCategoryError => isBangla
      ? 'à¦¸à¦‚à¦°à¦•à§à¦·à¦£à§‡à¦° à¦†à¦—à§‡ à¦à¦•à¦Ÿà¦¿ à¦•à§à¦¯à¦¾à¦Ÿà¦¾à¦—à¦°à¦¿ à¦¬à§‡à¦›à§‡ à¦¨à¦¿à¦¨à¥¤'
      : 'Choose a category before saving.';
  String get transactionSaved => isBangla
      ? 'à¦²à§‡à¦¨à¦¦à§‡à¦¨ à¦¸à¦‚à¦°à¦•à§à¦·à¦£ à¦¹à§Ÿà§‡à¦›à§‡à¥¤'
      : 'Transaction saved.';
  String get transactionUpdated => isBangla
      ? 'à¦²à§‡à¦¨à¦¦à§‡à¦¨ à¦†à¦ªà¦¡à§‡à¦Ÿ à¦¹à§Ÿà§‡à¦›à§‡à¥¤'
      : 'Transaction updated.';
  String get deleteCategoryTitle => isBangla
      ? 'à¦•à§à¦¯à¦¾à¦Ÿà¦¾à¦—à¦°à¦¿ à¦®à§à¦›à§à¦¨'
      : 'Delete category';
  String deleteCategoryPrompt(String name) => isBangla
      ? '"$name" à¦®à§à¦›à¦¬à§‡à¦¨? à¦ªà§à¦°à§‹à¦¨à§‹ à¦²à§‡à¦¨à¦¦à§‡à¦¨à¦—à§à¦²à§‹ à¦†à¦—à§‡à¦° à¦•à§à¦¯à¦¾à¦Ÿà¦¾à¦—à¦°à¦¿ à¦†à¦‡à¦¡à¦¿ à¦°à§‡à¦–à§‡à¦‡ à¦¥à¦¾à¦•à¦¬à§‡à¥¤'
      : 'Delete "$name"? Existing transactions will still keep the old category id, so only remove categories you no longer need.';
  String get categoryDeleted => isBangla
      ? 'à¦•à§à¦¯à¦¾à¦Ÿà¦¾à¦—à¦°à¦¿ à¦®à§à¦›à§‡ à¦«à§‡à¦²à¦¾ à¦¹à§Ÿà§‡à¦›à§‡à¥¤'
      : 'Category deleted.';
  String createCategoryTitle(String typeLabel) => isBangla
      ? '$typeLabel à¦•à§à¦¯à¦¾à¦Ÿà¦¾à¦—à¦°à¦¿ à¦¤à§ˆà¦°à¦¿ à¦•à¦°à§à¦¨'
      : 'Create $typeLabel category';
  String get categoryAutoSelectHint => isBangla
      ? 'à¦¸à¦‚à¦°à¦•à§à¦·à¦£ à¦•à¦°à¦¾à¦° à¦ªà¦° à¦¨à¦¤à§à¦¨ à¦•à§à¦¯à¦¾à¦Ÿà¦¾à¦—à¦°à¦¿à¦Ÿà¦¿ à¦¨à¦¿à¦œà§‡ à¦¥à§‡à¦•à§‡à¦‡ à¦¬à§‡à¦›à§‡ à¦¨à§‡à¦“à§Ÿà¦¾ à¦¹à¦¬à§‡à¥¤'
      : 'The new category will be selected automatically after you save it.';
  String get createWithLabel =>
      isBangla ? 'à¦¤à§ˆà¦°à¦¿à¦° à¦§à¦°à¦¨' : 'Create with';
  String get templateLabel =>
      isBangla ? 'à¦Ÿà§‡à¦®à¦ªà§à¦²à§‡à¦Ÿ' : 'Template';
  String get manualLabel => isBangla ? 'à¦®à§à¦¯à¦¾à¦¨à§à§Ÿà¦¾à¦²' : 'Manual';
  String get categoryTemplateLabel => isBangla
      ? 'à¦•à§à¦¯à¦¾à¦Ÿà¦¾à¦—à¦°à¦¿ à¦Ÿà§‡à¦®à¦ªà§à¦²à§‡à¦Ÿ'
      : 'Template';
  String get categoryNameLabel =>
      isBangla ? 'à¦•à§à¦¯à¦¾à¦Ÿà¦¾à¦—à¦°à¦¿à¦° à¦¨à¦¾à¦®' : 'Category name';
  String get categoryNameHint => isBangla
      ? 'à¦‡à¦‚à¦°à§‡à¦œà¦¿ à¦¬à¦¾ à¦¬à¦¾à¦‚à¦²à¦¾ à¦²à¦¿à¦–à§à¦¨'
      : 'Write in English or Bangla';
  String get categoryNameHelper => isBangla
      ? 'à¦¸à¦®à§à¦­à¦¬ à¦¹à¦²à§‡ à¦†à¦®à¦°à¦¾ à¦¬à¦¿à¦ªà¦°à§€à¦¤ à¦­à¦¾à¦·à¦¾à¦Ÿà¦¿à¦“ à¦¸à§à¦¬à§Ÿà¦‚à¦•à§à¦°à¦¿à§Ÿà¦­à¦¾à¦¬à§‡ à¦ªà§‚à¦°à¦£ à¦•à¦°à¦¬à¥¤'
      : 'We will fill the opposite language automatically when possible.';
  String get chooseTemplateFirstError => isBangla
      ? 'à¦†à¦—à§‡ à¦à¦•à¦Ÿà¦¿ à¦Ÿà§‡à¦®à¦ªà§à¦²à§‡à¦Ÿ à¦¬à§‡à¦›à§‡ à¦¨à¦¿à¦¨à¥¤'
      : 'Choose a template first.';
  String get writeCategoryNameError => isBangla
      ? 'à¦‡à¦‚à¦°à§‡à¦œà¦¿ à¦¬à¦¾ à¦¬à¦¾à¦‚à¦²à¦¾à§Ÿ à¦à¦•à¦Ÿà¦¿ à¦•à§à¦¯à¦¾à¦Ÿà¦¾à¦—à¦°à¦¿à¦° à¦¨à¦¾à¦® à¦²à¦¿à¦–à§à¦¨à¥¤'
      : 'Write a category name in English or Bangla.';
  String get createCategoryAction => isBangla
      ? 'à¦•à§à¦¯à¦¾à¦Ÿà¦¾à¦—à¦°à¦¿ à¦¤à§ˆà¦°à¦¿ à¦•à¦°à§à¦¨'
      : 'Create category';
  String get useTemplateAction => isBangla
      ? 'à¦Ÿà§‡à¦®à¦ªà§à¦²à§‡à¦Ÿ à¦¬à§à¦¯à¦¬à¦¹à¦¾à¦° à¦•à¦°à§à¦¨'
      : 'Use template';
  String get chooseIconLabel =>
      isBangla ? 'à¦†à¦‡à¦•à¦¨ à¦¬à§‡à¦›à§‡ à¦¨à¦¿à¦¨' : 'Choose icon';
  String get chooseColorLabel =>
      isBangla ? 'à¦°à¦‚ à¦¬à§‡à¦›à§‡ à¦¨à¦¿à¦¨' : 'Choose color';
  String get manualCategorySubtitle => isBangla
      ? 'à¦®à§à¦¯à¦¾à¦¨à§à§Ÿà¦¾à¦² à¦•à§à¦¯à¦¾à¦Ÿà¦¾à¦—à¦°à¦¿'
      : 'Manual category';
  String get categoryPreviewTitle => isBangla
      ? 'à¦•à§à¦¯à¦¾à¦Ÿà¦¾à¦—à¦°à¦¿ à¦ªà§à¦°à¦¿à¦­à¦¿à¦‰'
      : 'Category preview';
  String get alreadyAvailableTitle =>
      isBangla ? 'à¦‡à¦¤à¦¿à¦®à¦§à§à¦¯à§‡à¦‡ à¦†à¦›à§‡' : 'Already available';
  String get quickCreateTitle =>
      isBangla ? 'à¦¦à§à¦°à§à¦¤ à¦¤à§ˆà¦°à¦¿' : 'Quick create';
  String get templateExistsSubtitle => isBangla
      ? 'à¦à¦‡ à¦Ÿà§‡à¦®à¦ªà§à¦²à§‡à¦Ÿà¦Ÿà¦¿ à¦†à¦—à§‡ à¦¥à§‡à¦•à§‡à¦‡ à¦†à¦›à§‡à¥¤ à¦¸à¦‚à¦°à¦•à§à¦·à¦£ à¦•à¦°à¦²à§‡ à¦¶à§à¦§à§ à¦à¦Ÿà¦¿ à¦¨à¦¿à¦°à§à¦¬à¦¾à¦šà¦¨ à¦¹à¦¬à§‡à¥¤'
      : 'This template already exists. Saving will just select it.';
  String get templateReadySubtitle => isBangla
      ? 'à¦¦à§à¦°à§à¦¤ à¦à¦¨à§à¦Ÿà§à¦°à¦¿à¦° à¦œà¦¨à§à¦¯ à¦à¦‡ à¦Ÿà§‡à¦®à¦ªà§à¦²à§‡à¦Ÿà¦Ÿà¦¿ à¦¸à¦™à§à¦—à§‡ à¦¸à¦™à§à¦—à§‡ à¦¤à§ˆà¦°à¦¿ à¦•à¦°à¦¾ à¦¯à¦¾à¦¬à§‡à¥¤'
      : 'This template is ready to create instantly for faster entry.';

  String get budgetsTitleText => isBangla ? 'à¦¬à¦¾à¦œà§‡à¦Ÿ' : 'Budgets';
  String get categoryBudgetsTitle => isBangla
      ? 'à¦•à§à¦¯à¦¾à¦Ÿà¦¾à¦—à¦°à¦¿ à¦¬à¦¾à¦œà§‡à¦Ÿ'
      : 'Category budgets';
  String get addBudgetAction =>
      isBangla ? 'à¦¬à¦¾à¦œà§‡à¦Ÿ à¦¯à§‹à¦— à¦•à¦°à§à¦¨' : 'Add budget';
  String get deleteBudgetTitle =>
      isBangla ? 'à¦¬à¦¾à¦œà§‡à¦Ÿ à¦®à§à¦›à§à¦¨' : 'Delete budget';
  String get deleteBudgetPrompt => isBangla
      ? 'à¦à¦‡ à¦¬à¦¾à¦œà§‡à¦Ÿ à¦¸à§€à¦®à¦¾ à¦®à§à¦›à¦¬à§‡à¦¨?'
      : 'Delete this budget limit?';
  String get budgetDeleted => isBangla
      ? 'à¦¬à¦¾à¦œà§‡à¦Ÿ à¦®à§à¦›à§‡ à¦«à§‡à¦²à¦¾ à¦¹à§Ÿà§‡à¦›à§‡à¥¤'
      : 'Budget deleted.';
  String get overallSpendingLabel =>
      isBangla ? 'à¦®à§‹à¦Ÿ à¦–à¦°à¦š' : 'Overall spending';
  String budgetEditorTitle(bool isEditing) => isEditing
      ? (isBangla ? 'à¦¬à¦¾à¦œà§‡à¦Ÿ à¦¸à¦®à§à¦ªà¦¾à¦¦à¦¨à¦¾' : 'Edit budget')
      : (isBangla ? 'à¦¬à¦¾à¦œà§‡à¦Ÿ à¦¯à§‹à¦— à¦•à¦°à§à¦¨' : 'Add budget');
  String get overallSpendingBudgetTitle => isBangla
      ? 'à¦®à§‹à¦Ÿ à¦–à¦°à¦šà§‡à¦° à¦¬à¦¾à¦œà§‡à¦Ÿ'
      : 'Overall spending budget';
  String get categoryBudgetTitle => isBangla
      ? 'à¦•à§à¦¯à¦¾à¦Ÿà¦¾à¦—à¦°à¦¿ à¦¬à¦¾à¦œà§‡à¦Ÿ'
      : 'Category budget';
  String get budgetsAutoUpdateSubtitle => isBangla
      ? 'à¦¸à¦®à§à¦ªà¦°à§à¦•à¦¿à¦¤ à¦¬à§à¦¯à§Ÿ à¦¬à¦¦à¦²à¦¾à¦²à§‡ à¦¬à¦¾à¦œà§‡à¦Ÿà§‡à¦° à¦–à¦°à¦š à¦¸à§à¦¬à§Ÿà¦‚à¦•à§à¦°à¦¿à§Ÿà¦­à¦¾à¦¬à§‡ à¦†à¦ªà¦¡à§‡à¦Ÿ à¦¹à¦¬à§‡à¥¤'
      : 'Budgets update their spent amount automatically whenever related expenses change.';
  String get budgetTypeLabel =>
      isBangla ? 'à¦¬à¦¾à¦œà§‡à¦Ÿà§‡à¦° à¦§à¦°à¦¨' : 'Budget type';
  String get budgetLimitLabel =>
      isBangla ? 'à¦¬à¦¾à¦œà§‡à¦Ÿ à¦¸à§€à¦®à¦¾' : 'Budget limit';
  String get updateBudgetAction => isBangla
      ? 'à¦¬à¦¾à¦œà§‡à¦Ÿ à¦†à¦ªà¦¡à§‡à¦Ÿ à¦•à¦°à§à¦¨'
      : 'Update budget';
  String get createBudgetAction =>
      isBangla ? 'à¦¬à¦¾à¦œà§‡à¦Ÿ à¦¤à§ˆà¦°à¦¿ à¦•à¦°à§à¦¨' : 'Create budget';
  String get validBudgetLimitError => isBangla
      ? 'à¦à¦•à¦Ÿà¦¿ à¦¸à¦ à¦¿à¦• à¦¬à¦¾à¦œà§‡à¦Ÿ à¦¸à§€à¦®à¦¾ à¦¦à¦¿à¦¨à¥¤'
      : 'Enter a valid budget limit.';
  String get budgetUpdated => isBangla
      ? 'à¦¬à¦¾à¦œà§‡à¦Ÿ à¦†à¦ªà¦¡à§‡à¦Ÿ à¦¹à§Ÿà§‡à¦›à§‡à¥¤'
      : 'Budget updated.';
  String get budgetCreated => isBangla
      ? 'à¦¬à¦¾à¦œà§‡à¦Ÿ à¦¤à§ˆà¦°à¦¿ à¦¹à§Ÿà§‡à¦›à§‡à¥¤'
      : 'Budget created.';
  String get overallMonthlyLimitLabel => isBangla
      ? 'à¦®à§‹à¦Ÿ à¦®à¦¾à¦¸à¦¿à¦• à¦¸à§€à¦®à¦¾'
      : 'Overall monthly limit';
  String get categoryBudgetTotalLabel => isBangla
      ? 'à¦•à§à¦¯à¦¾à¦Ÿà¦¾à¦—à¦°à¦¿ à¦¬à¦¾à¦œà§‡à¦Ÿ à¦®à§‹à¦Ÿ'
      : 'Category budget total';
  String percentUsedLabel(int percent) => isBangla
      ? '$percent% à¦¬à§à¦¯à¦¬à¦¹à¦¾à¦° à¦¹à§Ÿà§‡à¦›à§‡'
      : '$percent% used';
  String get exceededLabel =>
      isBangla ? 'à¦¸à§€à¦®à¦¾ à¦›à¦¾à§œà¦¿à§Ÿà§‡à¦›à§‡' : 'Exceeded';
  String get warningLabel => isBangla ? 'à¦¸à¦¤à¦°à§à¦•à¦¤à¦¾' : 'Warning';
  String get onTrackLabel => isBangla ? 'à¦¸à¦ à¦¿à¦• à¦ªà¦¥à§‡' : 'On track';
  String get noBudgetsYetTitle => isBangla
      ? 'à¦à¦–à¦¨à¦“ à¦•à§‹à¦¨à§‹ à¦¬à¦¾à¦œà§‡à¦Ÿ à¦¨à§‡à¦‡'
      : 'No budgets yet';
  String get noBudgetsYetSubtitle => isBangla
      ? 'à¦à¦‡ à¦®à¦¾à¦¸à§‡à¦° à¦œà¦¨à§à¦¯ à¦®à§‹à¦Ÿ à¦¬à¦¾ à¦•à§à¦¯à¦¾à¦Ÿà¦¾à¦—à¦°à¦¿ à¦¬à¦¾à¦œà§‡à¦Ÿ à¦¸à§‡à¦Ÿ à¦•à¦°à§à¦¨à¥¤'
      : 'Set an overall or category budget for this month to start tracking spending progress.';

  String get goalsTitleText => isBangla ? 'à¦²à¦•à§à¦·à§à¦¯' : 'Goals';
  String get activeGoalsTitle =>
      isBangla ? 'à¦¸à¦•à§à¦°à¦¿à§Ÿ à¦²à¦•à§à¦·à§à¦¯' : 'Active goals';
  String get addGoalAction =>
      isBangla ? 'à¦²à¦•à§à¦·à§à¦¯ à¦¯à§‹à¦— à¦•à¦°à§à¦¨' : 'Add goal';
  String get noActiveGoalTitle => isBangla
      ? 'à¦à¦–à¦¨à¦“ à¦•à§‹à¦¨à§‹ à¦¸à¦•à§à¦°à¦¿à§Ÿ à¦²à¦•à§à¦·à§à¦¯ à¦¨à§‡à¦‡'
      : 'No active goal yet';
  String get noActiveGoalSubtitle => isBangla
      ? 'à¦‡à¦®à¦¾à¦°à§à¦œà§‡à¦¨à§à¦¸à¦¿ à¦«à¦¾à¦¨à§à¦¡, à¦­à§à¦°à¦®à¦£, à¦¨à¦¤à§à¦¨ à¦¡à¦¿à¦­à¦¾à¦‡à¦¸ à¦¬à¦¾ à¦¯à§‡à¦•à§‹à¦¨à§‹ à¦•à¦¿à¦›à§à¦° à¦œà¦¨à§à¦¯ à¦²à¦•à§à¦·à§à¦¯ à¦¬à¦¾à¦¨à¦¾à¦¨à¥¤'
      : 'Create a goal for emergency savings, a trip, a new device, or anything you want to save for.';
  String completedGoalsTitle(int count) => isBangla
      ? 'à¦¸à¦®à§à¦ªà¦¨à§à¦¨ à¦²à¦•à§à¦·à§à¦¯ ($count)'
      : 'Completed goals ($count)';
  String get deleteGoalTitle =>
      isBangla ? 'à¦²à¦•à§à¦·à§à¦¯ à¦®à§à¦›à§à¦¨' : 'Delete goal';
  String get deleteSavingsGoalPrompt => isBangla
      ? 'à¦à¦‡ à¦¸à§‡à¦­à¦¿à¦‚à¦¸ à¦²à¦•à§à¦·à§à¦¯ à¦®à§à¦›à¦¬à§‡à¦¨?'
      : 'Delete this savings goal?';
  String get goalDeleted => isBangla
      ? 'à¦²à¦•à§à¦·à§à¦¯ à¦®à§à¦›à§‡ à¦«à§‡à¦²à¦¾ à¦¹à§Ÿà§‡à¦›à§‡à¥¤'
      : 'Goal deleted.';
  String get savingsGoalsTitle =>
      isBangla ? 'à¦¸à§‡à¦­à¦¿à¦‚à¦¸ à¦²à¦•à§à¦·à§à¦¯' : 'Savings goals';
  String savingsGoalsSubtitle(String? topGoalName) => topGoalName == null
      ? (isBangla
            ? 'à¦¯à§‡ à¦œà¦¿à¦¨à¦¿à¦¸à¦—à§à¦²à§‹à¦° à¦œà¦¨à§à¦¯ à¦¸à¦žà§à¦šà§Ÿ à¦•à¦°à¦¤à§‡ à¦šà¦¾à¦¨ à¦¸à§‡à¦—à§à¦²à§‹à¦° à¦²à¦•à§à¦·à§à¦¯ à¦¬à¦¾à¦¨à¦¾à¦¨ à¦à¦¬à¦‚ à¦…à¦—à§à¦°à¦—à¦¤à¦¿ à¦¦à§ƒà¦¶à§à¦¯à¦®à¦¾à¦¨ à¦°à¦¾à¦–à§à¦¨à¥¤'
            : 'Create goals for the things you want to save toward and keep your progress visible.')
      : (isBangla
            ? 'à¦¶à§€à¦°à§à¦· à¦¸à¦•à§à¦°à¦¿à§Ÿ à¦²à¦•à§à¦·à§à¦¯: $topGoalName'
            : 'Top active goal: $topGoalName');
  String goalSavedOf(String saved, String target) => isBangla
      ? '$saved à¦¸à§‡à¦­ à¦¹à§Ÿà§‡à¦›à§‡, à¦²à¦•à§à¦·à§à¦¯ $target'
      : '$saved of $target saved';
  String get completedStatus =>
      isBangla ? 'à¦¸à¦®à§à¦ªà¦¨à§à¦¨' : 'Completed';
  String get contributeAction =>
      isBangla ? 'à¦…à¦¬à¦¦à¦¾à¦¨ à¦¦à¦¿à¦¨' : 'Contribute';
  String goalTargetSummary(String amount, String date) => isBangla
      ? 'à¦²à¦•à§à¦·à§à¦¯ $amount â€¢ $date'
      : 'Target $amount â€¢ $date';
  String goalEditorTitle(bool isEditing) => isEditing
      ? (isBangla ? 'à¦²à¦•à§à¦·à§à¦¯ à¦¸à¦®à§à¦ªà¦¾à¦¦à¦¨à¦¾' : 'Edit goal')
      : (isBangla ? 'à¦²à¦•à§à¦·à§à¦¯ à¦¯à§‹à¦— à¦•à¦°à§à¦¨' : 'Add goal');
  String goalHeaderSubtitle(bool isEditing) => isEditing
      ? (isBangla
            ? 'à¦†à¦ªà¦¨à¦¾à¦° à¦¸à§‡à¦­à¦¿à¦‚à¦¸ à¦²à¦•à§à¦·à§à¦¯ à¦†à¦ªà¦¡à§‡à¦Ÿ à¦•à¦°à§à¦¨'
            : 'Update your savings target')
      : (isBangla
            ? 'à¦¨à¦¤à§à¦¨ à¦à¦•à¦Ÿà¦¿ à¦¸à§‡à¦­à¦¿à¦‚à¦¸ à¦²à¦•à§à¦·à§à¦¯ à¦¤à§ˆà¦°à¦¿ à¦•à¦°à§à¦¨'
            : 'Create a new savings target');
  String get goalNameLabel =>
      isBangla ? 'à¦²à¦•à§à¦·à§à¦¯à§‡à¦° à¦¨à¦¾à¦®' : 'Goal name';
  String get goalNameHint => isBangla
      ? 'à¦‡à¦®à¦¾à¦°à§à¦œà§‡à¦¨à§à¦¸à¦¿ à¦«à¦¾à¦¨à§à¦¡, à¦²à§à¦¯à¦¾à¦ªà¦Ÿà¦ª, à¦­à§à¦°à¦®à¦£, à¦¬à¦¾à¦‡à¦•'
      : 'Emergency fund, Laptop, Trip, Bike';
  String get targetAmountLabel => isBangla
      ? 'à¦²à¦•à§à¦·à§à¦¯à§‡à¦° à¦ªà¦°à¦¿à¦®à¦¾à¦£'
      : 'Target amount';
  String get targetDateLabel =>
      isBangla ? 'à¦²à¦•à§à¦·à§à¦¯à§‡à¦° à¦¤à¦¾à¦°à¦¿à¦–' : 'Target date';
  String get changeAction =>
      isBangla ? 'à¦ªà¦°à¦¿à¦¬à¦°à§à¦¤à¦¨ à¦•à¦°à§à¦¨' : 'Change';
  String get iconLabel => isBangla ? 'à¦†à¦‡à¦•à¦¨' : 'Icon';
  String get colorLabel => isBangla ? 'à¦°à¦‚' : 'Color';
  String get saveGoalAction => isBangla
      ? 'à¦²à¦•à§à¦·à§à¦¯ à¦¸à¦‚à¦°à¦•à§à¦·à¦£ à¦•à¦°à§à¦¨'
      : 'Save goal';
  String get createGoalAction =>
      isBangla ? 'à¦²à¦•à§à¦·à§à¦¯ à¦¤à§ˆà¦°à¦¿ à¦•à¦°à§à¦¨' : 'Create goal';
  String get enterGoalNameError => isBangla
      ? 'à¦²à¦•à§à¦·à§à¦¯à§‡à¦° à¦¨à¦¾à¦® à¦²à¦¿à¦–à§à¦¨à¥¤'
      : 'Please enter a goal name.';
  String get enterTargetAmountError => isBangla
      ? 'à¦¸à¦ à¦¿à¦• à¦²à¦•à§à¦·à§à¦¯ à¦ªà¦°à¦¿à¦®à¦¾à¦£ à¦¦à¦¿à¦¨à¥¤'
      : 'Please enter a valid target amount.';
  String get goalUpdated => isBangla
      ? 'à¦²à¦•à§à¦·à§à¦¯ à¦¸à¦«à¦²à¦­à¦¾à¦¬à§‡ à¦†à¦ªà¦¡à§‡à¦Ÿ à¦¹à§Ÿà§‡à¦›à§‡à¥¤'
      : 'Goal updated successfully.';
  String get goalCreated => isBangla
      ? 'à¦²à¦•à§à¦·à§à¦¯ à¦¸à¦«à¦²à¦­à¦¾à¦¬à§‡ à¦¤à§ˆà¦°à¦¿ à¦¹à§Ÿà§‡à¦›à§‡à¥¤'
      : 'Goal created successfully.';
  String deleteNamedGoalPrompt(String name) =>
      isBangla ? '"$name" à¦®à§à¦›à¦¬à§‡à¦¨?' : 'Delete "$name"?';
  String get contributeToGoalTitle => isBangla
      ? 'à¦²à¦•à§à¦·à§à¦¯à§‡ à¦…à¦¬à¦¦à¦¾à¦¨ à¦¦à¦¿à¦¨'
      : 'Contribute to goal';
  String contributionSavedOf(String saved, String target) => isBangla
      ? '$saved à¦¸à§‡à¦­ à¦¹à§Ÿà§‡à¦›à§‡, à¦²à¦•à§à¦·à§à¦¯ $target'
      : '$saved saved of $target';
  String get contributionAmountLabel => isBangla
      ? 'à¦…à¦¬à¦¦à¦¾à¦¨à§‡à¦° à¦ªà¦°à¦¿à¦®à¦¾à¦£'
      : 'Contribution amount';
  String get noWalletForGoalSubtitle => isBangla
      ? 'à¦²à¦•à§à¦·à§à¦¯à§‡ à¦…à¦¬à¦¦à¦¾à¦¨ à¦¦à§‡à¦“à§Ÿà¦¾à¦° à¦†à¦—à§‡ à¦à¦•à¦Ÿà¦¿ à¦“à§Ÿà¦¾à¦²à§‡à¦Ÿ à¦¤à§ˆà¦°à¦¿ à¦•à¦°à§à¦¨à¥¤'
      : 'Create a wallet before contributing to a goal.';
  String get sourceWalletLabel =>
      isBangla ? 'à¦‰à§Žà¦¸ à¦“à§Ÿà¦¾à¦²à§‡à¦Ÿ' : 'Source wallet';
  String get contributionNoteHint => isBangla
      ? 'à¦à¦‡ à¦…à¦¬à¦¦à¦¾à¦¨à§‡à¦° à¦œà¦¨à§à¦¯ à¦à¦šà§à¦›à¦¿à¦• à¦¨à§‹à¦Ÿà¥¤'
      : 'Optional note for this contribution.';
  String get addContributionAction =>
      isBangla ? 'à¦…à¦¬à¦¦à¦¾à¦¨ à¦¯à§‹à¦— à¦•à¦°à§à¦¨' : 'Add contribution';
  String get validContributionAmountError => isBangla
      ? 'à¦¸à¦ à¦¿à¦• à¦…à¦¬à¦¦à¦¾à¦¨à§‡à¦° à¦ªà¦°à¦¿à¦®à¦¾à¦£ à¦¦à¦¿à¦¨à¥¤'
      : 'Please enter a valid contribution amount.';
  String get chooseSourceWalletError => isBangla
      ? 'à¦à¦•à¦Ÿà¦¿ à¦‰à§Žà¦¸ à¦“à§Ÿà¦¾à¦²à§‡à¦Ÿ à¦¬à§‡à¦›à§‡ à¦¨à¦¿à¦¨à¥¤'
      : 'Please choose a source wallet.';
  String goalCompletedMessage(String name) => isBangla
      ? 'à¦²à¦•à§à¦·à§à¦¯ à¦¸à¦®à§à¦ªà¦¨à§à¦¨! $name à¦ªà§à¦°à§‹à¦ªà§à¦°à¦¿ à¦ªà§‚à¦°à¦£ à¦¹à§Ÿà§‡à¦›à§‡à¥¤'
      : 'Goal completed! $name is fully funded.';
  String get contributionAdded => isBangla
      ? 'à¦…à¦¬à¦¦à¦¾à¦¨ à¦¸à¦«à¦²à¦­à¦¾à¦¬à§‡ à¦¯à§‹à¦— à¦¹à§Ÿà§‡à¦›à§‡à¥¤'
      : 'Contribution added successfully.';
  String get goalCompletedTitleText =>
      isBangla ? 'à¦²à¦•à§à¦·à§à¦¯ à¦¸à¦®à§à¦ªà¦¨à§à¦¨' : 'Goal completed';
  String goalCompletedDialog(String name) => isBangla
      ? 'à¦†à¦ªà¦¨à¦¿ "$name" à¦à¦° à¦²à¦•à§à¦·à§à¦¯ à¦ªà§‚à¦°à¦£ à¦•à¦°à§‡à¦›à§‡à¦¨à¥¤ à¦¦à¦¾à¦°à§à¦£ à¦•à¦¾à¦œà¥¤'
      : 'You reached your target for "$name". Nice work.';
  String get greatAction => isBangla ? 'à¦¦à¦¾à¦°à§à¦£' : 'Great';

  String get billsTitleText => isBangla ? 'à¦¬à¦¿à¦²' : 'Bills';
  String get upcomingTabLabel => isBangla ? 'à¦†à¦¸à¦¨à§à¦¨' : 'Upcoming';
  String get paidThisMonthTabLabel => isBangla
      ? 'à¦à¦‡ à¦®à¦¾à¦¸à§‡ à¦ªà¦°à¦¿à¦¶à§‹à¦§à¦¿à¦¤'
      : 'Paid this month';
  String get noBillDueSoonTitle => isBangla
      ? 'à¦¶à¦¿à¦—à¦—à¦¿à¦° à¦•à§‹à¦¨à§‹ à¦¬à¦¿à¦² à¦¨à§‡à¦‡'
      : 'No bill due soon';
  String get noBillDueSoonSubtitle => isBangla
      ? 'à¦­à¦¾à§œà¦¾, à¦‡à¦¨à§à¦Ÿà¦¾à¦°à¦¨à§‡à¦Ÿ, à¦‡à¦‰à¦Ÿà¦¿à¦²à¦¿à¦Ÿà¦¿ à¦¬à¦¾ à¦¯à§‡à¦•à§‹à¦¨à§‹ à¦°à¦¿à¦•à¦¾à¦°à¦¿à¦‚ à¦¬à¦¿à¦² à¦¯à§‹à¦— à¦•à¦°à§à¦¨à¥¤'
      : 'Add recurring rent, internet, utilities, or any subscription you want to track.';
  String get noBillCreatedYetTitle => isBangla
      ? 'à¦à¦–à¦¨à¦“ à¦•à§‹à¦¨à§‹ à¦¬à¦¿à¦² à¦¤à§ˆà¦°à¦¿ à¦¹à§Ÿà¦¨à¦¿'
      : 'No bill created yet';
  String get noBillCreatedYetSubtitle => isBangla
      ? 'à¦ªà§à¦°à¦¥à¦® à¦°à¦¿à¦•à¦¾à¦°à¦¿à¦‚ à¦¬à¦¿à¦² à¦¤à§ˆà¦°à¦¿ à¦•à¦°à§à¦¨, à¦…à§à¦¯à¦¾à¦ª à¦à¦Ÿà¦¿ à¦—à§à¦›à¦¾à¦¨à§‹ à¦°à¦¾à¦–à¦¬à§‡à¥¤'
      : 'Create your first recurring bill and the app will keep it organized here.';
  String get nothingPaidThisMonthTitle => isBangla
      ? 'à¦à¦‡ à¦®à¦¾à¦¸à§‡ à¦•à¦¿à¦›à§à¦‡ à¦ªà¦°à¦¿à¦¶à§‹à¦§ à¦¹à§Ÿà¦¨à¦¿'
      : 'Nothing paid this month';
  String get nothingPaidThisMonthSubtitle => isBangla
      ? 'à¦¯à§‡ à¦¬à¦¿à¦²à¦—à§à¦²à§‹ à¦ªà¦°à¦¿à¦¶à§‹à¦§à¦¿à¦¤ à¦¹à¦¿à¦¸à§‡à¦¬à§‡ à¦šà¦¿à¦¹à§à¦¨à¦¿à¦¤ à¦•à¦°à¦¬à§‡à¦¨, à¦¸à§‡à¦—à§à¦²à§‹ à¦à¦–à¦¾à¦¨à§‡ à¦¦à§‡à¦–à¦¾ à¦¯à¦¾à¦¬à§‡à¥¤'
      : 'Bills you mark as paid will show up here during the current month.';
  String get addBillAction =>
      isBangla ? 'à¦¬à¦¿à¦² à¦¯à§‹à¦— à¦•à¦°à§à¦¨' : 'Add bill';
  String get recurringBillsSnapshotTitle => isBangla
      ? 'à¦°à¦¿à¦•à¦¾à¦°à¦¿à¦‚ à¦¬à¦¿à¦²à§‡à¦° à¦¸à¦¾à¦°à¦¾à¦‚à¦¶'
      : 'Recurring bills snapshot';
  String get recurringBillsSnapshotSubtitle => isBangla
      ? 'à¦†à¦¸à¦¨à§à¦¨ à¦¤à¦¾à¦°à¦¿à¦– à¦¦à§‡à¦–à§à¦¨, à¦°à¦¿à¦•à¦¾à¦°à¦¿à¦‚ à¦–à¦°à¦š à¦—à§à¦›à¦¿à§Ÿà§‡ à¦°à¦¾à¦–à§à¦¨, à¦†à¦° à¦à¦• à¦•à§à¦²à¦¿à¦•à§‡ à¦ªà¦°à¦¿à¦¶à§‹à¦§à¦¿à¦¤ à¦¹à¦¿à¦¸à§‡à¦¬à§‡ à¦šà¦¿à¦¹à§à¦¨à¦¿à¦¤ à¦•à¦°à§à¦¨à¥¤'
      : 'Track upcoming due dates, keep recurring expenses organized, and mark bills as paid in one move.';
  String get dueSoonLabel =>
      isBangla ? 'à¦¶à¦¿à¦—à¦—à¦¿à¦° à¦¬à¦¾à¦•à¦¿' : 'Due soon';
  String scheduledAmount(String amount) =>
      isBangla ? '$amount à¦¨à¦¿à¦°à§à¦§à¦¾à¦°à¦¿à¦¤' : '$amount scheduled';
  String clearedAmount(String amount) =>
      isBangla ? '$amount à¦ªà¦°à¦¿à¦¶à§‹à¦§à¦¿à¦¤' : '$amount cleared';
  String billMarkedPaid(String name) => isBangla
      ? '$name à¦ªà¦°à¦¿à¦¶à§‹à¦§à¦¿à¦¤ à¦¹à¦¿à¦¸à§‡à¦¬à§‡ à¦šà¦¿à¦¹à§à¦¨à¦¿à¦¤ à¦¹à§Ÿà§‡à¦›à§‡à¥¤'
      : '$name marked as paid.';
  String get markAsPaidAction => isBangla
      ? 'à¦ªà¦°à¦¿à¦¶à§‹à¦§à¦¿à¦¤ à¦šà¦¿à¦¹à§à¦¨à¦¿à¦¤ à¦•à¦°à§à¦¨'
      : 'Mark as paid';
  String get nextDueLabel =>
      isBangla ? 'à¦ªà¦°à¦¬à¦°à§à¦¤à§€ à¦¤à¦¾à¦°à¦¿à¦–' : 'Next due';
  String get deleteBillTitle =>
      isBangla ? 'à¦¬à¦¿à¦² à¦®à§à¦›à§à¦¨' : 'Delete bill';
  String deleteNamedBillPrompt(String name) =>
      isBangla ? '"$name" à¦®à§à¦›à¦¬à§‡à¦¨?' : 'Delete "$name"?';
  String get billDeleted => isBangla
      ? 'à¦¬à¦¿à¦² à¦®à§à¦›à§‡ à¦«à§‡à¦²à¦¾ à¦¹à§Ÿà§‡à¦›à§‡à¥¤'
      : 'Bill deleted.';
  String get billNameLabel =>
      isBangla ? 'à¦¬à¦¿à¦²à§‡à¦° à¦¨à¦¾à¦®' : 'Bill name';
  String get billNameHint => isBangla
      ? 'à¦‡à¦¨à§à¦Ÿà¦¾à¦°à¦¨à§‡à¦Ÿ, à¦­à¦¾à§œà¦¾, à¦¨à§‡à¦Ÿà¦«à§à¦²à¦¿à¦•à§à¦¸, à¦¬à¦¿à¦¦à§à¦¯à§à§Ž'
      : 'Internet, Rent, Netflix, Electricity';
  String get expenseCategoryLabel => isBangla
      ? 'à¦¬à§à¦¯à§Ÿà§‡à¦° à¦•à§à¦¯à¦¾à¦Ÿà¦¾à¦—à¦°à¦¿'
      : 'Expense category';
  String get nextDueDateLabel => isBangla
      ? 'à¦ªà¦°à¦¬à¦°à§à¦¤à§€ à¦ªà§à¦°à¦¦à¦¾à¦¨à§‡à¦° à¦¤à¦¾à¦°à¦¿à¦–'
      : 'Next due date';
  String get reminderLabel =>
      isBangla ? 'à¦°à¦¿à¦®à¦¾à¦‡à¦¨à§à¦¡à¦¾à¦°' : 'Reminder';
  String get sameDayLabel => isBangla ? 'à¦¸à§‡à¦‡ à¦¦à¦¿à¦¨' : 'Same day';
  String get oneDayBeforeLabel =>
      isBangla ? 'à§§ à¦¦à¦¿à¦¨ à¦†à¦—à§‡' : '1 day before';
  String get twoDaysBeforeLabel =>
      isBangla ? 'à§¨ à¦¦à¦¿à¦¨ à¦†à¦—à§‡' : '2 days before';
  String get threeDaysBeforeLabel =>
      isBangla ? 'à§© à¦¦à¦¿à¦¨ à¦†à¦—à§‡' : '3 days before';
  String get sevenDaysBeforeLabel =>
      isBangla ? 'à§­ à¦¦à¦¿à¦¨ à¦†à¦—à§‡' : '7 days before';
  String get enterBillNameError => isBangla
      ? 'à¦¬à¦¿à¦²à§‡à¦° à¦¨à¦¾à¦® à¦²à¦¿à¦–à§à¦¨à¥¤'
      : 'Please enter a bill name.';
  String get validBillAmountError => isBangla
      ? 'à¦¸à¦ à¦¿à¦• à¦ªà¦°à¦¿à¦®à¦¾à¦£ à¦¦à¦¿à¦¨à¥¤'
      : 'Please enter a valid amount.';
  String get chooseCategoryWalletError => isBangla
      ? 'à¦à¦•à¦Ÿà¦¿ à¦•à§à¦¯à¦¾à¦Ÿà¦¾à¦—à¦°à¦¿ à¦“ à¦“à§Ÿà¦¾à¦²à§‡à¦Ÿ à¦¬à§‡à¦›à§‡ à¦¨à¦¿à¦¨à¥¤'
      : 'Please choose a category and wallet.';
  String get billEditorNeedsDataTitle => isBangla
      ? 'à¦¬à¦¿à¦²à§‡à¦° à¦œà¦¨à§à¦¯ à¦•à§à¦¯à¦¾à¦Ÿà¦¾à¦—à¦°à¦¿ à¦“ à¦“à§Ÿà¦¾à¦²à§‡à¦Ÿ à¦¦à¦°à¦•à¦¾à¦°'
      : 'Bills need categories and wallets';
  String get billEditorNeedsDataSubtitle => isBangla
      ? 'à¦¸à§à¦Ÿà¦¾à¦°à§à¦Ÿà¦¾à¦° à¦«à¦¾à¦‡à¦¨à§à¦¯à¦¾à¦¨à§à¦¸ à¦¡à¦¾à¦Ÿà¦¾ à¦²à§‹à¦¡ à¦¹à¦²à§‡ à¦à¦‡ à¦ªà§‡à¦œ à¦†à¦¬à¦¾à¦° à¦–à§à¦²à§à¦¨à¥¤'
      : 'Make sure the starter finance data has loaded, then open this page again.';
  String billEditorTitle(bool isEditing) => isEditing
      ? (isBangla ? 'à¦¬à¦¿à¦² à¦¸à¦®à§à¦ªà¦¾à¦¦à¦¨à¦¾' : 'Edit bill')
      : (isBangla ? 'à¦¬à¦¿à¦² à¦¯à§‹à¦— à¦•à¦°à§à¦¨' : 'Add bill');
  String billHeaderSubtitle(bool isEditing) => isEditing
      ? (isBangla
            ? 'à¦°à¦¿à¦•à¦¾à¦°à¦¿à¦‚ à¦¬à¦¿à¦² à¦†à¦ªà¦¡à§‡à¦Ÿ à¦•à¦°à§à¦¨'
            : 'Update recurring bill')
      : (isBangla
            ? 'à¦°à¦¿à¦•à¦¾à¦°à¦¿à¦‚ à¦¬à¦¿à¦² à¦¤à§ˆà¦°à¦¿ à¦•à¦°à§à¦¨'
            : 'Create recurring bill');
  String get billAutoCreateHint => isBangla
      ? 'à¦†à¦ªà¦¨à¦¿ à¦à¦‡ à¦¬à¦¿à¦² à¦ªà¦°à¦¿à¦¶à§‹à¦§à¦¿à¦¤ à¦šà¦¿à¦¹à§à¦¨à¦¿à¦¤ à¦•à¦°à¦²à§‡ à¦…à§à¦¯à¦¾à¦ª à¦à¦•à¦Ÿà¦¿ à¦¬à¦¾à¦¸à§à¦¤à¦¬ à¦¬à§à¦¯à§Ÿ à¦²à§‡à¦¨à¦¦à§‡à¦¨ à¦¤à§ˆà¦°à¦¿ à¦•à¦°à¦¬à§‡ à¦à¦¬à¦‚ à¦ªà¦°à¦¬à¦°à§à¦¤à§€ à¦¤à¦¾à¦°à¦¿à¦– à¦à¦—à¦¿à§Ÿà§‡ à¦¦à§‡à¦¬à§‡à¥¤'
      : 'When you mark this bill as paid, the app creates a real expense transaction and moves the next due date forward automatically.';
  String get billUpdated => isBangla
      ? 'à¦¬à¦¿à¦² à¦¸à¦«à¦²à¦­à¦¾à¦¬à§‡ à¦†à¦ªà¦¡à§‡à¦Ÿ à¦¹à§Ÿà§‡à¦›à§‡à¥¤'
      : 'Bill updated successfully.';
  String get billCreated => isBangla
      ? 'à¦¬à¦¿à¦² à¦¸à¦«à¦²à¦­à¦¾à¦¬à§‡ à¦¤à§ˆà¦°à¦¿ à¦¹à§Ÿà§‡à¦›à§‡à¥¤'
      : 'Bill created successfully.';

  String transferEditorTitle(bool isEditing) => isEditing
      ? (isBangla
            ? 'à¦Ÿà§à¦°à¦¾à¦¨à§à¦¸à¦«à¦¾à¦° à¦¸à¦®à§à¦ªà¦¾à¦¦à¦¨à¦¾'
            : 'Edit transfer')
      : (isBangla
            ? 'à¦Ÿà¦¾à¦•à¦¾ à¦Ÿà§à¦°à¦¾à¦¨à§à¦¸à¦«à¦¾à¦°'
            : 'Transfer money');
  String transferHeaderTitle(bool isEditing) => isEditing
      ? (isBangla
            ? 'à¦“à§Ÿà¦¾à¦²à§‡à¦Ÿ à¦Ÿà§à¦°à¦¾à¦¨à§à¦¸à¦«à¦¾à¦° à¦†à¦ªà¦¡à§‡à¦Ÿ à¦•à¦°à§à¦¨'
            : 'Update wallet transfer')
      : (isBangla
            ? 'à¦“à§Ÿà¦¾à¦²à§‡à¦Ÿà§‡à¦° à¦®à¦§à§à¦¯à§‡ à¦Ÿà¦¾à¦•à¦¾ à¦¸à¦°à¦¾à¦¨'
            : 'Move money between wallets');
  String get transferHeaderSubtitle => isBangla
      ? 'à¦Ÿà§à¦°à¦¾à¦¨à§à¦¸à¦«à¦¾à¦° à¦à¦•à¦¸à¦¾à¦¥à§‡ à¦¦à§à¦‡ à¦“à§Ÿà¦¾à¦²à§‡à¦Ÿà§‡à¦° à¦¬à§à¦¯à¦¾à¦²à§‡à¦¨à§à¦¸ à¦†à¦ªà¦¡à§‡à¦Ÿ à¦•à¦°à§‡ à¦à¦¬à¦‚ à¦¹à¦¿à¦¸à§à¦Ÿà¦°à¦¿à¦¤à§‡ à¦¸à¦‚à¦¯à§à¦•à§à¦¤ à¦¥à¦¾à¦•à§‡à¥¤'
      : 'Transfers update both wallet balances together and stay linked in history.';
  String get fromWalletLabel =>
      isBangla ? 'à¦¯à§‡ à¦“à§Ÿà¦¾à¦²à§‡à¦Ÿ à¦¥à§‡à¦•à§‡' : 'From wallet';
  String get toWalletLabel =>
      isBangla ? 'à¦¯à§‡ à¦“à§Ÿà¦¾à¦²à§‡à¦Ÿà§‡' : 'To wallet';
  String get optionalTransferNoteHint => isBangla
      ? 'à¦à¦šà§à¦›à¦¿à¦• à¦Ÿà§à¦°à¦¾à¦¨à§à¦¸à¦«à¦¾à¦° à¦¨à§‹à¦Ÿ'
      : 'Optional transfer note';
  String get validTransferAmountError => isBangla
      ? 'à¦¸à¦ à¦¿à¦• à¦Ÿà§à¦°à¦¾à¦¨à§à¦¸à¦«à¦¾à¦° à¦ªà¦°à¦¿à¦®à¦¾à¦£ à¦¦à¦¿à¦¨à¥¤'
      : 'Enter a valid transfer amount.';
  String get chooseBothWalletsError => isBangla
      ? 'à¦à¦‡ à¦Ÿà§à¦°à¦¾à¦¨à§à¦¸à¦«à¦¾à¦°à§‡à¦° à¦œà¦¨à§à¦¯ à¦¦à§à¦Ÿà¦¿ à¦“à§Ÿà¦¾à¦²à§‡à¦Ÿà¦‡ à¦¬à§‡à¦›à§‡ à¦¨à¦¿à¦¨à¥¤'
      : 'Choose both wallets for this transfer.';
  String get differentWalletsError => isBangla
      ? 'à¦¦à§à¦Ÿà¦¿ à¦†à¦²à¦¾à¦¦à¦¾ à¦“à§Ÿà¦¾à¦²à§‡à¦Ÿ à¦¹à¦¤à§‡ à¦¹à¦¬à§‡à¥¤'
      : 'From and to wallets must be different.';
  String get transferDetailsLoadingError => isBangla
      ? 'à¦Ÿà§à¦°à¦¾à¦¨à§à¦¸à¦«à¦¾à¦°à§‡à¦° à¦¬à¦¿à¦¸à§à¦¤à¦¾à¦°à¦¿à¦¤ à¦à¦–à¦¨à¦“ à¦²à§‹à¦¡ à¦¹à¦šà§à¦›à§‡à¥¤ à¦†à¦¬à¦¾à¦° à¦šà§‡à¦·à§à¦Ÿà¦¾ à¦•à¦°à§à¦¨à¥¤'
      : 'Transfer details are still loading. Try again.';
  String get transferDeleted => isBangla
      ? 'à¦Ÿà§à¦°à¦¾à¦¨à§à¦¸à¦«à¦¾à¦° à¦®à§à¦›à§‡ à¦«à§‡à¦²à¦¾ à¦¹à§Ÿà§‡à¦›à§‡à¥¤'
      : 'Transfer deleted.';
  String get transferUpdated => isBangla
      ? 'à¦Ÿà§à¦°à¦¾à¦¨à§à¦¸à¦«à¦¾à¦° à¦†à¦ªà¦¡à§‡à¦Ÿ à¦¹à§Ÿà§‡à¦›à§‡à¥¤'
      : 'Transfer updated.';
  String get transferCompleted => isBangla
      ? 'à¦Ÿà§à¦°à¦¾à¦¨à§à¦¸à¦«à¦¾à¦° à¦¸à¦®à§à¦ªà¦¨à§à¦¨ à¦¹à§Ÿà§‡à¦›à§‡à¥¤'
      : 'Transfer completed.';

  String walletEditorTitle(bool isEditing) => isEditing
      ? (isBangla
            ? 'à¦“à§Ÿà¦¾à¦²à§‡à¦Ÿ à¦¸à¦®à§à¦ªà¦¾à¦¦à¦¨à¦¾'
            : 'Edit wallet')
      : (isBangla ? 'à¦“à§Ÿà¦¾à¦²à§‡à¦Ÿ à¦¯à§‹à¦— à¦•à¦°à§à¦¨' : 'Add wallet');
  String get walletPreviewTitle =>
      isBangla ? 'à¦“à§Ÿà¦¾à¦²à§‡à¦Ÿ à¦ªà§à¦°à¦¿à¦­à¦¿à¦‰' : 'Wallet preview';
  String get walletNameFieldLabel =>
      isBangla ? 'à¦“à§Ÿà¦¾à¦²à§‡à¦Ÿà§‡à¦° à¦¨à¦¾à¦®' : 'Wallet name';
  String get walletTypeFieldLabel =>
      isBangla ? 'à¦“à§Ÿà¦¾à¦²à§‡à¦Ÿà§‡à¦° à¦§à¦°à¦¨' : 'Wallet type';
  String get currentBalanceFieldLabel => isBangla
      ? 'à¦¬à¦°à§à¦¤à¦®à¦¾à¦¨ à¦¬à§à¦¯à¦¾à¦²à§‡à¦¨à§à¦¸'
      : 'Current balance';
  String get currentBalanceFieldHint => isBangla
      ? 'à¦²à§‡à¦¨à¦¦à§‡à¦¨ à¦“ à¦Ÿà§à¦°à¦¾à¦¨à§à¦¸à¦«à¦¾à¦° à¦…à¦¨à§à¦¯à¦¾à§Ÿà§€ à¦¬à§à¦¯à¦¾à¦²à§‡à¦¨à§à¦¸ à¦¸à§à¦¬à§Ÿà¦‚à¦•à§à¦°à¦¿à§Ÿà¦­à¦¾à¦¬à§‡ à¦†à¦ªà¦¡à§‡à¦Ÿ à¦¹à§Ÿà¥¤'
      : 'Balance follows transactions and transfers automatically.';
  String get initialBalanceFieldLabel => isBangla
      ? 'à¦¶à§à¦°à§à¦° à¦¬à§à¦¯à¦¾à¦²à§‡à¦¨à§à¦¸'
      : 'Initial balance';
  String get setAsDefaultWalletLabel => isBangla
      ? 'à¦¡à¦¿à¦«à¦²à§à¦Ÿ à¦“à§Ÿà¦¾à¦²à§‡à¦Ÿ à¦¹à¦¿à¦¸à§‡à¦¬à§‡ à¦¸à§‡à¦Ÿ à¦•à¦°à§à¦¨'
      : 'Set as default wallet';
  String get walletNameRequired => isBangla
      ? 'à¦à¦•à¦Ÿà¦¿ à¦“à§Ÿà¦¾à¦²à§‡à¦Ÿà§‡à¦° à¦¨à¦¾à¦® à¦²à¦¿à¦–à§à¦¨à¥¤'
      : 'Please enter a wallet name.';
  String get walletUpdated => isBangla
      ? 'à¦“à§Ÿà¦¾à¦²à§‡à¦Ÿ à¦†à¦ªà¦¡à§‡à¦Ÿ à¦¹à§Ÿà§‡à¦›à§‡à¥¤'
      : 'Wallet updated.';
  String get walletCreated => isBangla
      ? 'à¦“à§Ÿà¦¾à¦²à§‡à¦Ÿ à¦¤à§ˆà¦°à¦¿ à¦¹à§Ÿà§‡à¦›à§‡à¥¤'
      : 'Wallet created.';
  String get updateWalletAction => isBangla
      ? 'à¦“à§Ÿà¦¾à¦²à§‡à¦Ÿ à¦†à¦ªà¦¡à§‡à¦Ÿ à¦•à¦°à§à¦¨'
      : 'Update wallet';
  String get createWalletAction => isBangla
      ? 'à¦“à§Ÿà¦¾à¦²à§‡à¦Ÿ à¦¤à§ˆà¦°à¦¿ à¦•à¦°à§à¦¨'
      : 'Create wallet';
  String walletTypeName(String type) {
    switch (type) {
      case 'cash':
        return isBangla ? 'à¦•à§à¦¯à¦¾à¦¶' : 'Cash';
      case 'bank':
        return isBangla ? 'à¦¬à§à¦¯à¦¾à¦‚à¦•' : 'Bank';
      case 'bkash':
        return 'bKash';
      case 'nagad':
        return 'Nagad';
      case 'savings':
        return isBangla ? 'à¦¸à§‡à¦­à¦¿à¦‚à¦¸' : 'Savings';
      default:
        return type;
    }
  }

  String get calendarMonthViewLabel => isBangla ? 'à¦®à¦¾à¦¸' : 'Month';
  String get calendarWeekViewLabel => isBangla ? 'à¦¸à¦ªà§à¦¤à¦¾à¦¹' : 'Week';
  String get calendarLoadingTitle => isBangla
      ? 'à¦•à§à¦¯à¦¾à¦²à§‡à¦¨à§à¦¡à¦¾à¦° à¦²à§‹à¦¡ à¦¹à¦šà§à¦›à§‡'
      : 'Calendar is loading';
  String get selectMonthHelp =>
      isBangla ? 'à¦®à¦¾à¦¸ à¦¬à§‡à¦›à§‡ à¦¨à¦¿à¦¨' : 'Select month';
  String get calendarSelectedDaySubtitle => isBangla
      ? 'à¦¨à¦¿à¦°à§à¦¬à¦¾à¦šà¦¿à¦¤ à¦¦à¦¿à¦¨à§‡à¦° à¦†à§Ÿ, à¦¬à§à¦¯à§Ÿ à¦“ à¦²à§‡à¦¨à¦¦à§‡à¦¨à§‡à¦° à¦¬à¦¿à¦¸à§à¦¤à¦¾à¦°à¦¿à¦¤'
      : 'Income, expense, and transaction details for the selected day.';
  String get noTransactionsOnDayTitle => isBangla
      ? 'à¦à¦‡ à¦¦à¦¿à¦¨à§‡ à¦•à§‹à¦¨à§‹ à¦²à§‡à¦¨à¦¦à§‡à¦¨ à¦¨à§‡à¦‡'
      : 'No transaction on this day';
  String get noTransactionsOnDaySubtitle => isBangla
      ? 'à¦…à¦¨à§à¦¯ à¦à¦•à¦Ÿà¦¿ à¦¤à¦¾à¦°à¦¿à¦– à¦¬à§‡à¦›à§‡ à¦¨à¦¿à¦¨ à¦¬à¦¾ à¦¨à¦¤à§à¦¨ à¦à¦¨à§à¦Ÿà§à¦°à¦¿ à¦¯à§‹à¦— à¦•à¦°à§à¦¨à¥¤'
      : 'Pick another date or add a new entry to start building your calendar.';
  String get exportDataTitle => isBangla ? 'ডাটা এক্সপোর্ট' : 'Export data';
  String get exportDataSubtitle => isBangla
      ? 'CSV বা PDF আকারে আপনার আর্থিক ডাটা সংরক্ষণ বা শেয়ার করুন।'
      : 'Save or share your finance data as CSV or PDF files.';
  String get exportCsvTitle => isBangla ? 'CSV এক্সপোর্ট' : 'CSV export';
  String get exportPdfTitle => isBangla ? 'PDF রিপোর্ট' : 'PDF report';
  String get exportFromReportsTooltip =>
      isBangla ? 'রিপোর্ট এক্সপোর্ট' : 'Export reports';
  String get shareFileAction => isBangla ? 'শেয়ার করুন' : 'Share';
  String get exportNowAction => isBangla ? 'এখন এক্সপোর্ট করুন' : 'Export now';
  String get allDatesLabel => isBangla ? 'সব তারিখ' : 'All dates';
  String get pickDateRangeAction =>
      isBangla ? 'তারিখ বেছে নিন' : 'Pick date range';
  String get clearDateRangeAction => isBangla ? 'তারিখ মুছুন' : 'Clear dates';
  String get exportTypeLabel => isBangla ? 'এক্সপোর্ট ধরন' : 'Export type';
  String get monthlyReportLabel =>
      isBangla ? 'মাসিক রিপোর্ট' : 'Monthly report';
  String get yearlyReportLabel =>
      isBangla ? 'বার্ষিক রিপোর্ট' : 'Yearly report';
  String get reportMonthLabel => isBangla ? 'রিপোর্ট মাস' : 'Report month';
  String get reportYearLabel => isBangla ? 'রিপোর্ট বছর' : 'Report year';
  String get csvFiltersLabel => isBangla ? 'CSV ফিল্টার' : 'CSV filters';
  String get exportedFileSaved => isBangla
      ? 'এক্সপোর্ট ফাইল সংরক্ষণ করা হয়েছে।'
      : 'Export file saved successfully.';
  String exportFailedMessage(String message) =>
      isBangla ? 'এক্সপোর্ট করা যায়নি: $message' : 'Export failed: $message';
  String get noTransactionsToExport => isBangla
      ? 'এক্সপোর্ট করার মতো কোনো লেনদেন পাওয়া যায়নি।'
      : 'No transactions found for export.';
  String get exportSectionInProfile =>
      isBangla ? 'ডাটা এক্সপোর্ট ও ব্যাকআপ' : 'Export and backup';
  String get exportSectionProfileSubtitle => isBangla
      ? 'CSV ডাউনলোড করুন অথবা PDF সারাংশ শেয়ার করুন।'
      : 'Download CSV files or share PDF summaries.';
}
