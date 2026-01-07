import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/checklist_model.dart';
import '../data/repositories/business_signals_loader.dart';
import '../logic/business_progress_engine.dart';

/// Servicio singleton para rastrear y actualizar el progreso del usuario automáticamente.
/// Se integra con el sistema de checklist existente y emite eventos cuando hay cambios.
class ProgressTrackerService {
  static final instance = ProgressTrackerService._();
  ProgressTrackerService._();

  static const String _progressPrefix = 'progress_completed_';
  
  // Stream controller para emitir cambios de progreso
  final _progressController = StreamController<BusinessProgressModel>.broadcast();
  
  /// Stream de cambios de progreso. Las tarjetas del home pueden escuchar esto.
  Stream<BusinessProgressModel> get progressUpdates => _progressController.stream;

  /// Marca un item como completado basado en su autoRuleKey.
  /// 
  /// @param autoRuleKey La clave única del item (ej: 'hasBusinessProfile')
  /// @param showNotification Si debe mostrar notificación de logro (default: true)
  Future<void> markCompleted(
    String autoRuleKey, {
    bool showNotification = true,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_progressPrefix$autoRuleKey';
      
      // Verificar si ya estaba completado
      final wasCompleted = prefs.getBool(key) ?? false;
      if (wasCompleted) {
        return; // Ya está completado, no hacer nada
      }

      // Marcar como completado
      await prefs.setBool(key, true);
      await prefs.setString('${key}_date', DateTime.now().toIso8601String());

      // Recalcular progreso
      final progress = await getCurrentProgress();

      // Emitir evento de cambio
      _progressController.add(progress);

      // Mostrar notificación si se solicita
      if (showNotification) {
        // La lógica de notificación se maneja externamente
        // El componente que llama a markCompleted puede mostrar la notificación
      }

      print('✅ Progress: Marked "$autoRuleKey" as completed');
    } catch (e) {
      print('❌ Error marking progress: $e');
    }
  }

  /// Verifica si un item específico ya está completado.
  Future<bool> isCompleted(String autoRuleKey) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('$_progressPrefix$autoRuleKey') ?? false;
    } catch (e) {
      print('❌ Error checking completion: $e');
      return false;
    }
  }

  /// Obtiene el modelo de progreso actual calculando todas las áreas.
  Future<BusinessProgressModel> getCurrentProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final signalsLoader = BusinessSignalsLoader(prefs);
      final allItems = await signalsLoader.loadAllSignals();

      // Separar por área
      final startItems = allItems.where((i) => i.area == ProgressArea.start).toList();
      final payrollItems = allItems.where((i) => i.area == ProgressArea.payroll).toList();
      final accountingItems = allItems.where((i) => i.area == ProgressArea.accounting).toList();
      final marketingItems = allItems.where((i) => i.area == ProgressArea.marketing).toList();

      // Calcular progreso usando el engine
      final progress = BusinessProgressEngine.buildSummary(
        startItems: startItems,
        payrollItems: payrollItems,
        accountingItems: accountingItems,
        marketingItems: marketingItems,
      );

      return progress;
    } catch (e) {
      print('❌ Error getting current progress: $e');
      return BusinessProgressModel.empty;
    }
  }

  /// Auto-detecta progreso basado en datos existentes del usuario.
  /// Útil para marcar items retroactivamente cuando el usuario ya tiene datos guardados.
  /// 
  /// IMPORTANTE: No muestra notificaciones para evitar spam.
  Future<void> autoDetectProgress() async {
    try {
      print('🔍 Auto-detecting progress from existing data...');

      final prefs = await SharedPreferences.getInstance();
      final signalsLoader = BusinessSignalsLoader(prefs);
      final allItems = await signalsLoader.loadAllSignals();

      // Contar cuántos se detectaron
      int detectedCount = 0;

      for (final item in allItems) {
        if (item.done && item.autoRuleKey != null) {
          final wasAlreadyMarked = await isCompleted(item.autoRuleKey!);
          if (!wasAlreadyMarked) {
            await markCompleted(item.autoRuleKey!, showNotification: false);
            detectedCount++;
          }
        }
      }

      if (detectedCount > 0) {
        print('✅ Auto-detected $detectedCount completed items');
        // Recalcular y emitir progreso final
        final progress = await getCurrentProgress();
        _progressController.add(progress);
      } else {
        print('ℹ️ No new progress detected');
      }
    } catch (e) {
      print('❌ Error in auto-detection: $e');
    }
  }

  /// Resetea todo el progreso (útil para testing o reiniciar).
  Future<void> resetAllProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      
      // Remover todas las claves de progreso
      for (final key in keys) {
        if (key.startsWith(_progressPrefix)) {
          await prefs.remove(key);
        }
      }

      // Emitir progreso vacío
      _progressController.add(BusinessProgressModel.empty);
      print('🔄 All progress reset');
    } catch (e) {
      print('❌ Error resetting progress: $e');
    }
  }

  /// Libera recursos cuando ya no se necesite (raro, es singleton)
  void dispose() {
    _progressController.close();
  }
}
