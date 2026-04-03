import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';

class DebtPaymentModel {
  const DebtPaymentModel({
    required this.id,
    required this.amount,
    required this.date,
    required this.note,
    required this.createdAt,
  });

  final String id;
  final double amount;
  final DateTime date;
  final String note;
  final DateTime createdAt;

  factory DebtPaymentModel.fromMap(Map<String, dynamic> data) {
    final dateValue = data['date'];
    final createdAtValue = data['createdAt'];

    return DebtPaymentModel(
      id: data['id'] as String? ?? '',
      amount: (data['amount'] as num?)?.toDouble() ?? 0,
      date: dateValue is Timestamp ? dateValue.toDate() : DateTime.now(),
      note: data['note'] as String? ?? '',
      createdAt: createdAtValue is Timestamp
          ? createdAtValue.toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'note': note,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

class DebtRecordModel {
  const DebtRecordModel({
    required this.id,
    required this.personName,
    required this.type,
    required this.totalAmount,
    required this.paidAmount,
    required this.startDate,
    required this.dueDate,
    required this.installments,
    required this.note,
    required this.payments,
    required this.createdAt,
    required this.updatedAt,
    this.closedAt,
  });

  static const String borrowedType = 'borrowed';
  static const String lentType = 'lent';

  final String id;
  final String personName;
  final String type;
  final double totalAmount;
  final double paidAmount;
  final DateTime startDate;
  final DateTime dueDate;
  final int installments;
  final String note;
  final List<DebtPaymentModel> payments;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? closedAt;

  bool get isBorrowed => type == borrowedType;
  bool get isLent => type == lentType;

  double get remainingAmount => math.max(0, totalAmount - paidAmount);

  double get progress {
    if (totalAmount <= 0) {
      return 0;
    }
    return (paidAmount / totalAmount).clamp(0, 1);
  }

  bool get isSettled => remainingAmount <= 0.009;

  bool get isOverdue {
    if (isSettled) {
      return false;
    }
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
    return due.isBefore(today);
  }

  double get installmentAmount {
    if (installments <= 0) {
      return totalAmount;
    }
    return totalAmount / installments;
  }

  factory DebtRecordModel.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? <String, dynamic>{};
    final startDateValue = data['startDate'];
    final dueDateValue = data['dueDate'];
    final createdAtValue = data['createdAt'];
    final updatedAtValue = data['updatedAt'];
    final closedAtValue = data['closedAt'];
    final paymentsValue = data['payments'] as List<dynamic>? ?? const [];

    final payments =
        paymentsValue
            .whereType<Map<String, dynamic>>()
            .map(DebtPaymentModel.fromMap)
            .toList(growable: false)
          ..sort((a, b) => b.date.compareTo(a.date));

    return DebtRecordModel(
      id: document.id,
      personName: data['personName'] as String? ?? '',
      type: data['type'] as String? ?? borrowedType,
      totalAmount: (data['totalAmount'] as num?)?.toDouble() ?? 0,
      paidAmount: (data['paidAmount'] as num?)?.toDouble() ?? 0,
      startDate: startDateValue is Timestamp
          ? startDateValue.toDate()
          : DateTime.now(),
      dueDate: dueDateValue is Timestamp
          ? dueDateValue.toDate()
          : DateTime.now(),
      installments: (data['installments'] as num?)?.toInt() ?? 1,
      note: data['note'] as String? ?? '',
      payments: payments,
      createdAt: createdAtValue is Timestamp
          ? createdAtValue.toDate()
          : DateTime.now(),
      updatedAt: updatedAtValue is Timestamp
          ? updatedAtValue.toDate()
          : DateTime.now(),
      closedAt: closedAtValue is Timestamp ? closedAtValue.toDate() : null,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'personName': personName,
      'type': type,
      'totalAmount': totalAmount,
      'paidAmount': paidAmount,
      'startDate': Timestamp.fromDate(startDate),
      'dueDate': Timestamp.fromDate(dueDate),
      'installments': installments,
      'note': note,
      'payments': payments.map((payment) => payment.toMap()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'closedAt': closedAt == null ? null : Timestamp.fromDate(closedAt!),
    };
  }

  DebtRecordModel copyWith({
    String? id,
    String? personName,
    String? type,
    double? totalAmount,
    double? paidAmount,
    DateTime? startDate,
    DateTime? dueDate,
    int? installments,
    String? note,
    List<DebtPaymentModel>? payments,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? closedAt,
    bool clearClosedAt = false,
  }) {
    return DebtRecordModel(
      id: id ?? this.id,
      personName: personName ?? this.personName,
      type: type ?? this.type,
      totalAmount: totalAmount ?? this.totalAmount,
      paidAmount: paidAmount ?? this.paidAmount,
      startDate: startDate ?? this.startDate,
      dueDate: dueDate ?? this.dueDate,
      installments: installments ?? this.installments,
      note: note ?? this.note,
      payments: payments ?? this.payments,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      closedAt: clearClosedAt ? null : closedAt ?? this.closedAt,
    );
  }
}
