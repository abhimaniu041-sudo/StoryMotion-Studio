class AppConstants {
  AppConstants._();

  static const appName = 'StoryMotion Studio';
  static const appTagline = 'Create stories that move';

  static const videoDurations = [
    '30 sec',
    '1 min',
    '3 min',
    '5 min',
    '10 min',
    '15 min',
  ];

  static const videoStyles = [
    'Cartoon',
    'Anime',
    'Realistic',
    'Kids',
  ];

  static const languages = [
    'Hindi',
    'English',
    'Punjabi',
  ];

  static const voiceTypes = [
    'Male',
    'Female',
    'Child',
  ];

  static const videoQualities = [
    '720p',
    '1080p',
  ];

  static const renderSteps = [
    'Generating Story',
    'Creating Scenes',
    'Assigning Characters',
    'Generating Voice',
    'Rendering Video',
    'Finalizing',
  ];

  static const aiTimeout = Duration(seconds: 30);
  static const maxPromptLength = 500;
  static const providerDegradedThreshold = 3;
  static const providerRetryMinutes = 5;

  static const hiveSettingsBox = 'settings_box';
  static const hiveProjectsBox = 'projects_cache_box';

  static const storagePath = 'Movies/StoryMotion';
}
