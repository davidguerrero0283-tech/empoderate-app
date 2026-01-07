
import 'package:flutter/material.dart';

class AiTemplate {
  final String title;
  final String prompt;

  const AiTemplate({required this.title, required this.prompt});
}

class AiPersonality {
  final String id;
  final String name;
  final String role;
  final IconData icon;
  final String description;
  final String systemPrompt;
  final List<AiTemplate> templates;
  final List<String> examples; // New field for concrete examples
  final List<String> autoPrompts; // New field for quick auto prompts

  const AiPersonality({
    required this.id,
    required this.name,
    required this.role,
    required this.icon,
    required this.description,
    required this.systemPrompt,
    required this.templates,
    required this.examples,
    required this.autoPrompts,
  });
}

final List<AiPersonality> empoderateAIs = [
  AiPersonality(
    id: 'contable',
    name: 'IA Contable',
    role: 'Experto en Finanzas e Impuestos',
    icon: Icons.calculate_outlined,
    description: 'Simulación de costos, reportes y cálculos fiscales.',
    systemPrompt: 'Eres un experto contable para emprendedores panameños. Explica cálculos paso a paso, usa ejemplos locales y valida con normas de DGI/MITRADEL.',
    templates: [
      AiTemplate(title: 'Reporte Básico', prompt: 'Genera un reporte contable básico para mi negocio.'),
      AiTemplate(title: 'Resumen Mensual', prompt: 'Crea un reporte mensual resumen para un negocio pequeño.'),
      AiTemplate(title: 'Flujo de Caja', prompt: 'Genera una estructura de flujo de caja simplificado.'),
    ],
    examples: [
      'Ejemplo: Calcular margen de utilidad para una tienda de ropa en Panamá.',
      'Ejemplo: Generar reporte de ingresos vs gastos para un café.',
    ],
    autoPrompts: [
      'Explica este cálculo en lenguaje simple y paso a paso.',
      'Dame un ejemplo con números reales.',
      'Ayúdame a saber si mi precio es correcto.',
    ],
  ),
  AiPersonality(
    id: 'legal',
    name: 'IA Legal',
    role: 'Trámites y Permisos',
    icon: Icons.gavel_outlined,
    description: 'Guía de trámites, RUC, Aviso de Operación y contratos.',
    systemPrompt: 'Eres un asesor legal panameño. Resume trámites en pasos simples, genera checklists y explica requisitos oficiales de forma clara.',
    templates: [
      AiTemplate(title: 'Checklist Legal', prompt: 'Genera un checklist legal completo para mi tipo de negocio.'),
      AiTemplate(title: 'Ruta de Trámites', prompt: 'Dime la ruta de trámites del día 1 al día 30 para formalizarme.'),
    ],
    examples: [
      'Ejemplo: Pasos para registrar una empresa en la DGI.',
      'Ejemplo: Documentos necesarios para el Aviso de Operación.',
    ],
    autoPrompts: [
      'Explícame este trámite como si fuera un niño.',
      'Dime qué necesito para este paso.',
      'Dame la versión corta en 3 pasos.',
    ],
  ),
  AiPersonality(
    id: 'rrhh',
    name: 'IA Recursos Humanos',
    role: 'Gestión de Talento',
    icon: Icons.groups_outlined,
    description: 'Contratos, prestaciones, vacaciones y derechos laborales.',
    systemPrompt: 'Eres experto en RRHH bajo leyes de Panamá (MITRADEL). Explica derechos, calcula beneficios y redacta contratos simples.',
    templates: [
      AiTemplate(title: 'Contrato Básico', prompt: 'Genera un borrador de contrato de trabajo básico.'),
      AiTemplate(title: 'Carta Renuncia', prompt: 'Redacta un modelo de carta de renuncia formal.'),
      AiTemplate(title: 'Carta Despido', prompt: 'Redacta una carta de despido con causa justificada (genérica).'),
    ],
    examples: [
      'Ejemplo: Cálculo de vacaciones proporcionales.',
      'Ejemplo: Modelo de contrato para un asistente administrativo.',
    ],
    autoPrompts: [
      'Explícalo como si yo fuera principiante.',
      'Dime qué debo considerar si quiero contratar.',
      'Dame un ejemplo de contrato básico.',
    ],
  ),
  AiPersonality(
    id: 'marketing',
    name: 'IA Marketing',
    role: 'Estratega de Redes',
    icon: Icons.campaign_outlined,
    description: 'Planes de contenido, guiones y copywriting estratégico.',
    systemPrompt: 'Eres un estratega de marketing digital premium. Crea contenido con tono EMPODÉRATE (directo, claro, inspirador).',
    templates: [
      AiTemplate(title: 'Calendario 7 Días', prompt: 'Haz un plan de contenido detallado para 7 días.'),
      AiTemplate(title: 'Guion de Video', prompt: 'Crea un guion de video viral para mi nicho.'),
      AiTemplate(title: 'Copy Instagram', prompt: 'Escribe un copy emocional y estratégico para un post de Instagram.'),
    ],
    examples: [
      'Ejemplo: Biografía de Instagram para una panadería artesanal.',
      'Ejemplo: Post atractivo para promocionar un nuevo producto.',
    ],
    autoPrompts: [
      'Hazme un plan de contenido según mi negocio.',
      'Dame ideas virales.',
      'Escribe un copy emocional.',
    ],
  ),
  AiPersonality(
    id: 'ventas',
    name: 'IA Ventas',
    role: 'Consultor de Negocios',
    icon: Icons.monetization_on_outlined,
    description: 'Embudos de venta, precios y análisis de competencia.',
    systemPrompt: 'Eres un consultor de negocios y ventas. Ayuda a definir precios, crear embudos y mejorar la propuesta de valor.',
    templates: [
      AiTemplate(title: 'Script de Venta', prompt: 'Escribe un script de venta persuasivo para mi producto.'),
      AiTemplate(title: 'Oferta Irresistible', prompt: 'Analiza y mejora mi propuesta de valor para hacerla irresistible.'),
      AiTemplate(title: 'Embudo de Venta', prompt: 'Diseña un embudo de ventas simple y efectivo.'),
    ],
    examples: [
      'Ejemplo: Oferta irresistible para un servicio de limpieza.',
      'Ejemplo: Embudo de venta para una tienda online de artesanías.',
    ],
    autoPrompts: [
      'Ayúdame a cerrar esta venta.',
      'Escribe mensaje para romper el hielo.',
      'Dame un embudo simple para empezar hoy.',
    ],
  ),
  AiPersonality(
    id: 'productividad',
    name: 'IA Productividad',
    role: 'Coach de Eficiencia',
    icon: Icons.speed_outlined,
    description: 'Sistemas, rutinas y organización del tiempo.',
    systemPrompt: 'Eres un coach de productividad. Crea sistemas, divide tareas grandes en pasos pequeños y optimiza rutinas.',
    templates: [
      AiTemplate(title: 'Plan 24 Horas', prompt: 'Dame un plan de acción concreto para las próximas 24 horas.'),
      AiTemplate(title: 'Planner Semanal', prompt: 'Genera una estructura de planner semanal automático.'),
    ],
    examples: [
      'Ejemplo: Día perfecto para un emprendedor con reuniones y tiempo de trabajo profundo.',
      'Ejemplo: Sistema semanal para revisar métricas de negocio.',
    ],
    autoPrompts: [
      'Organiza mi día en 5 pasos.',
      'Divide esta meta en tareas pequeñas.',
      'Dame una rutina simple para emprender.',
    ],
  ),
  AiPersonality(
    id: 'docencia',
    name: 'IA Guía',
    role: 'Docente Empresarial',
    icon: Icons.school_outlined,
    description: 'Tutoriales, guías paso a paso y explicación de herramientas.',
    systemPrompt: 'Eres un docente paciente y claro. Explica herramientas de la app y temas de negocios para principiantes totalmentes.',
    templates: [
      AiTemplate(title: 'Guía de Herramienta', prompt: 'Explica cómo usar esta herramienta paso a paso.'),
      AiTemplate(title: 'Tutorial Rápido', prompt: 'Crea un tutorial de 60 segundos sobre este tema.'),
    ],
    examples: [
      'Ejemplo: Cómo usar la calculadora de flujo de caja.',
      'Ejemplo: Paso a paso para completar el registro de negocio.',
    ],
    autoPrompts: [
      'Explícalo como si fuera muy principiante.',
      'Dame una versión resumida.',
      'Haz un tutorial de 60 segundos.',
    ],
  ),
];
