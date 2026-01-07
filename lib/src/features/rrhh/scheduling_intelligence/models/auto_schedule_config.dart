
enum RotationMode {
  fixed,   // Same shift every day (Estático)
  rotating // Changes daily (Dinámico)
}

class AutoScheduleConfig {
  /// Requirements by Shift and Role
  /// Key: Shift ID -> Value: Map(Role -> Count)
  final Map<String, Map<String, int>> roleRequirements;

  /// Fixed Assignments (Locked workers)
  /// Key: Worker ID -> Value: Shift ID (or null/special value)
  final Map<String, String?> fixedAssignments;

  /// Unavailable Dates per Worker
  /// Key: Worker ID -> Value: List of DateTime
  final Map<String, List<DateTime>> unavailableDates;

  /// Rotation Mode (Feature 3)
  final RotationMode rotationMode;

  /// Fairness vs Efficiency Weight (Feature 4)
  /// 0.0 = Pure Efficiency (Cheapest)
  /// 1.0 = Pure Fairness (Equal Shifts)
  final double fairnessWeight;

  const AutoScheduleConfig({
    this.roleRequirements = const {},
    this.fixedAssignments = const {},
    this.unavailableDates = const {},
    this.rotationMode = RotationMode.rotating,
    this.fairnessWeight = 0.5, // Default balanced
  });

  /// Create a copy with modifications
  AutoScheduleConfig copyWith({
    Map<String, Map<String, int>>? roleRequirements,
    Map<String, String?>? fixedAssignments,
    Map<String, List<DateTime>>? unavailableDates,
    RotationMode? rotationMode,
    double? fairnessWeight,
  }) {
    return AutoScheduleConfig(
      roleRequirements: roleRequirements ?? this.roleRequirements,
      fixedAssignments: fixedAssignments ?? this.fixedAssignments,
      unavailableDates: unavailableDates ?? this.unavailableDates,
      rotationMode: rotationMode ?? this.rotationMode,
      fairnessWeight: fairnessWeight ?? this.fairnessWeight,
    );
  }
  /// Factory for default configuration
  factory AutoScheduleConfig.defaultConfig() {
    return const AutoScheduleConfig();
  }
}
