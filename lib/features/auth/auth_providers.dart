import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/providers/firebase_providers.dart';
import '../profile/profile_providers.dart';
import 'auth_service.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(
    firebaseAuth: ref.watch(firebaseAuthProvider),
    firestore: ref.watch(firestoreProvider),
    googleSignIn: ref.watch(googleSignInProvider),
  );
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

final authControllerProvider = AsyncNotifierProvider<AuthController, void>(
  AuthController.new,
);

final authRefreshListenableProvider = Provider<StreamAuthRefreshNotifier>((
  ref,
) {
  final notifier = StreamAuthRefreshNotifier(
    ref.watch(authServiceProvider).authStateChanges,
  );
  ref.onDispose(notifier.dispose);
  return notifier;
});

class AuthController extends AsyncNotifier<void> {
  AuthService get _service => ref.read(authServiceProvider);

  @override
  FutureOr<void> build() {}

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    await _runAction(() async {
      await _service.signInWithEmail(email: email, password: password);
      await _syncProfilePreferences();
    });
  }

  Future<void> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    await _runAction(() async {
      await _service.signUpWithEmail(
        name: name,
        email: email,
        password: password,
      );
      await _syncProfilePreferences();
    });
  }

  Future<void> signInWithGoogle() async {
    await _runAction(() async {
      await _service.signInWithGoogle();
      await _syncProfilePreferences();
    });
  }

  Future<void> signOut() async {
    await _runAction(_service.signOut);
  }

  Future<void> resetPassword(String email) async {
    await _runAction(() => _service.resetPassword(email));
  }

  Future<void> _runAction(Future<void> Function() action) async {
    state = const AsyncLoading<void>();
    state = await AsyncValue.guard(action);
    if (state.hasError) {
      throw state.error!;
    }
  }

  Future<void> _syncProfilePreferences() async {
    await ref.read(profilePreferencesSyncProvider.future);
  }
}

class StreamAuthRefreshNotifier extends ChangeNotifier {
  StreamAuthRefreshNotifier(Stream<User?> stream) {
    _subscription = stream.asBroadcastStream().listen((_) {
      notifyListeners();
    });
  }

  late final StreamSubscription<User?> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
