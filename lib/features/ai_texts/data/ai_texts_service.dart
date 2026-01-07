import 'package:proyecto_empoderate/features/ai_texts/domain/ai_text_request.dart';
import 'package:proyecto_empoderate/features/ai_texts/domain/ai_text_output.dart';
import 'package:proyecto_empoderate/core/ai/ai_provider.dart';
import 'package:proyecto_empoderate/core/ai/ai_config.dart';
import 'package:proyecto_empoderate/core/ai/mock_ai_provider.dart';
import 'package:proyecto_empoderate/core/ai/remote_ai_provider.dart';
import 'package:proyecto_empoderate/features/ai_texts/data/ai_texts_repository.dart';

class AiTextsService {
  final AiTextsRepository _repository = AiTextsRepository();
  late final AiProvider _provider;

  AiTextsService() {
    // Injected based on configuration
    if (AiConfig.currentMode == AiMode.mock) {
      _provider = MockAiProvider();
    } else {
      _provider = RemoteAiProvider();
    }
  }

  Future<AiTextOutput> generate(AiTextRequest request) async {
    return await _provider.generateAiText(request);
  }

  Future<void> save(AiTextOutput output) async {
    await _repository.save(output);
  }

  Future<List<AiTextOutput>> getSavedTexts() async {
    return await _repository.list();
  }

  Future<void> deleteSavedText(String id) async {
    await _repository.delete(id);
  }
}
