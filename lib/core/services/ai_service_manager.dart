import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../constants/api_constants.dart';
import '../constants/app_constants.dart';

abstract class AIProvider {
  String get name;
  Future<bool> isHealthy();
  Future<String> generateStory(
      String prompt, Map<String, dynamic> settings);
  Future<List<Map<String, dynamic>>> generateScenes(
      String story, int durationSeconds);
  Future<String> generateDialogue(Map<String, dynamic> scene);
}

class GeminiProvider implements AIProvider {
  final Dio _dio = Dio();
  final String apiKey = ApiConstants.geminiApiKey;
  final String baseUrl = ApiConstants.geminiBaseUrl;
  final String model = ApiConstants.geminiModel;

  @override
  String get name => 'Gemini';

  @override
  Future<bool> isHealthy() async {
    try {
      final response = await _dio
          .get(
            '$baseUrl/models/$model?key=$apiKey',
          )
          .timeout(const Duration(seconds: 10));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<String> generateStory(
      String prompt, Map<String, dynamic> settings) async {
    final url = '$baseUrl/models/$model:generateContent?key=$apiKey';
    final body = {
      'contents': [
        {
          'parts': [
            {
              'text': '''
You are a creative story writer. Generate a complete story for a 2D animated video.

Prompt: $prompt
Style: ${settings['style']}
Duration: ${settings['duration']}
Language: ${settings['language']}

Return ONLY a JSON object with this structure:
{
  "title": "story title",
  "summary": "brief summary",
  "story": "full story text",
  "chapters": ["chapter 1", "chapter 2"]
}
'''
            }
          ]
        }
      ]
    };

    final response = await _dio
        .post(url, data: body)
        .timeout(AppConstants.aiTimeout);

    final text = response.data['candidates'][0]['content']['parts'][0]['text']
        as String;
    return text;
  }

  @override
  Future<List<Map<String, dynamic>>> generateScenes(
      String story, int durationSeconds) async {
    final url = '$baseUrl/models/$model:generateContent?key=$apiKey';
    final body = {
      'contents': [
        {
          'parts': [
            {
              'text': '''
Break this story into scenes for a 2D animated video.
Total duration: $durationSeconds seconds.

Story: $story

Return ONLY a JSON array:
[
  {
    "scene_number": 1,
    "duration_seconds": 10,
    "background": "forest",
    "characters": ["rabbit", "turtle"],
    "action": "rabbit_idle, turtle_walk",
    "dialogue": "character dialogue here",
    "camera": "medium_shot"
  }
]
'''
            }
          ]
        }
      ]
    };

    final response = await _dio
        .post(url, data: body)
        .timeout(AppConstants.aiTimeout);

    final text = response.data['candidates'][0]['content']['parts'][0]['text']
        as String;
    final clean = text
        .replaceAll('```json', '')
        .replaceAll('```', '')
        .trim();

    final list = (clean as dynamic);
    return List<Map<String, dynamic>>.from(list);
  }

  @override
  Future<String> generateDialogue(Map<String, dynamic> scene) async {
    final url = '$baseUrl/models/$model:generateContent?key=$apiKey';
    final body = {
      'contents': [
        {
          'parts': [
            {
              'text':
                  'Generate natural dialogue for this scene: ${scene.toString()}. Return only the dialogue text.'
            }
          ]
        }
      ]
    };

    final response = await _dio
        .post(url, data: body)
        .timeout(AppConstants.aiTimeout);

    return response.data['candidates'][0]['content']['parts'][0]['text']
        as String;
  }
}

class GroqProvider implements AIProvider {
  final Dio _dio = Dio();
  final String apiKey = ApiConstants.groqApiKey;
  final String baseUrl = ApiConstants.groqBaseUrl;
  final String model = ApiConstants.groqModel;

  @override
  String get name => 'Groq';

  Map<String, String> get _headers => {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      };

  @override
  Future<bool> isHealthy() async {
    try {
      final response = await _dio
          .get('$baseUrl/models',
              options: Options(headers: _headers))
          .timeout(const Duration(seconds: 10));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<String> generateStory(
      String prompt, Map<String, dynamic> settings) async {
    final body = {
      'model': model,
      'messages': [
        {
          'role': 'user',
          'content': '''
Generate a complete story for a 2D animated video.
Prompt: $prompt
Style: ${settings['style']}
Duration: ${settings['duration']}
Language: ${settings['language']}

Return ONLY a JSON object with fields: title, summary, story, chapters.
'''
        }
      ],
      'temperature': 0.7,
    };

    final response = await _dio
        .post(
          '$baseUrl/chat/completions',
          data: body,
          options: Options(headers: _headers),
        )
        .timeout(AppConstants.aiTimeout);

    return response.data['choices'][0]['message']['content'] as String;
  }

  @override
  Future<List<Map<String, dynamic>>> generateScenes(
      String story, int durationSeconds) async {
    final body = {
      'model': model,
      'messages': [
        {
          'role': 'user',
          'content': '''
Break this story into scenes. Total duration: $durationSeconds seconds.
Story: $story
Return ONLY a JSON array of scene objects with fields:
scene_number, duration_seconds, background, characters, action, dialogue, camera.
'''
        }
      ],
      'temperature': 0.7,
    };

    final response = await _dio
        .post(
          '$baseUrl/chat/completions',
          data: body,
          options: Options(headers: _headers),
        )
        .timeout(AppConstants.aiTimeout);

    final text =
        response.data['choices'][0]['message']['content'] as String;
    final clean =
        text.replaceAll('```json', '').replaceAll('```', '').trim();
    return List<Map<String, dynamic>>.from(clean as dynamic);
  }

  @override
  Future<String> generateDialogue(Map<String, dynamic> scene) async {
    final body = {
      'model': model,
      'messages': [
        {
          'role': 'user',
          'content':
              'Generate natural dialogue for this scene: ${scene.toString()}. Return only dialogue text.'
        }
      ],
    };

    final response = await _dio
        .post(
          '$baseUrl/chat/completions',
          data: body,
          options: Options(headers: _headers),
        )
        .timeout(AppConstants.aiTimeout);

    return response.data['choices'][0]['message']['content'] as String;
  }
}

class MistralProvider implements AIProvider {
  final Dio _dio = Dio();
  final String apiKey = ApiConstants.mistralApiKey;
  final String baseUrl = ApiConstants.mistralBaseUrl;
  final String model = ApiConstants.mistralModel;

  @override
  String get name => 'Mistral';

  Map<String, String> get _headers => {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      };

  @override
  Future<bool> isHealthy() async {
    try {
      final response = await _dio
          .get('$baseUrl/models',
              options: Options(headers: _headers))
          .timeout(const Duration(seconds: 10));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<String> generateStory(
      String prompt, Map<String, dynamic> settings) async {
    final body = {
      'model': model,
      'messages': [
        {
          'role': 'user',
          'content': '''
Generate a complete story for a 2D animated video.
Prompt: $prompt
Style: ${settings['style']}
Duration: ${settings['duration']}
Language: ${settings['language']}
Return ONLY JSON with fields: title, summary, story, chapters.
'''
        }
      ],
    };

    final response = await _dio
        .post(
          '$baseUrl/chat/completions',
          data: body,
          options: Options(headers: _headers),
        )
        .timeout(AppConstants.aiTimeout);

    return response.data['choices'][0]['message']['content'] as String;
  }

  @override
  Future<List<Map<String, dynamic>>> generateScenes(
      String story, int durationSeconds) async {
    final body = {
      'model': model,
      'messages': [
        {
          'role': 'user',
          'content': '''
Break this story into scenes. Total duration: $durationSeconds seconds.
Story: $story
Return ONLY a JSON array with fields per scene:
scene_number, duration_seconds, background, characters, action, dialogue, camera.
'''
        }
      ],
    };

    final response = await _dio
        .post(
          '$baseUrl/chat/completions',
          data: body,
          options: Options(headers: _headers),
        )
        .timeout(AppConstants.aiTimeout);

    final text =
        response.data['choices'][0]['message']['content'] as String;
    final clean =
        text.replaceAll('```json', '').replaceAll('```', '').trim();
    return List<Map<String, dynamic>>.from(clean as dynamic);
  }

  @override
  Future<String> generateDialogue(Map<String, dynamic> scene) async {
    final body = {
      'model': model,
      'messages': [
        {
          'role': 'user',
          'content':
              'Write natural dialogue for this animated scene: ${scene.toString()}. Return only the dialogue.'
        }
      ],
    };

    final response = await _dio
        .post(
          '$baseUrl/chat/completions',
          data: body,
          options: Options(headers: _headers),
        )
        .timeout(AppConstants.aiTimeout);

    return response.data['choices'][0]['message']['content'] as String;
  }
}

class AIServiceManager {
  static final AIServiceManager _instance = AIServiceManager._internal();
  factory AIServiceManager() => _instance;
  AIServiceManager._internal();

  final List<AIProvider> _providers = [
    GeminiProvider(),
    GroqProvider(),
    MistralProvider(),
  ];

  final Map<String, int> _failureCounts = {};
  final Map<String, DateTime> _degradedUntil = {};

  bool _isDegraded(AIProvider provider) {
    final until = _degradedUntil[provider.name];
    if (until == null) return false;
    if (DateTime.now().isAfter(until)) {
      _degradedUntil.remove(provider.name);
      _failureCounts[provider.name] = 0;
      return false;
    }
    return true;
  }

  void _recordFailure(AIProvider provider) {
    final count = (_failureCounts[provider.name] ?? 0) + 1;
    _failureCounts[provider.name] = count;
    if (count >= AppConstants.providerDegradedThreshold) {
      _degradedUntil[provider.name] = DateTime.now().add(
        Duration(minutes: AppConstants.providerRetryMinutes),
      );
    }
  }

  void _recordSuccess(AIProvider provider) {
    _failureCounts[provider.name] = 0;
    _degradedUntil.remove(provider.name);
  }

  Future<void> _logToFirestore({
    required String userId,
    required String providerUsed,
    required List<String> providersTried,
    required bool success,
    String error = '',
  }) async {
    try {
      await FirebaseFirestore.instance.collection('ai_logs').add({
        'user_id': userId,
        'provider_used': providerUsed,
        'providers_tried': providersTried,
        'success': success,
        'error': error,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (_) {}
  }

  Future<String> generateStory({
    required String prompt,
    required Map<String, dynamic> settings,
    required String userId,
  }) async {
    final tried = <String>[];

    for (final provider in _providers) {
      if (_isDegraded(provider)) continue;

      tried.add(provider.name);

      try {
        final healthy = await provider.isHealthy();
        if (!healthy) {
          _recordFailure(provider);
          continue;
        }

        final result = await provider.generateStory(prompt, settings);
        _recordSuccess(provider);

        await _logToFirestore(
          userId: userId,
          providerUsed: provider.name,
          providersTried: tried,
          success: true,
        );

        return result;
      } catch (e) {
        _recordFailure(provider);
        continue;
      }
    }

    await _logToFirestore(
      userId: userId,
      providerUsed: 'none',
      providersTried: tried,
      success: false,
      error: 'All providers failed',
    );

    throw Exception('Story generation failed. Please try again.');
  }

  Future<List<Map<String, dynamic>>> generateScenes({
    required String story,
    required int durationSeconds,
    required String userId,
  }) async {
    final tried = <String>[];

    for (final provider in _providers) {
      if (_isDegraded(provider)) continue;
      tried.add(provider.name);

      try {
        final healthy = await provider.isHealthy();
        if (!healthy) {
          _recordFailure(provider);
          continue;
        }
        final result =
            await provider.generateScenes(story, durationSeconds);
        _recordSuccess(provider);
        return result;
      } catch (e) {
        _recordFailure(provider);
        continue;
      }
    }

    throw Exception('Scene generation failed. Please try again.');
  }
}
