import '../models/schedule_context.dart';
import '../models/suggestion.dart';
import '../models/constraint_result.dart';
import '../models/explanation.dart';
import '../models/business_rules_config.dart';
import '../models/audit_event.dart';
import '../rules/rule_engine.dart';
import 'package:proyecto_empoderate/src/features/schedule_management/logic/schedule_controller.dart';
import 'package:uuid/uuid.dart';

/// Service providing intelligent scheduling capabilities
class SchedulingIntelligenceService {
  final BusinessRulesConfig config;
  
  SchedulingIntelligenceService({
    this.config = const BusinessRulesConfig(),
  });

  /// Generate intelligent suggestions for improving the schedule
  List<Suggestion> generateSuggestions(ScheduleContext context) {
    final suggestions = <Suggestion>[];
    
    final evaluation = RuleEngine.evaluate(context);
    
    // 1. Suggest fixing hard violations
    for (var violation in evaluation.violations) {
      if (violation.type == ConstraintType.hard) {
        suggestions.add(Suggestion(
          id: const Uuid().v4(),
          title: 'Corregir: ${violation.description}',
          description: 'Esta asignación rompe una regla obligatoria. Recomendación: Eliminar o reasignar.',
          actionType: 'fix_violation',
          workerId: violation.workerId,
          dayIndex: violation.dayIndex,
          explanation: Explanation(
            summary: 'Violación de regla obligatoria detectada.',
            reasons: ['Viola la regla: ${violation.ruleId}', violation.description],
            scoreChange: 10,
            improvedFairness: false,
          ),
        ));
      }
    }
    
    // 2. Suggest improvements for Soft Constraints (e.g. Fatigue)
    // (Simplified logic: if score is low, suggest generic improvement)
    if (evaluation.score < 80) {
       suggestions.add(Suggestion(
          id: const Uuid().v4(),
          title: 'Mejorar Balance del Horario',
          description: 'El horario tiene una puntuación baja (${evaluation.score.toStringAsFixed(1)}). Considere rotar más los turnos.',
          actionType: 'optimize',
          explanation: Explanation(
            summary: 'La eficiencia del horario es subóptima.',
            reasons: ['Alta fatiga detectada', 'Distribución desigual de turnos'],
            scoreChange: 5,
            improvedFairness: true,
          ),
        ));
    }

    return suggestions;
  }
  /// Optimize the schedule by resolving conflicts and improving fairness
  ScheduleContext optimizeSchedule(ScheduleContext context) {
    final optimized = context.copyWith(); // Work on a copy

    // 1. ENFORCE CLOSED DAYS (Hard constraint)
    for (int day = 0; day < optimized.totalDays; day++) {
      if (!optimized.operatingDays[day]!) {
        for (var worker in optimized.workers) {
          optimized.assignments[worker.id]?[day] = null;
          optimized.cellMetadata['${worker.id}_$day'] = CellStatus(type: CellStatusType.dayOff, reason: 'Cerrado');
        }
      }
    }

    // 2. ENSURE MINIMUM DAYS OFF (Fairness/Hard)
    // Basic rotation logic similar to original but on context
    final openDays = <int>[];
    for (int i = 0; i < optimized.totalDays; i++) {
        if (optimized.operatingDays[i]!) openDays.add(i);
    }

    if (openDays.isNotEmpty) {
      // Required days off (hardcoded to 1 for generic logic, or passed in config?)
      // Let's assume 1 for now or calculate based on load
      int requiredDaysOff = 1; 

      for (int workerIdx = 0; workerIdx < optimized.workers.length; workerIdx++) {
        final worker = optimized.workers[workerIdx];
        final assignments = optimized.assignments[worker.id]!;
        
        int currentDaysOff = 0;
        for (int d = 0; d < optimized.totalDays; d++) {
             if (assignments[d] == null) currentDaysOff++;
        }
        
        int needed = requiredDaysOff - currentDaysOff;
        if (needed > 0) {
            // Greedy assignment of days off
            for (int attempt = 0; attempt < openDays.length && needed > 0; attempt++) {
                final dayChoice = openDays[(workerIdx + attempt) % openDays.length];
                if (assignments[dayChoice] != null) {
                    assignments[dayChoice] = null;
                    optimized.cellMetadata['${worker.id}_$dayChoice'] = CellStatus(type: CellStatusType.dayOff);
                    needed--;
                }
            }
        }
      }
    }

    // 3. FATIGUE MANAGEMENT (Soft/Hard)
    // Reduce massive consecutive days if possible, or weird doubles
    // (Mock implementation: just ensuring no 7-day streaks if possible, covered above by day off)

    return optimized;
  }
}
