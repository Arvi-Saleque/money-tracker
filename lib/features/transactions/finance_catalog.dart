import 'package:flutter/material.dart';

import '../../shared/models/category_model.dart';
import '../../shared/models/transaction_model.dart';
import '../../shared/models/wallet_model.dart';

class FinanceIconOption {
  const FinanceIconOption({required this.key, required this.icon});

  final String key;
  final IconData icon;
}

class FinanceCategoryTemplate {
  const FinanceCategoryTemplate({
    required this.id,
    required this.name,
    required this.nameBn,
    required this.iconKey,
    required this.colorValue,
    required this.type,
    this.isDefault = false,
  });

  final String id;
  final String name;
  final String nameBn;
  final String iconKey;
  final int colorValue;
  final String type;
  final bool isDefault;

  CategoryModel toCategoryModel({
    String? id,
    bool? isDefault,
    DateTime? createdAt,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name,
      nameBn: nameBn,
      iconKey: iconKey,
      colorValue: colorValue,
      type: type,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? DateTime.now(),
    );
  }
}

class FinanceWalletTemplate {
  const FinanceWalletTemplate({
    required this.id,
    required this.name,
    required this.type,
    required this.iconKey,
    required this.colorValue,
    this.isDefault = false,
  });

  final String id;
  final String name;
  final String type;
  final String iconKey;
  final int colorValue;
  final bool isDefault;

  WalletModel toWalletModel({DateTime? createdAt}) {
    return WalletModel(
      id: id,
      name: name,
      type: type,
      balance: 0,
      iconKey: iconKey,
      colorValue: colorValue,
      isDefault: isDefault,
      createdAt: createdAt ?? DateTime.now(),
    );
  }
}

class FinanceWalletTypeOption {
  const FinanceWalletTypeOption({
    required this.type,
    required this.label,
    required this.iconKey,
    required this.colorValue,
  });

  final String type;
  final String label;
  final String iconKey;
  final int colorValue;
}

abstract final class FinanceCatalog {
  static const String incomeType = 'income';
  static const String expenseType = 'expense';
  static const String transferType = 'transfer';
  static const String goalContributionCategoryId = 'expense_savings_goal';
  static const String walletTypeCash = 'cash';
  static const String walletTypeBank = 'bank';
  static const String walletTypeBkash = 'bkash';
  static const String walletTypeNagad = 'nagad';
  static const String walletTypeSavings = 'savings';

  static const List<FinanceIconOption> categoryIcons = <FinanceIconOption>[
    FinanceIconOption(key: 'shopping_basket', icon: Icons.shopping_basket),
    FinanceIconOption(key: 'directions_bus', icon: Icons.directions_bus),
    FinanceIconOption(key: 'fastfood', icon: Icons.fastfood),
    FinanceIconOption(key: 'receipt_long', icon: Icons.receipt_long),
    FinanceIconOption(key: 'medical_services', icon: Icons.medical_services),
    FinanceIconOption(key: 'school', icon: Icons.school),
    FinanceIconOption(key: 'shopping_bag', icon: Icons.shopping_bag),
    FinanceIconOption(key: 'movie', icon: Icons.movie),
    FinanceIconOption(key: 'redeem', icon: Icons.redeem),
    FinanceIconOption(key: 'home', icon: Icons.home),
    FinanceIconOption(key: 'category', icon: Icons.category),
    FinanceIconOption(key: 'work', icon: Icons.work),
    FinanceIconOption(key: 'storefront', icon: Icons.storefront),
    FinanceIconOption(
      key: 'volunteer_activism',
      icon: Icons.volunteer_activism,
    ),
    FinanceIconOption(
      key: 'account_balance_wallet',
      icon: Icons.account_balance_wallet,
    ),
    FinanceIconOption(key: 'account_balance', icon: Icons.account_balance),
    FinanceIconOption(key: 'phone_android', icon: Icons.phone_android),
    FinanceIconOption(key: 'credit_card', icon: Icons.credit_card),
    FinanceIconOption(key: 'savings', icon: Icons.savings),
    FinanceIconOption(key: 'bolt', icon: Icons.bolt),
    FinanceIconOption(key: 'flight', icon: Icons.flight),
    FinanceIconOption(key: 'favorite', icon: Icons.favorite),
    FinanceIconOption(key: 'subscriptions', icon: Icons.subscriptions),
    FinanceIconOption(key: 'sports_esports', icon: Icons.sports_esports),
    FinanceIconOption(key: 'devices', icon: Icons.devices),
    FinanceIconOption(key: 'swap_horiz', icon: Icons.swap_horiz_rounded),
  ];

