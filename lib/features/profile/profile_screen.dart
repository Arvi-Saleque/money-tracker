import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/l10n_extension.dart';
import '../../shared/models/user_model.dart';
import '../../shared/providers/locale_provider.dart';
import '../../shared/providers/theme_provider.dart';
import '../../shared/widgets/premium_card.dart';
import '../auth/auth_providers.dart';
import '../auth/auth_ui_helpers.dart';
import 'profile_providers.dart';
import '../security/app_lock_providers.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String? _selectedCurrency;
  String? _selectedLanguage;
  String? _selectedTheme;
  String? _initializedProfileUid;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final profileAsync = ref.watch(currentUserProfileProvider);
    final bootstrapAsync = ref.watch(authProfileBootstrapProvider);
    final isSaving = ref.watch(profileControllerProvider).isLoading;
    final appLockState = ref.watch(appLockProvider);
    final currentTheme = ref.watch(themeProvider);
    final currentLocale = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profileTitle)),
      body: profileAsync.when(
        data: (profile) {
          if (profile == null) {
            if (bootstrapAsync.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (bootstrapAsync.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    authErrorMessage(bootstrapAsync.error!, l10n: l10n),
                  ),
                ),
              );
            }

            return Center(child: Text(l10n.profileMissing));
          }

          final safeCurrency = AppConstants.normalizeCurrency(profile.currency);
          final safeLanguage =
              AppConstants.supportedLanguageCodes.contains(profile.language)
              ? profile.language
              : AppConstants.supportedLanguageCodes.contains(
                  currentLocale.languageCode,
                )
              ? currentLocale.languageCode
              : AppConstants.defaultLanguageCode;
          final safeTheme = AppConstants.availableThemes.contains(profile.theme)
              ? profile.theme
              : AppConstants.availableThemes.contains(currentTheme)
              ? currentTheme
              : AppConstants.sapphireDarkTheme;

          if (_initializedProfileUid != profile.uid) {
            _initializedProfileUid = profile.uid;
            _nameController.text = profile.name;
            _selectedCurrency = safeCurrency;
            _selectedLanguage = safeLanguage;
            _selectedTheme = safeTheme;
          }

          final initials = _buildInitials(profile.name, profile.email);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Center(
                        child: Column(
                          children: <Widget>[
                            Stack(
                              children: <Widget>[
                                CircleAvatar(
                                  radius: 48,
                                  child: Text(
                                    initials,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: CircleAvatar(
                                    radius: 16,
                                    backgroundColor: Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withValues(alpha: 0.14),
                                    foregroundColor: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    child: const Icon(
                                      Icons.person_outline_rounded,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              profile.email,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(labelText: l10n.nameLabel),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return l10n.nameRequired;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        initialValue: profile.email,
                        readOnly: true,
                        decoration: InputDecoration(labelText: l10n.emailLabel),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedCurrency ?? safeCurrency,
                        decoration: InputDecoration(
                          labelText: l10n.currencyLabel,
                        ),
                        items: AppConstants.supportedCurrencies
                            .map(
                              (currency) => DropdownMenuItem<String>(
                                value: currency,
                                child: Text(currency),
                              ),
                            )
                            .toList(),
                        onChanged: isSaving
                            ? null
                            : (value) {
                                setState(() {
                                  _selectedCurrency = value;
                                });
                              },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedLanguage ?? safeLanguage,
                        decoration: InputDecoration(
                          labelText: l10n.languageLabel,
                        ),
                        items: <DropdownMenuItem<String>>[
                          DropdownMenuItem(
                            value: 'en',
                            child: Text(l10n.englishLabel),
                          ),
                          DropdownMenuItem(
                            value: 'bn',
                            child: Text(l10n.banglaLabel),
                          ),
                        ],
                        onChanged: isSaving
                            ? null
                            : (value) {
                                setState(() {
                                  _selectedLanguage = value;
                                });
                              },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedTheme ?? safeTheme,
                        decoration: InputDecoration(labelText: l10n.themeLabel),
                        items: AppConstants.availableThemes
                            .map(
                              (themeName) => DropdownMenuItem<String>(
                                value: themeName,
                                child: Text(l10n.themeName(themeName)),
                              ),
                            )
                            .toList(),
                        onChanged: isSaving
                            ? null
                            : (value) {
                                setState(() {
                                  _selectedTheme = value;
                                });
                              },
                      ),
                      const SizedBox(height: 14),
                      _ThemePreviewCard(
                        themeName: _selectedTheme ?? safeTheme,
                        languageCode: safeLanguage,
                      ),
                      const SizedBox(height: 20),
                      buildPremiumCard(
                        context: context,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              l10n.securityLockTitle,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 8),
                            Text(l10n.securityLockSubtitle),
                            const SizedBox(height: 14),
                            Text(
                              appLockState.enabled
                                  ? l10n.appLockEnabledLabel
                                  : l10n.appLockDisabledLabel,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 14),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: <Widget>[
                                if (!appLockState.enabled)
                                  FilledButton.tonalIcon(
                                    onPressed: isSaving ? null : _enablePinLock,
                                    icon: const Icon(
                                      Icons.lock_outline_rounded,
                                    ),
                                    label: Text(l10n.enablePinLockAction),
                                  )
                                else ...<Widget>[
                                  FilledButton.tonalIcon(
                                    onPressed: isSaving ? null : _changePin,
                                    icon: const Icon(Icons.password_rounded),
                                    label: Text(l10n.changePinAction),
                                  ),
                                  OutlinedButton.icon(
                                    onPressed: isSaving
                                        ? null
                                        : _disablePinLock,
                                    icon: const Icon(Icons.lock_open_rounded),
                                    label: Text(l10n.disablePinLockAction),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      buildPremiumCard(
                        context: context,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              l10n.exportSectionInProfile,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 8),
                            Text(l10n.exportSectionProfileSubtitle),
                            const SizedBox(height: 14),
                            OutlinedButton.icon(
                              onPressed: isSaving
                                  ? null
                                  : () =>
                                        context.push(AppConstants.exportRoute),
                              icon: const Icon(Icons.ios_share_rounded),
                              label: Text(l10n.exportDataTitle),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: isSaving
                            ? null
                            : () => _saveProfile(profile),
                        child: Text(isSaving ? l10n.saving : l10n.saveChanges),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: isSaving ? null : _signOut,
                        icon: const Icon(Icons.logout_rounded),
                        label: Text(l10n.signOut),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(authErrorMessage(error, l10n: l10n)),
          ),
        ),
      ),
    );
  }

  Future<void> _saveProfile(UserModel profile) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      await ref
          .read(profileControllerProvider.notifier)
          .saveProfile(
            currentProfile: profile,
            name: _nameController.text,
            currency:
                _selectedCurrency ??
                AppConstants.normalizeCurrency(profile.currency),
            language:
                _selectedLanguage ??
                AppConstants.normalizeLanguageCode(profile.language),
            themeName:
                _selectedTheme ??
                AppConstants.normalizeThemeName(profile.theme),
          );
      if (!mounted) {
        return;
      }
      showAppSnackBar(context, context.l10n.profileUpdated);
    } catch (error) {
      if (!mounted) {
        return;
      }
      showAppSnackBar(context, authErrorMessage(error, l10n: context.l10n));
    }
  }

  Future<void> _signOut() async {
    try {
      ref.read(appLockProvider.notifier).unlockWithoutPrompt();
      await ref.read(authControllerProvider.notifier).signOut();
    } catch (error) {
      if (!mounted) {
        return;
      }
      showAppSnackBar(context, authErrorMessage(error, l10n: context.l10n));
    }
  }

  String _buildInitials(String name, String email) {
    final raw = name.trim().isNotEmpty ? name.trim() : email.trim();
    final parts = raw.split(' ').where((part) => part.isNotEmpty).toList();
    if (parts.isEmpty) {
      return 'U';
    }
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
        .toUpperCase();
  }

  Future<void> _enablePinLock() async {
    final pin = await _showPinDialog(
      title: context.l10n.createPinTitle,
      confirmTitle: context.l10n.confirmPinFieldLabel,
    );
    if (pin == null || !mounted) {
      return;
    }

    await ref.read(appLockProvider.notifier).setPin(pin);
    if (!mounted) {
      return;
    }
    showAppSnackBar(context, context.l10n.lockEnabledMessage);
  }

  Future<void> _changePin() async {
    final pin = await _showPinDialog(
      title: context.l10n.changePinTitle,
      confirmTitle: context.l10n.confirmPinFieldLabel,
    );
    if (pin == null || !mounted) {
      return;
    }

    await ref.read(appLockProvider.notifier).setPin(pin);
    if (!mounted) {
      return;
    }
    showAppSnackBar(context, context.l10n.pinChangedMessage);
  }

  Future<void> _disablePinLock() async {
    await ref.read(appLockProvider.notifier).disable();
    if (!mounted) {
      return;
    }
    showAppSnackBar(context, context.l10n.lockDisabledMessage);
  }

  Future<String?> _showPinDialog({
    required String title,
    required String confirmTitle,
  }) async {
    return Navigator.of(context).push<String>(
      MaterialPageRoute<String>(
        builder: (_) => _PinSetupPage(title: title, confirmTitle: confirmTitle),
        fullscreenDialog: true,
      ),
    );
  }
}

class _PinSetupPage extends StatefulWidget {
  const _PinSetupPage({required this.title, required this.confirmTitle});

  final String title;
  final String confirmTitle;

  @override
  State<_PinSetupPage> createState() => _PinSetupPageState();
}

class _PinSetupPageState extends State<_PinSetupPage> {
  final _pinController = TextEditingController();
  final _confirmController = TextEditingController();
  String? _errorText;

  @override
  void dispose() {
    _pinController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  buildPremiumCard(
                    context: context,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        TextField(
                          controller: _pinController,
                          autofocus: true,
                          obscureText: true,
                          keyboardType: TextInputType.number,
                          maxLength: 4,
                          decoration: InputDecoration(
                            labelText: context.l10n.pinFieldLabel,
                            helperText: context.l10n.pinHelperText,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _confirmController,
                          obscureText: true,
                          keyboardType: TextInputType.number,
                          maxLength: 4,
                          decoration: InputDecoration(
                            labelText: widget.confirmTitle,
                          ),
                        ),
                        if (_errorText != null) ...<Widget>[
                          const SizedBox(height: 8),
                          Text(
                            _errorText!,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.error,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text(context.l10n.cancel),
                            ),
                            FilledButton(
                              onPressed: _save,
                              child: Text(context.l10n.saveAction),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _save() {
    final pin = _pinController.text.trim();
    final confirm = _confirmController.text.trim();
    if (pin.length != 4 || int.tryParse(pin) == null) {
      setState(() {
        _errorText = context.l10n.pinLengthError;
      });
      return;
    }
    if (pin != confirm) {
      setState(() {
        _errorText = context.l10n.pinMismatchError;
      });
      return;
    }
    Navigator.of(context).pop(pin);
  }
}

class _ThemePreviewCard extends StatelessWidget {
  const _ThemePreviewCard({
    required this.themeName,
    required this.languageCode,
  });

  final String themeName;
  final String languageCode;

  @override
  Widget build(BuildContext context) {
    final previewTheme = Theme.of(context).copyWith(
      colorScheme: AppTheme.getTheme(
        themeName,
        languageCode: languageCode,
      ).colorScheme,
      scaffoldBackgroundColor: AppTheme.getTheme(
        themeName,
        languageCode: languageCode,
      ).scaffoldBackgroundColor,
    );
    final colors = _ThemePreviewPalette.fromThemeName(themeName);

    return buildPremiumCard(
      context: context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            context.l10n.themeName(themeName),
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: <Color>[colors.primary, colors.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Aa',
                  style: previewTheme.textTheme.headlineMedium?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: <Widget>[
                    _ThemeColorDot(color: colors.primary),
                    const SizedBox(width: 8),
                    _ThemeColorDot(color: colors.income),
                    const SizedBox(width: 8),
                    _ThemeColorDot(color: colors.expense),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeColorDot extends StatelessWidget {
  const _ThemeColorDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
      ),
    );
  }
}

class _ThemePreviewPalette {
  const _ThemePreviewPalette({
    required this.primary,
    required this.secondary,
    required this.income,
    required this.expense,
    required this.onSurface,
  });

  final Color primary;
  final Color secondary;
  final Color income;
  final Color expense;
  final Color onSurface;

  factory _ThemePreviewPalette.fromThemeName(String themeName) {
    switch (themeName) {
      case AppConstants.emberDarkTheme:
        return const _ThemePreviewPalette(
          primary: Color(0xFFFF8A5B),
          secondary: Color(0xFF5B2B1F),
          income: Color(0xFF41C49A),
          expense: Color(0xFFFF6B6B),
          onSurface: Color(0xFFFFF3EE),
        );
      case AppConstants.emberLightTheme:
        return const _ThemePreviewPalette(
          primary: Color(0xFFDB6A39),
          secondary: Color(0xFFFFC8AE),
          income: Color(0xFF1F9D73),
          expense: Color(0xFFD94E4E),
          onSurface: Color(0xFF2F1A14),
        );
      case AppConstants.sapphireLightTheme:
        return const _ThemePreviewPalette(
          primary: Color(0xFF3D6BE4),
          secondary: Color(0xFFCFE0FF),
          income: Color(0xFF1EB386),
          expense: Color(0xFFD64545),
          onSurface: Color(0xFF14213D),
        );
      case AppConstants.sapphireDarkTheme:
      default:
        return const _ThemePreviewPalette(
          primary: Color(0xFF3D6BE4),
          secondary: Color(0xFF202B53),
          income: Color(0xFF2ECC9A),
          expense: Color(0xFFE85D5D),
          onSurface: Color(0xFFF8FAFC),
        );
    }
  }
}
