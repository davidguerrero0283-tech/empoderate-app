import 'package:flutter/material.dart';

class LearningLesson {
  final String title;
  final String subtitle;
  final String content; // Placeholder for now

  const LearningLesson({
    required this.title,
    required this.subtitle,
    this.content = 'Contenido del tema próximamente...',
  });
}

class LearningCategory {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final List<Color> gradientColors;
  final List<LearningLesson> lessons;
  final String? infoTitle;    // New field for InfoModal title
  final String? infoContent;  // New field for InfoModal content

  const LearningCategory({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.gradientColors,
    required this.lessons,
    this.infoTitle,
    this.infoContent,
  });
}

// DUMMY DATA POOL
final List<LearningCategory> learningCategories = [
  LearningCategory(
    id: 'fundamentos',
    title: 'Fundamentos del Emprendimiento',
    subtitle: 'Conceptos y bases para empezar.',
    icon: Icons.school,
    color: const Color(0xFFD4AF37), // Gold
    gradientColors: [const Color(0xFFD4AF37), const Color(0xFF003366)], // Gold to Blue
    lessons: [
      LearningLesson(title: '¿Qué es un emprendedor?', subtitle: 'Definición y mentalidad correcta.'),
      LearningLesson(title: 'Identificar una idea de negocio', subtitle: 'Cómo encontrar oportunidades.'),
      LearningLesson(title: 'Cómo validar tu idea', subtitle: 'Pruebas rápidas antes de invertir.'),
      LearningLesson(title: 'Entender el mercado', subtitle: 'Conoce a tus clientes y competencia.'),
      LearningLesson(title: 'Primeros pasos esenciales', subtitle: 'La lista de chequeo inicial.'),
    ],
  ),
  LearningCategory(
    id: 'admin_finanzas',
    title: 'Administración y Finanzas',
    subtitle: 'Control, contabilidad y flujo de caja.',
    icon: Icons.work,
    color: const Color(0xFF001B3A), // Navy Blue
    gradientColors: [const Color(0xFF003366), const Color(0xFF000000)], // Deep Blue to Black
    lessons: [
      LearningLesson(title: 'Cómo calcular costos', subtitle: 'Costos fijos, variables y ocultos.'),
      LearningLesson(title: 'Cómo poner precios', subtitle: 'Estrategias para no perder dinero.'),
      LearningLesson(title: 'Flujo de caja básico', subtitle: 'Entradas vs Salidas.'),
      LearningLesson(title: 'Manejo de ingresos y gastos', subtitle: 'Registro diario y control.'),
      LearningLesson(title: 'Margen de ganancia', subtitle: 'Entendiendo tu utilidad real.'),
    ],
  ),
  LearningCategory(
    id: 'marketing_ventas',
    title: 'Marketing y Ventas',
    subtitle: 'Promoción, contenidos y cierre de ventas.',
    icon: Icons.campaign,
    color: Colors.purple,
    gradientColors: [Colors.purple, Colors.deepPurple], // Purple Gradient
    lessons: [
      LearningLesson(title: 'Cómo crear contenido', subtitle: 'Estrategias para redes sociales.'),
      LearningLesson(title: 'Cómo atraer clientes', subtitle: 'Marketing orgánico y pago.'),
      LearningLesson(title: 'Cómo construir marca', subtitle: 'Identidad, logo y mensaje.'),
      LearningLesson(title: 'Redes sociales para negocios', subtitle: 'Facebook, Instagram y TikTok.'),
      LearningLesson(title: 'Ventas básicas', subtitle: 'Técnicas de cierre y negociación.'),
    ],
  ),
  LearningCategory(
    id: 'tramites_legal',
    title: 'Trámites y Legal',
    subtitle: 'Cómo cumplir requisitos y permisos.',
    icon: Icons.assignment,
    color: Colors.teal,
    gradientColors: [Colors.teal, Colors.tealAccent], // Teal Gradient
    lessons: [
      LearningLesson(title: 'Registro de Aviso de Operación', subtitle: 'El primer paso legal.'),
      LearningLesson(title: 'Permisos municipales', subtitle: 'Requisitos locales importantes.'),
      LearningLesson(title: 'Inscripción en DGI', subtitle: 'Obligaciones tributarias.'),
      LearningLesson(title: 'Seguridad Social', subtitle: 'Registro patronal y empleados.'),
      LearningLesson(title: 'Contratos sencillos', subtitle: 'Acuerdos básicos por escrito.'),
    ],
  ),
  LearningCategory(
    id: 'habilidades',
    title: 'Habilidades Prácticas',
    subtitle: 'Habilidades que todo emprendedor debe dominar.',
    icon: Icons.build,
    color: Colors.orange,
    gradientColors: [Colors.orange, Colors.deepOrange], // Orange Gradient
    lessons: [
      LearningLesson(title: 'Liderazgo de equipos', subtitle: 'Cómo gestionar personas.'),
      LearningLesson(title: 'Gestión del tiempo', subtitle: 'Productividad y priorización.'),
      LearningLesson(title: 'Resolución de conflictos', subtitle: 'Manejo de problemas con clientes.'),
      LearningLesson(title: 'Hablar en público', subtitle: 'Presenta tu negocio con confianza.'),
      LearningLesson(title: 'Negociación efectiva', subtitle: 'Llegar a acuerdos ganar-ganar.'),
    ],
  ),
  LearningCategory(
    id: 'conceptos_clave',
    title: 'Conceptos Clave',
    subtitle: 'Entiende los fundamentos de tu negocio.',
    icon: Icons.lightbulb_outline,
    color: const Color(0xFFD4AF37),
    gradientColors: [const Color(0xFFD4AF37), const Color(0xFFB8860B)],
    lessons: [],
    infoTitle: 'Conceptos Clave del Emprendimiento',
    infoContent: '''
En esta sección encontrarás explicaciones sencillas, claras y directas de los conceptos fundamentales que todo emprendedor debe conocer para manejar su negocio con seguridad. Cada concepto está desarrollado en un lenguaje accesible, sin tecnicismos, y con ejemplos prácticos aplicados al día a día de un negocio real.

Aquí aprenderás qué significan términos como flujo de caja, margen de ganancia, costos fijos, costos variables, punto de equilibrio, ventas recurrentes, validación de mercado, propuesta de valor, perfil del cliente, segmentación, entre otros. Estos conceptos son los pilares que te ayudarán a tomar decisiones más inteligentes y evitar errores comunes.

Este módulo está diseñado para que puedas aprender rápidamente, sin sentirte abrumado. Cada explicación te dará claridad sobre la función del concepto, cuándo aplicarlo y cómo puede ayudarte a evaluar y mejorar tu negocio. Puedes volver aquí cada vez que tengas dudas o cuando estés planificando una nueva estrategia.
''',
  ),
  LearningCategory(
    id: 'glosario',
    title: 'Glosario del Emprendedor',
    subtitle: 'Diccionario de términos empresariales.',
    icon: Icons.menu_book,
    color: Colors.teal,
    gradientColors: [Colors.teal, Colors.tealAccent],
    lessons: [],
    infoTitle: 'Glosario del Emprendedor',
    infoContent: '''
El Glosario del Emprendedor es tu diccionario empresarial dentro de Empodérate. Aquí encontrarás definiciones claras de términos financieros, legales, administrativos, contables y de marketing que puedes encontrar en el camino de construir tu negocio.

Cada término está explicado de manera simple, acompañado de ejemplos para que entiendas cómo aplicarlo en situaciones reales. No necesitas experiencia previa: este glosario está pensado para ayudarte a dominar el lenguaje empresarial poco a poco, sin estrés.

Puedes usarlo como referencia rápida cuando estés usando otras secciones de la app, como contabilidad, ventas, costos o trámites. Si encuentras un término complicado, vienes aquí, lo buscas y lo entiendes en segundos. También es perfecto para estudiar y repasar cuando estés avanzando en la Ruta del Emprendedor.
''',
  ),
  LearningCategory(
    id: 'lecciones_rapidas',
    title: 'Lecciones Rápidas',
    subtitle: 'Aprende en minutos temas clave.',
    icon: Icons.timer,
    color: Colors.deepOrange,
    gradientColors: [Colors.deepOrange, Colors.orangeAccent],
    lessons: [],
    infoTitle: 'Lecciones Rápidas',
    infoContent: '''
Las Lecciones Rápidas son pequeñas cápsulas educativas que te enseñan temas importantes del emprendimiento en solo unos minutos. Cada lección está diseñada para darte claridad inmediata sobre un tema sin necesidad de leer largas explicaciones o tomar cursos completos.

Aquí encontrarás lecciones sobre: cómo organizar tus finanzas, cómo optimizar tus procesos, cómo atender mejor a tus clientes, cómo mejorar tus precios, cómo usar herramientas digitales, cómo vender más y cómo mantener tu negocio funcionando de manera saludable.

Estas lecciones son perfectas para aprender en poco tiempo, cuando tienes un espacio libre del día o cuando te sientes confundido en algún punto específico del negocio. La idea es darte conocimiento práctico, rápido y aplicable, sin complicaciones.
''',
  ),
];
