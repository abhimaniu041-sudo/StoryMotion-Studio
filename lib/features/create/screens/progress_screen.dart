import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_constants.dart';
import '../../projects/screens/video_player_screen.dart';
import '../../home/screens/home_screen.dart';

class ProgressScreen extends ConsumerWidget {
  final String projectId;
  const ProgressScreen({super.key, required this.projectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Generating Video'),
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('projects')
            .doc(projectId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data =
              snapshot.data!.data() as Map<String, dynamic>? ?? {};
          final status = data['status'] ?? 'pending';
          final stepNumber = (data['step_number'] ?? 0) as int;
          final progress = (data['progress'] ?? 0.0) as double;
          final videoUrl = data['video_url'] as String?;

          if (status == 'done' && videoUrl != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => VideoPlayerScreen(
                    projectId: projectId,
                    videoUrl: videoUrl,
                    title: data['title'] ?? 'My Video',
                  ),
                ),
              );
            });
          }

          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  status == 'failed'
                      ? 'Generation Failed'
                      : 'Creating your video...',
                  style: theme.textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  status == 'failed'
                      ? 'Something went wrong. Please try again.'
                      : 'This may take a few minutes',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 32),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor:
                        theme.colorScheme.surface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 32),
                ...AppConstants.renderSteps
                    .asMap()
                    .entries
                    .map((entry) {
                  final index = entry.key;
                  final step = entry.value;
                  StepStatus s;
                  if (index < stepNumber) {
                    s = StepStatus.done;
                  } else if (index == stepNumber) {
                    s = StepStatus.processing;
                  } else {
                    s = StepStatus.pending;
                  }
                  return _StepTile(
                    label: step,
                    status: s,
                    theme: theme,
                  );
                }),
                const Spacer(),
                if (status == 'failed')
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const HomeScreen()),
                      ),
                      child: const Text('Go Back'),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

enum StepStatus { pending, processing, done }

class _StepTile extends StatelessWidget {
  final String label;
  final StepStatus status;
  final ThemeData theme;

  const _StepTile({
    required this.label,
    required this.status,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    Widget leading;
    switch (status) {
      case StepStatus.done:
        leading = Icon(Icons.check_circle, color: Colors.green, size: 24);
        break;
      case StepStatus.processing:
        leading = SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        );
        break;
      case StepStatus.pending:
        leading = Icon(Icons.radio_button_unchecked,
            color: theme.colorScheme.onSurface.withOpacity(0.3), size: 24);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          leading,
          const SizedBox(width: 16),
          Text(
            label,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: status == StepStatus.pending
                  ? theme.colorScheme.onSurface.withOpacity(0.4)
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
