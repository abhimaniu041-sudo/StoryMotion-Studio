import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsState {
  final String language;
  final String videoQuality;
  final String storageLocation;
  final String voiceType;

  const SettingsState({
    this.language = 'Hindi',
    this.videoQuality = '720p',
    this.storageLocation = 'Movies/StoryMotion',
    this.voiceType = 'Male',
  });

  SettingsState copyWith({
    String? language,
    String? videoQuality,
    String? storageLocation,
    String? voiceType,
  }) {
    return SettingsState(
      language: language ?? this.language,
      videoQuality: videoQuality ?? this.videoQuality,
      storageLocation: storageLocation ?? this.storageLocation,
      voiceType: voiceType ?? this.voiceType,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(const SettingsState()) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = SettingsState(
      language: prefs.getString('language') ?? 'Hindi',
      videoQuality: prefs.getString('video_quality') ?? '720p',
      storageLocation:
          prefs.getString('storage_location') ?? 'Movies/StoryMotion',
      voiceType: prefs.getString('voice_type') ?? 'Male',
    );
  }

  Future<void> setLanguage(String v) async {
    state = state.copyWith(language: v);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', v);
  }

  Future<void> setVideoQuality(String v) async {
    state = state.copyWith(videoQuality: v);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('video_quality', v);
  }

  Future<void> setVoiceType(String v) async {
    state = state.copyWith(voiceType: v);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('voice_type', v);
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>(
        (ref) => SettingsNotifier());
