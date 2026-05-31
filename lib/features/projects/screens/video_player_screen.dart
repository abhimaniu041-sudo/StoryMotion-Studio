import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../../../core/services/download_service.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String projectId;
  final String videoUrl;
  final String title;

  const VideoPlayerScreen({
    super.key,
    required this.projectId,
    required this.videoUrl,
    required this.title,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _videoController;
  ChewieController? _chewieController;
  bool _isLoading = true;
  double _downloadProgress = 0;
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    _videoController =
        VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
    await _videoController.initialize();
    _chewieController = ChewieController(
      videoPlayerController: _videoController,
      autoPlay: true,
      looping: false,
      aspectRatio: 16 / 9,
    );
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _download() async {
    setState(() => _isDownloading = true);
    final service = DownloadService();
    final path = await service.downloadVideo(
      url: widget.videoUrl,
      fileName: widget.title.replaceAll(' ', '_'),
      onProgress: (p) => setState(() => _downloadProgress = p),
    );

    setState(() => _isDownloading = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            path != null ? 'Saved to $path' : 'Download failed',
          ),
        ),
      );
    }
  }

  void _showYouTubeTools() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _YouTubeToolsSheet(title: widget.title),
    );
  }

  @override
  void dispose() {
    _videoController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.youtube_searched_for),
            onPressed: _showYouTubeTools,
            tooltip: 'YouTube Tools',
          ),
        ],
      ),
      body: Column(
        children: [
          if (_isLoading)
            const AspectRatio(
              aspectRatio: 16 / 9,
              child: Center(child: CircularProgressIndicator()),
            )
          else
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Chewie(controller: _chewieController!),
            ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                if (_isDownloading) ...[
                  LinearProgressIndicator(value: _downloadProgress),
                  const SizedBox(height: 8),
                  Text(
                    'Downloading ${(_downloadProgress * 100).toInt()}%',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                ],
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isDownloading ? null : _download,
                    icon: const Icon(Icons.download),
                    label: const Text('Download Video'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _showYouTubeTools,
                    icon: const Icon(Icons.video_call_outlined),
                    label: const Text('YouTube Creator Tools'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _YouTubeToolsSheet extends StatelessWidget {
  final String title;
  const _YouTubeToolsSheet({required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('YouTube Creator Tools',
              style: theme.textTheme.titleLarge),
          const SizedBox(height: 24),
          _ToolItem(
            label: 'Suggested Title',
            value: title,
            theme: theme,
          ),
          _ToolItem(
            label: 'Description',
            value:
                'Watch this amazing animated video: $title. Created with StoryMotion Studio.',
            theme: theme,
          ),
          _ToolItem(
            label: 'Tags',
            value:
                'animation, cartoon, story, 2D animation, StoryMotion',
            theme: theme,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _ToolItem extends StatelessWidget {
  final String label;
  final String value;
  final ThemeData theme;

  const _ToolItem({
    required this.label,
    required this.value,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: theme.textTheme.labelLarge
                  ?.copyWith(color: theme.colorScheme.primary)),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(value, style: theme.textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
