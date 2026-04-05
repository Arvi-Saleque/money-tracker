import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/models/shared_wallet_entry_model.dart';
import '../../shared/models/shared_wallet_invite_model.dart';
import '../../shared/models/shared_wallet_model.dart';
import '../../shared/models/user_model.dart';
import '../../shared/providers/firebase_providers.dart';
import '../auth/auth_providers.dart';
import '../profile/profile_providers.dart';
import '../transactions/transaction_providers.dart';
import 'shared_wallet_service.dart';

final sharedWalletServiceProvider = Provider<SharedWalletService>((ref) {
  return SharedWalletService(firestore: ref.watch(firestoreProvider));
});

final currentUserEmailProvider = Provider<String?>((ref) {
  return ref.watch(authStateProvider).value?.email;
});

final currentActorProvider = Provider<UserModel?>((ref) {
  return ref.watch(currentUserProfileProvider).asData?.value;
});

final sharedWalletsProvider = StreamProvider<List<SharedWalletModel>>((ref) {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) {
    return Stream<List<SharedWalletModel>>.value(const <SharedWalletModel>[]);
  }
  return ref.watch(sharedWalletServiceProvider).watchSharedWallets(uid);
});

final sharedWalletInvitesProvider =
    StreamProvider<List<SharedWalletInviteModel>>((ref) {
      final email = ref.watch(currentUserEmailProvider);
      if (email == null || email.trim().isEmpty) {
        return Stream<List<SharedWalletInviteModel>>.value(
          const <SharedWalletInviteModel>[],
        );
      }
      return ref.watch(sharedWalletServiceProvider).watchInvites(email.trim());
    });

final sharedWalletEntriesProvider =
    StreamProvider.family<List<SharedWalletEntryModel>, String>((
      ref,
      walletId,
    ) {
      return ref.watch(sharedWalletServiceProvider).watchEntries(walletId);
    });

final sharedWalletActionControllerProvider =
    AsyncNotifierProvider<SharedWalletActionController, void>(
      SharedWalletActionController.new,
    );

class SharedWalletActionController extends AsyncNotifier<void> {
  SharedWalletService get _service => ref.read(sharedWalletServiceProvider);

  @override
  FutureOr<void> build() {}

  Future<SharedWalletModel> createSharedWallet({
    required String name,
    required String type,
    required String iconKey,
    required int colorValue,
  }) async {
    final uid = _requireUserId();
    final actor = _requireActor();

    SharedWalletModel? createdWallet;
    state = const AsyncLoading<void>();
    state = await AsyncValue.guard(() async {
      createdWallet = await _service.createSharedWallet(
        ownerUid: uid,
        ownerName: _actorName(actor),
        name: name,
        type: type,
        iconKey: iconKey,
        colorValue: colorValue,
      );
    });
    if (state.hasError) {
      throw state.error!;
    }
    return createdWallet!;
  }

  Future<void> inviteMember({
    required SharedWalletModel wallet,
    required String email,
  }) async {
    final uid = _requireUserId();
    final actor = _requireActor();

    state = const AsyncLoading<void>();
    state = await AsyncValue.guard(
      () => _service.inviteMemberByEmail(
        wallet: wallet,
        inviterUid: uid,
        inviterName: _actorName(actor),
        inviteeEmail: email,
      ),
    );
    if (state.hasError) {
      throw state.error!;
    }
  }

  Future<void> acceptInvite(SharedWalletInviteModel invite) async {
    final uid = _requireUserId();
    final email = _requireEmail();
    final actor = _requireActor();

    state = const AsyncLoading<void>();
    state = await AsyncValue.guard(
      () => _service.acceptInvite(
        invite: invite,
        memberUid: uid,
        memberName: _actorName(actor),
        memberEmail: email,
      ),
    );
    if (state.hasError) {
      throw state.error!;
    }
  }

  Future<void> declineInvite(SharedWalletInviteModel invite) async {
    final email = _requireEmail();
    state = const AsyncLoading<void>();
    state = await AsyncValue.guard(
      () => _service.declineInvite(
        inviteeEmail: email,
        walletId: invite.walletId,
      ),
    );
    if (state.hasError) {
      throw state.error!;
    }
  }

  Future<void> addEntry({
    required String walletId,
    required double amount,
    required String type,
    required String note,
    required DateTime date,
  }) async {
    final uid = _requireUserId();
    final actor = _requireActor();
    final docId = DateTime.now().microsecondsSinceEpoch.toString();

    final entry = SharedWalletEntryModel(
      id: docId,
      amount: amount,
      type: type,
      note: note.trim(),
      date: date,
      createdAt: DateTime.now(),
      createdByUid: uid,
      createdByName: _actorName(actor),
    );

    state = const AsyncLoading<void>();
    state = await AsyncValue.guard(
      () => _service.addEntry(walletId: walletId, entry: entry),
    );
    if (state.hasError) {
      throw state.error!;
    }
  }

  Future<void> deleteEntry({
    required String walletId,
    required SharedWalletEntryModel entry,
  }) async {
    state = const AsyncLoading<void>();
    state = await AsyncValue.guard(
      () => _service.deleteEntry(walletId: walletId, entry: entry),
    );
    if (state.hasError) {
      throw state.error!;
    }
  }

  String _requireUserId() {
    final uid = ref.read(currentUserIdProvider);
    if (uid == null) {
      throw StateError('User is not signed in.');
    }
    return uid;
  }

  String _requireEmail() {
    final email = ref.read(currentUserEmailProvider);
    if (email == null || email.trim().isEmpty) {
      throw StateError('No email is available for this account.');
    }
    return email.trim();
  }

  UserModel _requireActor() {
    final actor = ref.read(currentActorProvider);
    if (actor == null) {
      throw StateError('User profile is not ready yet.');
    }
    return actor;
  }

  String _actorName(UserModel actor) {
    final trimmed = actor.name.trim();
    if (trimmed.isNotEmpty) {
      return trimmed;
    }
    if (actor.email.trim().isNotEmpty) {
      return actor.email.trim();
    }
    return 'Member';
  }
}
