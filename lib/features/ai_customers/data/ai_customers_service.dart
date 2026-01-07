import 'package:proyecto_empoderate/features/ai_customers/domain/ai_customer_request.dart';
import 'package:proyecto_empoderate/features/ai_customers/domain/ai_customer_output.dart';
import 'package:proyecto_empoderate/core/ai/ai_provider.dart';
import 'package:proyecto_empoderate/core/ai/ai_config.dart';
import 'package:proyecto_empoderate/core/ai/mock_ai_provider.dart';
import 'package:proyecto_empoderate/core/ai/remote_ai_provider.dart';
import 'package:proyecto_empoderate/features/ai_customers/data/ai_customers_repository.dart';

class AiCustomersService {
  final AiCustomersRepository _repository = AiCustomersRepository();

  AiProvider get _provider {
    switch (AiConfig.currentMode) {
      case AiMode.remote:
        return RemoteAiProvider();
      case AiMode.mock:
      default:
        return MockAiProvider();
    }
  }

  Future<AiCustomerOutput> generate(AiCustomerRequest request) async {
    return await _provider.generateAiCustomerStrategy(request);
  }

  Future<void> save(AiCustomerOutput output) async {
    await _repository.save(output);
  }

  Future<List<AiCustomerOutput>> getSaved() async {
    return await _repository.list();
  }

  Future<void> delete(String id) async {
    await _repository.delete(id);
  }
}
