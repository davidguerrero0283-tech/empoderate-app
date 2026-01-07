/// Configuration for Business Rules (Hard & Soft Constraints)
class BusinessRulesConfig {
  // HARD CONSTRAINTS (Violations block actions)
  final int minRestHoursBetweenShifts;
  final double maxWeeklyHours;
  final double maxDailyHours; // Panama: 8h day, 7h night
  final int maxConsecutiveWorkDays;
  final bool allowOvertime;
  final bool blockOnMaternity;
  final bool blockOnSickLeave;

  // SOFT CONSTRAINTS (Violations reduce score)
  // Weights (0-100)
  // SOFT CONSTRAINTS (Violations reduce score)
  // Weights (0.0 - 2.0 range for auto-tuning)
  final double fairnessWeight; // Distribution of bad shifts
  final double fatigueWeight; // Avoid heavy back-to-back
  final double preferenceWeight; // If implemented
  final double continuityWeight; // Prefer consistent schedules
  
  // Feature Flags for Intelligence
  final bool enableFairness;
  final bool enableFatigueControl;

  // Penalties (points deducted)
  final int penaltyDoubleShift; // Working morning then night same day (if feasible)
  final int penaltyWeekendClumping; // Working both Sat & Sun repeatedly

  const BusinessRulesConfig({
    this.minRestHoursBetweenShifts = 11,
    this.maxWeeklyHours = 48.0,
    this.maxDailyHours = 12.0, // Including overtime allowed?
    this.maxConsecutiveWorkDays = 6,
    this.allowOvertime = true,
    this.blockOnMaternity = true,
    this.blockOnSickLeave = true,
    
    this.fairnessWeight = 1.0,
    this.fatigueWeight = 0.8,
    this.preferenceWeight = 0.5,
    this.continuityWeight = 0.3,
    
    this.enableFairness = true,
    this.enableFatigueControl = true,
    
    this.penaltyDoubleShift = 50,
    this.penaltyWeekendClumping = 20,
  });

  // Factory for default Panama config
  factory BusinessRulesConfig.panamaDefault() {
    return const BusinessRulesConfig(
      minRestHoursBetweenShifts: 12, // Common practice
      maxWeeklyHours: 48.0, // Art 30
      maxDailyHours: 11.0, // 8h + 3h overtime max (Art 36)
      maxConsecutiveWorkDays: 6, // One rest day mandatory
    );
  }
}