  static const List<int> colorChoices = <int>[
    0xFF3D6BE4,
    0xFF2ECC9A,
    0xFFE85D5D,
    0xFFF59E0B,
    0xFF8B5CF6,
    0xFF06B6D4,
    0xFFEC4899,
    0xFF84CC16,
    0xFF64748B,
  ];

  static const List<FinanceWalletTemplate> starterWallets =
      <FinanceWalletTemplate>[
        FinanceWalletTemplate(
          id: 'wallet_cash',
          name: 'Cash',
          type: walletTypeCash,
          iconKey: 'account_balance_wallet',
          colorValue: 0xFF3D6BE4,
          isDefault: true,
        ),
        FinanceWalletTemplate(
          id: 'wallet_bkash',
          name: 'bKash',
          type: walletTypeBkash,
          iconKey: 'phone_android',
          colorValue: 0xFFE2136E,
        ),
        FinanceWalletTemplate(
          id: 'wallet_nagad',
          name: 'Nagad',
          type: walletTypeNagad,
          iconKey: 'phone_android',
          colorValue: 0xFFF97316,
        ),
        FinanceWalletTemplate(
          id: 'wallet_bank',
          name: 'Bank',
          type: walletTypeBank,
          iconKey: 'account_balance',
          colorValue: 0xFF16A34A,
        ),
        FinanceWalletTemplate(
          id: 'wallet_savings',
          name: 'Savings',
          type: walletTypeSavings,
          iconKey: 'savings',
          colorValue: 0xFF8B5CF6,
        ),
      ];

  static const List<FinanceWalletTypeOption> walletTypes =
      <FinanceWalletTypeOption>[
        FinanceWalletTypeOption(
          type: walletTypeCash,
          label: 'Cash',
          iconKey: 'account_balance_wallet',
          colorValue: 0xFF3D6BE4,
        ),
        FinanceWalletTypeOption(
          type: walletTypeBank,
          label: 'Bank',
          iconKey: 'account_balance',
          colorValue: 0xFF16A34A,
        ),
        FinanceWalletTypeOption(
          type: walletTypeBkash,
          label: 'bKash',
          iconKey: 'phone_android',
          colorValue: 0xFFE2136E,
        ),
        FinanceWalletTypeOption(
          type: walletTypeNagad,
          label: 'Nagad',
          iconKey: 'phone_android',
          colorValue: 0xFFF97316,
        ),
        FinanceWalletTypeOption(
          type: walletTypeSavings,
          label: 'Savings',
          iconKey: 'savings',
          colorValue: 0xFF8B5CF6,
        ),
      ];

