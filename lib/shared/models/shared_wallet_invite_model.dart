import 'package:cloud_firestore/cloud_firestore.dart';

class SharedWalletInviteModel {
  const SharedWalletInviteModel({
    required this.walletId,
    required this.walletName,
    required this.walletType,
    required this.walletIconKey,
    required this.walletColorValue,
    required this.inviterUid,
    required this.inviterName,
    required this.inviteeEmail,
    required this.createdAt,
  });

  final String walletId;
  final String walletName;
  final String walletType;
  final String walletIconKey;
  final int walletColorValue;
  final String inviterUid;
  final String inviterName;
  final String inviteeEmail;
  final DateTime createdAt;

  factory SharedWalletInviteModel.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    final createdAtValue = data['createdAt'];

    return SharedWalletInviteModel(
      walletId: data['walletId'] as String? ?? doc.id,
      walletName: data['walletName'] as String? ?? '',
      walletType: data['walletType'] as String? ?? 'cash',
      walletIconKey: data['walletIconKey'] as String? ?? 'groups',
      walletColorValue:
          (data['walletColorValue'] as num?)?.toInt() ?? 0xFF3D6BE4,
      inviterUid: data['inviterUid'] as String? ?? '',
      inviterName: data['inviterName'] as String? ?? '',
      inviteeEmail: data['inviteeEmail'] as String? ?? '',
      createdAt: createdAtValue is Timestamp
          ? createdAtValue.toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'walletId': walletId,
      'walletName': walletName,
      'walletType': walletType,
      'walletIconKey': walletIconKey,
      'walletColorValue': walletColorValue,
      'inviterUid': inviterUid,
      'inviterName': inviterName,
      'inviteeEmail': inviteeEmail,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
