import 'ai_provider.dart';
import 'package:proyecto_empoderate/features/ai_texts/domain/ai_text_request.dart';
import 'package:proyecto_empoderate/features/ai_texts/domain/ai_text_output.dart';
import 'package:proyecto_empoderate/features/ai_customers/domain/ai_customer_request.dart';
import 'package:proyecto_empoderate/features/ai_customers/domain/ai_customer_output.dart';
import 'package:proyecto_empoderate/features/ai_shared/domain/ai_generic_request.dart';
import 'package:proyecto_empoderate/features/ai_shared/domain/ai_generic_output.dart';

class RemoteAiProvider implements AiProvider {
  @override
  Future<AiTextOutput> generateAiText(AiTextRequest request) async {
    // In a real scenario, this would call your backend endpoint (not OpenAI directly)
    // For now, it's a placeholder that throws or falls back.
    throw UnimplementedError('RemoteAiProvider not implemented yet. Use MockAiProvider for now.');
  }

  @override
  Future<AiCustomerOutput> generateAiCustomerStrategy(AiCustomerRequest request) async {
    throw UnimplementedError('RemoteAiProvider not implemented yet. Use MockAiProvider for now.');
  }

  @override
  Future<AiGenericOutput> generateGeneric(AiGenericRequest request) async {
    throw UnimplementedError('RemoteAiProvider not implemented yet. Use MockAiProvider for now.');
  }
}