  static const List<FinanceCategoryTemplate>
  defaultCategoryTemplates = <FinanceCategoryTemplate>[
    FinanceCategoryTemplate(
      id: 'expense_groceries',
      name: 'Groceries',
      nameBn: '\u09AE\u09C1\u09A6\u09BF\u0996\u09BE\u09A8\u09BE',
      iconKey: 'shopping_basket',
      colorValue: 0xFF22C55E,
      type: expenseType,
      isDefault: true,
    ),
    FinanceCategoryTemplate(
      id: 'expense_transport',
      name: 'Transport',
      nameBn: '\u09AF\u09BE\u09A4\u09BE\u09AF\u09BC\u09BE\u09A4',
      iconKey: 'directions_bus',
      colorValue: 0xFF06B6D4,
      type: expenseType,
      isDefault: true,
    ),
    FinanceCategoryTemplate(
      id: 'expense_food',
      name: 'Food',
      nameBn: '\u0996\u09BE\u09AC\u09BE\u09B0',
      iconKey: 'fastfood',
      colorValue: 0xFFF97316,
      type: expenseType,
      isDefault: true,
    ),
    FinanceCategoryTemplate(
      id: 'expense_bills',
      name: 'Bills',
      nameBn: '\u09AC\u09BF\u09B2',
      iconKey: 'receipt_long',
      colorValue: 0xFFEF4444,
      type: expenseType,
      isDefault: true,
    ),
    FinanceCategoryTemplate(
      id: 'expense_medical',
      name: 'Medical',
      nameBn: '\u099A\u09BF\u0995\u09BF\u09CE\u09B8\u09BE',
      iconKey: 'medical_services',
      colorValue: 0xFF8B5CF6,
      type: expenseType,
      isDefault: true,
    ),
    FinanceCategoryTemplate(
      id: 'expense_education',
      name: 'Education',
      nameBn: '\u09B6\u09BF\u0995\u09CD\u09B7\u09BE',
      iconKey: 'school',
      colorValue: 0xFF14B8A6,
      type: expenseType,
      isDefault: true,
    ),
    FinanceCategoryTemplate(
      id: 'expense_shopping',
      name: 'Shopping',
      nameBn: '\u0995\u09C7\u09A8\u09BE\u0995\u09BE\u099F\u09BE',
      iconKey: 'shopping_bag',
      colorValue: 0xFFEC4899,
      type: expenseType,
      isDefault: true,
    ),
    FinanceCategoryTemplate(
      id: 'expense_entertainment',
      name: 'Entertainment',
      nameBn: '\u09AC\u09BF\u09A8\u09CB\u09A6\u09A8',
      iconKey: 'movie',
      colorValue: 0xFF6366F1,
      type: expenseType,
      isDefault: true,
    ),
    FinanceCategoryTemplate(
      id: 'expense_gift',
      name: 'Gift',
      nameBn: '\u0989\u09AA\u09B9\u09BE\u09B0',
      iconKey: 'redeem',
      colorValue: 0xFFF43F5E,
      type: expenseType,
      isDefault: true,
    ),
    FinanceCategoryTemplate(
      id: 'expense_rent',
      name: 'Rent',
      nameBn: '\u09AD\u09BE\u09DC\u09BE',
      iconKey: 'home',
      colorValue: 0xFF64748B,
      type: expenseType,
      isDefault: true,
    ),
    FinanceCategoryTemplate(
      id: goalContributionCategoryId,
      name: 'Savings Goal',
      nameBn:
          '\u09B8\u099E\u09CD\u099A\u09AF\u09BC \u09B2\u0995\u09CD\u09B7\u09CD\u09AF',
      iconKey: 'savings',
      colorValue: 0xFF8B5CF6,
      type: expenseType,
      isDefault: true,
    ),
    FinanceCategoryTemplate(
      id: 'expense_other',
      name: 'Other',
      nameBn: '\u0985\u09A8\u09CD\u09AF\u09BE\u09A8\u09CD\u09AF',
      iconKey: 'category',
      colorValue: 0xFF94A3B8,
      type: expenseType,
      isDefault: true,
    ),
    FinanceCategoryTemplate(
      id: 'income_salary',
      name: 'Salary',
      nameBn: '\u09AC\u09C7\u09A4\u09A8',
      iconKey: 'account_balance_wallet',
      colorValue: 0xFF10B981,
      type: incomeType,
      isDefault: true,
    ),
    FinanceCategoryTemplate(
      id: 'income_freelance',
      name: 'Freelance',
      nameBn:
          '\u09AB\u09CD\u09B0\u09BF\u09B2\u09CD\u09AF\u09BE\u09A8\u09CD\u09B8',
      iconKey: 'work',
      colorValue: 0xFF3B82F6,
      type: incomeType,
      isDefault: true,
    ),
    FinanceCategoryTemplate(
      id: 'income_business',
      name: 'Business',
      nameBn: '\u09AC\u09CD\u09AF\u09AC\u09B8\u09BE',
      iconKey: 'storefront',
      colorValue: 0xFFF59E0B,
      type: incomeType,
      isDefault: true,
    ),
    FinanceCategoryTemplate(
      id: 'income_gift_received',
      name: 'Gift Received',
      nameBn:
          '\u0989\u09AA\u09B9\u09BE\u09B0 \u09AA\u09C7\u09DF\u09C7\u099B\u09BF',
      iconKey: 'volunteer_activism',
      colorValue: 0xFFEC4899,
      type: incomeType,
      isDefault: true,
    ),
    FinanceCategoryTemplate(
      id: 'income_other',
      name: 'Other',
      nameBn: '\u0985\u09A8\u09CD\u09AF\u09BE\u09A8\u09CD\u09AF',
      iconKey: 'category',
      colorValue: 0xFF94A3B8,
      type: incomeType,
      isDefault: true,
    ),
  ];

