/// App Logger Service
/// 
/// Servicio centralizado de logging que:
/// - Envía errores a Sentry en producción
/// - Muestra logs en consola en desarrollo
/// - Agrega contexto automático

import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import '../core/config/env_config.dart';

enum LogLevel {
  debug,
  info,
  warning,
  error,
}

class AppLogger {
  AppLogger._();
  
  // ============================================
  // Logging Methods
  // ============================================
  
  /// Log de información general
  static void info(String message, {Map<String, dynamic>? data}) {
    _log(LogLevel.info, message, data: data);
  }
  
  /// Log de debug (solo en desarrollo)
  static void debug(String message, {Map<String, dynamic>? data}) {
    if (EnvConfig.enableDebugLogs) {
      _log(LogLevel.debug, message, data: data);
    }
  }
  
  /// Log de advertencia
  static void warning(String message, {Map<String, dynamic>? data}) {
    _log(LogLevel.warning, message, data: data);
  }
  
  /// Log de error
  static void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? data,
  }) {
    _log(
      LogLevel.error,
      message,
      error: error,
      stackTrace: stackTrace,
      data: data,
    );
  }
  
  // ============================================
  // Sentry Integration
  // ============================================
  
  /// Capturar excepción en Sentry
  static Future<void> captureException(
    Object exception, {
    StackTrace? stackTrace,
    Hint? hint,
    Map<String, dynamic>? extra,
    SentryLevel? level,
  }) async {
    // Log local
    debugPrint('❌ Exception: $exception');
    if (stackTrace != null) {
      debugPrint('Stack trace: $stackTrace');
    }
    
    // Enviar a Sentry
    await Sentry.captureException(
      exception,
      stackTrace: stackTrace,
      hint: hint,
      withScope: (scope) {
        if (extra != null) {
          extra.forEach((key, value) {
            scope.setExtra(key, value);
          });
        }
        if (level != null) {
          scope.level = level;
        }
      },
    );
  }
  
  /// Capturar mensaje en Sentry
  static Future<void> captureMessage(
    String message, {
    SentryLevel? level,
    Map<String, dynamic>? extra,
  }) async {
    await Sentry.captureMessage(
      message,
      level: level ?? SentryLevel.info,
      withScope: (scope) {
        if (extra != null) {
          extra.forEach((key, value) {
            scope.setExtra(key, value);
          });
        }
      },
    );
  }
  
  /// Agregar breadcrumb para contexto
  static void addBreadcrumb({
    required String message,
    String? category,
    Map<String, dynamic>? data,
    SentryLevel? level,
  }) {
    Sentry.addBreadcrumb(Breadcrumb(
      message: message,
      category: category ?? 'app',
      level: level ?? SentryLevel.info,
      data: data,
    ));
  }
  
  // ============================================
  // Performance Monitoring
  // ============================================
  
  /// Iniciar transacción de performance
  static ISentrySpan startTransaction({
    required String name,
    required String operation,
    Map<String, dynamic>? data,
  }) {
    final transaction = Sentry.startTransaction(
      name,
      operation,
      bindToScope: true,
    );
    
    if (data != null) {
      data.forEach((key, value) {
        transaction.setData(key, value);
      });
    }
    
    return transaction;
  }
  
  /// Medir duración de una operación
  static Future<T> measureOperation<T>({
    required String name,
    required String operation,
    required Future<T> Function() task,
    Map<String, dynamic>? data,
  }) async {
    final transaction = startTransaction(
      name: name,
      operation: operation,
      data: data,
    );
    
    try {
      final result = await task();
      transaction.status = const SpanStatus.ok();
      return result;
    } catch (error, stackTrace) {
      transaction.status = const SpanStatus.internalError();
      transaction.throwable = error;
      await captureException(error, stackTrace: stackTrace);
      rethrow;
    } finally {
      await transaction.finish();
    }
  }
  
  // ============================================
  // Private Methods
  // ============================================
  
  static void _log(
    LogLevel level,
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? data,
  }) {
    // Console log local
    final prefix = _getLogPrefix(level);
    debugPrint('$prefix $message');
    
    if (data != null && EnvConfig.enableDebugLogs) {
      debugPrint('Data: $data');
    }
    
    if (error != null) {
      debugPrint('Error: $error');
    }
    
    if (stackTrace != null && EnvConfig.enableDebugLogs) {
      debugPrint('Stack: $stackTrace');
    }
    
    // Enviar a Sentry si es error
    if (level == LogLevel.error && error != null) {
      captureException(
        error,
        stackTrace: stackTrace,
        hint: message.isNotEmpty ? Hint.withMap({'message': message}) : null,
        extra: data,
        level: _getSentryLevel(level),
      );
    }
    
    // Breadcrumb para contexto
    if (level != LogLevel.debug) {
      addBreadcrumb(
        message: message,
        category: 'app.log',
        level: _getSentryLevel(level),
        data: data,
      );
    }
  }
  
  static String _getLogPrefix(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return '🔍';
      case LogLevel.info:
        return 'ℹ️';
      case LogLevel.warning:
        return '⚠️';
      case LogLevel.error:
        return '❌';
    }
  }
  
  static SentryLevel _getSentryLevel(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return SentryLevel.debug;
      case LogLevel.info:
        return SentryLevel.info;
      case LogLevel.warning:
        return SentryLevel.warning;
      case LogLevel.error:
        return SentryLevel.error;
    }
  }
}
