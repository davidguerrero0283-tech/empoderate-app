import 'package:flutter/material.dart';

class ModuleGuideData {
  final String id;
  final String title;
  final String subtitle;
  final Color themeColor;
  final IconData icon;
  final List<GuideSection> sections;

  const ModuleGuideData({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.themeColor,
    required this.icon,
    required this.sections,
  });
}

class GuideSection {
  final String title;
  final String content;
  final List<String>? bullets;

  const GuideSection({required this.title, required this.content, this.bullets});
}

// STATIC DATA
class ModuleGuides {
  static const hr = ModuleGuideData(
    id: 'hr',
    title: 'Recursos Humanos 101',
    subtitle: 'Gestión de Personal y Liderazgo',
    themeColor: Color(0xFFFF4081), // Pink
    icon: Icons.people_outline,
    sections: [
      GuideSection(
        title: '¿Qué son los Recursos Humanos?',
        content: 'Es el departamento o función encargada de gestionar el activo más importante de tu empresa: las personas. No se trata solo de contratar y pagar, sino de desarrollar, motivar y retener el talento.',
      ),
      GuideSection(
        title: '¿Para qué sirve en una PYME?',
        content: 'Muchos emprendedores creen que RRHH es solo para grandes corporaciones. Falso. Una buena gestión desde el día 1 evita demandas laborales, reduce la rotación (gente que renuncia) y mejora la productividad.',
        bullets: [
          'Cumplimiento Legal: Evita multas del Ministerio de Trabajo.',
          'Clima Laboral: Gente feliz trabaja mejor.',
          'Eficiencia: Define roles claros para que nadie duplique trabajo.'
        ],
      ),
      GuideSection(
        title: 'Gestión del Personal: Paso a Paso',
        content: 'El ciclo de vida de un empleado tiene 4 etapas clave:',
        bullets: [
          '1. Reclutamiento: Definir el perfil (qué necesito) y buscar candidatos honestos y capaces, no solo "baratos".',
          '2. Contratación: Firmar contrato escrito (siempre) y registrar en CSS. La informalidad sale cara.',
          '3. Desarrollo/Día a Día: Pago puntual de planilla, feedback constante y trato digno.',
          '4. Desvinculación: Si alguien se va, que sea proceso justo, pagando su liquidación y prestaciones de ley.'
        ]
      ),
      GuideSection(
        title: 'Buenas Prácticas y Liderazgo',
        content: 'El trato al personal define tu marca empleadora.',
        bullets: [
          'Paga a tiempo: El salario es sagrado.',
          'Escucha: A veces el empleado tiene la solución al problema del cliente.',
          'Capacita: Enseña a tu equipo; si ellos crecen, tu negocio crece.',
          'Reglas Claras: Ten un reglamento interno simple pero firme.'
        ]
      ),
    ],
  );

  static const accounting = ModuleGuideData(
    id: 'accounting',
    title: 'Contabilidad para No Contadores',
    subtitle: 'El lenguaje de los negocios',
    themeColor: Color(0xFFD4AF37), // Gold
    icon: Icons.account_balance_wallet,
    sections: [
      GuideSection(
        title: '¿Qué es la Contabilidad?',
        content: 'Es el sistema de control y registro de los gastos, ingresos y demás operaciones económicas. Es la herramienta que te dice la VERDAD sobre tu negocio, más allá de lo que "sientes" que vendiste.',
      ),
      GuideSection(
        title: '¿Por qué es indispensable?',
        content: 'Sin contabilidad, manejas a ciegas.',
        bullets: [
          'Control: Sabes dónde se fue cada centavo.',
          'Decisiones: ¿Puedo contratar a alguien más? ¿Puedo comprar esa máquina? La contabilidad responde.',
          'Impuestos: La DGI exige registros claros. No tenerlos es invitar multas.',
          'Crédito: Ningún banco te prestará dinero si no tienes estados financieros organizados.'
        ],
      ),
      GuideSection(
        title: 'Conceptos Básicos',
        content: '',
        bullets: [
          'Ingresos: Dinero que entra por ventas.',
          'Costos: Lo que te cuesta producir tu producto (ej. insumos).',
          'Gastos: Lo que necesitas para operar (luz, alquiler, salarios).',
          'Utilidad: Lo que realmente te queda (Ingresos - Costos - Gastos).'
        ],
      ),
      GuideSection(
        title: 'Buenas Prácticas',
        content: 'Separa tus finanzas personales de las del negocio. Págate un salario y no uses la caja del negocio como billetera personal. Registra todo, incluso los gastos pequeños (caja menuda).',
      ),
    ],
  );

