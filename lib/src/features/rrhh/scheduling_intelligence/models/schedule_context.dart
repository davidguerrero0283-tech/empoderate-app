import 'package:proyecto_empoderate/src/calculators/schedule_models.dart';
import 'package:proyecto_empoderate/src/calculators/salario_models.dart';
import 'package:proyecto_empoderate/src/features/schedule_management/logic/schedule_controller.dart';
import 'package:proyecto_empoderate/src/services/panama_holidays_service.dart';
import 'business_rules_config.dart';

/// Context object containing all necessary data for the intelligence engine
class ScheduleContext {
  final List<WorkerProfile> workers;
  
  // Map<WorkerId, Map<DayIndex, ShiftId?>>
  final Map<String, Map<int, String?>> assignments;
  
  // Map<WorkerId_DayIndex, CellStatus>
  final Map<String, CellStatus> cellMetadata;
  
  final List<ShiftSlot> shifts;
  final DateTime weekStart;
  final int totalDays;
  final List<PublicHoliday> holidays;
  final Map<int, bool> operatingDays; // If false, business closed
  final BusinessRulesConfig rulesConfig;

  // Optional: Worker preferences if implemented later
  // final Map<String, WorkerPreferences> preferences;

  ScheduleContext({
    required this.workers,
    required this.assignments,
    required this.cellMetadata,
    required this.shifts,
    required this.weekStart,
    required this.totalDays,
    required this.holidays,
    required this.operatingDays,
    required this.rulesConfig,
  });

  /// Create deep copy for simulation
  ScheduleContext copyWith({
    Map<String, Map<int, String?>>? assignments,
    Map<String, CellStatus>? cellMetadata,
  }) {
    // Deep copy assignments map
    final newAssignments = assignments ?? {
      for (var entry in this.assignments.entries)
        entry.key: Map.from(entry.value)
    };

    // Deep copy metadata
    final newMetadata = cellMetadata ?? Map.from(this.cellMetadata);

    return ScheduleContext(
      workers: workers,
      assignments: newAssignments,
      cellMetadata: newMetadata,
      shifts: shifts,
      weekStart: weekStart,
      totalDays: totalDays,
      holidays: holidays,
      operatingDays: operatingDays,
      rulesConfig: rulesConfig,
    );
  }
}
