import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Modelo de un paso del tutorial
class TutorialStep {
  final String title;
  final String description;
  final IconData icon;
  final GlobalKey? targetKey;
  final Alignment tooltipPosition;
  final String? actionButtonText;
  final VoidCallback? onAction;

  const TutorialStep({
    required this.title,
    required this.description,
    this.icon = Icons.info_outline,
    this.targetKey,
    this.tooltipPosition = Alignment.center,
    this.actionButtonText,
    this.onAction,
  });
}

/// Configuración completa de tutorial para una pantalla
class TutorialConfig {
  final String screenKey;
  final String welcomeTitle;
  final String welcomeMessage;
  final List<TutorialStep> steps;
  final bool showOnFirstVisit;

  const TutorialConfig({
    required this.screenKey,
    required this.welcomeTitle,
    required this.welcomeMessage,
    required this.steps,
    this.showOnFirstVisit = true,
  });
}

/// Servicio singleton para gestionar tutoriales interactivos en la app.
/// Controla qué tutoriales se han visto y cuáles mostrar.
class TutorialService {
  static final instance = TutorialService._();
  TutorialService._();

  static const String _prefix = 'tutorial_seen_';
  static const String _enabledKey = 'tutorials_enabled';

  // ============================================================================
  // ESTADO Y CONFIGURACIÓN
  // ============================================================================

