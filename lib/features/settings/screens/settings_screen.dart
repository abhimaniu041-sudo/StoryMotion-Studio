import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/constants/app_constants.dart';
import '../providers/settings_provider.dart';
import '../../auth/services/auth_service.dart';
import '../../auth/screens/login_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final settings = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);
    final themeNotifier = ref.read(themeModeProvider.notifier);
    final themeMode = ref.watch(themeModeProvider);
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          _SectionHeader('Appearance', theme),
          SwitchListTile(
            title: const Text('Dark Theme'),
            subtitle: const Text('Switch between dark and light mode'),
            value: themeMode == ThemeMode.dark,
            onChanged: (_) => themeNotifier.toggleTheme(),
          ),
          _SectionHeader('Video', theme),
          _DropdownTile(
            title: 'Default Language',
            value: settings.language,
            options: AppConstants.languages,
            onChanged: settingsNotifier.setLanguage,
          ),
          _DropdownTile(
            title: 'Video Quality',
            value: settings.videoQuality,
            options: AppConstants.videoQualities,
            onChanged: settingsNotifier.setVideoQuality,
          ),
          _DropdownTile(
            title: 'Default Voice',
            value: settings.voiceType,
            options: AppConstants.voiceTypes,
            onChanged: settingsNotifier.setVoiceType,
          ),
          _SectionHeader('Storage', theme),
          ListTile(
            title: const Text('Save Location'),
            subtitle: Text(settings.storageLocation),
            leading: const Icon(Icons.folder_outlined),
          ),
          _SectionHeader('Account', theme),
          ListTile(
            title: const Text('Email'),
            subtitle: Text(user?.email ?? 'Guest'),
            leading: const Icon(Icons.email_outlined),
          ),
          ListTile(
            title: const Text('Display Name'),
            subtitle: Text(user?.displayName ?? 'Guest'),
            leading: const Icon(Icons.person_outline),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton.icon(
              onPressed: () async {
                await AuthService().signOut();
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const LoginScreen()),
                    (_) => false,
                  );
                }
              },
              icon: const Icon(Icons.logout),
              label: const Text('Sign Out'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final ThemeData theme;
  const _SectionHeader(this.title, this.theme);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: theme.textTheme.labelLarge?.copyWith(
          color: theme.colorScheme.primary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _DropdownTile extends StatelessWidget {
  final String title;
  final String value;
  final List<String> options;
  final void Function(String) onChanged;

  const _DropdownTile({
    required this.title,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      trailing: DropdownButton<String>(
        value: value,
        underline: const SizedBox(),
        items: options
            .map((o) => DropdownMenuItem(value: o, child: Text(o)))
            .toList(),
        onChanged: (v) => v != null ? onChanged(v) : null,
      ),
    );
  }
}
