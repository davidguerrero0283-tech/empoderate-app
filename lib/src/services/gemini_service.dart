import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Service for interacting with Google Gemini API
class GeminiService {
  static const String _apiKeyPref = 'gemini_api_key';
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent';
  
  String? _apiKey;
  
  /// Singleton instance
  static final GeminiService _instance = GeminiService._internal();
  factory GeminiService() => _instance;
  GeminiService._internal();

  /// Initialize and load API key from storage
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _apiKey = prefs.getString(_apiKeyPref);
  }

  /// Check if API key is configured
  bool get isConfigured => _apiKey != null && _apiKey!.isNotEmpty;

  /// Get current API key
  String? get apiKey => _apiKey;

  /// Save API key to storage
  Future<void> setApiKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_apiKeyPref, key);
    _apiKey = key;
  }

  /// Clear API key
  Future<void> clearApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_apiKeyPref);
    _apiKey = null;
  }

  /// Generate content using Gemini API
  /// Returns the generated text or throws an exception
  Future<String> generateContent(String prompt, {int maxTokens = 2048}) async {
    if (!isConfigured) {
      throw GeminiException('API Key no configurada. Ve a Configuración para agregarla.');
    }

    final url = Uri.parse('$_baseUrl?key=$_apiKey');
    
    final body = jsonEncode({
      'contents': [
        {
          'parts': [
            {'text': prompt}
          ]
        }
      ],
      'generationConfig': {
        'temperature': 0.7,
        'topK': 40,
        'topP': 0.95,
        'maxOutputTokens': maxTokens,
      },
      'safetySettings': [
        {'category': 'HARM_CATEGORY_HARASSMENT', 'threshold': 'BLOCK_MEDIUM_AND_ABOVE'},
        {'category': 'HARM_CATEGORY_HATE_SPEECH', 'threshold': 'BLOCK_MEDIUM_AND_ABOVE'},
        {'category': 'HARM_CATEGORY_SEXUALLY_EXPLICIT', 'threshold': 'BLOCK_MEDIUM_AND_ABOVE'},
        {'category': 'HARM_CATEGORY_DANGEROUS_CONTENT', 'threshold': 'BLOCK_MEDIUM_AND_ABOVE'},
      ],
    });

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      ).timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Extract text from response
        if (data['candidates'] != null && 
            data['candidates'].isNotEmpty &&
            data['candidates'][0]['content'] != null &&
            data['candidates'][0]['content']['parts'] != null &&
            data['candidates'][0]['content']['parts'].isNotEmpty) {
          return data['candidates'][0]['content']['parts'][0]['text'] ?? '';
        }
        
        throw GeminiException('Respuesta vacía de Gemini');
      } else if (response.statusCode == 400) {
        throw GeminiException('Error en la solicitud. Verifica tu API Key.');
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw GeminiException('API Key inválida o sin permisos.');
      } else if (response.statusCode == 429) {
        throw GeminiException('Límite de solicitudes alcanzado. Intenta en unos minutos.');
      } else {
        throw GeminiException('Error del servidor (${response.statusCode})');
      }
    } catch (e) {
      if (e is GeminiException) rethrow;
      throw GeminiException('Error de conexión: ${e.toString()}');
    }
  }
}

/// Custom exception for Gemini API errors
class GeminiException implements Exception {
  final String message;
  GeminiException(this.message);
  
  @override
  String toString() => message;
}
