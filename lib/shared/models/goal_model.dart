import 'package:cloud_firestore/cloud_firestore.dart';

class GoalModel {
  const GoalModel({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.savedAmount,
    required this.targetDate,
    required this.iconKey,
    required this.colorValue,
    required this.note,
    required this.createdAt,
    this.completedAt,
  });

  final String id;
  final String name;
  final double targetAmount;
  final double savedAmount;
  final DateTime targetDate;
  final String iconKey;
  final int colorValue;
  final String note;
  final DateTime createdAt;
  final DateTime? completedAt;

  bool get isCompleted => savedAmount >= targetAmount || completedAt != null;

  double get progress {
    if (targetAmount <= 0) {
      return 0;
    }
    return (savedAmount / targetAmount).clamp(0, 1).toDouble();
  }

  double get remainingAmount {
    return (targetAmount - savedAmount).clamp(0, double.infinity);
  }

  int get daysRemaining {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDay = DateTime(targetDate.year, targetDate.month, targetDate.day);
    return dueDay.difference(today).inDays;
  }

  factory GoalModel.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    final targetDateValue = data['targetDate'];
    final createdAtValue = data['createdAt'];
    final completedAtValue = data['completedAt'];

    return GoalModel(
      id: doc.id,
      name: data['name'] as String? ?? '',
      targetAmount: (data['targetAmount'] as num?)?.toDouble() ?? 0,
      savedAmount: (data['savedAmount'] as num?)?.toDouble() ?? 0,
      targetDate: targetDateValue is Timestamp
          ? targetDateValue.toDate()
          : DateTime.now(),
      iconKey: data['iconKey'] as String? ?? 'savings',
      colorValue: (data['colorValue'] as num?)?.toInt() ?? 0xFF3D6BE4,
      note: data['note'] as String? ?? '',
      createdAt: createdAtValue is Timestamp
          ? createdAtValue.toDate()
          : DateTime.now(),
      completedAt: completedAtValue is Timestamp
          ? completedAtValue.toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'targetAmount': targetAmount,
      'savedAmount': savedAmount,
      'targetDate': Timestamp.fromDate(targetDate),
      'iconKey': iconKey,
      'colorValue': colorValue,
      'note': note,
      'createdAt': Timestamp.fromDate(createdAt),
      'completedAt': completedAt == null
          ? null
          : Timestamp.fromDate(completedAt!),
    };
  }

  GoalModel copyWith({
    String? id,
    String? name,
    double? targetAmount,
    double? savedAmount,
    DateTime? targetDate,
    String? iconKey,
    int? colorValue,
    String? note,
    DateTime? createdAt,
    DateTime? completedAt,
    bool clearCompletedAt = false,
  }) {
    return GoalModel(
      id: id ?? this.id,
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      savedAmount: savedAmount ?? this.savedAmount,
      targetDate: targetDate ?? this.targetDate,
      iconKey: iconKey ?? this.iconKey,
      colorValue: colorValue ?? this.colorValue,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      completedAt: clearCompletedAt ? null : completedAt ?? this.completedAt,
    );
  }
}
