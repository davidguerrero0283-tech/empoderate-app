
class AppSection {
  final String id;
  final String title;
  final String description;
  final String group;
  final bool enabledByDefault;
  final bool isDevOnly;
  final String route; // Optional, for navigation blocking

  const AppSection({
    required this.id,
    required this.title,
    required this.description,
    required this.group,
    this.enabledByDefault = true,
    this.isDevOnly = false,
    this.route = '',
  });
}

class AppSectionsRegistry {
  // Groups
  static const String groupHomeMain = 'Inicio Principal';
  static const String groupHomeSecondary = 'Inicio Secundario'; // Blog, Mini-games
  static const String groupAdvanced = 'Herramientas Avanzadas';
  static const String groupFeatures = 'Módulos Funcionales';

  static const List<AppSection> allSections = [
    // -- HOME MAIN CARDS --
    AppSection(
      id: 'home.my_business',
      title: 'Mi Negocio (Rubros)',
      description: 'Tarjeta principal de "Mi Negocio"',
      group: groupHomeMain,
      route: '/mi_negocio_rubro', // AppRoutes.miNegocioRubro
    ),
    AppSection(
      id: 'home.accounting',
      title: 'Contabilidad V2',
      description: 'Módulo principal de Contabilidad',
      group: groupHomeMain,
      route: '/accounting_v2', // AppRoutes.accountingV2
    ),
    AppSection(
      id: 'home.hr',
      title: 'Recursos Humanos',
      description: 'Gestión de personal y cumplimiento',
      group: groupHomeMain,
      route: '/human_resources', // AppRoutes.humanResources
    ),
    AppSection(
      id: 'home.marketing',
      title: 'Marketing y Crecimiento',
      description: 'Embudos, Campañas y Cliente Ideal',
      group: groupHomeMain,
      route: '/marketing', // AppRoutes.marketing
    ),
    
    // -- HOME SECONDARY --
    AppSection(
      id: 'home.blog',
      title: 'Blog Empresarial',
      description: 'Tarjeta grande de "Aprende & Crece"',
      group: groupHomeSecondary,
      route: '/blog', // AppRoutes.blog
    ),
     AppSection(
      id: 'home.ruta_exito',
      title: 'La Ruta al Éxito',
      description: 'Mini juego interactivo en el Home',
      group: groupHomeSecondary,
      route: '/la_ruta_al_exito', // AppRoutes.laRutaAlExito
      enabledByDefault: true,
    ),
    AppSection(
      id: 'home.daily_missions',
      title: 'Misiones Diarias',
      description: 'Lista de chequeo diaria en el Home',
      group: groupHomeSecondary,
      route: '/misiones_diarias', // AppRoutes.misionesDiarias
      enabledByDefault: false,
    ),
     AppSection(
      id: 'home.tramites_check',
      title: 'Checklist Trámites',
      description: 'Tarjeta de "Requisitos del Negocio"',
      group: groupHomeSecondary,
      route: '/checklist_tramites', // AppRoutes.checklistTramites
      enabledByDefault: true,
    ),

    // -- ADVANCED TOOLS PANEL --
    AppSection(
      id: 'tools.ai_chat', // Renamed from tools.chatbot
      title: 'ChatBot con IA',
      description: 'Asistente virtual inteligente',
      group: groupAdvanced,
      route: '/ia/chat', // AppRoutes.aiChat
    ),
 
    AppSection(
      id: 'tools.courses',
      title: 'Cursos (Learning Center)',
      description: 'Centro de aprendizaje',
      group: groupAdvanced,
      route: '/learning_center', // AppRoutes.learningCenter
      enabledByDefault: true,
    ),
    AppSection(
      id: 'tools.library',
      title: 'Biblioteca',
      description: 'Recursos y documentos',
      group: groupAdvanced,
      route: '/library', // AppRoutes.library
      enabledByDefault: true,
    ),
    AppSection(
      id: 'tools.calculators',
      title: 'Calculadoras',
      description: 'Menú de calculadoras financieras',
      group: groupAdvanced,
      route: '/calculadoras', // AppRoutes.calculadoras
    ),
     AppSection(
      id: 'tools.audit',
      title: 'Auditoría',
      description: 'Auditoría de Negocio',
      group: groupAdvanced,
      route: '/auditoria', // AppRoutes.auditoria
    ),

  ];

  static AppSection? getById(String id) {
    try {
      return allSections.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }
}
