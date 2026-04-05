import 'package:cloud_firestore/cloud_firestore.dart';

class SharedWalletModel {
  const SharedWalletModel({
    required this.id,
    required this.name,
    required this.type,
    required this.balance,
    required this.iconKey,
    required this.colorValue,
    required this.ownerUid,
    required this.ownerName,
    required this.memberIds,
    required this.memberNames,
    required this.memberRoles,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String type;
  final double balance;
  final String iconKey;
  final int colorValue;
  final String ownerUid;
  final String ownerName;
  final List<String> memberIds;
  final Map<String, String> memberNames;
  final Map<String, String> memberRoles;
  final DateTime createdAt;

  bool isOwner(String uid) => ownerUid == uid;

  bool isMember(String uid) => memberIds.contains(uid);

  String roleFor(String uid) => memberRoles[uid] ?? 'member';

  factory SharedWalletModel.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    final createdAtValue = data['createdAt'];
    final rawMemberNames =
        data['memberNames'] as Map<String, dynamic>? ??
        const <String, dynamic>{};
    final rawMemberRoles =
        data['memberRoles'] as Map<String, dynamic>? ??
        const <String, dynamic>{};

    return SharedWalletModel(
      id: doc.id,
      name: data['name'] as String? ?? '',
      type: data['type'] as String? ?? 'cash',
      balance: (data['balance'] as num?)?.toDouble() ?? 0,
      iconKey: data['iconKey'] as String? ?? 'account_balance_wallet',
      colorValue: (data['colorValue'] as num?)?.toInt() ?? 0xFF3D6BE4,
      ownerUid: data['ownerUid'] as String? ?? '',
      ownerName: data['ownerName'] as String? ?? '',
      memberIds: (data['memberIds'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<String>()
          .toList(growable: false),
      memberNames: {
        for (final entry in rawMemberNames.entries)
          entry.key: entry.value?.toString() ?? '',
      },
      memberRoles: {
        for (final entry in rawMemberRoles.entries)
          entry.key: entry.value?.toString() ?? 'member',
      },
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
      'ownerUid': ownerUid,
      'ownerName': ownerName,
      'memberIds': memberIds,
      'memberNames': memberNames,
      'memberRoles': memberRoles,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  SharedWalletModel copyWith({
    String? id,
    String? name,
    String? type,
    double? balance,
    String? iconKey,
    int? colorValue,
    String? ownerUid,
    String? ownerName,
    List<String>? memberIds,
    Map<String, String>? memberNames,
    Map<String, String>? memberRoles,
    DateTime? createdAt,
  }) {
    return SharedWalletModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      balance: balance ?? this.balance,
      iconKey: iconKey ?? this.iconKey,
      colorValue: colorValue ?? this.colorValue,
      ownerUid: ownerUid ?? this.ownerUid,
      ownerName: ownerName ?? this.ownerName,
      memberIds: memberIds ?? this.memberIds,
      memberNames: memberNames ?? this.memberNames,
      memberRoles: memberRoles ?? this.memberRoles,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
