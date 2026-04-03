import 'package:cloud_firestore/cloud_firestore.dart';

class BudgetModel {
  const BudgetModel({
    required this.id,
    required this.categoryId,
    required this.limit,
    required this.spent,
    required this.month,
    required this.year,
    required this.createdAt,
  });

  static const String overallCategoryId = '__overall__';

  final String id;
  final String categoryId;
  final double limit;
  final double spent;
  final int month;
  final int year;
  final DateTime createdAt;

  bool get isOverall => categoryId == overallCategoryId;

  double get progress =>
      limit <= 0 ? 0 : (spent / limit).clamp(0, 999).toDouble();

  factory BudgetModel.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    final createdAtValue = data['createdAt'];

    return BudgetModel(
      id: doc.id,
      categoryId: data['categoryId'] as String? ?? overallCategoryId,
      limit: (data['limit'] as num?)?.toDouble() ?? 0,
      spent: (data['spent'] as num?)?.toDouble() ?? 0,
      month: (data['month'] as num?)?.toInt() ?? DateTime.now().month,
      year: (data['year'] as num?)?.toInt() ?? DateTime.now().year,
      createdAt: createdAtValue is Timestamp
          ? createdAtValue.toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'categoryId': categoryId,
      'limit': limit,
      'spent': spent,
      'month': month,
      'year': year,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  BudgetModel copyWith({
    String? id,
    String? categoryId,
    double? limit,
    double? spent,
    int? month,
    int? year,
    DateTime? createdAt,
  }) {
    return BudgetModel(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      limit: limit ?? this.limit,
      spent: spent ?? this.spent,
      month: month ?? this.month,
      year: year ?? this.year,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
