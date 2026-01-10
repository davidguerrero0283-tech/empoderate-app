import '../models/guide_question_model.dart';
import '../data/guide_master_questions.dart';

class GuideScoringResult {
  final String principal;
  final List<String> alternates;
  final String confidence; // 'Alta', 'Media', 'Baja'
  final List<String> reasoning;
  final List<String> risks;

  GuideScoringResult({
    required this.principal,
    required this.alternates,
    required this.confidence,
    required this.reasoning,
    required this.risks,
  });
}

class GuideMasterScoring {
  // Attributes (0-10 scale usually)
  static final Map<String, double> _attributes = {
    'capital': 0,
    'tiempo': 0,
    'urgencia': 0,
    'tolerancia_tramites': 0,
    'ventas': 0,
    'publico': 0,
    'digital': 0,
    'producto_vs_servicio': 0, // 0=Service, 10=Product
    'logistica_inventario': 0,
    'escalabilidad': 0,
  };

  static GuideScoringResult calculate(Map<int, dynamic> answers) {
    // 1. Reset attributes
    _attributes.updateAll((key, value) => 0.0);
    
    // 2. Process Answers
    // Normalize to 0-10 scale for calculation
    for (var entry in answers.entries) {
      var q = allQuestions.firstWhere((q) => q.id == entry.key, orElse: () => allQuestions.first);
      var answer = entry.value; // int index or double/int value
      
      for (var mapping in q.mappings) {
        double impact = 0.0;
        
        if (q.type == GuideQuestionType.single) {
           impact = mapping.valueMap?[answer] ?? 0.0;
        } else if (q.type == GuideQuestionType.scale) {
           // Scale 1-5 usually. answer is 1..5
           // mapping valueMap can handle 1:1, 5:10
           impact = mapping.valueMap?[answer] ?? (answer * 2.0); // Default to x2 to reach 10
        }
        
        // Add to attribute (Accumulative approach or Averaging?)
        // Let's do Accumulative then Normalize later, or just simple Accumulative cap.
        // For this logic, we just add. Weights can handle significance.
        _attributes[mapping.attribute] = (_attributes[mapping.attribute] ?? 0) + impact;
      }
    }

    // 3. Macro Scores
    // Define Rubro Scores
    Map<String, double> rubroScores = {
      'Comida': 0,
      'Belleza': 0,
      'Tienda': 0, // Retail
      'Digital': 0,
      'Servicios': 0,
    };

    // PESOS BASE (Heuristic)
    // Comida: Needs publico, logistica, tiempo high, some capital
    rubroScores['Comida'] = 
        (_attributes['publico']! * 1.2) + 
        (_attributes['logistica_inventario']! * 1.0) +
        (_attributes['tiempo']! * 1.5) + // Needs lots of time
        (_attributes['capital']! * 0.8) +
        (_attributes['producto_vs_servicio']! * 0.5); // Mixed/Product

    // Belleza: Publico, Ventas (recurrent), Manual skill (proxy?)
    rubroScores['Belleza'] = 
        (_attributes['publico']! * 1.5) +
        (_attributes['ventas']! * 1.0) +
        (_attributes['tiempo']! * 1.0) +
        (_attributes['producto_vs_servicio']! * -0.5); // Favors Service (low score on Product)

    // Tienda: Logistica, Capital, Product, Ventas
    rubroScores['Tienda'] = 
        (_attributes['logistica_inventario']! * 1.5) +
        (_attributes['capital']! * 1.2) +
        (_attributes['producto_vs_servicio']! * 1.5) + // High Product
        (_attributes['ventas']! * 0.8);

    // Digital: Digital, Escalabilidad, Low Urgency?
    rubroScores['Digital'] = 
        (_attributes['digital']! * 2.0) + // Critical
        (_attributes['escalabilidad']! * 1.2) +
        (_attributes['logistica_inventario']! * -1.0) + // Hates inventory usually
        (_attributes['publico']! * -0.5); // Introvert friendly

    // Servicios: Ventas, Service (low product), Low Capital
    rubroScores['Servicios'] = 
        (_attributes['ventas']! * 1.5) +
        (_attributes['producto_vs_servicio']! * -1.5) + // Strong Service
        (_attributes['capital']! * -0.5) + // Low barrier
        (_attributes['escalabilidad']! * 0.5);

    // 4. Hard Stops (Rules)
    /*
    - Si tiempo muy bajo y publico muy bajo: castigar fuerte Comida/Belleza.
    - Si capital muy bajo y no quiere inventario: castigar fuerte Tienda.
    - Si digital muy bajo: castigar moderado Digital.
    */
    
    // Check approximate max potential of attributes to know what is "Bajo"
    // Assuming roughly 5-10 questions per attribute, scores might range 0-50+
    // We'll use relative thresholds or raw checks if we had normalized.
    // Let's assume 'Low' is in bottom 25% of accumulated score map, but since we don't know max,
    // we check specific questions? Or just check if attribute is low relative to others.
    // For safety, let's use the Raw Sum comparison.
    
    // Hard Rule: Low Time & Low Public
    // (We treat thresholds heuristically for now)
    if (_attributes['tiempo']! < 15 && _attributes['publico']! < 15) {
      rubroScores['Comida'] = rubroScores['Comida']! * 0.5;
      rubroScores['Belleza'] = rubroScores['Belleza']! * 0.5;
    }

    // Hard Rule: Low Capital & Low Inventory interest
    if (_attributes['capital']! < 15 && _attributes['logistica_inventario']! < 10) {
      rubroScores['Tienda'] = rubroScores['Tienda']! * 0.3; // Very hard stop
    }

    // Hard Rule: Low Digital Skill
    if (_attributes['digital']! < 10) {
      rubroScores['Digital'] = rubroScores['Digital']! * 0.6;
    }

    // 5. Sort & Confidence
    var sorted = rubroScores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    String principal = sorted[0].key;
    List<String> alternates = [sorted[1].key, sorted[2].key];

    // Confidence
    // Gap between 1st and 2nd
    double gap = (sorted[0].value - sorted[1].value) / sorted[0].value;
    String confidence = 'Media';
    if (gap > 0.12) confidence = 'Alta';
    if (gap < 0.05) confidence = 'Baja';

    // Reasoning Generation (Simple)
    List<String> reasoning = [];
    if (principal == 'Comida') reasoning.add('Tienes alto interés en flujo diario y logística.');
    if (principal == 'Digital') reasoning.add('Tu perfil tecnológico y búsqueda de escalabilidad destacan.');
    if (principal == 'Tienda') reasoning.add('El comercio de productos físicos encaja con tu capital y orden.');
    if (principal == 'Belleza') reasoning.add('El trato personal y servicio son tus fortalezas.');
    if (principal == 'Servicios') reasoning.add('Vender tu habilidad sin inventario es tu camino óptimo.');

    // Risks
    List<String> risks = [];
    if (_attributes['capital']! < 10 && (principal == 'Tienda' || principal == 'Comida')) {
      risks.add('Tu capital es limitado para este rubro. Requiere creatividad financiera.');
    }
    if (_attributes['tiempo']! < 15 && (principal == 'Comida' || principal == 'Belleza')) {
      risks.add('Este rubro suele exigir más tiempo del que indicaste disponible.');
    }

    return GuideScoringResult(
      principal: principal,
      alternates: alternates,
      confidence: confidence,
      reasoning: reasoning,
      risks: risks,
    );
  }

