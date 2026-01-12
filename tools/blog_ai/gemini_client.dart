import 'dart:convert';
import 'dart:io';
import 'dart:math';

/// Gemini API Client for generating blog content
/// 
/// Reads configuration from environment variables:
/// - GEMINI_API_KEY (required): Your API key from AI Studio
/// - GEMINI_MODEL (optional): Model to use (dynamic discovery if not set or invalid)
/// - GEMINI_MAX_OUTPUT_TOKENS (optional): Max tokens (default: 1800)
class GeminiClient {
  final String apiKey;
  String _currentModel = 'gemini-2.0-flash-lite'; // Temporary default
  final int maxOutputTokens;
  final double temperature;
  final double topP;
  final HttpClient _httpClient;
  final Random _random = Random();

  static const String _baseUrl = 'generativelanguage.googleapis.com';
  
  List<String> _availableModels = [];
  bool _initialized = false;

  String get model => _currentModel;

  GeminiClient({
    String? apiKey,
    int? maxOutputTokens,
    double? temperature,
    double? topP,
  })  : apiKey = apiKey ?? _getApiKeyFromEnv(),
        maxOutputTokens = maxOutputTokens ?? _getMaxTokensFromEnv(),
        temperature = temperature ?? 0.6,
        topP = topP ?? 0.9,
        _httpClient = HttpClient();

  static String _getApiKeyFromEnv() {
    final key = Platform.environment['GEMINI_API_KEY'];
    if (key == null || key.isEmpty) {
      throw Exception('GEMINI_API_KEY not found in environment variables');
    }
    return key;
  }

  static int _getMaxTokensFromEnv() {
    final tokensStr = Platform.environment['GEMINI_MAX_OUTPUT_TOKENS'];
    if (tokensStr != null) {
      return int.tryParse(tokensStr) ?? 1800;
    }
    return 1800;
  }

  /// Initialize the client by fetching available models and selecting the best one
  Future<void> init() async {
    if (_initialized) return;

    print('🔍 Model Discovery: Fetching available models...');
    await _fetchAvailableModels();

    final envModel = Platform.environment['GEMINI_MODEL'];
    if (envModel != null && envModel.trim().isNotEmpty) {
      final requested = envModel.trim();
      if (_availableModels.contains(requested)) {
        _currentModel = requested;
        print('   ✅ Using requested model: $_currentModel');
      } else {
        print('   ⚠️ Requested model "$requested" not found or not supported.');
        _autoSelectModel();
      }
    } else {
      _autoSelectModel();
    }

    print('   ┌─ Gemini Client Ready ────────────────────────────────┐');
    print('   │ Selected Model: $_currentModel');
    print('   │ Max Tokens: $maxOutputTokens');
    print('   └──────────────────────────────────────────────────────┘');
    _initialized = true;
  }

  Future<void> _fetchAvailableModels() async {
    try {
      final uri = Uri.https(_baseUrl, '/v1beta/models', {'key': apiKey});
      final request = await _httpClient.getUrl(uri);
      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      if (response.statusCode != 200) {
        throw Exception('Failed to list models: $responseBody');
      }

      final data = jsonDecode(responseBody) as Map<String, dynamic>;
      final models = (data['models'] as List?) ?? [];
      
      _availableModels = models
          .where((m) => (m['supportedGenerationMethods'] as List?)?.contains('generateContent') ?? false)
          .map((m) => m['name'].toString().replaceFirst('models/', ''))
          .toList();

    } catch (e) {
      print('   ❌ Error discovering models: $e');
      // Fallback to a safe list if discovery fails
      _availableModels = ['gemini-2.0-flash-lite', 'gemini-1.5-flash', 'gemini-1.5-pro'];
    }
  }

  void _autoSelectModel() {
    // Priority order for auto-selection
    const priorities = [
      'gemini-2.0-flash-lite',
      'gemini-1.5-flash',
      'gemini-flash-latest',
      'gemini-2.0-flash',
      'gemini-1.5-pro',
      'gemini-pro-latest',
    ];

    for (final pref in priorities) {
      if (_availableModels.contains(pref)) {
        _currentModel = pref;
        print('   💡 Auto-selected best model: $_currentModel');
        return;
      }
    }

    if (_availableModels.isNotEmpty) {
      _currentModel = _availableModels.first;
      print('   💡 Auto-selected fallback model: $_currentModel');
    } else {
      print('   ❌ Proceeding with default: $_currentModel (Risk of 404)');
    }
  }

