import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import 'auth_providers.dart';
import 'auth_ui_helpers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authControllerProvider).isLoading;

    return AuthScaffold(
      title: 'Welcome back',
      subtitle: 'Sign in to continue tracking your money.',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'you@example.com',
              ),
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
                return null;
              },
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: isLoading
                    ? null
                    : () => context.push(AppConstants.forgotPasswordRoute),
                child: const Text('Forgot password?'),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: isLoading ? null : _handleLogin,
              child: Text(isLoading ? 'Signing in...' : 'Login'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: isLoading ? null : _handleGoogleSignIn,
              icon: const Icon(Icons.account_circle_outlined),
              label: const Text('Continue with Google'),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text("Don't have an account?"),
                TextButton(
                  onPressed: isLoading
                      ? null
                      : () => context.push(AppConstants.signUpRoute),
                  child: const Text('Sign up'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      await ref
          .read(authControllerProvider.notifier)
          .signInWithEmail(
            email: _emailController.text,
            password: _passwordController.text,
          );
    } catch (error) {
      if (!mounted) {
        return;
      }
      showAppSnackBar(context, authErrorMessage(error));
    }
  }

  Future<void> _handleGoogleSignIn() async {
    try {
      await ref.read(authControllerProvider.notifier).signInWithGoogle();
    } catch (error) {
      if (!mounted) {
        return;
      }
      showAppSnackBar(context, authErrorMessage(error));
    }
  }
}
