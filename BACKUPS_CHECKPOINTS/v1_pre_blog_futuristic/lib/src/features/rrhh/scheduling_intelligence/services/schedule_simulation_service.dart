import '../models/schedule_context.dart';
import '../rules/rule_engine.dart';
import '../models/constraint_result.dart';

class SimulationResult {
  final bool isViable;
  final double score;
  final List<ConstraintResult> violations;
  final double scoreDelta; // comparison to original

  SimulationResult({
    required this.isViable,
    required this.score,
    required this.violations,
    required this.scoreDelta,
  });
}

/// Service to simulate "What If" scenarios
class ScheduleSimulationService {
  
  /// Simulate a change to see its impact
  static SimulationResult simulateChange(
    ScheduleContext originalContext, 
    String workerId, 
    int dayIndex, 
    String? newShiftId
  ) {
    // 1. Create modified context
    final modifiedContext = originalContext.copyWith(); // Deep copy is handled in model
    modifiedContext.assignments[workerId]?[dayIndex] = newShiftId;
    
    // 2. Evaluate original
    final originalEval = RuleEngine.evaluate(originalContext);
    
    // 3. Evaluate modified
    final newEval = RuleEngine.evaluate(modifiedContext);
    
    return SimulationResult(
      isViable: newEval.isValid,
      score: newEval.score,
      violations: newEval.violations,
      scoreDelta: newEval.score - originalEval.score,
    );
  }
}