  static Map<String, String> getConcreteRubros(String macroCategory) {
    switch (macroCategory) {
      case 'Comida':
        return {
          'rest_small': 'Restaurante Pequeño',
          'food_truck': 'Food Truck',
          'coffee_shop': 'Cafetería / Panadería',
          'street_food': 'Puesto de Comida Rápida'
        };
      case 'Belleza':
        return {
          'beauty_salon': 'Salón de Belleza', // id guess
          'nails_spa': 'Nails Spa', // id guess
          'barber_shop': 'Barbería', // id guess
          'spa': 'Spa / Estética'
        };
      case 'Tienda':
        return {
          'clothing_store': 'Boutique de Ropa',
          'grocery_store': 'Minimarket / Abarrotería',
          'gift_shop': 'Tienda de Regalos',
          'online_store': 'E-commerce (Reselling)'
        };
      case 'Digital':
        return {
          'marketing': 'Agencia de Marketing',
          'freelance_dev': 'Desarrollo Web/App',
          'content_creator': 'Creación de Contenido',
          'consulting': 'Consultoría Online'
        };
      case 'Servicios':
        return {
          'cleaning': 'Servicios de Limpieza',
          'repair': 'Reparaciones / Mantenimiento',
          'tutoring': 'Tutorías / Clases',
          'delivery': 'Servicio de Delivery'
        };
      case 'Eventos':
         return {
          'event_planner': 'Organización de Eventos',
          'decoration': 'Decoración de Fiestas',
          'dj': 'DJ / Sonido',
          'catering': 'Catering / Boquitas'
         };
      default:
        return {};
    }
  }
}