  /// Verifica si el usuario ya vio el tutorial de una pantalla específica.
  Future<bool> hasSeenTutorial(String screenKey) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('$_prefix$screenKey') ?? false;
    } catch (e) {
      print('❌ Error checking tutorial status: $e');
      return false;
    }
  }

  /// Marca un tutorial como visto.
  Future<void> markTutorialSeen(String screenKey) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('$_prefix$screenKey', true);
      await prefs.setString('${_prefix}${screenKey}_date', DateTime.now().toIso8601String());
      print('✅ Tutorial "$screenKey" marked as seen');
    } catch (e) {
      print('❌ Error marking tutorial: $e');
    }
  }

  /// Verifica si los tutoriales están habilitados globalmente.
  Future<bool> areTutorialsEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_enabledKey) ?? true; // Default: enabled
    } catch (e) {
      print('❌ Error checking tutorials enabled: $e');
      return true;
    }
  }

  /// Activa o desactiva los tutoriales globalmente.
  Future<void> setTutorialsEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_enabledKey, enabled);
      print('✅ Tutorials ${enabled ? "enabled" : "disabled"}');
    } catch (e) {
      print('❌ Error setting tutorials state: $e');
    }
  }

  /// Resetea todos los tutoriales para volverlos a ver.
  Future<void> resetAllTutorials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      
      // Remover todas las claves de tutoriales vistos
      for (final key in keys) {
        if (key.startsWith(_prefix)) {
          await prefs.remove(key);
        }
      }

      print('🔄 All tutorials reset');
    } catch (e) {
      print('❌ Error resetting tutorials: $e');
    }
  }

  // ============================================================================
  // CATÁLOGO DE TUTORIALES
  // ============================================================================

  /// Obtiene la configuración de tutorial para una pantalla.
  TutorialConfig? getTutorialConfig(String screenKey) {
    return _tutorialCatalog[screenKey];
  }

  /// Catálogo completo de tutoriales por pantalla
  static final Map<String, TutorialConfig> _tutorialCatalog = {
    
    // HOME SCREEN
    'home': TutorialConfig(
      screenKey: 'home',
      welcomeTitle: '¡Bienvenido a Empodérate! 👋',
      welcomeMessage: 'Te guiaremos por las funciones principales para que aproveches al máximo la app.',
      steps: [
        TutorialStep(
          title: 'Tarjeta Comienza Aquí',
          description: 'Aquí verás tu progreso inicial. Completa estos pasos para empoderar tu negocio paso a paso.',
          icon: Icons.rocket_launch,
        ),
        TutorialStep(
          title: 'Barra de Progreso',
          description: 'Tu progreso se actualiza automáticamente mientras usas la app. No necesitas hacer nada manual.',
          icon: Icons.trending_up,
        ),
        TutorialStep(
          title: 'Siguiente Paso Sugerido',
          description: 'La app te sugiere qué hacer a continuación basado en tu progreso actual.',
          icon: Icons.navigate_next,
        ),
      ],
    ),

    // BUSINESS PROFILE
    'business_profile': TutorialConfig(
      screenKey: 'business_profile',
      welcomeTitle: 'Perfil de tu Negocio',
      welcomeMessage: 'Completa esta información para que tus documentos se vean profesionales.',
      steps: [
        TutorialStep(
          title: 'Logo de la Empresa',
          description: 'Sube tu logo aquí. Aparecerá automáticamente en comprobantes, cartas y documentos oficiales.',
          icon: Icons.image,
        ),
        TutorialStep(
          title: 'Datos Básicos',
          description: 'El nombre comercial y RUC se usarán en todos tus documentos oficiales.',
          icon: Icons.business,
        ),
        TutorialStep(
          title: 'Guardar Cambios',
          description: 'No olvides guardar tu perfil al terminar. Tus datos quedan almacenados de forma segura.',
          icon: Icons.save,
        ),
      ],
    ),

    // RRHH / HR
    'rrhh': TutorialConfig(
      screenKey: 'rrhh',
      welcomeTitle: 'Recursos Humanos',
      welcomeMessage: 'Gestiona tu equipo y obligaciones laborales desde aquí.',
      steps: [
        TutorialStep(
          title: 'Directorio de Empleados',
          description: 'Crea y gestiona el perfil de cada colaborador. Guarda datos importantes como cargo y salario.',
          icon: Icons.people,
        ),
        TutorialStep(
          title: 'Calculadora de Salario',
          description: 'Calcula deducciones, seguro social y salario neto automáticamente según las leyes panameñas.',
          icon: Icons.calculate,
        ),
        TutorialStep(
          title: 'Obligaciones Laborales',
          description: 'Programa y da seguimiento a tus obligaciones mensuales (planilla, CSS, impuestos, etc.).',
          icon: Icons.event_note,
        ),
      ],
    ),

    // SALARY CALCULATOR
    'salary_calculator': TutorialConfig(
      screenKey: 'salary_calculator',
      welcomeTitle: 'Calculadora de Salario',
      welcomeMessage: 'Calcula planillas de forma rápida y precisa.',
      steps: [
        TutorialStep(
          title: 'Datos del Empleado',
          description: 'Ingresa el salario bruto, tipo de contrato y horas extras si aplica.',
          icon: Icons.person,
        ),
        TutorialStep(
          title: 'Cálculo Automático',
          description: 'La app calcula todas las deducciones legales (CSS, ISR, SE) automáticamente.',
          icon: Icons.auto_awesome,
        ),
        TutorialStep(
          title: 'Generar Comprobante',
          description: 'Descarga el comprobante de pago en PDF. Incluirá tu logo si lo configuraste.',
          icon: Icons.download,
        ),
      ],
    ),

    // CONTABILIDAD
    'accounting': TutorialConfig(
      screenKey: 'accounting',
      welcomeTitle: 'Herramientas Contables',
      welcomeMessage: 'Controla tus finanzas y mantén tu contabilidad al día.',
      steps: [
        TutorialStep(
          title: 'Flujo de Caja',
          description: 'Registra ingresos y gastos para ver tu liquidez en tiempo real.',
          icon: Icons.account_balance_wallet,
        ),
        TutorialStep(
          title: 'Presupuesto',
          description: 'Define metas de ingresos y gastos. Compara contra lo real.',
          icon: Icons.pie_chart,
        ),
        TutorialStep(
          title: 'Reportes',
          description: 'Genera reportes mensuales y anuales para toma de decisiones.',
          icon: Icons.assessment,
        ),
      ],
    ),

    // MARKETING
    'marketing': TutorialConfig(
      screenKey: 'marketing',
      welcomeTitle: 'Marketing y Ventas',
      welcomeMessage: 'Atrae más clientes y aumenta tus ventas.',
      steps: [
        TutorialStep(
          title: 'Cliente Ideal',
          description: 'Define tu buyer persona para enfocar tus esfuerzos de marketing.',
          icon: Icons.person_pin,
        ),
        TutorialStep(
          title: 'Embudo de Ventas',
          description: 'Visualiza y optimiza cada etapa del proceso de venta.',
          icon: Icons.filter_alt,
        ),
        TutorialStep(
          title: 'Campañas',
          description: 'Crea y da seguimiento a tus campañas promocionales.',
          icon: Icons.campaign,
        ),
      ],
    ),
  };
}
