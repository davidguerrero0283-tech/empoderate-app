import '../models/schedule_context.dart';
import '../models/constraint_result.dart';
import '../models/business_rules_config.dart';
import 'package:proyecto_empoderate/src/features/schedule_management/logic/schedule_controller.dart';
import 'package:proyecto_empoderate/src/calculators/schedule_models.dart';

/// Implements mandatory rules that cannot be violated
class HardConstraints {
  
  /// Check all hard constraints for a specific assignment
  static List<ConstraintResult> checkAll(
    ScheduleContext context, 
    String workerId, 
    int dayIndex, 
    String? shiftId
  ) {
    final results = <ConstraintResult>[];
    
    if (shiftId != null) {
      // 1. Check Leave Status (Maternity, Sick, etc.)
      // Moved here so it only triggers if there's an actual shift assigned
      results.add(_checkLeaveStatus(context, workerId, dayIndex));

      // 2. Check Overlap (if assigning shift)
      // (This requires checking exact times not just slots, simplified for now)
      
      // 3. Check Rest Time (vs previous day)
      results.add(_checkMinRestTime(context, workerId, dayIndex, shiftId));
      
      // 4. Check Max Daily Hours
      results.add(_checkMaxDailyHours(context, workerId, shiftId));
    }

    return results.where((r) => r.isViolation).toList();
  }

  /// Rule: Cannot assign shift if worker is on blocking leave (Maternity, Sick, Vacation)
  static ConstraintResult _checkLeaveStatus(ScheduleContext context, String workerId, int dayIndex) {
    final cellStatus = context.cellMetadata['${workerId}_$dayIndex'];
    
    if (cellStatus != null) {
      if (context.rulesConfig.blockOnMaternity && cellStatus.type == CellStatusType.maternity) {
        return ConstraintResult.hardViolation(
          ruleId: 'hard_maternity',
          description: 'Conflicto con Licencia de Maternidad',
          workerId: workerId,
          dayIndex: dayIndex,
        );
      }
      if (context.rulesConfig.blockOnSickLeave && cellStatus.type == CellStatusType.sickLeave) {
        return ConstraintResult.hardViolation(
          ruleId: 'hard_sick_leave',
          description: 'Conflicto con Incapacidad Médica',
          workerId: workerId,
          dayIndex: dayIndex,
        );
      }
      if (cellStatus.type == CellStatusType.vacation) {
        return ConstraintResult.hardViolation(
          ruleId: 'hard_vacation',
          description: 'Conflicto con Vacaciones',
          workerId: workerId,
          dayIndex: dayIndex,
        );
      }
    }
    
    return ConstraintResult.pass(ruleId: 'hard_leave_status');
  }

  /// Rule: Minimum rest time between shifts (e.g., 11 hours) -> Panama: 12h ideally
  static ConstraintResult _checkMinRestTime(ScheduleContext context, String workerId, int dayIndex, String currentShiftId) {
    if (dayIndex <= 0) return ConstraintResult.pass(ruleId: 'hard_min_rest');

    final prevDayIndex = dayIndex - 1;
    final prevShiftId = context.assignments[workerId]?[prevDayIndex];

    if (prevShiftId == null) return ConstraintResult.pass(ruleId: 'hard_min_rest');

    final currentShift = context.shifts.firstWhere((s) => s.id == currentShiftId, orElse: () => throw Exception('Shift not found'));
    final prevShift = context.shifts.firstWhere((s) => s.id == prevShiftId, orElse: () => throw Exception('Shift not found'));

    // Convert to minutes from week (or arbitrary reference)
    // Prev shift end: Day 0 + end time
    // Current shift start: Day 1 + start time
    
    int prevEndMin = prevShift.endTime.hour * 60 + prevShift.endTime.minute;
    if (prevShift.endTime.hour < prevShift.startTime.hour) {
      prevEndMin += 24 * 60; // Ends next day (technically overlaps current day start if close)
    }
    
    int currStartMin = currentShift.startTime.hour * 60 + currentShift.startTime.minute;
    currStartMin += 24 * 60; // Add 24h as it's the next day
    
    final restMinutes = currStartMin - prevEndMin;
    final minRestMinutes = context.rulesConfig.minRestHoursBetweenShifts * 60;

    if (restMinutes < minRestMinutes) {
      return ConstraintResult.hardViolation(
        ruleId: 'hard_min_rest',
        description: 'Tiempo de descanso insuficiente (${(restMinutes/60).toStringAsFixed(1)}h < ${context.rulesConfig.minRestHoursBetweenShifts}h)',
        workerId: workerId,
        dayIndex: dayIndex,
      );
    }
    
    return ConstraintResult.pass(ruleId: 'hard_min_rest');
  }
  
  /// Rule: Max hours per day
  static ConstraintResult _checkMaxDailyHours(ScheduleContext context, String workerId, String shiftId) {
    final shift = context.shifts.firstWhere((s) => s.id == shiftId);
    
    int start = shift.startTime.hour * 60 + shift.startTime.minute;
    int end = shift.endTime.hour * 60 + shift.endTime.minute;
    if (end <= start) end += 24 * 60;
    
    double hours = (end - start) / 60.0;
    
    if (hours > context.rulesConfig.maxDailyHours) {
        return ConstraintResult.hardViolation(
        ruleId: 'hard_max_daily_hours',
        description: 'El turno excede las horas máximas permitidas (${hours.toStringAsFixed(1)}h > ${context.rulesConfig.maxDailyHours}h)',
        workerId: workerId,
      );
    }
    return ConstraintResult.pass(ruleId: 'hard_max_daily_hours');
  }
}
