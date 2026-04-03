import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';

String authErrorMessage(Object error) {
  if (error is FirebaseAuthException) {
    switch (error.code) {
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email or password is incorrect.';
      case 'email-already-in-use':
        return 'This email is already being used.';
      case 'weak-password':
        return 'Password should be at least 6 characters.';
      case 'network-request-failed':
        return 'Network error. Please try again.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait and try again.';
      default:
        return error.message ?? 'Authentication failed. Please try again.';
    }
  }

  if (error is FirebaseException) {
    switch (error.code) {
      case 'unavailable':
        return 'Network connection is unavailable right now. Please check your internet and try again.';
      case 'permission-denied':
        return 'You do not have permission for this action.';
      case 'failed-precondition':
        return 'This action needs extra Firebase setup, such as a Firestore index.';
      default:
        return error.message ?? 'Something went wrong. Please try again.';
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
                        AppConstants.appName,
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
