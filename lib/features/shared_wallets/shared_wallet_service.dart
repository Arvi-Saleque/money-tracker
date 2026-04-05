import 'package:cloud_firestore/cloud_firestore.dart';

import '../../shared/models/shared_wallet_entry_model.dart';
import '../../shared/models/shared_wallet_invite_model.dart';
import '../../shared/models/shared_wallet_model.dart';

class SharedWalletService {
  SharedWalletService({required FirebaseFirestore firestore})
    : _firestore = firestore;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _sharedWalletsRef =>
      _firestore.collection('shared_wallets');

  CollectionReference<Map<String, dynamic>> _inviteInboxRef(String email) {
    return _firestore
        .collection('shared_wallet_invites_by_email')
        .doc(email)
        .collection('invites');
  }

  CollectionReference<Map<String, dynamic>> _entriesRef(String walletId) {
    return _sharedWalletsRef.doc(walletId).collection('entries');
  }

  Stream<List<SharedWalletModel>> watchSharedWallets(String uid) {
    return _sharedWalletsRef
        .where('memberIds', arrayContains: uid)
        .orderBy('createdAt')
        .snapshots()
        .map((snapshot) {
          final wallets = snapshot.docs
              .map(SharedWalletModel.fromDocument)
              .toList(growable: false);
          wallets.sort((a, b) {
            final ownerCompare = (b.isOwner(uid) ? 1 : 0).compareTo(
              a.isOwner(uid) ? 1 : 0,
            );
            if (ownerCompare != 0) {
              return ownerCompare;
            }
            return a.createdAt.compareTo(b.createdAt);
          });
          return wallets;
        });
  }

  Stream<List<SharedWalletInviteModel>> watchInvites(String email) {
    if (email.trim().isEmpty) {
      return Stream<List<SharedWalletInviteModel>>.value(
        const <SharedWalletInviteModel>[],
      );
    }

    return _inviteInboxRef(email)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(SharedWalletInviteModel.fromDocument)
              .toList(growable: false),
        );
  }

  Stream<List<SharedWalletEntryModel>> watchEntries(String walletId) {
    return _entriesRef(walletId)
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(SharedWalletEntryModel.fromDocument)
              .toList(growable: false),
        );
  }

  Future<SharedWalletModel?> getSharedWallet(String walletId) async {
    final snapshot = await _sharedWalletsRef.doc(walletId).get();
    if (!snapshot.exists) {
      return null;
    }
    return SharedWalletModel.fromDocument(snapshot);
  }

  Future<SharedWalletModel> createSharedWallet({
    required String ownerUid,
    required String ownerName,
    required String name,
    required String type,
    required String iconKey,
    required int colorValue,
  }) async {
    final docRef = _sharedWalletsRef.doc();
    final wallet = SharedWalletModel(
      id: docRef.id,
      name: name.trim(),
      type: type,
      balance: 0,
      iconKey: iconKey,
      colorValue: colorValue,
      ownerUid: ownerUid,
      ownerName: ownerName.trim(),
      memberIds: <String>[ownerUid],
      memberNames: <String, String>{ownerUid: ownerName.trim()},
      memberRoles: <String, String>{ownerUid: 'owner'},
      createdAt: DateTime.now(),
    );
    await docRef.set(wallet.toMap());
    return wallet;
  }

  Future<void> inviteMemberByEmail({
    required SharedWalletModel wallet,
    required String inviterUid,
    required String inviterName,
    required String inviteeEmail,
  }) async {
    final normalizedEmail = inviteeEmail.trim();
    if (normalizedEmail.isEmpty) {
      throw StateError('Please enter an email address.');
    }
    if (wallet.memberNames.values.any(
      (name) => name.trim().toLowerCase() == normalizedEmail.toLowerCase(),
    )) {
      // best-effort local guard; actual membership is uid-based
    }

    final invite = SharedWalletInviteModel(
      walletId: wallet.id,
      walletName: wallet.name,
      walletType: wallet.type,
      walletIconKey: wallet.iconKey,
      walletColorValue: wallet.colorValue,
      inviterUid: inviterUid,
      inviterName: inviterName,
      inviteeEmail: normalizedEmail,
      createdAt: DateTime.now(),
    );

    await _inviteInboxRef(normalizedEmail).doc(wallet.id).set(invite.toMap());
  }

  Future<void> acceptInvite({
    required SharedWalletInviteModel invite,
    required String memberUid,
    required String memberName,
    required String memberEmail,
  }) async {
    final walletRef = _sharedWalletsRef.doc(invite.walletId);
    final walletSnapshot = await walletRef.get();
    if (!walletSnapshot.exists) {
      throw StateError('This shared wallet no longer exists.');
    }

    final wallet = SharedWalletModel.fromDocument(walletSnapshot);
    if (wallet.memberIds.contains(memberUid)) {
      await _inviteInboxRef(memberEmail).doc(invite.walletId).delete();
      return;
    }

    final nextMemberIds = <String>[...wallet.memberIds, memberUid];
    final nextMemberNames = <String, String>{
      ...wallet.memberNames,
      memberUid: memberName,
    };
    final nextMemberRoles = <String, String>{
      ...wallet.memberRoles,
      memberUid: 'member',
    };

    final batch = _firestore.batch();
    batch.update(walletRef, <String, dynamic>{
      'memberIds': nextMemberIds,
      'memberNames': nextMemberNames,
      'memberRoles': nextMemberRoles,
    });
    batch.delete(_inviteInboxRef(memberEmail).doc(invite.walletId));
    await batch.commit();
  }

  Future<void> declineInvite({
    required String inviteeEmail,
    required String walletId,
  }) async {
    await _inviteInboxRef(inviteeEmail).doc(walletId).delete();
  }

  Future<void> addEntry({
    required String walletId,
    required SharedWalletEntryModel entry,
  }) async {
    final entryRef = _entriesRef(walletId).doc(entry.id);
    final batch = _firestore.batch();
    batch.set(entryRef, entry.toMap());
    batch.update(_sharedWalletsRef.doc(walletId), <String, dynamic>{
      'balance': FieldValue.increment(_signedAmount(entry)),
    });
    await batch.commit();
  }

  Future<void> deleteEntry({
    required String walletId,
    required SharedWalletEntryModel entry,
  }) async {
    final batch = _firestore.batch();
    batch.delete(_entriesRef(walletId).doc(entry.id));
    batch.update(_sharedWalletsRef.doc(walletId), <String, dynamic>{
      'balance': FieldValue.increment(-_signedAmount(entry)),
    });
    await batch.commit();
  }

  double _signedAmount(SharedWalletEntryModel entry) {
    return entry.type == 'income' ? entry.amount : -entry.amount;
  }
}