  static const marketing = ModuleGuideData(
    id: 'marketing',
    title: 'Marketing y Crecimiento Pro',
    subtitle: 'Estrategias Completas para Escalar',
    themeColor: Color(0xFFD500F9), // Purple
    icon: Icons.trending_up,
    sections: [
      GuideSection(
        title: '¿Qué es el Marketing Realmente?',
        content: 'Marketing no es solo publicidad o redes sociales. Es el arte y ciencia de entender profundamente a tu cliente, identificar sus problemas y deseos, y comunicar cómo tu producto o servicio es la mejor solución. Es crear valor, construir relaciones y generar conversiones sostenibles.',
      ),
      GuideSection(
        title: 'El Embudo de Ventas (Sales Funnel)',
        content: 'El viaje completo de tu cliente desde que te descubre hasta que compra y recomienda:',
        bullets: [
          'ToFu (Top of Funnel - Conciencia): Que sepan que existes. Usa contenido educativo, viral, anuncios de alcance.',
          'MoFu (Middle - Consideración): Que entiendan por qué eres la mejor opción. Testimonios, casos de éxito, demos.',
          'BoFu (Bottom - Conversión): Que tomen acción y compren. Ofertas claras, urgencia, garantías.',
          'Post-Venta (Fidelización): Que vuelvan y recomienden. Email marketing, programas de lealtad, soporte excepcional.'
        ],
      ),
      GuideSection(
        title: 'Storytelling: El Arte de Contar Historias',
        content: 'Las personas no compran productos, compran historias y emociones. El storytelling convierte tu marca en algo memorable.',
        bullets: [
          'Héroe del Viaje: Tu cliente es el héroe, tú eres el guía que lo ayuda a superar obstáculos.',
          'Conflicto y Resolución: Muestra el problema (dolor) y cómo tu producto lo resuelve (transformación).',
          'Autenticidad: Comparte tu "por qué". ¿Por qué creaste este negocio? La gente conecta con propósitos reales.',
          'Testimonios Narrativos: No solo "5 estrellas", sino historias de clientes reales con antes/después.',
          'Ejemplo: "María tenía miedo de emprender. Hoy, gracias a [tu producto], tiene su propio negocio rentable."'
        ],
      ),
      GuideSection(
        title: 'Automatización con IA en Redes Sociales',
        content: 'La Inteligencia Artificial te permite escalar tu presencia sin trabajar 24/7. Aquí están las mejores herramientas y estrategias:',
        bullets: [
          'Creación de Contenido con IA: ChatGPT para captions, Midjourney/DALL-E para imágenes, Runway para videos. Genera ideas en segundos.',
          'Programación Automática: Buffer, Hootsuite, Later. Programa 30 posts en 1 hora, publica automáticamente en horarios óptimos.',
          'YouTube: TubeBuddy para SEO, VidIQ para tags/títulos, Descript para edición con IA (transcripciones, cortes automáticos).',
          'Instagram/TikTok: CapCut con IA para edición rápida, Canva Magic Write para textos, auto-subtítulos con Submagic.',
          'Facebook: Meta Business Suite para programar, Chatbots (ManyChat) para responder mensajes automáticamente.',
          'Análisis con IA: Sprout Social analiza qué contenido funciona y sugiere mejoras. Ahorra horas de análisis manual.',
          'Advertencia: La IA es asistente, no reemplazo. Siempre revisa y personaliza el contenido antes de publicar.'
        ],
      ),
      GuideSection(
        title: 'Copywriting: Escribir para Vender',
        content: 'El copywriting es redacción persuasiva. Cada palabra debe acercar al cliente a la compra.',
        bullets: [
          'AIDA: Atención (hook impactante) → Interés (beneficios) → Deseo (emoción) → Acción (CTA claro).',
          'PAS: Problema (identifica el dolor) → Agitación (intensifica la urgencia) → Solución (tu oferta).',
          'Beneficios vs Características: No digas "batería de 5000mAh", di "dura todo el día sin cargar".',
          'CTA Poderoso: "Empieza Gratis Hoy" es mejor que "Registrarse". Usa verbos de acción.',
          'Urgencia y Escasez: "Solo quedan 3 cupos" o "Oferta válida hasta mañana" aumentan conversiones.'
        ],
      ),
      GuideSection(
        title: 'Métricas Clave (KPIs de Marketing)',
        content: 'Si no mides, no puedes mejorar. Estas son las métricas esenciales:',
        bullets: [
          'CTR (Click-Through Rate): % de personas que hacen clic en tu anuncio. Ideal: 2-5%.',
          'CPA (Costo Por Adquisición): Cuánto gastas para conseguir un cliente. Debe ser menor que tu margen.',
          'ROAS (Return on Ad Spend): Por cada \$1 invertido, cuánto generas. Mínimo aceptable: 3x.',
          'CAC (Customer Acquisition Cost): Costo total de marketing ÷ nuevos clientes. Compáralo con LTV.',
          'LTV (Lifetime Value): Cuánto vale un cliente durante toda su relación contigo. Debe ser 3x el CAC.',
          'Tasa de Conversión: % de visitantes que compran. E-commerce promedio: 2-3%.'
        ],
      ),
      GuideSection(
        title: 'Estrategias por Plataforma',
        content: 'Cada red social tiene su lenguaje y audiencia. Adapta tu contenido:',
        bullets: [
          'Instagram: Visual, aspiracional. Usa Reels, Stories, carruseles educativos. Ideal para B2C lifestyle.',
          'TikTok: Entretenimiento rápido, trends, autenticidad. Perfecto para viralidad y audiencias jóvenes.',
          'Facebook: Comunidades, grupos, anuncios segmentados. Bueno para B2C local y +35 años.',
          'LinkedIn: Profesional, B2B, liderazgo de pensamiento. Publica artículos, casos de éxito.',
          'YouTube: Contenido largo, tutoriales, reviews. Alto engagement y SEO en Google.',
          'WhatsApp Business: Atención directa, ventas conversacionales, automatización con chatbots.'
        ],
      ),
      GuideSection(
        title: 'Psicología del Consumidor',
        content: 'Entender cómo piensa tu cliente te da ventaja competitiva:',
        bullets: [
          'Prueba Social: "Más de 10,000 clientes satisfechos" genera confianza.',
          'Escasez: "Últimas unidades" activa el miedo a perder (FOMO).',
          'Reciprocidad: Da valor gratis (ebook, webinar) y la gente querrá devolver comprando.',
          'Autoridad: Certificaciones, premios, apariciones en medios aumentan credibilidad.',
          'Anclaje: Muestra un precio alto primero, luego el descuento parece una ganga.',
          'Efecto Halo: Si tu packaging es premium, asumen que el producto también lo es.'
        ],
      ),
      GuideSection(
        title: 'Errores Fatales en Marketing',
        content: 'Evita estos errores que matan campañas:',
        bullets: [
          'No definir tu audiencia: "Vender a todos" es vender a nadie. Define tu avatar ideal.',
          'Ignorar datos: Intuición sin métricas es apostar a ciegas. Usa Google Analytics, Meta Ads Manager.',
          'Copiar sin adaptar: Lo que funciona para Nike no funciona para tu PYME. Adapta estrategias.',
          'No hacer seguimiento: El 80% de ventas requiere 5+ contactos. Implementa email marketing y retargeting.',
          'Contenido sin CTA: Si no dices qué hacer (comprar, suscribirse), la gente no actúa.',
          'Descuidar atención al cliente: Una mala experiencia se comparte 10 veces más que una buena.'
        ],
      ),
      GuideSection(
        title: 'Plan de Acción Rápido',
        content: 'Pasos para lanzar tu primera campaña exitosa:',
        bullets: [
          '1. Define tu objetivo: ¿Ventas, leads, reconocimiento de marca?',
          '2. Conoce a tu cliente ideal: Edad, problemas, deseos, objeciones.',
          '3. Crea contenido de valor: Educa, entretiene o inspira. No solo vendas.',
          '4. Elige 1-2 plataformas: Enfócate donde está tu audiencia.',
          '5. Lanza, mide, ajusta: Prueba anuncios, analiza qué funciona, optimiza.',
          '6. Escala lo que funciona: Invierte más en lo que da resultados, elimina lo que no.'
        ],
      ),
    ],
  );

