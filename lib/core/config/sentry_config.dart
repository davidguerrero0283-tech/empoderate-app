/// Sentry Configuration for Empodérate
/// 
/// Inicializa Sentry con configuración por ambiente
/// y captura de errores no manejados.

import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'env_config.dart';

class SentryConfig {
  SentryConfig._();
  
  /// Inicializar Sentry
  /// Debe llamarse ANTES de runApp() en main.dart
  static Future<void> init({
    required Function() appRunner,
  }) async {
    if (EnvConfig.sentryDsn.isEmpty) {
      // Si no hay DSN configurado, ejecutar app sin Sentry
      debugPrint('⚠️ Sentry DSN not configured, skipping initialization');
      appRunner();
      return;
    }

    await SentryFlutter.init(
      (options) {
        // DSN de Sentry
        options.dsn = EnvConfig.sentryDsn;
        
        // Ambiente (dev/staging/prod)
        options.environment = EnvConfig.current.name;
        
        // Sample rate para errores (100% = capturar todos)
        options.sampleRate = 1.0;
        
        // Sample rate para performance (20% = capturar 1 de cada 5)
        options.tracesSampleRate = EnvConfig.current == Environment.prod ? 0.2 : 1.0;
        
        // Habilitar breadcrumbs automáticos
        options.enableAutoSessionTracking = true;
        options.autoSessionTrackingInterval = const Duration(seconds: 30);
        
        // Configuración de release
        options.release = 'empoderate@${EnvConfig.appVersion}';
        
        // Filtrar eventos sensibles en producción
        options.beforeSend = (event, {hint}) {
          // No enviar eventos en dev si se prefiere
          if (EnvConfig.current == Environment.dev && !EnvConfig.enableAnalytics) {
            return null; // Bloquear evento
          }
          return event;
        };
        
        // Debug mode solo en desarrollo
        options.debug = EnvConfig.enableDebugLogs;
      },
      appRunner: appRunner,
    );
    
    // Configurar tags por defecto después de la inicialización
    Sentry.configureScope((scope) {
      scope.setTag('platform', 'web');
      scope.setTag('environment', EnvConfig.current.name);
    });
  }
  
  /// Configurar usuario cuando haga login
  static void setUser({
    required String uid,
    String? email,
    String? displayName,
  }) {
    Sentry.configureScope((scope) {
      scope.setUser(SentryUser(
        id: uid,
        email: email,
        username: displayName,
      ));
      
      // Agregar tag de uid para búsquedas
      scope.setTag('uid', uid);
    });
  }
  
  /// Limpiar usuario cuando haga logout
  static void clearUser() {
    Sentry.configureScope((scope) {
      scope.setUser(null);
      scope.removeTag('uid');
    });
  }
  
  /// Agregar contexto adicional
  static void setContext(String key, Map<String, dynamic> data) {
    Sentry.configureScope((scope) {
      scope.setContexts(key, data);
    });
  }
  
  /// Agregar breadcrumb manual
  static void addBreadcrumb({
    required String message,
    String? category,
    SentryLevel? level,
    Map<String, dynamic>? data,
  }) {
    Sentry.addBreadcrumb(Breadcrumb(
      message: message,
      category: category,
      level: level ?? SentryLevel.info,
      data: data,
    ));
  }
}
