import 'package:flutter/material.dart';

class FinanceIconOption {
  const FinanceIconOption({required this.key, required this.icon});

  final String key;
  final IconData icon;
}

abstract final class FinanceCatalog {
  static const String incomeType = 'income';
  static const String expenseType = 'expense';

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
  ];

  static const List<Map<String, Object>>
  defaultCategories = <Map<String, Object>>[
    {
      'id': 'expense_groceries',
      'name': 'Groceries',
      'nameBn': '\u09AE\u09C1\u09A6\u09BF\u0996\u09BE\u09A8\u09BE',
      'iconKey': 'shopping_basket',
      'colorValue': 0xFF22C55E,
      'type': expenseType,
    },
    {
      'id': 'expense_transport',
      'name': 'Transport',
      'nameBn': '\u09AF\u09BE\u09A4\u09BE\u09AF\u09BC\u09BE\u09A4',
      'iconKey': 'directions_bus',
      'colorValue': 0xFF06B6D4,
      'type': expenseType,
    },
    {
      'id': 'expense_food',
      'name': 'Food',
      'nameBn': '\u0996\u09BE\u09AC\u09BE\u09B0',
      'iconKey': 'fastfood',
      'colorValue': 0xFFF97316,
      'type': expenseType,
    },
    {
      'id': 'expense_bills',
      'name': 'Bills',
      'nameBn': '\u09AC\u09BF\u09B2',
      'iconKey': 'receipt_long',
      'colorValue': 0xFFEF4444,
      'type': expenseType,
    },
    {
      'id': 'expense_medical',
      'name': 'Medical',
      'nameBn': '\u099A\u09BF\u0995\u09BF\u09CE\u09B8\u09BE',
      'iconKey': 'medical_services',
      'colorValue': 0xFF8B5CF6,
      'type': expenseType,
    },
    {
      'id': 'expense_education',
      'name': 'Education',
      'nameBn': '\u09B6\u09BF\u0995\u09CD\u09B7\u09BE',
      'iconKey': 'school',
      'colorValue': 0xFF14B8A6,
      'type': expenseType,
    },
    {
      'id': 'expense_shopping',
      'name': 'Shopping',
      'nameBn': '\u0995\u09C7\u09A8\u09BE\u0995\u09BE\u099F\u09BE',
      'iconKey': 'shopping_bag',
      'colorValue': 0xFFEC4899,
      'type': expenseType,
    },
    {
      'id': 'expense_entertainment',
      'name': 'Entertainment',
      'nameBn': '\u09AC\u09BF\u09A8\u09CB\u09A6\u09A8',
      'iconKey': 'movie',
      'colorValue': 0xFF6366F1,
      'type': expenseType,
    },
    {
      'id': 'expense_gift',
      'name': 'Gift',
      'nameBn': '\u0989\u09AA\u09B9\u09BE\u09B0',
      'iconKey': 'redeem',
      'colorValue': 0xFFF43F5E,
      'type': expenseType,
    },
    {
      'id': 'expense_rent',
      'name': 'Rent',
      'nameBn': '\u09AD\u09BE\u09DC\u09BE',
      'iconKey': 'home',
      'colorValue': 0xFF64748B,
      'type': expenseType,
    },
    {
      'id': 'expense_other',
      'name': 'Other',
      'nameBn': '\u0985\u09A8\u09CD\u09AF\u09BE\u09A8\u09CD\u09AF',
      'iconKey': 'category',
      'colorValue': 0xFF94A3B8,
      'type': expenseType,
    },
    {
      'id': 'income_salary',
      'name': 'Salary',
      'nameBn': '\u09AC\u09C7\u09A4\u09A8',
      'iconKey': 'account_balance_wallet',
      'colorValue': 0xFF10B981,
      'type': incomeType,
    },
    {
      'id': 'income_freelance',
      'name': 'Freelance',
      'nameBn':
          '\u09AB\u09CD\u09B0\u09BF\u09B2\u09CD\u09AF\u09BE\u09A8\u09CD\u09B8',
      'iconKey': 'work',
      'colorValue': 0xFF3B82F6,
      'type': incomeType,
    },
    {
      'id': 'income_business',
      'name': 'Business',
      'nameBn': '\u09AC\u09CD\u09AF\u09AC\u09B8\u09BE',
      'iconKey': 'storefront',
      'colorValue': 0xFFF59E0B,
      'type': incomeType,
    },
    {
      'id': 'income_gift_received',
      'name': 'Gift Received',
      'nameBn':
          '\u0989\u09AA\u09B9\u09BE\u09B0 \u09AA\u09C7\u09DF\u09C7\u099B\u09BF',
      'iconKey': 'volunteer_activism',
      'colorValue': 0xFFEC4899,
      'type': incomeType,
    },
    {
      'id': 'income_other',
      'name': 'Other',
      'nameBn': '\u0985\u09A8\u09CD\u09AF\u09BE\u09A8\u09CD\u09AF',
      'iconKey': 'category',
      'colorValue': 0xFF94A3B8,
      'type': incomeType,
    },
  ];

  static IconData iconForKey(String key) {
    for (final option in categoryIcons) {
      if (option.key == key) {
        return option.icon;
      }
    }
    return Icons.category;
  }
}
