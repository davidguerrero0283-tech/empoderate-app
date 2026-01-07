import 'package:proyecto_empoderate/core/ai/ai_provider.dart';
import 'package:proyecto_empoderate/core/ai/ai_config.dart';
import 'package:proyecto_empoderate/core/ai/mock_ai_provider.dart';
import 'package:proyecto_empoderate/core/ai/remote_ai_provider.dart';
import '../domain/ai_generic_request.dart';
import '../domain/ai_generic_output.dart';
import '../domain/ai_shared_types.dart';
import 'ai_generic_repository.dart';

class AiGenericService {
  final AiGenericRepository _repository = AiGenericRepository();

  AiProvider get _provider {
    switch (AiConfig.currentMode) {
      case AiMode.remote:
        return RemoteAiProvider();
      case AiMode.mock:
      default:
        return MockAiProvider();
    }
  }

  Future<AiGenericOutput> generate(AiGenericRequest request) async {
    return await _provider.generateGeneric(request);
  }

  Future<void> save(AiGenericOutput output) async {
    await _repository.save(output.request.type, output);
  }

  Future<List<AiGenericOutput>> getSaved(AiFeatureType type) async {
    return await _repository.list(type);
  }

  Future<void> delete(AiFeatureType type, String id) async {
    await _repository.delete(type, id);
  }
}
