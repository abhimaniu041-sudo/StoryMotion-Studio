import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  ApiConstants._();

  static String get baseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'https://your-backend.railway.app';

  static String get geminiApiKey =>
      dotenv.env['GEMINI_API_KEY'] ?? '';

  static String get groqApiKey =>
      dotenv.env['GROQ_API_KEY'] ?? '';

  static String get mistralApiKey =>
      dotenv.env['MISTRAL_API_KEY'] ?? '';

  // Backend endpoints
  static const generateEndpoint = '/api/generate';
  static const statusEndpoint = '/api/status';
  static const projectsEndpoint = '/api/projects';
  static const deleteEndpoint = '/api/project';

  // Gemini
  static const geminiBaseUrl =
      'https://generativelanguage.googleapis.com/v1beta';
  static const geminiModel = 'gemini-1.5-flash';

  // Groq
  static const groqBaseUrl = 'https://api.groq.com/openai/v1';
  static const groqModel = 'llama3-8b-8192';

  // Mistral
  static const mistralBaseUrl = 'https://api.mistral.ai/v1';
  static const mistralModel = 'mistral-small-latest';
}
