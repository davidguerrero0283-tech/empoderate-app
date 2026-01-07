import 'package:flutter/material.dart';
import '../calculators/schedule_models.dart';
import '../calculators/shift_models.dart';
import '../calculators/salario_models.dart';
import '../services/worker_service.dart';
import 'dart:math';

enum SuggestionType {
  staffing, // Sobrecarga o falta de personal
  fairness, // Inequidad en distribución
  cost,     // Costos elevados / horas extra
  optimization, // Mejoras generales
}

class OptimizationSuggestion {
  final String title;
  final String message;
  final String actionLabel;
  final SuggestionType type;
  final VoidCallback? onAction;
  final bool isHighPriority;
  final dynamic explanation; // New: Explanation object from Smart V1

  OptimizationSuggestion({
    required this.title,
    required this.message,
    this.actionLabel = '',
    required this.type,
    this.onAction,
    this.isHighPriority = false,
    this.explanation,
  });
}

class SmartScheduleService {
  
  List<OptimizationSuggestion> analyzeSchedule({
    required List<WorkerProfile> workers,
    required Map<String, Map<int, String?>> assignments,
    required List<ShiftSlot> shifts,
    required List<bool> operatingDays,
  }) {
    final suggestions = <OptimizationSuggestion>[];
    
    if (workers.isEmpty || shifts.isEmpty) return suggestions;

    // 1. Detectar Sobrecarga de Días (Staffing)
    _checkDailyOverload(suggestions, workers, assignments, operatingDays);

    // 2. Detectar Inequidad (Fairness)
    _checkWorkloadFairness(suggestions, workers, assignments, shifts);

    // 3. Detectar Cobertura Baja en Días Operativos
    _checkLowCoverage(suggestions, workers, assignments, operatingDays);

    return suggestions;
  }

  void _checkDailyOverload(
    List<OptimizationSuggestion> suggestions,
    List<WorkerProfile> workers,
    Map<String, Map<int, String?>> assignments,
    List<bool> operatingDays,
  ) {
    final dayNames = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
    
    for (int i = 0; i < 7; i++) {
      if (!operatingDays[i]) continue;

      int assignedCount = 0;
      for (var worker in workers) {
        if (assignments[worker.id]?[i] != null) {
          assignedCount++;
        }
      }

      // Si más del 90% de la plantilla está asignada un solo día
      if (workers.length > 2 && assignedCount >= workers.length * 0.9) {
        suggestions.add(OptimizationSuggestion(
          title: 'Sobrecarga el ${dayNames[i]}',
          message: 'El ${assignedCount}/${workers.length} de tus empleados trabaja este día. Riesgo alto ante ausencias.',
          type: SuggestionType.staffing,
          isHighPriority: true,
        ));
      }
    }
  }

  void _checkWorkloadFairness(
    List<OptimizationSuggestion> suggestions,
    List<WorkerProfile> workers,
    Map<String, Map<int, String?>> assignments,
    List<ShiftSlot> shifts,
  ) {
    final shiftMap = {for (var s in shifts) s.id: s};
    final workerHours = <String, double>{};

    for (var worker in workers) {
      double totalMinutes = 0;
      final workerAssignments = assignments[worker.id];
      if (workerAssignments == null) continue;

      for (int i = 0; i < 7; i++) {
        final slotId = workerAssignments[i];
        if (slotId != null && shiftMap.containsKey(slotId)) {
          final shift = shiftMap[slotId]!;
           int start = shift.startTime.hour * 60 + shift.startTime.minute;
           int end = shift.endTime.hour * 60 + shift.endTime.minute;
           if (end <= start) end += 24 * 60;
           totalMinutes += (end - start);
        }
      }
      workerHours[worker.id] = totalMinutes / 60;
    }

    if (workerHours.isEmpty) return;

    final hours = workerHours.values.toList();
    final mean = hours.reduce((a, b) => a + b) / hours.length;
    
    // Calcular desviación estándar
    final variance = hours.map((h) => pow(h - mean, 2)).reduce((a, b) => a + b) / hours.length;
    final stdDev = sqrt(variance);

    // Si la desviación estándar es alta (> 8 horas de diferencia típica)
    if (stdDev > 8) {
      final minWorker = workerHours.entries.reduce((a, b) => a.value < b.value ? a : b);
      final maxWorker = workerHours.entries.reduce((a, b) => a.value > b.value ? a : b);
      final minName = workers.firstWhere((w) => w.id == minWorker.key).name;
      final maxName = workers.firstWhere((w) => w.id == maxWorker.key).name;

      suggestions.add(OptimizationSuggestion(
        title: 'Distribución Inequitativa',
        message: 'Gran brecha entre $maxName (${maxWorker.value.toStringAsFixed(1)}h) y $minName (${minWorker.value.toStringAsFixed(1)}h).',
        type: SuggestionType.fairness,
        actionLabel: 'Auto-balancear',
        isHighPriority: true,
      ));
    }
  }

  void _checkLowCoverage(
    List<OptimizationSuggestion> suggestions,
    List<WorkerProfile> workers,
    Map<String, Map<int, String?>> assignments,
    List<bool> operatingDays,
  ) {
    final dayNames = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];

    for (int i = 0; i < 7; i++) {
        if (!operatingDays[i]) continue;

        int assignedCount = 0;
        for (var worker in workers) {
          if (assignments[worker.id]?[i] != null) {
            assignedCount++;
          }
        }
        
        // Menos del 30% del personal (si hay al menos 3 empleados)
        if (workers.length >= 3 && assignedCount < workers.length * 0.3) {
           suggestions.add(OptimizationSuggestion(
            title: 'Cobertura Baja el ${dayNames[i]}',
            message: 'Solo ${assignedCount} empleados asignados. Podría afectar el servicio.',
            type: SuggestionType.staffing,
          )); 
        }
    }
  }
}
