import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import 'auth_providers.dart';
import 'auth_ui_helpers.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authControllerProvider).isLoading;

    return AuthScaffold(
      title: 'Create account',
      subtitle: 'Set up your profile and start saving your financial history.',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Full name'),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Name is required.';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
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
            const SizedBox(height: 14),
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Password is required.';
                }
                if (value.length < 6) {
                  return 'Password must be at least 6 characters.';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Confirm password'),
              validator: (value) {
                if (value != _passwordController.text) {
                  return 'Passwords do not match.';
                }
                return null;
              },
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: isLoading ? null : _handleSignUp,
              child: Text(isLoading ? 'Creating account...' : 'Sign up'),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text('Already have an account?'),
                TextButton(
                  onPressed: isLoading
                      ? null
                      : () => context.go(AppConstants.authRoute),
                  child: const Text('Login'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      await ref
          .read(authControllerProvider.notifier)
          .signUpWithEmail(
            name: _nameController.text,
            email: _emailController.text,
            password: _passwordController.text,
          );
      if (!mounted) {
        return;
      }
      context.go(AppConstants.homeRoute);
    } catch (error) {
      if (!mounted) {
        return;
      }
      showAppSnackBar(context, authErrorMessage(error));
    }
  }
}
