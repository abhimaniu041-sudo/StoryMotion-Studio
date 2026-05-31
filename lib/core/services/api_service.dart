import 'package:dio/dio.dart';
import '../constants/api_constants.dart';

class ApiService {
  late final Dio _dio;

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 60),
      headers: {'Content-Type': 'application/json'},
    ));

    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
    ));
  }

  Future<Map<String, dynamic>> generateVideo({
    required String prompt,
    required String duration,
    required String style,
    required String language,
    required String voiceType,
    required String userId,
  }) async {
    final response = await _dio.post(
      ApiConstants.generateEndpoint,
      data: {
        'prompt': prompt,
        'duration': duration,
        'style': style,
        'language': language,
        'voice_type': voiceType,
        'user_id': userId,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getStatus(String projectId) async {
    final response = await _dio.get(
      '${ApiConstants.statusEndpoint}/$projectId',
    );
    return response.data as Map<String, dynamic>;
  }

  Future<List<dynamic>> getUserProjects(String userId) async {
    final response = await _dio.get(
      '${ApiConstants.projectsEndpoint}/$userId',
    );
    return response.data as List<dynamic>;
  }

  Future<void> deleteProject(String projectId) async {
    await _dio.delete(
      '${ApiConstants.deleteEndpoint}/$projectId',
    );
  }
}
