import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/api_service.dart';
import '../models/video_request_model.dart';
import '../../../core/constants/app_constants.dart';

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

class CreateState {
  final String prompt;
  final String duration;
  final String style;
  final String language;
  final String voiceType;
  final bool isLoading;
  final String? error;
  final String? projectId;

  const CreateState({
    this.prompt = '',
    this.duration = '1 min',
    this.style = 'Cartoon',
    this.language = 'Hindi',
    this.voiceType = 'Male',
    this.isLoading = false,
    this.error,
    this.projectId,
  });

  CreateState copyWith({
    String? prompt,
    String? duration,
    String? style,
    String? language,
    String? voiceType,
    bool? isLoading,
    String? error,
    String? projectId,
  }) {
    return CreateState(
      prompt: prompt ?? this.prompt,
      duration: duration ?? this.duration,
      style: style ?? this.style,
      language: language ?? this.language,
      voiceType: voiceType ?? this.voiceType,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      projectId: projectId ?? this.projectId,
    );
  }
}

class CreateNotifier extends StateNotifier<CreateState> {
  final ApiService _api;

  CreateNotifier(this._api) : super(const CreateState());

  void setPrompt(String v) => state = state.copyWith(prompt: v);
  void setDuration(String v) => state = state.copyWith(duration: v);
  void setStyle(String v) => state = state.copyWith(style: v);
  void setLanguage(String v) => state = state.copyWith(language: v);
  void setVoiceType(String v) => state = state.copyWith(voiceType: v);

  Future<String?> generate(String userId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _api.generateVideo(
        prompt: state.prompt,
        duration: state.duration,
        style: state.style,
        language: state.language,
        voiceType: state.voiceType,
        userId: userId,
      );
      final projectId = result['project_id'] as String;
      state = state.copyWith(isLoading: false, projectId: projectId);
      return projectId;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Could not start generation. Please try again.',
      );
      return null;
    }
  }
}

final createProvider =
    StateNotifierProvider<CreateNotifier, CreateState>((ref) {
  return CreateNotifier(ref.read(apiServiceProvider));
});
