import 'package:proyecto_empoderate/features/ai_texts/domain/ai_text_request.dart';
import 'package:proyecto_empoderate/features/ai_texts/domain/ai_text_output.dart';
import 'package:proyecto_empoderate/features/ai_customers/domain/ai_customer_request.dart';
import 'package:proyecto_empoderate/features/ai_customers/domain/ai_customer_output.dart';
import 'package:proyecto_empoderate/features/ai_shared/domain/ai_generic_request.dart';
import 'package:proyecto_empoderate/features/ai_shared/domain/ai_generic_output.dart';

abstract class AiProvider {
  Future<AiTextOutput> generateAiText(AiTextRequest request);
  Future<AiCustomerOutput> generateAiCustomerStrategy(AiCustomerRequest request);
  Future<AiGenericOutput> generateGeneric(AiGenericRequest request);
}
