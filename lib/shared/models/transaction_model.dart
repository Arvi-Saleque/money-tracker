import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  const TransactionModel({
    required this.id,
    required this.amount,
    required this.type,
    required this.categoryId,
    required this.walletId,
    required this.note,
    required this.date,
    required this.createdAt,
  });

  final String id;
  final double amount;
  final String type;
  final String categoryId;
  final String walletId;
  final String note;
  final DateTime date;
  final DateTime createdAt;

  factory TransactionModel.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    final dateValue = data['date'];
    final createdAtValue = data['createdAt'];

    return TransactionModel(
      id: doc.id,
      amount: (data['amount'] as num?)?.toDouble() ?? 0,
      type: data['type'] as String? ?? 'expense',
      categoryId: data['categoryId'] as String? ?? '',
      walletId: data['walletId'] as String? ?? '',
      note: data['note'] as String? ?? '',
      date: dateValue is Timestamp ? dateValue.toDate() : DateTime.now(),
      createdAt: createdAtValue is Timestamp
          ? createdAtValue.toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'amount': amount,
      'type': type,
      'categoryId': categoryId,
      'walletId': walletId,
      'note': note,
      'date': Timestamp.fromDate(date),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  TransactionModel copyWith({
    String? id,
    double? amount,
    String? type,
    String? categoryId,
    String? walletId,
    String? note,
    DateTime? date,
    DateTime? createdAt,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      walletId: walletId ?? this.walletId,
      note: note ?? this.note,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
