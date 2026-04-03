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

  String get openAction => isBangla ? 'খুলুন' : 'Open';
  String get retryAction => isBangla ? 'আবার চেষ্টা করুন' : 'Retry';
  String get dismissAction => isBangla ? 'বন্ধ করুন' : 'Dismiss';
  String get clearAction => isBangla ? 'মুছুন' : 'Clear';
  String get applyAction => isBangla ? 'প্রয়োগ করুন' : 'Apply';
  String get addAction => isBangla ? 'যোগ করুন' : 'Add';
  String get addTransactionAction =>
      isBangla ? 'লেনদেন যোগ করুন' : 'Add transaction';
  String get addNewAction => isBangla ? 'নতুন যোগ করুন' : 'Add new';
  String get editAction => isBangla ? 'সম্পাদনা' : 'Edit';
  String get saveAction => isBangla ? 'সংরক্ষণ করুন' : 'Save';
  String get updateAction => isBangla ? 'আপডেট করুন' : 'Update';
  String get allLabel => isBangla ? 'সব' : 'All';
  String get otherLabel => isBangla ? 'অন্যান্য' : 'Other';
  String get liveLabel => isBangla ? 'লাইভ' : 'Live';
  String get shortcutsLabel => isBangla ? 'শর্টকাট' : 'Shortcuts';
  String get todayLabel => isBangla ? 'আজ' : 'Today';
  String get yesterdayLabel => isBangla ? 'গতকাল' : 'Yesterday';
  String get transferLabel => isBangla ? 'ট্রান্সফার' : 'Transfer';
  String get incomeTypeLabel => isBangla ? 'আয়' : 'Income';
  String get expenseTypeLabel => isBangla ? 'ব্যয়' : 'Expense';

  String get homeAvailableBalance =>
      isBangla ? 'মোট ব্যালেন্স' : 'Available balance';
  String get homeTodayIncome => isBangla ? 'আজকের আয়' : 'Today income';
  String get homeTodayExpense => isBangla ? 'আজকের ব্যয়' : 'Today expense';
  String get homeMonthExpense => isBangla ? 'মাসের ব্যয়' : 'Month expense';
  String get homeNetToday => isBangla ? 'আজকের নেট' : 'Net today';
  String get walletReadyTitle =>
      isBangla ? 'আপনার ওয়ালেট প্রস্তুত হচ্ছে' : 'Your wallet is getting ready';
  String get walletReadySubtitle => isBangla
      ? 'সাইন ইন করার পর স্টার্টার ডাটা আসতে একটু সময় লাগে। একটু পরে আবার দেখুন।'
      : 'Starter data usually appears right after sign-in. Give it a moment and reopen the screen if needed.';
  String get walletBalancesTitle =>
      isBangla ? 'ওয়ালেট ব্যালেন্স' : 'Wallet balances';
  String get expenseTrendTitle => isBangla ? 'ব্যয়ের ট্রেন্ড' : 'Expense trend';
  String get expenseTrendSubtitle => isBangla
      ? 'চলতি মাসে প্রতিদিনের ব্যয়ের পরিবর্তন।'
      : 'Daily expense movement for the current month.';
  String get monthPulseTitle =>
      isBangla ? 'এই মাসের অবস্থা' : 'This month pulse';
  String get monthPulseSubtitle => isBangla
      ? 'লাইভ ব্যালেন্স আর ক্যাটাগরির ট্রেন্ড একসাথে দেখুন।'
      : 'Your dashboard now blends live balances with category trends.';
  String get monthIncomeLabel => isBangla ? 'মাসের আয়' : 'Month income';
  String get waitingForSpending =>
      isBangla ? 'খরচ শুরু হলে এখানে দেখা যাবে' : 'Waiting for spending';
  String get analyticsLoadingTitle =>
      isBangla ? 'অ্যানালিটিক্স প্রস্তুত হচ্ছে' : 'Analytics are catching up';
  String get upcomingBillsTitle => isBangla ? 'আসন্ন বিল' : 'Upcoming bills';
  String get noBillsDueSoon => isBangla
      ? 'শিগগির কোনো বিল বাকি নেই। একটি রিকারিং বিল যোগ করলে এখানে দেখা যাবে।'
      : 'Nothing is due soon. Add a recurring bill and it will show up here.';

  String dueLabel(int days) {
    if (days < 0) {
      return isBangla ? '${days.abs()} দিন ওভারডিউ' : 'Overdue ${days.abs()}d';
    }
    if (days == 0) {
      return isBangla ? 'আজ দিতে হবে' : 'Due today';
    }
    if (days == 1) {
      return isBangla ? 'আগামীকাল দিতে হবে' : 'Due tomorrow';
    }
    return isBangla ? '$days দিনের মধ্যে' : 'In $days days';
  }

  String dueWithWallet(int days, String walletName) =>
      '${dueLabel(days)} • $walletName';

  String get topGoalTitle => isBangla ? 'সেরা লক্ষ্য' : 'Top goal';
  String get noActiveGoalYet => isBangla
      ? 'এখনও কোনো সক্রিয় সেভিংস লক্ষ্য নেই। একটি বানালে এখানে অগ্রগতি দেখা যাবে।'
      : 'No active savings goal yet. Create one to see progress here.';

  String daysLeftLabel(int days) {
    if (days < 0) {
      return isBangla
          ? '${days.abs()} দিন লক্ষ্য সময়ের পরে'
          : 'Past target by ${days.abs()} days';
    }
    return isBangla ? '$days দিন বাকি' : '$days days left';
  }

  String get historyNeedsAttention =>
      isBangla ? 'হিস্টরি লোড করতে সমস্যা হয়েছে' : 'History needs attention';
  String transactionEmptyTitle(bool hasSearch) => hasSearch
      ? (isBangla ? 'মিল পাওয়া যায়নি' : 'No matching transaction')
      : (isBangla ? 'এখনও কোনো লেনদেন নেই' : 'No transaction yet');
  String transactionEmptySubtitle(bool hasSearch) => hasSearch
      ? (isBangla
            ? 'সার্চ, সাজানো বা ফিল্টার বদলে আবার চেষ্টা করুন।'
            : 'Try changing the search, sort, or filters to widen the result.')
      : (isBangla
            ? 'প্রথম আয় বা ব্যয়ের এন্ট্রি যোগ করুন, তারপর হিস্টরি তৈরি হবে।'
            : 'Add your first entry and your full history will start building here.');
  String get loadMoreAction => isBangla ? 'আরও দেখুন' : 'Load more';
  String get endOfHistoryLabel => isBangla
      ? 'আপনার হিস্টরির শেষ প্রান্তে পৌঁছে গেছেন।'
      : 'You\'ve reached the end of your history.';
  String get deleteTransactionTitle =>
      isBangla ? 'লেনদেন মুছুন' : 'Delete transaction';
  String get deleteTransactionPrompt => isBangla
      ? 'এটি মুছে গেলে ওয়ালেট ব্যালেন্সও সাথে সাথে আপডেট হবে।'
      : 'This will remove the transaction and update the wallet balance immediately.';
  String get transactionDeleted =>
      isBangla ? 'লেনদেন মুছে ফেলা হয়েছে।' : 'Transaction deleted.';
  String get sortTransactionsTitle =>
      isBangla ? 'লেনদেন সাজান' : 'Sort transactions';
  String get filterByCategoryTitle =>
      isBangla ? 'ক্যাটাগরি দিয়ে ফিল্টার' : 'Filter by category';
  String get filterByWalletTitle =>
      isBangla ? 'ওয়ালেট দিয়ে ফিল্টার' : 'Filter by wallet';
  String get transactionHistoryTitle =>
      isBangla ? 'লেনদেনের হিস্টরি' : 'Transaction history';
  String resultCountLabel(int count) => isBangla
      ? 'বর্তমান ভিউতে $countটি ফলাফল'
      : '$count result${count == 1 ? '' : 's'} in the current view';
  String get searchNoteAmountHint =>
      isBangla ? 'নোট বা পরিমাণ দিয়ে খুঁজুন' : 'Search by note or amount';
  String categoryFilterLabel(int count) => count == 0
      ? (isBangla ? 'ক্যাটাগরি' : 'Category')
      : (isBangla ? 'ক্যাটাগরি ($count)' : 'Category ($count)');
  String walletFilterLabel(int count) => count == 0
      ? (isBangla ? 'ওয়ালেট' : 'Wallet')
      : (isBangla ? 'ওয়ালেট ($count)' : 'Wallet ($count)');
  String get dateRangeLabel => isBangla ? 'তারিখ সীমা' : 'Date range';
  String get dateRangeSetLabel =>
      isBangla ? 'তারিখ সীমা সেট' : 'Date range set';
  String get topSpendingCategoryTitle =>
      isBangla ? 'সবচেয়ে বেশি খরচের ক্যাটাগরি' : 'Top spending category';
  String get reportsIncomeVsExpenseTitle =>
      isBangla ? 'আয় বনাম ব্যয়' : 'Income vs expense';
  String get reportsCategoryBreakdownTitle =>
      isBangla ? 'ক্যাটাগরি বিশ্লেষণ' : 'Category breakdown';
  String get totalIncomeLabel => isBangla ? 'মোট আয়' : 'Total income';
  String get reportTitle => isBangla ? 'আর্থিক রিপোর্ট' : 'Financial report';
  String get totalExpenseLabel => isBangla ? 'মোট ব্যয়' : 'Total expense';
  String get netBalanceLabel => isBangla ? 'নেট ব্যালেন্স' : 'Net balance';
  String get topCategoryLabel => isBangla ? 'সেরা ক্যাটাগরি' : 'Top category';
  String get reportsLoadingTitle =>
      isBangla ? 'রিপোর্ট লোড হচ্ছে' : 'Reports are loading';
  String get noTopCategoryYet =>
      isBangla ? 'এখনও সেরা ক্যাটাগরি নেই' : 'No top category yet';

  String analyticsPeriodLabel(String key) {
    switch (key) {
      case 'weekly':
        return isBangla ? 'এই সপ্তাহ' : 'This Week';
      case 'monthly':
        return isBangla ? 'এই মাস' : 'This Month';
      case 'yearly':
        return isBangla ? 'এই বছর' : 'This Year';
      default:
        return key;
    }
  }

  String averageExpenseLabel(String key) {
    if (key == 'yearly') {
      return isBangla ? 'গড় মাসিক ব্যয়' : 'Avg monthly expense';
    }
    return isBangla ? 'গড় দৈনিক ব্যয়' : 'Avg daily expense';
  }

  String peakExpenseLabel(String key) {
    if (key == 'yearly') {
      return isBangla ? 'সর্বোচ্চ ব্যয়ের মাস' : 'Highest spending month';
    }
    return isBangla ? 'সর্বোচ্চ ব্যয়ের দিন' : 'Highest spending day';
  }

  String get budgetPulseTitle => isBangla ? 'বাজেট অবস্থা' : 'Budget pulse';
  String get spentLabel => isBangla ? 'খরচ' : 'Spent';
  String get limitLabel => isBangla ? 'সীমা' : 'Limit';
  String get activeBudgetsLabel => isBangla ? 'সক্রিয় বাজেট' : 'Active budgets';
  String get monthlyProgressLabel =>
      isBangla ? 'মাসিক অগ্রগতি' : 'Monthly progress';
  String get notSetLabel => isBangla ? 'সেট নয়' : 'Not set';
  String budgetAlertsTitle(bool hasExceeded) => hasExceeded
      ? (isBangla ? 'বাজেট সতর্কতা' : 'Budget alerts')
      : (isBangla ? 'বাজেট সতর্কবার্তা' : 'Budget warnings');
  String categoryExceededLabel(String category, String amount) => isBangla
      ? '$category সীমার $amount বেশি হয়ে গেছে।'
      : '$category exceeded by $amount.';
  String categoryNearLimitLabel(String category, int percent) => isBangla
      ? '$category তার সীমার $percent% এ পৌঁছেছে।'
      : '$category is at $percent% of its limit.';
  String get recentTransactionsTitle =>
      isBangla ? 'সাম্প্রতিক লেনদেন' : 'Recent transactions';
  String get noTransactionsYetTitle =>
      isBangla ? 'এখনও কোনো লেনদেন নেই' : 'No transactions yet';
  String get noTransactionsYetSubtitle => isBangla
      ? 'অ্যাড বাটন ব্যবহার করে প্রথম আয় বা ব্যয়ের এন্ট্রি দিন।'
      : 'Use the add button to save your first expense or income entry.';
  String get todaysPulseTitle => isBangla ? 'আজকের সারাংশ' : 'Today\'s pulse';
  String get homeLiveSubtitle => isBangla
      ? 'হোম স্ক্রিন এখন Firestore-এর লাইভ লেনদেন দেখায়।'
      : 'Your home screen now reflects live transaction data from Firestore.';
  String get incomeVsExpenseLabel =>
      isBangla ? 'আয় বনাম ব্যয়' : 'Income vs expense';
  String get todayNetLabel => isBangla ? 'আজকের নেট' : 'Today net';
  String get monthNetLabel => isBangla ? 'মাসের নেট' : 'Month net';
  String get recentItemsLabel => isBangla ? 'সাম্প্রতিক আইটেম' : 'Recent items';

  String transactionEditorTitle(bool isEditing) => isEditing
      ? (isBangla ? 'লেনদেন সম্পাদনা' : 'Edit transaction')
      : (isBangla ? 'লেনদেন যোগ করুন' : 'Add transaction');
  String get transactionEditorSubtitle => isBangla
      ? 'একটি লেনদেন তৈরি করুন বা আপডেট করুন'
      : 'Create or update a transaction';
  String get formBadge => isBangla ? 'ফর্ম' : 'Form';
  String get typeLabel => isBangla ? 'ধরন' : 'Type';
  String get amountFieldLabel => isBangla ? 'পরিমাণ' : 'Amount';
  String get walletFieldLabel => isBangla ? 'ওয়ালেট' : 'Wallet';
  String get categoryFieldLabel => isBangla ? 'ক্যাটাগরি' : 'Category';
  String get newCategoryAction => isBangla ? 'নতুন ক্যাটাগরি' : 'New category';
  String get dateFieldLabel => isBangla ? 'তারিখ' : 'Date';
  String get noteFieldLabel => isBangla ? 'নোট' : 'Note';
  String get optionalTransactionNoteHint => isBangla
      ? 'এই লেনদেন সম্পর্কে ঐচ্ছিক নোট'
      : 'Optional note about this transaction';
  String get noWalletYetTitle =>
      isBangla ? 'এখনও কোনো ওয়ালেট নেই' : 'No wallet yet';
  String get noWalletYetSubtitle => isBangla
      ? 'স্টার্টার ডাটা এখনও লোড হচ্ছে। একটু পরে আবার খুলুন।'
      : 'Starter data is still loading. Reopen this sheet in a moment.';
  String get noCategoryAvailableTitle =>
      isBangla ? 'কোনো ক্যাটাগরি নেই' : 'No category available';
  String get noCategoryAvailableSubtitle => isBangla
      ? 'স্টার্টার ক্যাটাগরি এখনও সিঙ্ক হচ্ছে। চাইলে এখনই একটি বানাতে পারেন।'
      : 'Starter categories are still syncing. You can also create one right now.';
  String get starterDataSyncingHint => isBangla
      ? 'স্টার্টার ডাটা সিঙ্ক শেষ না হলেও আপনি এখানে থাকতে পারেন।'
      : 'You can still stay here while starter data finishes syncing.';
  String get saveTransactionAction => isBangla ? 'সংরক্ষণ করুন' : 'Save';
  String get updateTransactionAction => isBangla ? 'আপডেট করুন' : 'Update';
  String get validAmountError => isBangla
      ? '০ এর বেশি একটি সঠিক পরিমাণ দিন।'
      : 'Enter a valid amount greater than 0.';
  String get chooseWalletError => isBangla
      ? 'সংরক্ষণের আগে একটি ওয়ালেট বেছে নিন।'
      : 'Choose a wallet before saving.';
  String get chooseCategoryError => isBangla
      ? 'সংরক্ষণের আগে একটি ক্যাটাগরি বেছে নিন।'
      : 'Choose a category before saving.';
  String get transactionSaved =>
      isBangla ? 'লেনদেন সংরক্ষণ হয়েছে।' : 'Transaction saved.';
  String get transactionUpdated =>
      isBangla ? 'লেনদেন আপডেট হয়েছে।' : 'Transaction updated.';
  String get deleteCategoryTitle =>
      isBangla ? 'ক্যাটাগরি মুছুন' : 'Delete category';
  String deleteCategoryPrompt(String name) => isBangla
      ? '"$name" মুছবেন? পুরোনো লেনদেনগুলো আগের ক্যাটাগরি আইডি রেখেই থাকবে।'
      : 'Delete "$name"? Existing transactions will still keep the old category id, so only remove categories you no longer need.';
  String get categoryDeleted =>
      isBangla ? 'ক্যাটাগরি মুছে ফেলা হয়েছে।' : 'Category deleted.';
  String createCategoryTitle(String typeLabel) => isBangla
      ? '$typeLabel ক্যাটাগরি তৈরি করুন'
      : 'Create $typeLabel category';
  String get categoryAutoSelectHint => isBangla
      ? 'সংরক্ষণ করার পর নতুন ক্যাটাগরিটি নিজে থেকেই বেছে নেওয়া হবে।'
      : 'The new category will be selected automatically after you save it.';
  String get createWithLabel => isBangla ? 'তৈরির ধরন' : 'Create with';
  String get templateLabel => isBangla ? 'টেমপ্লেট' : 'Template';
  String get manualLabel => isBangla ? 'ম্যানুয়াল' : 'Manual';
  String get categoryTemplateLabel =>
      isBangla ? 'ক্যাটাগরি টেমপ্লেট' : 'Template';
  String get categoryNameLabel => isBangla ? 'ক্যাটাগরির নাম' : 'Category name';
  String get categoryNameHint =>
      isBangla ? 'ইংরেজি বা বাংলা লিখুন' : 'Write in English or Bangla';
  String get categoryNameHelper => isBangla
      ? 'সম্ভব হলে আমরা বিপরীত ভাষাটিও স্বয়ংক্রিয়ভাবে পূরণ করব।'
      : 'We will fill the opposite language automatically when possible.';
  String get chooseTemplateFirstError =>
      isBangla ? 'আগে একটি টেমপ্লেট বেছে নিন।' : 'Choose a template first.';
  String get writeCategoryNameError => isBangla
      ? 'ইংরেজি বা বাংলায় একটি ক্যাটাগরির নাম লিখুন।'
      : 'Write a category name in English or Bangla.';
  String get createCategoryAction =>
      isBangla ? 'ক্যাটাগরি তৈরি করুন' : 'Create category';
  String get useTemplateAction =>
      isBangla ? 'টেমপ্লেট ব্যবহার করুন' : 'Use template';
  String get chooseIconLabel => isBangla ? 'আইকন বেছে নিন' : 'Choose icon';
  String get chooseColorLabel => isBangla ? 'রং বেছে নিন' : 'Choose color';
  String get manualCategorySubtitle =>
      isBangla ? 'ম্যানুয়াল ক্যাটাগরি' : 'Manual category';
  String get categoryPreviewTitle =>
      isBangla ? 'ক্যাটাগরি প্রিভিউ' : 'Category preview';
  String get alreadyAvailableTitle =>
      isBangla ? 'ইতিমধ্যেই আছে' : 'Already available';
  String get quickCreateTitle => isBangla ? 'দ্রুত তৈরি' : 'Quick create';
  String get templateExistsSubtitle => isBangla
      ? 'এই টেমপ্লেটটি আগে থেকেই আছে। সংরক্ষণ করলে শুধু এটি নির্বাচন হবে।'
      : 'This template already exists. Saving will just select it.';
  String get templateReadySubtitle => isBangla
      ? 'দ্রুত এন্ট্রির জন্য এই টেমপ্লেটটি সঙ্গে সঙ্গে তৈরি করা যাবে।'
      : 'This template is ready to create instantly for faster entry.';

  String get budgetsTitleText => isBangla ? 'বাজেট' : 'Budgets';
  String get categoryBudgetsTitle =>
      isBangla ? 'ক্যাটাগরি বাজেট' : 'Category budgets';
  String get addBudgetAction => isBangla ? 'বাজেট যোগ করুন' : 'Add budget';
  String get deleteBudgetTitle => isBangla ? 'বাজেট মুছুন' : 'Delete budget';
  String get deleteBudgetPrompt =>
      isBangla ? 'এই বাজেট সীমা মুছবেন?' : 'Delete this budget limit?';
  String get budgetDeleted =>
      isBangla ? 'বাজেট মুছে ফেলা হয়েছে।' : 'Budget deleted.';
  String get overallSpendingLabel => isBangla ? 'মোট খরচ' : 'Overall spending';
  String budgetEditorTitle(bool isEditing) => isEditing
      ? (isBangla ? 'বাজেট সম্পাদনা' : 'Edit budget')
      : (isBangla ? 'বাজেট যোগ করুন' : 'Add budget');
  String get overallSpendingBudgetTitle =>
      isBangla ? 'মোট খরচের বাজেট' : 'Overall spending budget';
  String get categoryBudgetTitle =>
      isBangla ? 'ক্যাটাগরি বাজেট' : 'Category budget';
  String get budgetsAutoUpdateSubtitle => isBangla
      ? 'সম্পর্কিত ব্যয় বদলালে বাজেটের খরচ স্বয়ংক্রিয়ভাবে আপডেট হবে।'
      : 'Budgets update their spent amount automatically whenever related expenses change.';
  String get budgetTypeLabel => isBangla ? 'বাজেটের ধরন' : 'Budget type';
  String get budgetLimitLabel => isBangla ? 'বাজেট সীমা' : 'Budget limit';
  String get updateBudgetAction =>
      isBangla ? 'বাজেট আপডেট করুন' : 'Update budget';
  String get createBudgetAction =>
      isBangla ? 'বাজেট তৈরি করুন' : 'Create budget';
  String get validBudgetLimitError =>
      isBangla ? 'একটি সঠিক বাজেট সীমা দিন।' : 'Enter a valid budget limit.';
  String get budgetUpdated =>
      isBangla ? 'বাজেট আপডেট হয়েছে।' : 'Budget updated.';
  String get budgetCreated =>
      isBangla ? 'বাজেট তৈরি হয়েছে।' : 'Budget created.';
  String get overallMonthlyLimitLabel =>
      isBangla ? 'মোট মাসিক সীমা' : 'Overall monthly limit';
  String get categoryBudgetTotalLabel =>
      isBangla ? 'ক্যাটাগরি বাজেট মোট' : 'Category budget total';
  String percentUsedLabel(int percent) =>
      isBangla ? '$percent% ব্যবহার হয়েছে' : '$percent% used';
  String get exceededLabel => isBangla ? 'সীমা ছাড়িয়েছে' : 'Exceeded';
  String get warningLabel => isBangla ? 'সতর্কতা' : 'Warning';
  String get onTrackLabel => isBangla ? 'সঠিক পথে' : 'On track';
  String get noBudgetsYetTitle =>
      isBangla ? 'এখনও কোনো বাজেট নেই' : 'No budgets yet';
  String get noBudgetsYetSubtitle => isBangla
      ? 'এই মাসের জন্য মোট বা ক্যাটাগরি বাজেট সেট করুন।'
      : 'Set an overall or category budget for this month to start tracking spending progress.';

  String get goalsTitleText => isBangla ? 'লক্ষ্য' : 'Goals';
  String get activeGoalsTitle => isBangla ? 'সক্রিয় লক্ষ্য' : 'Active goals';
  String get addGoalAction => isBangla ? 'লক্ষ্য যোগ করুন' : 'Add goal';
  String get noActiveGoalTitle =>
      isBangla ? 'এখনও কোনো সক্রিয় লক্ষ্য নেই' : 'No active goal yet';
  String get noActiveGoalSubtitle => isBangla
      ? 'ইমার্জেন্সি ফান্ড, ভ্রমণ, নতুন ডিভাইস বা যেকোনো কিছুর জন্য লক্ষ্য বানান।'
      : 'Create a goal for emergency savings, a trip, a new device, or anything you want to save for.';
  String completedGoalsTitle(int count) =>
      isBangla ? 'সম্পন্ন লক্ষ্য ($count)' : 'Completed goals ($count)';
  String get deleteGoalTitle => isBangla ? 'লক্ষ্য মুছুন' : 'Delete goal';
  String get deleteSavingsGoalPrompt =>
      isBangla ? 'এই সেভিংস লক্ষ্য মুছবেন?' : 'Delete this savings goal?';
  String get goalDeleted =>
      isBangla ? 'লক্ষ্য মুছে ফেলা হয়েছে।' : 'Goal deleted.';
  String get savingsGoalsTitle => isBangla ? 'সেভিংস লক্ষ্য' : 'Savings goals';
  String savingsGoalsSubtitle(String? topGoalName) => topGoalName == null
      ? (isBangla
            ? 'যে জিনিসগুলোর জন্য সঞ্চয় করতে চান সেগুলোর লক্ষ্য বানান এবং অগ্রগতি দৃশ্যমান রাখুন।'
            : 'Create goals for the things you want to save toward and keep your progress visible.')
      : (isBangla
            ? 'শীর্ষ সক্রিয় লক্ষ্য: $topGoalName'
            : 'Top active goal: $topGoalName');
  String goalSavedOf(String saved, String target) =>
      isBangla ? '$saved সেভ হয়েছে, লক্ষ্য $target' : '$saved of $target saved';
  String get completedStatus => isBangla ? 'সম্পন্ন' : 'Completed';
  String get contributeAction => isBangla ? 'অবদান দিন' : 'Contribute';
  String goalTargetSummary(String amount, String date) =>
      isBangla ? 'লক্ষ্য $amount • $date' : 'Target $amount • $date';
  String goalEditorTitle(bool isEditing) => isEditing
      ? (isBangla ? 'লক্ষ্য সম্পাদনা' : 'Edit goal')
      : (isBangla ? 'লক্ষ্য যোগ করুন' : 'Add goal');
  String goalHeaderSubtitle(bool isEditing) => isEditing
      ? (isBangla
            ? 'আপনার সেভিংস লক্ষ্য আপডেট করুন'
            : 'Update your savings target')
      : (isBangla
            ? 'নতুন একটি সেভিংস লক্ষ্য তৈরি করুন'
            : 'Create a new savings target');
  String get goalNameLabel => isBangla ? 'লক্ষ্যের নাম' : 'Goal name';
  String get goalNameHint => isBangla
      ? 'ইমার্জেন্সি ফান্ড, ল্যাপটপ, ভ্রমণ, বাইক'
      : 'Emergency fund, Laptop, Trip, Bike';
  String get targetAmountLabel =>
      isBangla ? 'লক্ষ্যের পরিমাণ' : 'Target amount';
  String get targetDateLabel => isBangla ? 'লক্ষ্যের তারিখ' : 'Target date';
  String get changeAction => isBangla ? 'পরিবর্তন করুন' : 'Change';
  String get iconLabel => isBangla ? 'আইকন' : 'Icon';
  String get colorLabel => isBangla ? 'রং' : 'Color';
  String get saveGoalAction => isBangla ? 'লক্ষ্য সংরক্ষণ করুন' : 'Save goal';
  String get createGoalAction => isBangla ? 'লক্ষ্য তৈরি করুন' : 'Create goal';
  String get enterGoalNameError =>
      isBangla ? 'লক্ষ্যের নাম লিখুন।' : 'Please enter a goal name.';
  String get enterTargetAmountError => isBangla
      ? 'সঠিক লক্ষ্য পরিমাণ দিন।'
      : 'Please enter a valid target amount.';
  String get goalUpdated =>
      isBangla ? 'লক্ষ্য সফলভাবে আপডেট হয়েছে।' : 'Goal updated successfully.';
  String get goalCreated =>
      isBangla ? 'লক্ষ্য সফলভাবে তৈরি হয়েছে।' : 'Goal created successfully.';
  String deleteNamedGoalPrompt(String name) =>
      isBangla ? '"$name" মুছবেন?' : 'Delete "$name"?';
  String get contributeToGoalTitle =>
      isBangla ? 'লক্ষ্যে অবদান দিন' : 'Contribute to goal';
  String contributionSavedOf(String saved, String target) =>
      isBangla ? '$saved সেভ হয়েছে, লক্ষ্য $target' : '$saved saved of $target';
  String get contributionAmountLabel =>
      isBangla ? 'অবদানের পরিমাণ' : 'Contribution amount';
  String get noWalletForGoalSubtitle => isBangla
      ? 'লক্ষ্যে অবদান দেওয়ার আগে একটি ওয়ালেট তৈরি করুন।'
      : 'Create a wallet before contributing to a goal.';
  String get sourceWalletLabel => isBangla ? 'উৎস ওয়ালেট' : 'Source wallet';
  String get contributionNoteHint => isBangla
      ? 'এই অবদানের জন্য ঐচ্ছিক নোট।'
      : 'Optional note for this contribution.';
  String get addContributionAction =>
      isBangla ? 'অবদান যোগ করুন' : 'Add contribution';
  String get validContributionAmountError => isBangla
      ? 'সঠিক অবদানের পরিমাণ দিন।'
      : 'Please enter a valid contribution amount.';
  String get chooseSourceWalletError =>
      isBangla ? 'একটি উৎস ওয়ালেট বেছে নিন।' : 'Please choose a source wallet.';
  String goalCompletedMessage(String name) => isBangla
      ? 'লক্ষ্য সম্পন্ন! $name পুরোপুরি পূরণ হয়েছে।'
      : 'Goal completed! $name is fully funded.';
  String get contributionAdded => isBangla
      ? 'অবদান সফলভাবে যোগ হয়েছে।'
      : 'Contribution added successfully.';
  String get goalCompletedTitleText =>
      isBangla ? 'লক্ষ্য সম্পন্ন' : 'Goal completed';
  String goalCompletedDialog(String name) => isBangla
      ? 'আপনি "$name" এর লক্ষ্য পূরণ করেছেন। দারুণ কাজ।'
      : 'You reached your target for "$name". Nice work.';
  String get greatAction => isBangla ? 'দারুণ' : 'Great';

  String get billsTitleText => isBangla ? 'বিল' : 'Bills';
  String get upcomingTabLabel => isBangla ? 'আসন্ন' : 'Upcoming';
  String get paidThisMonthTabLabel =>
      isBangla ? 'এই মাসে পরিশোধিত' : 'Paid this month';
  String get noBillDueSoonTitle =>
      isBangla ? 'শিগগির কোনো বিল নেই' : 'No bill due soon';
  String get noBillDueSoonSubtitle => isBangla
      ? 'ভাড়া, ইন্টারনেট, ইউটিলিটি বা যেকোনো রিকারিং বিল যোগ করুন।'
      : 'Add recurring rent, internet, utilities, or any subscription you want to track.';
  String get noBillCreatedYetTitle =>
      isBangla ? 'এখনও কোনো বিল তৈরি হয়নি' : 'No bill created yet';
  String get noBillCreatedYetSubtitle => isBangla
      ? 'প্রথম রিকারিং বিল তৈরি করুন, অ্যাপ এটি গুছানো রাখবে।'
      : 'Create your first recurring bill and the app will keep it organized here.';
  String get nothingPaidThisMonthTitle =>
      isBangla ? 'এই মাসে কিছুই পরিশোধ হয়নি' : 'Nothing paid this month';
  String get nothingPaidThisMonthSubtitle => isBangla
      ? 'যে বিলগুলো পরিশোধিত হিসেবে চিহ্নিত করবেন, সেগুলো এখানে দেখা যাবে।'
      : 'Bills you mark as paid will show up here during the current month.';
  String get addBillAction => isBangla ? 'বিল যোগ করুন' : 'Add bill';
  String get recurringBillsSnapshotTitle =>
      isBangla ? 'রিকারিং বিলের সারাংশ' : 'Recurring bills snapshot';
  String get recurringBillsSnapshotSubtitle => isBangla
      ? 'আসন্ন তারিখ দেখুন, রিকারিং খরচ গুছিয়ে রাখুন, আর এক ক্লিকে পরিশোধিত হিসেবে চিহ্নিত করুন।'
      : 'Track upcoming due dates, keep recurring expenses organized, and mark bills as paid in one move.';
  String get dueSoonLabel => isBangla ? 'শিগগির বাকি' : 'Due soon';
  String scheduledAmount(String amount) =>
      isBangla ? '$amount নির্ধারিত' : '$amount scheduled';
  String clearedAmount(String amount) =>
      isBangla ? '$amount পরিশোধিত' : '$amount cleared';
  String billMarkedPaid(String name) => isBangla
      ? '$name পরিশোধিত হিসেবে চিহ্নিত হয়েছে।'
      : '$name marked as paid.';
  String get markAsPaidAction =>
      isBangla ? 'পরিশোধিত চিহ্নিত করুন' : 'Mark as paid';
  String get nextDueLabel => isBangla ? 'পরবর্তী তারিখ' : 'Next due';
  String get deleteBillTitle => isBangla ? 'বিল মুছুন' : 'Delete bill';
  String deleteNamedBillPrompt(String name) =>
      isBangla ? '"$name" মুছবেন?' : 'Delete "$name"?';
  String get billDeleted => isBangla ? 'বিল মুছে ফেলা হয়েছে।' : 'Bill deleted.';
  String get billNameLabel => isBangla ? 'বিলের নাম' : 'Bill name';
  String get billNameHint => isBangla
      ? 'ইন্টারনেট, ভাড়া, নেটফ্লিক্স, বিদ্যুৎ'
      : 'Internet, Rent, Netflix, Electricity';
  String get expenseCategoryLabel =>
      isBangla ? 'ব্যয়ের ক্যাটাগরি' : 'Expense category';
  String get nextDueDateLabel =>
      isBangla ? 'পরবর্তী প্রদানের তারিখ' : 'Next due date';
  String get reminderLabel => isBangla ? 'রিমাইন্ডার' : 'Reminder';
  String get sameDayLabel => isBangla ? 'সেই দিন' : 'Same day';
  String get oneDayBeforeLabel => isBangla ? '১ দিন আগে' : '1 day before';
  String get twoDaysBeforeLabel => isBangla ? '২ দিন আগে' : '2 days before';
  String get threeDaysBeforeLabel => isBangla ? '৩ দিন আগে' : '3 days before';
  String get sevenDaysBeforeLabel => isBangla ? '৭ দিন আগে' : '7 days before';
  String get enterBillNameError =>
      isBangla ? 'বিলের নাম লিখুন।' : 'Please enter a bill name.';
  String get validBillAmountError =>
      isBangla ? 'সঠিক পরিমাণ দিন।' : 'Please enter a valid amount.';
  String get chooseCategoryWalletError => isBangla
      ? 'একটি ক্যাটাগরি ও ওয়ালেট বেছে নিন।'
      : 'Please choose a category and wallet.';
  String get billEditorNeedsDataTitle => isBangla
      ? 'বিলের জন্য ক্যাটাগরি ও ওয়ালেট দরকার'
      : 'Bills need categories and wallets';
  String get billEditorNeedsDataSubtitle => isBangla
      ? 'স্টার্টার ফাইন্যান্স ডাটা লোড হলে এই পেজ আবার খুলুন।'
      : 'Make sure the starter finance data has loaded, then open this page again.';
  String billEditorTitle(bool isEditing) => isEditing
      ? (isBangla ? 'বিল সম্পাদনা' : 'Edit bill')
      : (isBangla ? 'বিল যোগ করুন' : 'Add bill');
  String billHeaderSubtitle(bool isEditing) => isEditing
      ? (isBangla ? 'রিকারিং বিল আপডেট করুন' : 'Update recurring bill')
      : (isBangla ? 'রিকারিং বিল তৈরি করুন' : 'Create recurring bill');
  String get billAutoCreateHint => isBangla
      ? 'আপনি এই বিল পরিশোধিত চিহ্নিত করলে অ্যাপ একটি বাস্তব ব্যয় লেনদেন তৈরি করবে এবং পরবর্তী তারিখ এগিয়ে দেবে।'
      : 'When you mark this bill as paid, the app creates a real expense transaction and moves the next due date forward automatically.';
  String get billUpdated =>
      isBangla ? 'বিল সফলভাবে আপডেট হয়েছে।' : 'Bill updated successfully.';
  String get billCreated =>
      isBangla ? 'বিল সফলভাবে তৈরি হয়েছে।' : 'Bill created successfully.';

  String transferEditorTitle(bool isEditing) => isEditing
      ? (isBangla ? 'ট্রান্সফার সম্পাদনা' : 'Edit transfer')
      : (isBangla ? 'টাকা ট্রান্সফার' : 'Transfer money');
  String transferHeaderTitle(bool isEditing) => isEditing
      ? (isBangla ? 'ওয়ালেট ট্রান্সফার আপডেট করুন' : 'Update wallet transfer')
      : (isBangla ? 'ওয়ালেটের মধ্যে টাকা সরান' : 'Move money between wallets');
  String get transferHeaderSubtitle => isBangla
      ? 'ট্রান্সফার একসাথে দুই ওয়ালেটের ব্যালেন্স আপডেট করে এবং হিস্টরিতে সংযুক্ত থাকে।'
      : 'Transfers update both wallet balances together and stay linked in history.';
  String get fromWalletLabel => isBangla ? 'যে ওয়ালেট থেকে' : 'From wallet';
  String get toWalletLabel => isBangla ? 'যে ওয়ালেটে' : 'To wallet';
  String get optionalTransferNoteHint =>
      isBangla ? 'ঐচ্ছিক ট্রান্সফার নোট' : 'Optional transfer note';
  String get validTransferAmountError => isBangla
      ? 'সঠিক ট্রান্সফার পরিমাণ দিন।'
      : 'Enter a valid transfer amount.';
  String get chooseBothWalletsError => isBangla
      ? 'এই ট্রান্সফারের জন্য দুটি ওয়ালেটই বেছে নিন।'
      : 'Choose both wallets for this transfer.';
  String get differentWalletsError => isBangla
      ? 'দুটি আলাদা ওয়ালেট হতে হবে।'
      : 'From and to wallets must be different.';
  String get transferDetailsLoadingError => isBangla
      ? 'ট্রান্সফারের বিস্তারিত এখনও লোড হচ্ছে। আবার চেষ্টা করুন।'
      : 'Transfer details are still loading. Try again.';
  String get transferDeleted =>
      isBangla ? 'ট্রান্সফার মুছে ফেলা হয়েছে।' : 'Transfer deleted.';
  String get transferUpdated =>
      isBangla ? 'ট্রান্সফার আপডেট হয়েছে।' : 'Transfer updated.';
  String get transferCompleted =>
      isBangla ? 'ট্রান্সফার সম্পন্ন হয়েছে।' : 'Transfer completed.';

  String walletEditorTitle(bool isEditing) => isEditing
      ? (isBangla ? 'ওয়ালেট সম্পাদনা' : 'Edit wallet')
      : (isBangla ? 'ওয়ালেট যোগ করুন' : 'Add wallet');
  String get walletPreviewTitle =>
      isBangla ? 'ওয়ালেট প্রিভিউ' : 'Wallet preview';
  String get walletNameFieldLabel => isBangla ? 'ওয়ালেটের নাম' : 'Wallet name';
  String get walletTypeFieldLabel => isBangla ? 'ওয়ালেটের ধরন' : 'Wallet type';
  String get currentBalanceFieldLabel =>
      isBangla ? 'বর্তমান ব্যালেন্স' : 'Current balance';
  String get currentBalanceFieldHint => isBangla
      ? 'লেনদেন ও ট্রান্সফার অনুযায়ী ব্যালেন্স স্বয়ংক্রিয়ভাবে আপডেট হয়।'
      : 'Balance follows transactions and transfers automatically.';
  String get initialBalanceFieldLabel =>
      isBangla ? 'শুরুর ব্যালেন্স' : 'Initial balance';
  String get setAsDefaultWalletLabel =>
      isBangla ? 'ডিফল্ট ওয়ালেট হিসেবে সেট করুন' : 'Set as default wallet';
  String get walletNameRequired =>
      isBangla ? 'একটি ওয়ালেটের নাম লিখুন।' : 'Please enter a wallet name.';
  String get walletUpdated =>
      isBangla ? 'ওয়ালেট আপডেট হয়েছে।' : 'Wallet updated.';
  String get walletCreated =>
      isBangla ? 'ওয়ালেট তৈরি হয়েছে।' : 'Wallet created.';
  String get updateWalletAction =>
      isBangla ? 'ওয়ালেট আপডেট করুন' : 'Update wallet';
  String get createWalletAction =>
      isBangla ? 'ওয়ালেট তৈরি করুন' : 'Create wallet';
  String walletTypeName(String type) {
    switch (type) {
      case 'cash':
        return isBangla ? 'ক্যাশ' : 'Cash';
      case 'bank':
        return isBangla ? 'ব্যাংক' : 'Bank';
      case 'bkash':
        return 'bKash';
      case 'nagad':
        return 'Nagad';
      case 'savings':
        return isBangla ? 'সেভিংস' : 'Savings';
      default:
        return type;
    }
  }

  String get calendarMonthViewLabel => isBangla ? 'মাস' : 'Month';
  String get calendarWeekViewLabel => isBangla ? 'সপ্তাহ' : 'Week';
  String get calendarLoadingTitle =>
      isBangla ? 'ক্যালেন্ডার লোড হচ্ছে' : 'Calendar is loading';
  String get selectMonthHelp => isBangla ? 'মাস বেছে নিন' : 'Select month';
  String get calendarSelectedDaySubtitle => isBangla
      ? 'নির্বাচিত দিনের আয়, ব্যয় ও লেনদেনের বিস্তারিত'
      : 'Income, expense, and transaction details for the selected day.';
  String get noTransactionsOnDayTitle =>
      isBangla ? 'এই দিনে কোনো লেনদেন নেই' : 'No transaction on this day';
  String get noTransactionsOnDaySubtitle => isBangla
      ? 'অন্য একটি তারিখ বেছে নিন বা নতুন এন্ট্রি যোগ করুন।'
      : 'Pick another date or add a new entry to start building your calendar.';
  String get debtsTitleText => isBangla ? 'ধার ও ঋণ' : 'Debts & loans';
  String get borrowedTabLabel => isBangla ? 'ধার করা' : 'Borrowed';
  String get lentTabLabel => isBangla ? 'ধার দেওয়া' : 'Lent';
  String get debtBorrowedTypeLabel =>
      isBangla ? 'আমি এখনো পরিশোধ করিনি' : 'You still owe this amount';
  String get debtLentTypeLabel =>
      isBangla ? 'অন্যজন এখনো ফেরত দেয়নি' : 'They still owe you this amount';
  String get addDebtAction => isBangla ? 'ধার/ঋণ যোগ করুন' : 'Add debt';
  String get debtTrackerHeroTitle =>
      isBangla ? 'ধার ও ঋণের সারাংশ' : 'Debt and loan snapshot';
  String get debtTrackerHeroSubtitle => isBangla
      ? 'কে কত পাবে, কাকে কত দিতে হবে, আর কোনগুলো দ্রুত ফলো-আপ দরকার তা এক জায়গায় দেখুন।'
      : 'Track what you owe, what others owe you, and which items need follow-up soon.';
  String get totalOwedLabel => isBangla ? 'মোট দিতে হবে' : 'Total owed';
  String get totalReceivableLabel =>
      isBangla ? 'মোট পাবেন' : 'Total receivable';
  String get noDebtRecordsYet => isBangla
      ? 'এখনও কোনো ধার বা ঋণের রেকর্ড নেই।'
      : 'No debt or loan records yet.';
  String overdueDebtCountLabel(int count) =>
      isBangla ? '$count টি ওভারডিউ' : '$count overdue';
  String dueSoonDebtCountLabel(int count) =>
      isBangla ? '$count টি দ্রুত ফলো-আপ' : '$count due soon';
  String activeBorrowedCountLabel(int count) =>
      isBangla ? '$count টি ধার করা' : '$count borrowed';
  String activeLentCountLabel(int count) =>
      isBangla ? '$count টি ধার দেওয়া' : '$count lent';
  String get noBorrowedDebtTitle =>
      isBangla ? 'কোনো ধার করা টাকা নেই' : 'No borrowed money yet';
  String get noBorrowedDebtSubtitle => isBangla
      ? 'আপনি কারও কাছ থেকে টাকা নিয়ে থাকলে এখানে যোগ করুন, যাতে কত বাকি আছে তা দেখা যায়।'
      : 'Add money you borrowed from someone so the remaining balance stays visible.';
  String get noLentDebtTitle =>
      isBangla ? 'কোনো ধার দেওয়া টাকা নেই' : 'No lent money yet';
  String get noLentDebtSubtitle => isBangla
      ? 'আপনি কাউকে টাকা ধার দিলে এখানে রাখুন, যাতে ফেরত পাওয়ার অগ্রগতি দেখা যায়।'
      : 'Track money you lent to someone so repayments stay organized.';
  String settledDebtsTitle(int count) =>
      isBangla ? 'সেটেলড রেকর্ড ($count)' : 'Settled records ($count)';
  String get settledLabel => isBangla ? 'সেটেলড' : 'Settled';
  String get overdueLabel => isBangla ? 'ওভারডিউ' : 'Overdue';
  String get remainingLabel => isBangla ? 'বাকি' : 'Remaining';
  String get paidLabel => isBangla ? 'পরিশোধিত' : 'Paid';
  String get installmentsLabel => isBangla ? 'কিস্তি' : 'Installments';
  String installmentPlanLabel(String amount, String count) => isBangla
      ? '$count কিস্তিতে প্রতি কিস্তি $amount'
      : '$amount per installment across $count installments';
  String get recordPaymentAction =>
      isBangla ? 'পেমেন্ট যোগ করুন' : 'Record payment';
  String get paymentHistoryTitle =>
      isBangla ? 'পেমেন্ট হিস্ট্রি' : 'Payment history';
  String debtEditorTitle(bool isEditing) => isEditing
      ? (isBangla ? 'ধার/ঋণ সম্পাদনা' : 'Edit debt')
      : (isBangla ? 'ধার/ঋণ যোগ করুন' : 'Add debt');
  String get debtBorrowedHeroTitle =>
      isBangla ? 'ধার করা টাকার রেকর্ড' : 'Track borrowed money';
  String get debtBorrowedHeroSubtitle => isBangla
      ? 'আপনি কার কাছ থেকে নিয়েছেন, কত নিয়েছেন, আর কবে ফেরত দেবেন তা সংরক্ষণ করুন।'
      : 'Save who you borrowed from, how much it was, and when you expect to repay it.';
  String get debtLentHeroTitle =>
      isBangla ? 'ধার দেওয়া টাকার রেকর্ড' : 'Track lent money';
  String get debtLentHeroSubtitle => isBangla
      ? 'আপনি কাকে দিয়েছেন, কত দিয়েছেন, আর কবে ফেরত পাওয়ার কথা তা লিখে রাখুন।'
      : 'Track who received your money, how much they owe, and when it should return.';
  String get debtPersonNameLabel => isBangla ? 'ব্যক্তির নাম' : 'Person name';
  String get debtAmountLabel => isBangla ? 'মোট পরিমাণ' : 'Total amount';
  String get debtStartDateLabel => isBangla ? 'শুরুর তারিখ' : 'Start date';
  String get debtDueDateLabel => isBangla ? 'পরিশোধ/ফেরতের তারিখ' : 'Due date';
  String debtDueDateLabelWithValue(String date) =>
      isBangla ? 'ডিউ তারিখ: $date' : 'Due date: $date';
  String get debtNoteHint => isBangla
      ? 'ঐচ্ছিক নোট, যেমন কেন টাকা নেওয়া/দেওয়া হয়েছিল।'
      : 'Optional note, such as why this money was borrowed or lent.';
  String get debtNameRequiredError =>
      isBangla ? 'একটি নাম লিখুন।' : 'Please enter a person name.';
  String get validDebtAmountError =>
      isBangla ? 'সঠিক পরিমাণ লিখুন।' : 'Please enter a valid amount.';
  String get validInstallmentsError => isBangla
      ? 'কিস্তির সংখ্যা ১ বা তার বেশি হতে হবে।'
      : 'Installments must be at least 1.';
  String get debtDueDateAfterStartError => isBangla
      ? 'ডিউ তারিখ শুরুর তারিখের আগে হতে পারবে না।'
      : 'Due date cannot be earlier than the start date.';
  String debtAmountLowerThanPaidError(String paidAmount) => isBangla
      ? 'মোট পরিমাণ ইতিমধ্যে পরিশোধিত $paidAmount এর কম হতে পারবে না।'
      : 'Total amount cannot be less than the already paid $paidAmount.';
  String get debtCreated =>
      isBangla ? 'ধার/ঋণের রেকর্ড তৈরি হয়েছে।' : 'Debt record created.';
  String get debtUpdated =>
      isBangla ? 'ধার/ঋণের রেকর্ড আপডেট হয়েছে।' : 'Debt record updated.';
  String get deleteDebtTitle => isBangla ? 'ধার/ঋণ মুছুন' : 'Delete debt';
  String deleteNamedDebtPrompt(String name) =>
      isBangla ? '"$name" রেকর্ডটি মুছবেন?' : 'Delete "$name"?';
  String get debtDeleted =>
      isBangla ? 'ধার/ঋণের রেকর্ড মুছে ফেলা হয়েছে।' : 'Debt record deleted.';
  String get paymentEditorTitle =>
      isBangla ? 'পেমেন্ট যোগ করুন' : 'Record payment';
  String get paymentAmountLabel =>
      isBangla ? 'পেমেন্টের পরিমাণ' : 'Payment amount';
  String get paymentDateLabel => isBangla ? 'পেমেন্টের তারিখ' : 'Payment date';
  String get paymentNoteHint => isBangla
      ? 'ঐচ্ছিক নোট, যেমন কিস্তি, ব্যাংক ট্রান্সফার, নগদ ইত্যাদি।'
      : 'Optional note such as installment, bank transfer, or cash.';
  String get validPaymentAmountError => isBangla
      ? 'সঠিক পেমেন্টের পরিমাণ লিখুন।'
      : 'Please enter a valid payment amount.';
  String get paymentExceedsRemainingError => isBangla
      ? 'এই পেমেন্ট বাকি পরিমাণের চেয়ে বেশি।'
      : 'This payment is higher than the remaining amount.';
  String get paymentAdded =>
      isBangla ? 'পেমেন্ট যোগ করা হয়েছে।' : 'Payment recorded.';
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
