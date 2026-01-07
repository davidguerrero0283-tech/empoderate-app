import 'package:proyecto_empoderate/src/services/business_service.dart';
import '../../ai_shared/domain/ai_shared_types.dart';

class AiGenericContextService {
  final BusinessService _businessService = BusinessService();

  Future<String> buildContextString(AiFeatureType type) async {
    final profile = await _businessService.getProfile();
    
    // Default context if no profile
    String baseContext = "Eres un asistente experto para emprendedores en Panamá.";
    
    if (profile != null) {
      baseContext += "\n\nDATOS DEL NEGOCIO DEL USUARIO:"
          "\n- Nombre Comercial: ${profile.nombre}"
          "\n- Rubro/Industria: ${profile.rubro}"
          "\n- Actividad: ${profile.actividad}"
          "\n- Ubicación: ${profile.municipio}, Panamá";
    }

    // Persona / Tone adjustments based on Feature Type
    switch (type) {
      case AiFeatureType.contracts:
        baseContext += "\n\nROL: Abogado experto en leyes panameñas."
            "\nINSTRUCCIÓN: Cita siempre el Código de Trabajo de Panamá y la normativa local."
            "\nTONO: Formal, preciso y protector de los intereses del negocio.";
        break;
      case AiFeatureType.strategies:
        baseContext += "\n\nROL: Consultor de Estrategia de Negocios."
            "\nINSTRUCCIÓN: Enfócate en crecimiento, ventas y retención de clientes."
            "\nTONO: Motivador, accionable y directo.";
        break;
      case AiFeatureType.products:
        baseContext += "\n\nROL: Copywriter experto en ventas persuasivas."
            "\nINSTRUCCIÓN: Usa técnicas de neuropublicidad (AIDA, PAS). Destaca beneficios sobre características."
            "\nTONO: Atractivo, emocional y vendedor.";
        break;
      case AiFeatureType.processes:
        baseContext += "\n\nROL: Ingeniero de Procesos y Operaciones."
            "\nINSTRUCCIÓN: Optimiza recursos, reduce tiempos y elimina desperdicios (Lean)."
            "\nTONO: Estructurado, lógico y eficiente.";
        break;
    }

    return baseContext;
  }
}
