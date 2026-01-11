import '../models/schedule_context.dart';
import '../models/constraint_result.dart';
import 'hard_constraints.dart';
import 'soft_constraints.dart';

class RuleEvaluationResult {
  final bool isValid; // No hard violations
  final double score; // 0-100
  final List<ConstraintResult> violations; // Details
  
  RuleEvaluationResult({
    required this.isValid,
    required this.score,
    required this.violations,
  });
}

class RuleEngine {
  
  /// Evaluate the full schedule context
  static RuleEvaluationResult evaluate(ScheduleContext context) {
    final violations = <ConstraintResult>[];
    double totalScore = 0;
    int workerCount = 0;

    // Evaluate per worker
    for (var worker in context.workers) {
      workerCount++;
      
      // Check Hard Constraints for each day assigned
      for (int i = 0; i < context.totalDays; i++) {
        final shiftId = context.assignments[worker.id]?[i];
        final results = HardConstraints.checkAll(context, worker.id, i, shiftId);
        violations.addAll(results);
      }
      
      // Calculate Soft Score
      totalScore += SoftConstraints.scoreWorkerSchedule(context, worker.id);
    }
    
    // Average score
    double finalScore = workerCount > 0 ? totalScore / workerCount : 100;

    return RuleEvaluationResult(
      isValid: violations.isEmpty, 
      score: finalScore, 
      violations: violations,
    );
  }
  
  /// Validate a specific proposed change (single assignment)
  static RuleEvaluationResult validateChange(ScheduleContext context, String workerId, int dayIndex, String? shiftId) {
     final violations = HardConstraints.checkAll(context, workerId, dayIndex, shiftId);
     
     // To get true score impact, we'd need to simulate the change context.
     // For now, just return violations for quick check.
     
     return RuleEvaluationResult(
       isValid: violations.isEmpty,
       score: 100, // Placeholder
       violations: violations,
     );
  }
}