  static const List<FinanceCategoryTemplate>
  quickCategoryTemplates = <FinanceCategoryTemplate>[
    FinanceCategoryTemplate(
      id: 'expense_mobile_recharge',
      name: 'Mobile Recharge',
      nameBn:
          '\u09AE\u09CB\u09AC\u09BE\u0987\u09B2 \u09B0\u09BF\u099A\u09BE\u09B0\u09CD\u099C',
      iconKey: 'phone_android',
      colorValue: 0xFF3D6BE4,
      type: expenseType,
    ),
    FinanceCategoryTemplate(
      id: 'expense_utilities',
      name: 'Utilities',
      nameBn: '\u0987\u0989\u099F\u09BF\u09B2\u09BF\u099F\u09BF\u099C',
      iconKey: 'bolt',
      colorValue: 0xFFF59E0B,
      type: expenseType,
    ),
    FinanceCategoryTemplate(
      id: 'expense_travel',
      name: 'Travel',
      nameBn: '\u09AD\u09CD\u09B0\u09AE\u09A3',
      iconKey: 'flight',
      colorValue: 0xFF06B6D4,
      type: expenseType,
    ),
    FinanceCategoryTemplate(
      id: 'expense_personal_care',
      name: 'Personal Care',
      nameBn:
          '\u09AC\u09CD\u09AF\u0995\u09CD\u09A4\u09BF\u0997\u09A4 \u09AF\u09A4\u09CD\u09A8',
      iconKey: 'favorite',
      colorValue: 0xFFEC4899,
      type: expenseType,
    ),
    FinanceCategoryTemplate(
      id: 'expense_subscriptions',
      name: 'Subscriptions',
      nameBn:
          '\u09B8\u09BE\u09AC\u09B8\u09CD\u0995\u09CD\u09B0\u09BF\u09AA\u09B6\u09A8',
      iconKey: 'subscriptions',
      colorValue: 0xFF8B5CF6,
      type: expenseType,
    ),
    FinanceCategoryTemplate(
      id: 'expense_gadgets',
      name: 'Gadgets',
      nameBn: '\u0997\u09CD\u09AF\u09BE\u099C\u09C7\u099F',
      iconKey: 'devices',
      colorValue: 0xFF64748B,
      type: expenseType,
    ),
    FinanceCategoryTemplate(
      id: 'expense_other_fast',
      name: 'Other',
      nameBn: '\u0985\u09A8\u09CD\u09AF\u09BE\u09A8\u09CD\u09AF',
      iconKey: 'category',
      colorValue: 0xFF94A3B8,
      type: expenseType,
    ),
    FinanceCategoryTemplate(
      id: 'income_bonus',
      name: 'Bonus',
      nameBn: '\u09AC\u09CB\u09A8\u09BE\u09B8',
      iconKey: 'redeem',
      colorValue: 0xFF2ECC9A,
      type: incomeType,
    ),
    FinanceCategoryTemplate(
      id: 'income_commission',
      name: 'Commission',
      nameBn: '\u0995\u09AE\u09BF\u09B6\u09A8',
      iconKey: 'savings',
      colorValue: 0xFF3D6BE4,
      type: incomeType,
    ),
    FinanceCategoryTemplate(
      id: 'income_interest',
      name: 'Interest',
      nameBn: '\u09B8\u09C1\u09A6',
      iconKey: 'account_balance',
      colorValue: 0xFFF59E0B,
      type: incomeType,
    ),
    FinanceCategoryTemplate(
      id: 'income_refund',
      name: 'Refund',
      nameBn: '\u09B0\u09BF\u09AB\u09BE\u09A8\u09CD\u09A1',
      iconKey: 'account_balance_wallet',
      colorValue: 0xFF06B6D4,
      type: incomeType,
    ),
    FinanceCategoryTemplate(
      id: 'income_allowance',
      name: 'Allowance',
      nameBn: '\u09AD\u09BE\u09A4\u09BE',
      iconKey: 'work',
      colorValue: 0xFFEC4899,
      type: incomeType,
    ),
    FinanceCategoryTemplate(
      id: 'income_other_fast',
      name: 'Other',
      nameBn: '\u0985\u09A8\u09CD\u09AF\u09BE\u09A8\u09CD\u09AF',
      iconKey: 'category',
      colorValue: 0xFF94A3B8,
      type: incomeType,
    ),
  ];

