import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../l10n/l10n_extension.dart';

String authErrorMessage(Object error, {AppLocalizations? l10n}) {
  if (error is FirebaseAuthException) {
    switch (error.code) {
      case 'invalid-email':
        return l10n?.authInvalidEmail ?? 'Please enter a valid email address.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return l10n?.authWrongCredentials ?? 'Email or password is incorrect.';
      case 'email-already-in-use':
        return l10n?.authEmailAlreadyInUse ??
            'This email is already being used.';
      case 'weak-password':
        return l10n?.authWeakPassword ??
            'Password should be at least 6 characters.';
      case 'network-request-failed':
        return l10n?.authNetwork ?? 'Network error. Please try again.';
      case 'too-many-requests':
        return l10n?.authTooManyRequests ??
            'Too many attempts. Please wait and try again.';
      default:
        return error.message ??
            l10n?.authGeneric ??
            'Authentication failed. Please try again.';
    }
  }

  if (error is FirebaseException) {
    switch (error.code) {
      case 'unavailable':
        return l10n?.firebaseUnavailable ??
            'Network connection is unavailable right now. Please check your internet and try again.';
      case 'permission-denied':
        return l10n?.firebasePermissionDenied ??
            'You do not have permission for this action.';
      case 'failed-precondition':
        return l10n?.firebaseNeedsIndex ??
            'This action needs extra Firebase setup, such as a Firestore index.';
      default:
        return error.message ??
            l10n?.genericError ??
            'Something went wrong. Please try again.';
    }
  }

  return error.toString();
}

void showAppSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        l10n.appTitle,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        title,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.textTheme.bodyMedium?.color?.withValues(
                            alpha: 0.72,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      child,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
