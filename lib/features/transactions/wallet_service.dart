import 'package:cloud_firestore/cloud_firestore.dart';

import '../../shared/models/transaction_model.dart';
import '../../shared/models/wallet_model.dart';
import 'finance_catalog.dart';

class WalletService {
  WalletService({required FirebaseFirestore firestore})
    : _firestore = firestore;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _walletsRef(String uid) {
    return _firestore.collection('users').doc(uid).collection('wallets');
  }

  CollectionReference<Map<String, dynamic>> _transactionsRef(String uid) {
    return _firestore.collection('users').doc(uid).collection('transactions');
  }

  Stream<List<WalletModel>> watchWallets(String uid) {
    return _walletsRef(uid).orderBy('createdAt').snapshots().map((snapshot) {
      final wallets = snapshot.docs.map(WalletModel.fromDocument).toList();
      wallets.sort((a, b) {
        if (a.isDefault == b.isDefault) {
          return a.createdAt.compareTo(b.createdAt);
        }
        return a.isDefault ? -1 : 1;
      });
      return wallets;
    });
  }

  Future<List<WalletModel>> getWallets(String uid) async {
    final snapshot = await _walletsRef(uid).orderBy('createdAt').get();
    final wallets = snapshot.docs.map(WalletModel.fromDocument).toList();
    wallets.sort((a, b) {
      if (a.isDefault == b.isDefault) {
        return a.createdAt.compareTo(b.createdAt);
      }
      return a.isDefault ? -1 : 1;
    });
    return wallets;
  }

  Future<WalletModel> addWallet(String uid, WalletModel wallet) async {
    final existingWallets = await getWallets(uid);
    final shouldBeDefault = wallet.isDefault || existingWallets.isEmpty;
    final docRef = wallet.id.trim().isEmpty
        ? _walletsRef(uid).doc()
        : _walletsRef(uid).doc(wallet.id);
    final nextWallet = wallet.copyWith(
      id: docRef.id,
      isDefault: shouldBeDefault,
    );
    final batch = _firestore.batch();

    if (shouldBeDefault) {
      for (final existing in existingWallets.where((item) => item.isDefault)) {
        batch.update(_walletsRef(uid).doc(existing.id), <String, dynamic>{
          'isDefault': false,
        });
      }
    }

    batch.set(docRef, nextWallet.toMap());
    await batch.commit();
    return nextWallet;
  }

  Future<void> updateWallet(String uid, WalletModel wallet) async {
    final existingWallets = await getWallets(uid);
    final batch = _firestore.batch();

    if (wallet.isDefault) {
      for (final existing in existingWallets) {
        if (existing.id == wallet.id || !existing.isDefault) {
          continue;
        }
        batch.update(_walletsRef(uid).doc(existing.id), <String, dynamic>{
          'isDefault': false,
        });
      }
    }

    batch.set(
      _walletsRef(uid).doc(wallet.id),
      wallet.toMap(),
      SetOptions(merge: true),
    );
    await batch.commit();
  }

  Future<void> deleteWallet(String uid, WalletModel wallet) async {
    final wallets = await getWallets(uid);
    if (wallets.length <= 1) {
      throw StateError('Keep at least one wallet in your account.');
    }

    if (wallet.balance.abs() > 0.009) {
      throw StateError('Set the wallet balance to zero before deleting it.');
    }

    final directTransactions = await _transactionsRef(
      uid,
    ).where('walletId', isEqualTo: wallet.id).limit(1).get();
    if (directTransactions.docs.isNotEmpty) {
      throw StateError('This wallet already has transactions linked to it.');
    }

    final transferReferences = await _transactionsRef(
      uid,
    ).where('transferWalletId', isEqualTo: wallet.id).limit(1).get();
    if (transferReferences.docs.isNotEmpty) {
      throw StateError(
        'This wallet is referenced by a transfer history entry.',
      );
    }

    final batch = _firestore.batch();
    if (wallet.isDefault) {
      final replacement = wallets.firstWhere((item) => item.id != wallet.id);
      batch.update(_walletsRef(uid).doc(replacement.id), <String, dynamic>{
        'isDefault': true,
      });
    }

    batch.delete(_walletsRef(uid).doc(wallet.id));
    await batch.commit();
  }

