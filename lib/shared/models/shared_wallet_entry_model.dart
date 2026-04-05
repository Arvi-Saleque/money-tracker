import 'package:cloud_firestore/cloud_firestore.dart';

class SharedWalletEntryModel {
  const SharedWalletEntryModel({
    required this.id,
    required this.amount,
    required this.type,
    required this.note,
    required this.date,
    required this.createdAt,
    required this.createdByUid,
    required this.createdByName,
  });

  final String id;
  final double amount;
  final String type;
  final String note;
  final DateTime date;
  final DateTime createdAt;
  final String createdByUid;
  final String createdByName;

  factory SharedWalletEntryModel.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    final dateValue = data['date'];
    final createdAtValue = data['createdAt'];

    return SharedWalletEntryModel(
      id: doc.id,
      amount: (data['amount'] as num?)?.toDouble() ?? 0,
      type: data['type'] as String? ?? 'expense',
      note: data['note'] as String? ?? '',
      date: dateValue is Timestamp ? dateValue.toDate() : DateTime.now(),
      createdAt: createdAtValue is Timestamp
          ? createdAtValue.toDate()
          : DateTime.now(),
      createdByUid: data['createdByUid'] as String? ?? '',
      createdByName: data['createdByName'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'amount': amount,
      'type': type,
      'note': note,
      'date': Timestamp.fromDate(date),
      'createdAt': Timestamp.fromDate(createdAt),
      'createdByUid': createdByUid,
      'createdByName': createdByName,
    };
  }
}
