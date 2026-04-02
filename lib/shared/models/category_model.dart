import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryModel {
  const CategoryModel({
    required this.id,
    required this.name,
    required this.nameBn,
    required this.iconKey,
    required this.colorValue,
    required this.type,
    required this.isDefault,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String nameBn;
  final String iconKey;
  final int colorValue;
  final String type;
  final bool isDefault;
  final DateTime createdAt;

  String localizedName(String languageCode) {
    if (languageCode == 'bn' && nameBn.trim().isNotEmpty) {
      return nameBn;
    }

    return name;
  }

  factory CategoryModel.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? <String, dynamic>{};
    final createdAtValue = data['createdAt'];

    return CategoryModel(
      id: document.id,
      name: data['name'] as String? ?? '',
      nameBn: data['nameBn'] as String? ?? '',
      iconKey: data['iconKey'] as String? ?? 'category',
      colorValue: (data['colorValue'] as num?)?.toInt() ?? 0xFF3D6BE4,
      type: data['type'] as String? ?? 'expense',
      isDefault: data['isDefault'] as bool? ?? false,
      createdAt: createdAtValue is Timestamp
          ? createdAtValue.toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'nameBn': nameBn,
      'iconKey': iconKey,
      'colorValue': colorValue,
      'type': type,
      'isDefault': isDefault,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
