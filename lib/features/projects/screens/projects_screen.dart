import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../providers/projects_provider.dart';
import '../models/project_model.dart';
import 'video_player_screen.dart';

class ProjectsScreen extends ConsumerWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final projectsAsync = ref.watch(allProjectsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Projects')),
      body: projectsAsync.when(
        data: (projects) => projects.isEmpty
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.video_library_outlined,
                        size: 64,
                        color: theme.colorScheme.onSurface
                            .withOpacity(0.2)),
                    const SizedBox(height: 16),
                    Text('No projects yet',
                        style: theme.textTheme.bodyLarge),
                    const SizedBox(height: 8),
                    Text('Create your first video',
                        style: theme.textTheme.bodyMedium),
                  ],
                ),
              )
            : GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.75,
                ),
                itemCount: projects.length,
                itemBuilder: (_, i) =>
                    _ProjectCard(project: projects[i]),
              ),
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
            child: Text('Failed to load', style: theme.textTheme.bodyLarge)),
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final ProjectModel project;
  const _ProjectCard({required this.project});

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Project'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await FirebaseFirestore.instance
          .collection('projects')
          .doc(project.id)
          .delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: project.status == 'done'
          ? () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => VideoPlayerScreen(
                    projectId: project.id,
                    videoUrl: project.videoUrl,
                    title: project.title,
                  ),
                ),
              )
          : null,
      onLongPress: () => _confirmDelete(context),
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                child: Icon(
                  Icons.movie_outlined,
                  size: 48,
                  color: theme.colorScheme.primary.withOpacity(0.5),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    project.title,
                    style: theme.textTheme.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    project.duration,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('MMM d, y').format(project.createdAt),
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
