import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../l10n/l10n_extension.dart';
import '../../shared/models/user_model.dart';
import '../../shared/providers/locale_provider.dart';
import '../../shared/providers/theme_provider.dart';
import '../../shared/widgets/premium_card.dart';
import '../auth/auth_providers.dart';
import '../auth/auth_ui_helpers.dart';
import 'profile_providers.dart';

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
}