  /// Generate content using Gemini API with exponential backoff and fallback
  Future<String> generateContent(String prompt) async {
    if (!_initialized) await init();

    int consecutiveRateLimits = 0;
    const maxRetries = 5;
    
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        return await _makeRequest(prompt);
      } on RateLimitException catch (e) {
        consecutiveRateLimits++;
        
        bool isQuotaExhausted = e.message.contains('limit: 0') || 
                               e.message.contains('quota exhausted') ||
                               e.message.contains('QUOTA_EXCEEDED');

        int delayMs;
        if (e.retryAfterSeconds > 0) {
          delayMs = (e.retryAfterSeconds * 1000) + _random.nextInt(500);
          print('   ⏳ API-requested delay: ${e.retryAfterSeconds}s (Attempt $attempt/$maxRetries)');
        } else {
          delayMs = (2000 * pow(2, attempt - 1).toInt()) + _random.nextInt(600);
          print('   ⏳ Backoff delay: ${delayMs}ms (Attempt $attempt/$maxRetries)');
        }
        
        if (isQuotaExhausted || consecutiveRateLimits >= 2) {
          final nextModel = _getNextFallbackModel();
          if (nextModel != null) {
            print('   🔄 Quota swap: $_currentModel → $nextModel');
            _currentModel = nextModel;
            consecutiveRateLimits = 0; 
          } else {
             print('   ⚠️ No more fallback models available.');
          }
        }
        
        await Future.delayed(Duration(milliseconds: delayMs));
        
      } on GeminiApiException catch (e) {
        if (e.statusCode == 401 || e.statusCode == 403) rethrow;
        
        if (e.statusCode == 404) {
           print('   ⚠️ Model $_currentModel returned 404. Retrying discovery...');
           await _fetchAvailableModels();
           final nextModel = _getNextFallbackModel();
           if (nextModel != null) {
              _currentModel = nextModel;
              continue;
           }
        }
        rethrow;
      } catch (e) {
        if (attempt == maxRetries) rethrow;
        print('   ⚠️ Warning: Attempt $attempt failed: $e');
        await Future.delayed(Duration(seconds: attempt));
      }
    }
    
    throw Exception('Failed after $maxRetries attempts');
  }

  String? _getNextFallbackModel() {
    // Just pick the next one in available models that isn't the current one
    final index = _availableModels.indexOf(_currentModel);
    if (index >= 0 && index < _availableModels.length - 1) {
      return _availableModels[index + 1];
    }
    
    // Return null if no other models available
    try {
       return _availableModels.firstWhere((m) => m != _currentModel);
    } catch (_) {
       return null;
    }
  }

  Future<String> _makeRequest(String prompt) async {
    final uri = Uri.https(_baseUrl, '/v1beta/models/$_currentModel:generateContent', {'key': apiKey});
    final body = jsonEncode({
      'contents': [{'parts': [{'text': prompt}]}],
      'generationConfig': {
        'temperature': temperature,
        'topP': topP,
        'maxOutputTokens': maxOutputTokens,
      },
    });

    final request = await _httpClient.postUrl(uri);
    request.headers.set('Content-Type', 'application/json');
    request.write(body);

    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();

    if (response.statusCode == 429) {
      int retrySec = 0;
      try {
        final err = jsonDecode(responseBody);
        final details = err['error']?['details'] as List?;
        if (details != null) {
          for (final d in details) {
            if (d['@type']?.toString().contains('RetryInfo') == true) {
              final delay = d['retryDelay']?.toString() ?? '';
              retrySec = int.tryParse(RegExp(r'(\d+)').firstMatch(delay)?.group(1) ?? '0') ?? 0;
            }
          }
        }
      } catch (_) {}
      throw RateLimitException(statusCode: 429, message: responseBody, retryAfterSeconds: retrySec);
    }

    if (response.statusCode == 401 || response.statusCode == 403) {
      throw GeminiApiException(statusCode: response.statusCode, message: 'Auth Error: $responseBody');
    }

    if (response.statusCode != 200) {
      throw GeminiApiException(statusCode: response.statusCode, message: responseBody);
    }

    final json = jsonDecode(responseBody);
    return json['candidates'][0]['content']['parts'][0]['text'] as String;
  }

  void close() => _httpClient.close();
}

class RateLimitException implements Exception {
  final int statusCode;
  final String message;
  final int retryAfterSeconds;
  RateLimitException({required this.statusCode, required this.message, required this.retryAfterSeconds});
}

class GeminiApiException implements Exception {
  final int statusCode;
  final String message;
  GeminiApiException({required this.statusCode, required this.message});
}
