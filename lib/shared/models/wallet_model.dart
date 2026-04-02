import 'package:cloud_firestore/cloud_firestore.dart';

class WalletModel {
  const WalletModel({
    required this.id,
    required this.name,
    required this.type,
    required this.balance,
    required this.iconKey,
    required this.colorValue,
    required this.isDefault,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String type;
  final double balance;
  final String iconKey;
  final int colorValue;
  final bool isDefault;
  final DateTime createdAt;

  factory WalletModel.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    final createdAtValue = data['createdAt'];

    return WalletModel(
      id: doc.id,
      name: data['name'] as String? ?? '',
      type: data['type'] as String? ?? 'cash',
      balance: (data['balance'] as num?)?.toDouble() ?? 0,
      iconKey: data['iconKey'] as String? ?? 'payments',
      colorValue: (data['colorValue'] as num?)?.toInt() ?? 0xFF3D6BE4,
      isDefault: data['isDefault'] as bool? ?? false,
      createdAt: createdAtValue is Timestamp
          ? createdAtValue.toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'type': type,
      'balance': balance,
      'iconKey': iconKey,
      'colorValue': colorValue,
      'isDefault': isDefault,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
