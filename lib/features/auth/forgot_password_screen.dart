import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import 'auth_providers.dart';
import 'auth_ui_helpers.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authControllerProvider).isLoading;

    return AuthScaffold(
      title: 'Reset password',
      subtitle: 'Enter your email and we will send you a reset link.',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email'),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Email is required.';
                }
                if (!value.contains('@')) {
                  return 'Enter a valid email.';
                }
                return null;
              },
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: isLoading ? null : _handleReset,
              child: Text(isLoading ? 'Sending...' : 'Send reset link'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: isLoading
                  ? null
                  : () => context.go(AppConstants.authRoute),
              child: const Text('Back to login'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleReset() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      await ref
          .read(authControllerProvider.notifier)
          .resetPassword(_emailController.text);
      if (!mounted) {
        return;
      }
      showAppSnackBar(context, 'Reset email sent. Check your inbox.');
      context.go(AppConstants.authRoute);
    } catch (error) {
      if (!mounted) {
        return;
      }
      showAppSnackBar(context, authErrorMessage(error));
    }
  }
}
