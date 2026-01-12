import 'dart:convert';
import 'dart:io';

void main() async {
  print('🔍 Listing available Gemini models...');

  final apiKey = Platform.environment['GEMINI_API_KEY'];
  if (apiKey == null || apiKey.isEmpty) {
    print('❌ Error: GEMINI_API_KEY environment variable not found.');
    exit(1);
  }

  final client = HttpClient();
  try {
    final uri = Uri.https(
      'generativelanguage.googleapis.com',
      '/v1beta/models',
      {'key': apiKey},
    );

    final request = await client.getUrl(uri);
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();

    if (response.statusCode != 200) {
      print('❌ API Error (${response.statusCode}): $responseBody');
      exit(1);
    }

    final data = jsonDecode(responseBody) as Map<String, dynamic>;
    final models = (data['models'] as List?) ?? [];

    if (models.isEmpty) {
      print('⚠️ No models found for this API key.');
      return;
    }

    print('\nAvailable Models:');
    print('------------------------------------------------------------');
    print('${"Model Name".padRight(35)} | Supports GenerateContent');
    print('------------------------------------------------------------');

    for (final model in models) {
      final name = model['name']?.toString() ?? 'unknown';
      final cleanName = name.startsWith('models/') ? name.substring(7) : name;
      final methods = (model['supportedGenerationMethods'] as List?) ?? [];
      final supportsGenerate = methods.contains('generateContent');

      print('${cleanName.padRight(35)} | ${supportsGenerate ? "✅ YES" : "❌ NO"}');
    }
    print('------------------------------------------------------------\n');

  } catch (e) {
    print('❌ Unexpected error: $e');
  } finally {
    client.close();
  }
}
