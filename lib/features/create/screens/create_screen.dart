import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/custom_button.dart';
import '../providers/create_provider.dart';
import 'progress_screen.dart';

class CreateScreen extends ConsumerWidget {
  const CreateScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(createProvider);
    final notifier = ref.read(createProvider.notifier);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Create Video')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text('Describe your video', style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          Text('Be as detailed as you like',
              style: theme.textTheme.bodyMedium),
          const SizedBox(height: 16),
          TextFormField(
            maxLines: 5,
            maxLength: AppConstants.maxPromptLength,
            decoration: const InputDecoration(
              hintText: 'Describe your video idea...',
            ),
            onChanged: notifier.setPrompt,
          ),
          const SizedBox(height: 28),
          _SectionLabel('Duration', theme),
          const SizedBox(height: 12),
          _ChipSelector(
            options: AppConstants.videoDurations,
            selected: state.duration,
            onSelect: notifier.setDuration,
          ),
          const SizedBox(height: 24),
          _SectionLabel('Style', theme),
          const SizedBox(height: 12),
          _ChipSelector(
            options: AppConstants.videoStyles,
            selected: state.style,
            onSelect: notifier.setStyle,
          ),
          const SizedBox(height: 24),
          _SectionLabel('Language', theme),
          const SizedBox(height: 12),
          _ChipSelector(
            options: AppConstants.languages,
            selected: state.language,
            onSelect: notifier.setLanguage,
          ),
          const SizedBox(height: 24),
          _SectionLabel('Voice Type', theme),
          const SizedBox(height: 12),
          _ChipSelector(
            options: AppConstants.voiceTypes,
            selected: state.voiceType,
            onSelect: notifier.setVoiceType,
          ),
          const SizedBox(height: 12),
          Text(
            'Estimated time: ${_estimateTime(state.duration)}',
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          if (state.error != null) ...[
            Text(state.error!,
                style: TextStyle(
                    color: theme.colorScheme.error, fontSize: 14)),
            const SizedBox(height: 12),
          ],
          CustomButton(
            label: 'Generate Video',
            isLoading: state.isLoading,
            onTap: state.prompt.trim().isEmpty
                ? null
                : () async {
                    final uid =
                        FirebaseAuth.instance.currentUser?.uid ?? '';
                    final projectId =
                        await notifier.generate(uid);
                    if (projectId != null && context.mounted) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ProgressScreen(projectId: projectId),
                        ),
                      );
                    }
                  },
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  String _estimateTime(String duration) {
    switch (duration) {
      case '30 sec':
        return '2-3 minutes';
      case '1 min':
        return '4-5 minutes';
      case '3 min':
        return '8-10 minutes';
      case '5 min':
        return '12-15 minutes';
      case '10 min':
        return '20-25 minutes';
      case '15 min':
        return '30-40 minutes';
      default:
        return '5-10 minutes';
    }
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final ThemeData theme;
  const _SectionLabel(this.label, this.theme);

  @override
  Widget build(BuildContext context) {
    return Text(label, style: theme.textTheme.titleMedium);
  }
}

class _ChipSelector extends StatelessWidget {
  final List<String> options;
  final String selected;
  final void Function(String) onSelect;

  const _ChipSelector({
    required this.options,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((o) {
        final isSelected = o == selected;
        return ChoiceChip(
          label: Text(o),
          selected: isSelected,
          onSelected: (_) => onSelect(o),
          selectedColor: theme.colorScheme.primary.withOpacity(0.2),
          labelStyle: TextStyle(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.textTheme.bodyMedium?.color,
            fontWeight:
                isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        );
      }).toList(),
    );
  }
}
