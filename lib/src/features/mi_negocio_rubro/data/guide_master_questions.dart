import '../models/guide_question_model.dart';

const List<GuideQuestion> allQuestions = [
  // --- Q1 to Q10: ESSENTIAL / CORE ---
  GuideQuestion(
    id: 1,
    text: '¿Cuál es tu meta principal con este negocio?',
    type: GuideQuestionType.single,
    options: ['Ingreso extra', 'Reemplazar mi salario actual', 'Construir una empresa grande'],
    mappings: [
      AttributeMapping(attribute: 'escalabilidad', valueMap: {0: 2, 1: 5, 2: 10}),
      AttributeMapping(attribute: 'tiempo', valueMap: {0: 2, 1: 8, 2: 10}) // Needs more time for bigger goals
    ],
    priority: 'rapido',
  ),
  GuideQuestion(
    id: 2,
    text: '¿Con qué urgencia necesitas generar ganancias?',
    type: GuideQuestionType.single,
    options: ['0-30 días (Inmediato)', '1-3 meses', '3-6 meses', '6+ meses (Largo plazo)'],
    mappings: [
      AttributeMapping(attribute: 'urgencia', valueMap: {0: 10, 1: 7, 2: 4, 3: 1}),
    ],
    priority: 'rapido',
  ),
  GuideQuestion(
    id: 3,
    text: '¿Cuál es tu rango de capital inicial disponible?',
    type: GuideQuestionType.single,
    options: ['Muy bajo (<\$500)', 'Bajo (\$500 - \$2,000)', 'Medio (\$2,000 - \$10,000)', 'Alto (>\$10,000)'],
    mappings: [
      AttributeMapping(attribute: 'capital', valueMap: {0: 1, 1: 3, 2: 6, 3: 10}),
    ],
    priority: 'rapido',
  ),
  GuideQuestion(
    id: 4,
    text: '¿Tienes acceso a crédito o financiamiento adicional si fuera necesario?',
    type: GuideQuestionType.single,
    options: ['Sí, fácilmente', 'No, dependo solo de mi ahorro', 'Limitado'],
    mappings: [
      AttributeMapping(attribute: 'capital', valueMap: {0: 8, 1: 2, 2: 4}),
    ],
    priority: 'intermedio',
  ),
  GuideQuestion(
    id: 5,
    text: '¿Cuánto tiempo real puedes dedicarle a la semana?',
    type: GuideQuestionType.single,
    options: ['5-10 horas (Side hustl)', '10-20 horas (Medio tiempo)', '20-40 horas (Completo)', '40+ horas (Obsesivo)'],
    mappings: [
      AttributeMapping(attribute: 'tiempo', valueMap: {0: 2, 1: 5, 2: 8, 3: 10}),
    ],
    priority: 'rapido',
  ),
  GuideQuestion(
    id: 6,
    text: '¿Desde dónde prefieres operar?',
    type: GuideQuestionType.single,
    options: ['Desde casa (Home office/store)', 'Necesito un local físico', 'Mixto / Nómada'],
    mappings: [
      AttributeMapping(attribute: 'digital', valueMap: {0: 7, 1: 1, 2: 9}), // Local lowers digital score implication usually
      // Also implies strictness on 'logistica_inventario' maybe? 
    ],
    priority: 'rapido',
  ),
  GuideQuestion(
    id: 7,
    text: '¿Cuentas con vehículo propio para transporte/logística?',
    type: GuideQuestionType.single,
    options: ['Sí', 'No'],
    mappings: [
       AttributeMapping(attribute: 'logistica_inventario', valueMap: {0: 7, 1: 3}),
    ],
    priority: 'rapido',
  ),
  GuideQuestion(
    id: 8,
    text: 'Del 1 al 5, ¿qué tan cómodo te sientes VENDIENDO cara a cara?',
    type: GuideQuestionType.scale,
    mappings: [
      AttributeMapping(attribute: 'ventas', valueMap: {1: 1, 2: 3, 3: 5, 4: 8, 5: 10}),
    ],
    priority: 'rapido',
  ),
  GuideQuestion(
    id: 9,
    text: 'Del 1 al 5, ¿qué tan cómodo te sientes ATENDIENDO público todo el día?',
    type: GuideQuestionType.scale,
    mappings: [
      AttributeMapping(attribute: 'publico', valueMap: {1: 1, 2: 3, 3: 5, 4: 8, 5: 10}),
    ],
    priority: 'rapido',
  ),
  GuideQuestion(
    id: 10,
    text: 'Del 1 al 5, ¿cuál es tu nivel de habilidad con tecnología/computadoras?',
    type: GuideQuestionType.scale,
    mappings: [
      AttributeMapping(attribute: 'digital', valueMap: {1: 1, 2: 3, 3: 5, 4: 8, 5: 10}),
    ],
    priority: 'rapido',
  ),
  
  // --- Q11 to Q25: MORE RAPID ONES ---
  GuideQuestion(
    id: 11,
    text: '¿Te interesa manejar inventario físico (comprar, guardar, enviar)?',
    type: GuideQuestionType.single,
    options: ['Sí, me gusta ver el producto', 'No, prefiero evitarlo (Digital/Servicios)'],
    mappings: [
      AttributeMapping(attribute: 'logistica_inventario', valueMap: {0: 10, 1: 1}),
      AttributeMapping(attribute: 'producto_vs_servicio', valueMap: {0: 10, 1: 1}), // High = Product
    ],
    priority: 'rapido',
  ),
  GuideQuestion(
    id: 12,
    text: '¿Prefieres vender Productos o Servicios?',
    type: GuideQuestionType.single,
    options: ['Producto tangible', 'Servicio (mi tiempo/habilidad)', 'Mixto'],
    mappings: [
      AttributeMapping(attribute: 'producto_vs_servicio', valueMap: {0: 10, 1: 1, 2: 5}),
    ],
    priority: 'rapido',
  ),
  GuideQuestion(
    id: 13,
    text: '¿Estás dispuesto a trabajar fines de semana?',
    type: GuideQuestionType.single,
    options: ['Sí', 'No', 'Solo si es necesario'],
    mappings: [
       // Implicitly favors Events/Food vs B2B Services
       AttributeMapping(attribute: 'urgencia', valueMap: {0: 8, 1: 2, 2: 5}), // Works harder?
    ],
    priority: 'rapido', // Often critical for food/events
  ),
  GuideQuestion(
    id: 14,
    text: '¿Cuál es tu tolerancia al estrés operativo (bomberazos, problemas diarios)?',
    type: GuideQuestionType.single,
    options: ['Baja (Prefiero paz)', 'Media', 'Alta (Me muevo bien en caos)'],
    mappings: [
      AttributeMapping(attribute: 'tolerancia_tramites', valueMap: {0: 2, 1: 5, 2: 9}), // Proxy for operating complexity
    ],
    priority: 'rapido',
  ),
  GuideQuestion(
    id: 15,
    text: 'Del 1 al 5, ¿qué tan ordenado eres con procesos y administración?',
    type: GuideQuestionType.scale,
    mappings: [
      AttributeMapping(attribute: 'logistica_inventario', valueMap: {1: 2, 2: 4, 3: 6, 4: 8, 5: 10}), // Inventory needs order
    ],
    priority: 'intermedio',
  ),
  GuideQuestion(
    id: 16,
    text: '¿Buscas clientes de una sola vez o recurrentes?',
    type: GuideQuestionType.single,
    options: ['Una vez (Venta transaccional)', 'Recurrentes (Relación a largo plazo)'],
    mappings: [
      AttributeMapping(attribute: 'publico', valueMap: {0: 3, 1: 8}), // Recurring needs more people skills usually
    ],
    priority: 'intermedio',
  ),
  GuideQuestion(
    id: 17,
    text: '¿Estás dispuesto a salir en cámara (fotos/videos) para tu marca?',
    type: GuideQuestionType.single,
    options: ['Sí, sin problema', 'No, me da pena', 'Solo mi voz/manos'],
    mappings: [
      AttributeMapping(attribute: 'ventas', valueMap: {0: 10, 1: 2, 2: 6}),
      AttributeMapping(attribute: 'digital', valueMap: {0: 8, 1: 2, 2: 5}),
    ],
    priority: 'rapido',
  ),
  GuideQuestion(
    id: 18,
    text: '¿Prefieres muchas ventas pequeñas o pocas ventas grandes?',
    type: GuideQuestionType.single,
    options: ['Muchas pequeñas (Volumen)', 'Pocas grandes (High Ticket)', 'Indiferente'],
    mappings: [
      // Volume = Retail/Food. High Ticket = Services/Consulting/Specialized
      // Not direct attribute map, maybe Sales style? 
      // Let's map to 'ventas' (Volume needs more automated sales, High ticket needs subtle sales)
    ],
    priority: 'intermedio',
  ),
  GuideQuestion(
    id: 19,
    text: '¿Planeas contratar personal pronto?',
    type: GuideQuestionType.single,
    options: ['Sí', 'No, quiero ser solopreneur al inicio'],
    mappings: [
      AttributeMapping(attribute: 'escalabilidad', valueMap: {0: 8, 1: 3}),
    ],
    priority: 'rapido',
  ),
  GuideQuestion(
    id: 20,
    text: '¿Qué tan rápido eres respondiendo mensajes/chats?',
    type: GuideQuestionType.single,
    options: ['Inmediato', 'Normal', 'Lento / Me agobia'],
    mappings: [
      AttributeMapping(attribute: 'ventas', valueMap: {0: 10, 1: 6, 2: 2}),
      AttributeMapping(attribute: 'digital', valueMap: {0: 8, 1: 5, 2: 2}),
    ],
    priority: 'rapido',
  ),
  GuideQuestion(
    id: 21,
    text: '¿Es vital para ti que el negocio sea escalable (franquicia/global) o prefieres algo local/artesanal?',
    type: GuideQuestionType.single,
    options: ['Escalable es vital', 'Prefiero local/boutique', 'No lo he pensado'],
    mappings: [
      AttributeMapping(attribute: 'escalabilidad', valueMap: {0: 10, 1: 3, 2: 5}),
    ],
    priority: 'rapido',
  ),
  
  // --- Q26 to Q50: INTERMEDIO ---
  GuideQuestion(
    id: 26,
    text: '¿Puedes mantener un horario fijo de atención estrictamente?',
    type: GuideQuestionType.single,
    options: ['Sí', 'No, necesito flexibilidad total'],
    mappings: [
      AttributeMapping(attribute: 'tiempo', valueMap: {0: 8, 1: 3}), // Fixed schedule implies retail/food
    ],
    priority: 'intermedio',
  ),
  GuideQuestion(
    id: 27,
    text: '¿Te molesta negociar precios/calidad con proveedores?',
    type: GuideQuestionType.single,
    options: ['Sí, prefiero no hacerlo', 'No, me gusta negociar'],
    mappings: [
      AttributeMapping(attribute: 'logistica_inventario', valueMap: {0: 2, 1: 9}),
    ],
    priority: 'intermedio',
  ),
  GuideQuestion(
    id: 28,
    text: 'Del 1 al 5, ¿cuál es tu tolerancia a manejar quejas y devoluciones?',
    type: GuideQuestionType.scale,
    mappings: [
      AttributeMapping(attribute: 'publico', valueMap: {1: 1, 2: 3, 3: 5, 4: 7, 5: 10}),
    ],
    priority: 'intermedio',
  ),
  GuideQuestion(
    id: 30,
    text: '¿Disfrutas el trabajo manual / artesanal?',
    type: GuideQuestionType.single,
    options: ['Sí, me relaja/gusta', 'No, soy torpe/prefiero digital'],
    mappings: [
        // Helps distinguish between Food/Beauty/Crafts vs Digital/RetailResale
    ],
    priority: 'intermedio',
  ),
  GuideQuestion(
    id: 32,
    text: '¿Te grabarías a ti mismo explicando tus productos/servicios?',
    type: GuideQuestionType.single,
    options: ['Sí', 'No'],
    mappings: [
      AttributeMapping(attribute: 'digital', valueMap: {0: 9, 1: 3}),
    ],
    priority: 'intermedio',
  ),
  GuideQuestion(
    id: 33,
    text: '¿Te interesa coordinar envíos y logística de entrega?',
    type: GuideQuestionType.single,
    options: ['Sí', 'No, que flojera'],
    mappings: [
      AttributeMapping(attribute: 'logistica_inventario', valueMap: {0: 9, 1: 2}),
    ],
    priority: 'intermedio',
  ),
  GuideQuestion(
    id: 35,
    text: 'Del 1 al 5, ¿cuánta paciencia tienes para explicar lo mismo varias veces a clientes?',
    type: GuideQuestionType.scale,
    mappings: [
      AttributeMapping(attribute: 'publico', valueMap: {1: 1, 2: 3, 3: 5, 4: 8, 5: 10}),
    ],
    priority: 'intermedio',
  ),
  GuideQuestion(
    id: 37,
    text: '¿Estás dispuesto a "empezar feo" (pequeño/incompleto) e ir mejorando?',
    type: GuideQuestionType.single,
    options: ['Sí', 'No, soy perfeccionista'],
    mappings: [
      AttributeMapping(attribute: 'tolerancia_tramites', valueMap: {0: 8, 1: 3}), // Agility
    ],
    priority: 'intermedio',
  ),
  GuideQuestion(
    id: 43,
    text: 'Del 1 al 5, ¿qué tan importante es para ti tener una ubicación física premium?',
    type: GuideQuestionType.scale,
    mappings: [
      // High importance -> Retail/Food Restaurant
    ],
    priority: 'intermedio',
  ),
  GuideQuestion(
    id: 46,
    text: 'Del 1 al 5, ¿cuánta tolerancia tienes a la prueba y error?',
    type: GuideQuestionType.scale,
    mappings: [
      // Innovation factor
    ],
    priority: 'intermedio',
  ),
  
  // --- Q51 to Q70: AVANZADO ---
  GuideQuestion(
    id: 51,
    text: '¿Te gustaría franquiciar tu modelo de negocio algún día?',
    type: GuideQuestionType.single,
    options: ['Sí', 'No me interesa', 'Tal vez'],
    mappings: [
      AttributeMapping(attribute: 'escalabilidad', valueMap: {0: 10, 1: 3, 2: 6}),
    ],
    priority: 'avanzado',
  ),
  GuideQuestion(
    id: 54,
    text: '¿Cuál es tu tolerancia a la merma (productos que se echan a perder/no se venden)?',
    type: GuideQuestionType.single,
    options: ['Baja (Odio tirar dinero)', 'Media', 'Alta (Entiendo que es parte del negocio)'],
    mappings: [
      AttributeMapping(attribute: 'logistica_inventario', valueMap: {0: 2, 1: 5, 2: 8}),
    ],
    priority: 'avanzado',
  ),
  GuideQuestion(
    id: 55,
    text: '¿Tienes colchón financiero para aguantar meses de ventas bajas?',
    type: GuideQuestionType.single,
    options: ['Sí', 'No, vivo al día'],
    mappings: [
      AttributeMapping(attribute: 'tolerancia_tramites', valueMap: {0: 8, 1: 2}), // Resilience
    ],
    priority: 'avanzado',
  ),
  GuideQuestion(
    id: 59,
    text: '¿Te interesa más construir una marca fuerte o solo generar cashflow?',
    type: GuideQuestionType.single,
    options: ['Marca fuerte (Asset)', 'Cashflow rápido'],
    mappings: [
      AttributeMapping(attribute: 'escalabilidad', valueMap: {0: 9, 1: 4}),
    ],
    priority: 'avanzado',
  ),
  GuideQuestion(
    id: 62,
    text: '¿Te visualizas operando fuera de tu ciudad/país?',
    type: GuideQuestionType.single,
    options: ['Sí', 'No, solo local'],
    mappings: [
      AttributeMapping(attribute: 'escalabilidad', valueMap: {0: 10, 1: 4}),
    ],
    priority: 'avanzado',
  ),
  GuideQuestion(
    id: 67,
    text: '¿Tienes interés en vender a través de Marketplaces (Amazon, MercadoLibre)?',
    type: GuideQuestionType.single,
    options: ['Sí', 'No', 'No sé qué implica'],
    mappings: [
      AttributeMapping(attribute: 'digital', valueMap: {0: 9, 1: 2, 2: 4}),
    ],
    priority: 'avanzado',
  ),
];

// Helper to get curated list
List<GuideQuestion> getQuestionsForLevel(int level) {
  // 25 Questions (Rapido + Some Intermedio essential to reach 25)
  // Logic: priority 'rapido' are essential.
  // There are ~17 'rapido' marked above. We need 25.
  // We will grab all 'rapido' + first few 'intermedio' to make 25.
  
  if (level == 25) {
    var core = allQuestions.where((q) => q.priority == 'rapido').toList();
    var extra = allQuestions.where((q) => q.priority == 'intermedio').take(25 - core.length).toList();
    return [...core, ...extra];
  }
  
  // 50 Questions
  if (level == 50) {
    var core = allQuestions.where((q) => q.priority == 'rapido' || q.priority == 'intermedio').toList();
    var extra = allQuestions.where((q) => q.priority == 'avanzado').take(50 - core.length).toList();
    return [...core, ...extra];
  }
  
  // 70 Questions (All)
  return allQuestions;
}
