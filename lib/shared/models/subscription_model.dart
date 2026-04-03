import 'package:cloud_firestore/cloud_firestore.dart';

class SubscriptionModel {
  const SubscriptionModel({
    required this.id,
    required this.name,
    required this.amount,
    required this.categoryId,
    required this.walletId,
    required this.frequency,
    required this.nextDueDate,
    required this.reminderDaysBefore,
    required this.isPaid,
    required this.note,
    required this.createdAt,
    this.lastPaidAt,
  });

  final String id;
  final String name;
  final double amount;
  final String categoryId;
  final String walletId;
  final String frequency;
  final DateTime nextDueDate;
  final int reminderDaysBefore;
  final bool isPaid;
  final String note;
  final DateTime createdAt;
  final DateTime? lastPaidAt;

  bool get isOverdue {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDay = DateTime(
      nextDueDate.year,
      nextDueDate.month,
      nextDueDate.day,
    );
    return dueDay.isBefore(today);
  }

  int get daysUntilDue {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDay = DateTime(
      nextDueDate.year,
      nextDueDate.month,
      nextDueDate.day,
    );
    return dueDay.difference(today).inDays;
  }

  factory SubscriptionModel.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    final dueDateValue = data['nextDueDate'];
    final createdAtValue = data['createdAt'];
    final lastPaidAtValue = data['lastPaidAt'];

    return SubscriptionModel(
      id: doc.id,
      name: data['name'] as String? ?? '',
      amount: (data['amount'] as num?)?.toDouble() ?? 0,
      categoryId: data['categoryId'] as String? ?? '',
      walletId: data['walletId'] as String? ?? '',
      frequency: data['frequency'] as String? ?? SubscriptionFrequency.monthly,
      nextDueDate: dueDateValue is Timestamp
          ? dueDateValue.toDate()
          : DateTime.now(),
      reminderDaysBefore: (data['reminderDaysBefore'] as num?)?.toInt() ?? 2,
      isPaid: data['isPaid'] as bool? ?? false,
      note: data['note'] as String? ?? '',
      createdAt: createdAtValue is Timestamp
          ? createdAtValue.toDate()
          : DateTime.now(),
      lastPaidAt: lastPaidAtValue is Timestamp
          ? lastPaidAtValue.toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'amount': amount,
      'categoryId': categoryId,
      'walletId': walletId,
      'frequency': frequency,
      'nextDueDate': Timestamp.fromDate(nextDueDate),
      'reminderDaysBefore': reminderDaysBefore,
      'isPaid': isPaid,
      'note': note,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastPaidAt': lastPaidAt == null ? null : Timestamp.fromDate(lastPaidAt!),
    };
  }

  SubscriptionModel copyWith({
    String? id,
    String? name,
    double? amount,
    String? categoryId,
    String? walletId,
    String? frequency,
    DateTime? nextDueDate,
    int? reminderDaysBefore,
    bool? isPaid,
    String? note,
    DateTime? createdAt,
    DateTime? lastPaidAt,
    bool clearLastPaidAt = false,
  }) {
    return SubscriptionModel(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      walletId: walletId ?? this.walletId,
      frequency: frequency ?? this.frequency,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      reminderDaysBefore: reminderDaysBefore ?? this.reminderDaysBefore,
      isPaid: isPaid ?? this.isPaid,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      lastPaidAt: clearLastPaidAt ? null : lastPaidAt ?? this.lastPaidAt,
    );
  }
}

abstract final class SubscriptionFrequency {
  static const String daily = 'daily';
  static const String weekly = 'weekly';
  static const String monthly = 'monthly';
  static const String yearly = 'yearly';

  static const List<String> values = <String>[daily, weekly, monthly, yearly];

  static String label(String value) {
    switch (value) {
      case daily:
        return 'Daily';
      case weekly:
        return 'Weekly';
      case yearly:
        return 'Yearly';
      case monthly:
      default:
        return 'Monthly';
    }
  }
}