  static const start = ModuleGuideData(
    id: 'start',
    title: 'Guía Maestra: Elegir tu Rubro',
    subtitle: 'Toma la decisión correcta para tu inversión',
    themeColor: Color(0xFF00E5FF), // Cyan
    icon: Icons.lightbulb_outline,
    sections: [
      GuideSection(
        title: 'A) ¿Qué rubro te conviene?',
        content: 'Descúbrelo con nuestro diagnóstico rápido. Analizaremos tu presupuesto, tiempo y habilidades para recomendarte la mejor opción.',
        // The button for the questionnaire is injected by the screen based on 'start' ID
      ),
      GuideSection(
        title: 'B) Ventajas y Riesgos por Tipo',
        content: 'Analiza la realidad de cada industria antes de invertir:',
      ),
      GuideSection(
        title: '🍔 Comida y Bebidas',
        content: 'Desde food trucks hasta restaurantes.',
        bullets: [
          '✅ Alta demanda diaria (la gente siempre come).',
          '✅ Flujo de caja efectivo (dinero entra diario).',
          '✅ Espacio para creatividad infinita.',
          '⚠️ Alta competencia y márgenes ajustados.',
          '⚠️ Regulaciones sanitarias estrictas (alimentos).',
          '⚠️ Horarios sacrificados (fines de semana/noches).'
        ],
      ),
      GuideSection(
        title: '💅 Belleza y Estética',
        content: 'Salones, barberías, uñas, spa.',
        bullets: [
          '✅ Clientes fieles (recurrencia quincenal/mensual).',
          '✅ Ticket medio-alto por servicio.',
          '✅ Posibilidad de empezar a domicilio.',
          '⚠️ Depende mucho de la mano de obra calificada.',
          '⚠️ Tendencias cambian muy rápido.',
          '⚠️ Requiere actualización constante de equipos/técnicas.'
        ],
      ),
      GuideSection(
        title: '🛍️ Comercio (Retail)',
        content: 'Tiendas de ropa, accesorios, mini supers.',
        bullets: [
          '✅ Operación más sencilla (comprar barato/vender caro).',
          '✅ Escalable con e-commerce.',
          '✅ Menos regulaciones que comida/salud.',
          '⚠️ Gestión de inventario compleja (dinero estancado).',
          '⚠️ Competencia feroz con grandes cadenas/online.',
          '⚠️ Requiere buena ubicación (física) o gran marketing (digital).'
        ],
      ),
      GuideSection(
        title: '💻 Servicios Digitales / Profesionales',
        content: 'Consultoría, diseño, marketing, contabilidad.',
        bullets: [
          '✅ Inversión inicial casi nula (tu conocimiento).',
          '✅ Trabajo remoto y flexible.',
          '✅ Márgenes de ganancia muy altos.',
          '⚠️ Cuesta construir confianza y reputación.',
          '⚠️ Ingresos inestables al inicio.',
          '⚠️ Vendes tu tiempo (difícil de escalar sin equipo).'
        ],
      ),
      GuideSection(
        title: 'C) 10 Decisiones Clave',
        content: 'Antes de firmar nada, define esto:',
        bullets: [
          '1. ¿Local Físico (alto costo) o Desde Casa/Móvil (bajo costo)?',
          '2. ¿Vender productos (inventario) o servicios (tiempo)?',
          '3. ¿Público Masivo (precios bajos) o Exclusivo (precios altos)?',
          '4. ¿Operarás tú solo o necesitas contratar personal ya?',
          '5. ¿Tienes colchón financiero para 6 meses sin ganancias?',
          '6. ¿Te ves haciendo esto todos los días por 5 años?',
          '7. ¿Tu zona necesita esto o ya hay 10 iguales?',
          '8. ¿Cumples los requisitos legales mínimos?',
          '9. ¿Tienes proveedores confiables identificados?',
          '10. ¿Cuál es tu Plan B si no funciona en 1 año?'
        ],
      ),
      GuideSection(
        title: 'D) Matriz: Inversión vs. Complejidad',
        content: 'Ubica tu idea en este cuadrante:',
        bullets: [
          '🟩 BAJA Inversión / BAJA Complejidad: Servicios profesionales (Freelance), Paseo de perros, Tutorías.',
          '🟨 BAJA Inversión / ALTA Complejidad: Programación de softare, Agencias de Marketing (requiere alto skill).',
          '🟧 ALTA Inversión / BAJA Complejidad: Franquicias probadas, Bienes Raíces (alquileres simple).',
          '🟥 ALTA Inversión / ALTA Complejidad: Restaurantes grandes, Fábricas, Hoteles.'
        ],
      ),
    ],
  );
}
