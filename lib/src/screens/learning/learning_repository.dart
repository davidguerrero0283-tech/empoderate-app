import 'package:flutter/material.dart';
import '../../ui/theme/empoderate_theme.dart';

class Course {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String level;
  final String duration;
  final String category; // Added Category
  final List<CourseModule> modules;

  const Course({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.level,
    required this.duration,
    required this.category,
    required this.modules,
  });
}

class CourseModule {
  final String title;
  final String description;
  final String contentMarkdown;

  const CourseModule({
    required this.title,
    required this.description,
    required this.contentMarkdown,
  });
}

class LearningRepository {
  static const List<Course> courses = [
    // --- LEGAL & INICIO ---
    Course(
      id: 'business_start',
      title: 'Cómo Iniciar un Negocio',
      description: 'Guía definitiva para pasar de la idea a la legalidad.',
      icon: Icons.rocket_launch,
      color: EmpoderateTheme.goldStrong,
      level: 'Principiante',
      duration: '3h',
      category: 'start',
      modules: [
        CourseModule(
          title: '1. Validación de la Idea',
          description: 'Antes de gastar, asegúrate de que alguien quiera comprar.',
          contentMarkdown: 'Contenido sobre validación, entrevistas de problema y MVP...',
        ),
        CourseModule(
          title: '2. Aviso de Operación y RUC',
          description: 'El paso a paso legal en Panamá Emprende y DGI.',
          contentMarkdown: 'Guía sobre Panamá Emprende, costos y registro en DGI...',
        ),
        CourseModule(
          title: '3. Permisos Municipales',
          description: 'Lo que nadie te dice sobre el Municipio.',
          contentMarkdown: 'Inscripción municipal, requisitos y multas...',
        ),
      ],
    ),
    Course(
      id: 'legal_contracts',
      title: 'Contratos y Protección Legal',
      description: 'Evita demandas y protege tu patrimonio.',
      icon: Icons.gavel,
      color: EmpoderateTheme.goldStrong,
      level: 'Intermedio',
      duration: '4h',
      category: 'legal',
      modules: [
        CourseModule(
          title: '1. Tipos de Sociedades',
          description: 'S.A. vs S. de R.L. vs Persona Natural.',
          contentMarkdown: 'Diferencias clave, protección patrimonial y costos de mantenimiento...',
        ),
        CourseModule(
          title: '2. Contratos Laborales',
          description: 'Indefinido vs Definido vs Servicios Profesionales.',
          contentMarkdown: 'Cuándo usar cada uno para evitar pasivos laborales gigantes...',
        ),
      ],
    ),

    // --- FINANZAS ---
    Course(
      id: 'basic_accounting',
      title: 'Contabilidad No Contadores',
      description: 'Domina los números y evita quiebras.',
      icon: Icons.calculate,
      color: EmpoderateTheme.cyanAccent,
      level: 'Intermedio',
      duration: '5h',
      category: 'finance',
      modules: [
        CourseModule(
          title: '1. La Ecuación Contable',
          description: 'Activos = Pasivos + Patrimonio.',
          contentMarkdown: 'Explicación simple de cómo funciona el balance...',
        ),
        CourseModule(
          title: '2. Flujo de Caja vs Utilidad',
          description: 'Por qué puedes quebrar aunque "ganes" dinero.',
          contentMarkdown: 'La importancia de la liquidez sobre la rentabilidad en papel...',
        ),
      ],
    ),
    Course(
      id: 'pricing_strategy',
      title: 'Estrategia de Precios',
      description: 'Deja de cobrar barato y empieza a cobrar por valor.',
      icon: Icons.price_change,
      color: EmpoderateTheme.cyanAccent,
      level: 'Avanzado',
      duration: '2h',
      category: 'finance',
      modules: [
        CourseModule(
          title: '1. Costos vs Valor',
          description: 'No cobres (Costo + 30%), cobra lo que vale el problema.',
          contentMarkdown: 'Modelos de pricing basados en valor percíbido...',
        ),
        CourseModule(
          title: '2. Psicología de Precios',
          description: 'Anclaje y ofertas irresistibles.',
          contentMarkdown: 'Cómo presentar tus precios para que parezcan una ganga...',
        ),
      ],
    ),

    // --- MARKETING ---
    Course(
      id: 'marketing_pro',
      title: 'Marketing Digital Pro',
      description: 'Estrategias reales para vender en redes.',
      icon: Icons.campaign,
      color: EmpoderateTheme.purpleAccent,
      level: 'Todos',
      duration: '4h',
      category: 'marketing',
      modules: [
        CourseModule(
          title: '1. Definiendo tu Avatar',
          description: 'Si le vendes a todos, no le vendes a nadie.',
          contentMarkdown: 'Cómo crear el perfil de tu cliente ideal...',
        ),
        CourseModule(
          title: '2. El Embudo de Ventas',
          description: 'Atraer, Convertir, Cerrar.',
          contentMarkdown: 'Estructura de un funnel básico que funciona...',
        ),
      ],
    ),
    Course(
      id: 'customer_service',
      title: 'Atención al Cliente',
      description: 'Convierte quejas en clientes fieles.',
      icon: Icons.support_agent,
      color: EmpoderateTheme.purpleAccent,
      level: 'Básico',
      duration: '3h',
      category: 'marketing',
      modules: [
        CourseModule(
          title: '1. Protocolos de Respuesta',
          description: 'Qué decir cuando el cliente está furioso.',
          contentMarkdown: 'Scripts para manejo de crisis y devoluciones...',
        ),
        CourseModule(
          title: '2. Seguimiento Post-Venta',
          description: 'La venta real empieza después del pago.',
          contentMarkdown: 'Estrategias de fidelización y upselling...',
        ),
      ],
    ),

    // --- RRHH & GESTIÓN ---
    Course(
      id: 'hr_management',
      title: 'Liderazgo de Equipos',
      description: 'Construye un equipo que trabaje solo.',
      icon: Icons.groups,
      color: Colors.blueAccent,
      level: 'Avanzado',
      duration: '6h',
      category: 'hr',
      modules: [
        CourseModule(
          title: '1. Contratación Inteligente',
          description: 'Contrata lento, despide rápido.',
          contentMarkdown: 'Procesos de selección que filtran a los malos candidatos...',
        ),
        CourseModule(
          title: '2. Cultura y Clima',
          description: 'Salario emocional y retención.',
          contentMarkdown: 'Cómo mantener motivado al equipo sin solo subir sueldos...',
        ),
      ],
    ),
    Course(
      id: 'productivity_hacks',
      title: 'Productividad Dueño',
      description: 'Deja de ser autoempleado y sé empresario.',
      icon: Icons.timer,
      color: Colors.pinkAccent,
      level: 'Todos',
      duration: '2h',
      category: 'management',
      modules: [
        CourseModule(
          title: '1. Matriz de Eisenhower',
          description: 'Urgente vs Importante.',
          contentMarkdown: 'Cómo priorizar tareas y delegar lo que no debes hacer tú...',
        ),
        CourseModule(
          title: '2. Sistematización',
          description: 'Si no está escrito, no existe.',
          contentMarkdown: 'Cómo crear manuales de procesos simples...',
        ),
      ],
    ),
  ];
}