  static List<FinanceCategoryTemplate> templatesForType(String type) {
    return <FinanceCategoryTemplate>[
      ...defaultCategoryTemplates.where((template) => template.type == type),
      ...quickCategoryTemplates.where((template) => template.type == type),
    ];
  }

  static IconData iconForKey(String key) {
    for (final option in categoryIcons) {
      if (option.key == key) {
        return option.icon;
      }
    }
    return Icons.category;
  }

  static FinanceWalletTypeOption walletTypeFor(String type) {
    for (final option in walletTypes) {
      if (option.type == type) {
        return option;
      }
    }
    return walletTypes.first;
  }

  static bool isTransferTransaction(TransactionModel transaction) {
    return transaction.isTransfer;
  }

  static String transactionTitle(
    TransactionModel transaction, {
    CategoryModel? category,
    WalletModel? otherWallet,
    required String languageCode,
  }) {
    if (transaction.isTransfer) {
      final walletName = otherWallet?.name ?? 'wallet';
      return transaction.type == incomeType
          ? 'Transfer from $walletName'
          : 'Transfer to $walletName';
    }

    final baseLabel = category?.localizedName(languageCode) ?? 'Category';
    if (!transaction.isSplit) {
      return baseLabel;
    }

    final moreCount = transaction.normalizedSplitItems.length - 1;
    if (languageCode == 'bn') {
      return '$baseLabel + আরও $moreCount';
    }
    return '$baseLabel + $moreCount more';
  }

  static Color transactionColor(TransactionModel transaction) {
    if (transaction.isTransfer) {
      return const Color(0xFF3D6BE4);
    }

    return transaction.type == incomeType
        ? const Color(0xFF2ECC9A)
        : const Color(0xFFE85D5D);
  }

  static IconData transactionIcon(
    TransactionModel transaction, {
    CategoryModel? category,
  }) {
    if (transaction.isTransfer) {
      return Icons.swap_horiz_rounded;
    }

    return iconForKey(category?.iconKey ?? 'category');
  }
}
