import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/l10n_extension.dart';
import '../../shared/widgets/premium_card.dart';
import '../auth/auth_providers.dart';
import 'app_lock_providers.dart';

class AppLockGate extends ConsumerStatefulWidget {
  const AppLockGate({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<AppLockGate> createState() => _AppLockGateState();
}

class _AppLockGateState extends ConsumerState<AppLockGate>
    with WidgetsBindingObserver {
  bool _shouldLockOnResume = false;
  late final ProviderSubscription<AsyncValue<User?>> _authSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _authSubscription = ref.listenManual(authStateProvider, (previous, next) {
      final previousUserId = previous?.value?.uid;
      final nextUserId = next.value?.uid;
      if (previousUserId == nextUserId) {
        return;
      }

      if (nextUserId == null) {
        ref.read(appLockProvider.notifier).unlockWithoutPrompt();
        return;
      }

      final lockState = ref.read(appLockProvider);
      if (lockState.enabled && lockState.hasPin) {
        ref.read(appLockProvider.notifier).lock();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _authSubscription.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final authUser = ref.read(authStateProvider).value;
    final lockState = ref.read(appLockProvider);
    if (authUser == null || !lockState.enabled || !lockState.hasPin) {
      return;
    }

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.detached) {
      _shouldLockOnResume = true;
    }

    if (state == AppLifecycleState.resumed && _shouldLockOnResume) {
      _shouldLockOnResume = false;
      ref.read(appLockProvider.notifier).lock();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authUser = ref.watch(authStateProvider).value;
    final lockState = ref.watch(appLockProvider);

    final showLock =
        authUser != null &&
        lockState.enabled &&
        lockState.hasPin &&
        lockState.isLocked;

    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        widget.child,
        if (showLock) const Positioned.fill(child: _AppLockOverlay()),
      ],
    );
  }
}

class _AppLockOverlay extends ConsumerStatefulWidget {
  const _AppLockOverlay();

  @override
  ConsumerState<_AppLockOverlay> createState() => _AppLockOverlayState();
}

class _AppLockOverlayState extends ConsumerState<_AppLockOverlay> {
  static const int _pinLength = 4;

  String _pin = '';
  String? _errorText;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return ColoredBox(
      color: theme.scaffoldBackgroundColor.withValues(alpha: 0.97),
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: PopScope(
                canPop: false,
                child: buildPremiumCard(
                  context: context,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: theme.colorScheme.primary.withValues(
                          alpha: 0.14,
                        ),
                        foregroundColor: theme.colorScheme.primary,
                        child: const Icon(Icons.lock_rounded, size: 30),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.appLockTitle,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.appLockSubtitle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.textTheme.bodyMedium?.color?.withValues(
                            alpha: 0.76,
                          ),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List<Widget>.generate(_pinLength, (index) {
                          final filled = index < _pin.length;
                          return Container(
                            width: 16,
                            height: 16,
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: filled
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.surfaceContainerHighest,
                              border: Border.all(
                                color: filled
                                    ? theme.colorScheme.primary
                                    : theme.dividerColor,
                              ),
                            ),
                          );
                        }),
                      ),
                      if (_errorText != null) ...<Widget>[
                        const SizedBox(height: 12),
                        Text(
                          _errorText!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.error,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                      const SizedBox(height: 24),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        alignment: WrapAlignment.center,
                        children: <Widget>[
                          for (final value in const [
                            '1',
                            '2',
                            '3',
                            '4',
                            '5',
                            '6',
                            '7',
                            '8',
                            '9',
                            '',
                            '0',
                            'back',
                          ])
                            _PinKey(
                              label: value == 'back' ? '' : value,
                              icon: value == 'back'
                                  ? Icons.backspace_outlined
                                  : null,
                              onTap: value.isEmpty
                                  ? null
                                  : () => _handleKey(value),
                            ),
                        ],
                      ),
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

  void _handleKey(String value) {
    if (value == 'back') {
      if (_pin.isEmpty) {
        return;
      }
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
        _errorText = null;
      });
      return;
    }

    if (_pin.length >= _pinLength) {
      return;
    }

    setState(() {
      _pin = '$_pin$value';
      _errorText = null;
    });

    if (_pin.length == _pinLength) {
      final success = ref.read(appLockProvider.notifier).verifyPin(_pin);
      if (!success) {
        setState(() {
          _pin = '';
          _errorText = context.l10n.incorrectPinError;
        });
      }
    }
  }
}

class _PinKey extends StatelessWidget {
  const _PinKey({required this.label, this.icon, this.onTap});

  final String label;
  final IconData? icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final child = icon == null
        ? Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          )
        : Icon(icon);

    return SizedBox(
      width: 84,
      height: 64,
      child: FilledButton.tonal(onPressed: onTap, child: child),
    );
  }
}