  Future<void> transferBetweenWallets(
    String uid, {
    required String fromWalletId,
    required String toWalletId,
    required double amount,
    required String note,
    required DateTime date,
  }) async {
    if (fromWalletId == toWalletId) {
      throw StateError('Choose two different wallets for a transfer.');
    }
    if (amount <= 0) {
      throw StateError('Transfer amount must be greater than zero.');
    }

    final outgoingRef = _transactionsRef(uid).doc();
    final incomingRef = _transactionsRef(uid).doc();
    final createdAt = DateTime.now();
    final outgoing = TransactionModel(
      id: outgoingRef.id,
      amount: amount,
      type: FinanceCatalog.expenseType,
      categoryId: '',
      walletId: fromWalletId,
      isTransfer: true,
      note: note.trim(),
      date: date,
      createdAt: createdAt,
      transferWalletId: toWalletId,
      linkedTransactionId: incomingRef.id,
    );
    final incoming = TransactionModel(
      id: incomingRef.id,
      amount: amount,
      type: FinanceCatalog.incomeType,
      categoryId: '',
      walletId: toWalletId,
      isTransfer: true,
      note: note.trim(),
      date: date,
      createdAt: createdAt,
      transferWalletId: fromWalletId,
      linkedTransactionId: outgoingRef.id,
    );

    final batch = _firestore.batch();
    batch.set(outgoingRef, outgoing.toMap());
    batch.set(incomingRef, incoming.toMap());
    batch.update(_walletsRef(uid).doc(fromWalletId), <String, dynamic>{
      'balance': FieldValue.increment(-amount),
    });
    batch.update(_walletsRef(uid).doc(toWalletId), <String, dynamic>{
      'balance': FieldValue.increment(amount),
    });
    await batch.commit();
  }

  Future<TransactionModel?> getTransferPairTransaction(
    String uid,
    String transactionId,
  ) async {
    final snapshot = await _transactionsRef(uid).doc(transactionId).get();
    if (!snapshot.exists) {
      return null;
    }
    return TransactionModel.fromDocument(snapshot);
  }

  Future<void> updateTransferPair(
    String uid, {
    required TransactionModel baseTransaction,
    required TransactionModel linkedTransaction,
    required String fromWalletId,
    required String toWalletId,
    required double amount,
    required String note,
    required DateTime date,
  }) async {
    if (fromWalletId == toWalletId) {
      throw StateError('Choose two different wallets for a transfer.');
    }
    if (amount <= 0) {
      throw StateError('Transfer amount must be greater than zero.');
    }

    final outgoingExisting = baseTransaction.type == FinanceCatalog.expenseType
        ? baseTransaction
        : linkedTransaction;
    final incomingExisting = baseTransaction.type == FinanceCatalog.incomeType
        ? baseTransaction
        : linkedTransaction;
    final balanceChanges = <String, double>{
      outgoingExisting.walletId: outgoingExisting.amount,
      incomingExisting.walletId: -incomingExisting.amount,
    };
    balanceChanges.update(
      fromWalletId,
      (value) => value - amount,
      ifAbsent: () => -amount,
    );
    balanceChanges.update(
      toWalletId,
      (value) => value + amount,
      ifAbsent: () => amount,
    );

    final outgoingNext = outgoingExisting.copyWith(
      amount: amount,
      walletId: fromWalletId,
      isTransfer: true,
      note: note.trim(),
      date: date,
      transferWalletId: toWalletId,
      linkedTransactionId: incomingExisting.id,
    );
    final incomingNext = incomingExisting.copyWith(
      amount: amount,
      walletId: toWalletId,
      isTransfer: true,
      note: note.trim(),
      date: date,
      transferWalletId: fromWalletId,
      linkedTransactionId: outgoingExisting.id,
    );

    final batch = _firestore.batch();
    batch.set(
      _transactionsRef(uid).doc(outgoingExisting.id),
      outgoingNext.toMap(),
    );
    batch.set(
      _transactionsRef(uid).doc(incomingExisting.id),
      incomingNext.toMap(),
    );
    for (final entry in balanceChanges.entries) {
      if (entry.value.abs() <= 0.009) {
        continue;
      }
      batch.update(_walletsRef(uid).doc(entry.key), <String, dynamic>{
        'balance': FieldValue.increment(entry.value),
      });
    }
    await batch.commit();
  }

  Future<void> deleteTransferPair(
    String uid, {
    required TransactionModel baseTransaction,
    TransactionModel? linkedTransaction,
  }) async {
    final linked =
        linkedTransaction ??
        (baseTransaction.linkedTransactionId == null
            ? null
            : await getTransferPairTransaction(
                uid,
                baseTransaction.linkedTransactionId!,
              ));
    if (linked == null) {
      throw StateError('The linked transfer entry could not be found.');
    }

    final outgoing = baseTransaction.type == FinanceCatalog.expenseType
        ? baseTransaction
        : linked;
    final incoming = baseTransaction.type == FinanceCatalog.incomeType
        ? baseTransaction
        : linked;

    final batch = _firestore.batch();
    batch.delete(_transactionsRef(uid).doc(outgoing.id));
    batch.delete(_transactionsRef(uid).doc(incoming.id));
    batch.update(_walletsRef(uid).doc(outgoing.walletId), <String, dynamic>{
      'balance': FieldValue.increment(outgoing.amount),
    });
    batch.update(_walletsRef(uid).doc(incoming.walletId), <String, dynamic>{
      'balance': FieldValue.increment(-incoming.amount),
    });
    await batch.commit();
  }
}
