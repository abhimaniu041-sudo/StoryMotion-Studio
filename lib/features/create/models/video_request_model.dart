class VideoRequestModel {
  final String prompt;
  final String duration;
  final String style;
  final String language;
  final String voiceType;
  final String userId;

  const VideoRequestModel({
    required this.prompt,
    required this.duration,
    required this.style,
    required this.language,
    required this.voiceType,
    required this.userId,
  });

  Map<String, dynamic> toMap() => {
        'prompt': prompt,
        'duration': duration,
        'style': style,
        'language': language,
        'voice_type': voiceType,
        'user_id': userId,
      };
}
