import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/constants/app_constants.dart';
import '../../shared/models/user_model.dart';
import '../../shared/providers/locale_provider.dart';
import '../../shared/providers/theme_provider.dart';
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
  bool _initialized = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(currentUserProfileProvider);
    final isSaving = ref.watch(profileControllerProvider).isLoading;
    final currentTheme = ref.watch(themeProvider);
    final currentLocale = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: profileAsync.when(
        data: (profile) {
          if (profile == null) {
            return const Center(child: Text('No profile found.'));
          }

          if (!_initialized) {
            _initialized = true;
            _nameController.text = profile.name;
            _selectedCurrency = profile.currency;
            _selectedLanguage = profile.language;
            _selectedTheme = profile.theme;
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
                                  backgroundImage: profile.avatarUrl.isNotEmpty
                                      ? NetworkImage(profile.avatarUrl)
                                      : null,
                                  child: profile.avatarUrl.isEmpty
                                      ? Text(
                                          initials,
                                          style: Theme.of(context)
                                              .textTheme
                                              .headlineSmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.w700,
                                              ),
                                        )
                                      : null,
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: IconButton.filled(
                                    onPressed: isSaving
                                        ? null
                                        : () => _pickAvatar(profile.uid),
                                    icon: const Icon(
                                      Icons.photo_camera_outlined,
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
                        decoration: const InputDecoration(labelText: 'Name'),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Name is required.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        initialValue: profile.email,
                        readOnly: true,
                        decoration: const InputDecoration(labelText: 'Email'),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedCurrency ?? profile.currency,
                        decoration: const InputDecoration(
                          labelText: 'Currency',
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
                        initialValue:
                            _selectedLanguage ?? currentLocale.languageCode,
                        decoration: const InputDecoration(
                          labelText: 'Language',
                        ),
                        items: const <DropdownMenuItem<String>>[
                          DropdownMenuItem(value: 'en', child: Text('English')),
                          DropdownMenuItem(value: 'bn', child: Text('Bangla')),
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
                        initialValue: _selectedTheme ?? currentTheme,
                        decoration: const InputDecoration(labelText: 'Theme'),
                        items: AppConstants.availableThemes
                            .map(
                              (themeName) => DropdownMenuItem<String>(
                                value: themeName,
                                child: Text(AppConstants.themeLabel(themeName)),
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
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: isSaving
                            ? null
                            : () => _saveProfile(profile),
                        child: Text(isSaving ? 'Saving...' : 'Save changes'),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: isSaving ? null : _signOut,
                        icon: const Icon(Icons.logout_rounded),
                        label: const Text('Sign out'),
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
            child: Text(authErrorMessage(error)),
          ),
        ),
      ),
    );
  }

  Future<void> _pickAvatar(String uid) async {
    try {
      final picker = ImagePicker();
      final file = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 82,
      );

      if (file == null) {
        return;
      }

      final profile = ref.read(currentUserProfileProvider).value;
      if (profile == null) {
        return;
      }

      await ref
          .read(profileControllerProvider.notifier)
          .uploadAvatar(currentProfile: profile, file: file);
      if (!mounted) {
        return;
      }
      showAppSnackBar(context, 'Profile photo updated.');
    } catch (error) {
      if (!mounted) {
        return;
      }
      showAppSnackBar(context, authErrorMessage(error));
    }
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
            currency: _selectedCurrency ?? profile.currency,
            language: _selectedLanguage ?? profile.language,
            themeName: _selectedTheme ?? profile.theme,
          );
      if (!mounted) {
        return;
      }
      showAppSnackBar(context, 'Profile updated successfully.');
    } catch (error) {
      if (!mounted) {
        return;
      }
      showAppSnackBar(context, authErrorMessage(error));
    }
  }

  Future<void> _signOut() async {
    try {
      await ref.read(authControllerProvider.notifier).signOut();
    } catch (error) {
      if (!mounted) {
        return;
      }
      showAppSnackBar(context, authErrorMessage(error));
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
