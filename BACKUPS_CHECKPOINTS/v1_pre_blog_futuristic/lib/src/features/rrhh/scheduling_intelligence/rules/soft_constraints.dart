import '../models/schedule_context.dart';
import '../models/constraint_result.dart';
import 'package:proyecto_empoderate/src/calculators/schedule_models.dart';

/// Implements soft rules that affect the score (optimization)
class SoftConstraints {
  
  /// Calculate total score for a worker's schedule
  static double scoreWorkerSchedule(ScheduleContext context, String workerId) {
    double score = 100.0; // Start perfect
    
    // 1. Fatigue Check (Consecutive heavy shifts)
    score += _scoreFatigue(context, workerId);
    
    // 2. Continuity (Consistency of start times)
    score += _scoreContinuity(context, workerId);
    
    // 3. Fairness (checked globally usually, but local impact here)
    // (Skipped local check for now, handled in global)

    return score.clamp(0.0, 100.0);
  }

  /// Penalize back-to-back heavy shifts (e.g., closing then opening, or many night shifts)
  static double _scoreFatigue(ScheduleContext context, String workerId) {
    double penalty = 0;
    final assignments = context.assignments[workerId]!;
    
    int consecutiveWorkDays = 0;
    
    for (int i = 0; i < context.totalDays; i++) {
        if (assignments[i] != null) {
            consecutiveWorkDays++;
        } else {
            consecutiveWorkDays = 0;
        }
        
        if (consecutiveWorkDays > context.rulesConfig.maxConsecutiveWorkDays) {
            penalty -= (consecutiveWorkDays - context.rulesConfig.maxConsecutiveWorkDays) * 10;
        }
    }
    return penalty * context.rulesConfig.fatigueWeight;
  }
  
  /// Reward consistent start times (less jetlag-like effect)
  static double _scoreContinuity(ScheduleContext context, String workerId) {
    double score = 0;
    final assignments = context.assignments[workerId]!;
    
    int? prevStartHour;
    
    for (int i = 0; i < context.totalDays; i++) {
        final sid = assignments[i];
        if (sid != null) {
            final shift = context.shifts.firstWhere((s) => s.id == sid);
            final startHour = shift.startTime.hour;
            
            if (prevStartHour != null) {
                // If start time changes by more than 3 hours, slight penalty
                int diff = (startHour - prevStartHour).abs();
                if (diff > 3) {
                    score -= (diff - 3) * 2;
                } else {
                    score += 5; // Reward consistency
                }
            }
            prevStartHour = startHour;
        }
    }
    
    return score * context.rulesConfig.continuityWeight;
  }
}
