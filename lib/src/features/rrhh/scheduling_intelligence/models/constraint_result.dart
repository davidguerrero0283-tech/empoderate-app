/// Result of a single rule evaluation
enum ConstraintType { hard, soft }

class ConstraintResult {
  final String ruleId;
  final String description;
  final ConstraintType type;
  final bool isViolation;
  final double scoreImpact; // Nagative for soft violations
  final String? workerId;
  final int? dayIndex;

  ConstraintResult({
    required this.ruleId,
    required this.description,
    required this.type,
    required this.isViolation,
    this.scoreImpact = 0.0,
    this.workerId,
    this.dayIndex,
  });

  // Factory methods
  factory ConstraintResult.hardViolation({
    required String ruleId, 
    required String description, 
    String? workerId, 
    int? dayIndex
  }) {
    return ConstraintResult(
      ruleId: ruleId,
      description: description,
      type: ConstraintType.hard,
      isViolation: true,
      scoreImpact: -1000.0, // Massive penalty
      workerId: workerId,
      dayIndex: dayIndex,
    );
  }

  factory ConstraintResult.softViolation({
    required String ruleId, 
    required String description, 
    required double scoreImpact,
    String? workerId, 
    int? dayIndex
  }) {
    return ConstraintResult(
      ruleId: ruleId,
      description: description,
      type: ConstraintType.soft,
      isViolation: true,
      scoreImpact: scoreImpact, // Should be negative
      workerId: workerId,
      dayIndex: dayIndex,
    );
  }

  factory ConstraintResult.pass({required String ruleId}) {
    return ConstraintResult(
      ruleId: ruleId,
      description: 'Pass',
      type: ConstraintType.hard, // Doesn't matter
      isViolation: false,
      scoreImpact: 0,
    );
  }
}
