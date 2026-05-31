class ProjectModel {
  final String id;
  final String userId;
  final String title;
  final String prompt;
  final String status;
  final String currentStep;
  final int stepNumber;
  final double progress;
  final String videoUrl;
  final String thumbnailUrl;
  final String duration;
  final String style;
  final String language;
  final DateTime createdAt;

  const ProjectModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.prompt,
    required this.status,
    required this.currentStep,
    required this.stepNumber,
    required this.progress,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.duration,
    required this.style,
    required this.language,
    required this.createdAt,
  });

  factory ProjectModel.fromMap(Map<String, dynamic> map, String id) {
    return ProjectModel(
      id: id,
      userId: map['user_id'] ?? '',
      title: map['title'] ?? 'Untitled',
      prompt: map['prompt'] ?? '',
      status: map['status'] ?? 'pending',
      currentStep: map['current_step'] ?? '',
      stepNumber: (map['step_number'] ?? 0) as int,
      progress: (map['progress'] ?? 0.0) as double,
      videoUrl: map['video_url'] ?? '',
      thumbnailUrl: map['thumbnail_url'] ?? '',
      duration: map['duration'] ?? '',
      style: map['style'] ?? '',
      language: map['language'] ?? '',
      createdAt: map['created_at'] != null
          ? (map['created_at'] as dynamic).toDate()
          : DateTime.now(),
    );
  }
}
