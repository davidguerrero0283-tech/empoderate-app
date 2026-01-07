import 'package:flutter/foundation.dart';
import '../models/work_hours_breakdown.dart';
import '../calculators/schedule_models.dart';
import '../calculators/salario_models.dart';
import 'schedule_service.dart';

/// Service to calculate hours worked from schedule assignments
class ScheduleHoursCalculator {
  final ScheduleService _scheduleService = ScheduleService();
  
  /// Get hours worked for a specific worker in a date range
  Future<WorkHoursBreakdown?> getWorkedHours({
    required String workerId,
    required DateTime periodStart,
    required DateTime periodEnd,
  }) async {
    try {
      // 1. Get all schedules
      final schedules = await _scheduleService.getSchedules();
      
      if (schedules.isEmpty) {
        debugPrint('No schedules found');
        return null;
      }
      
      // 2. Filter assignments for this worker in period
      List<WorkerAssignment> relevantAssignments = [];
      List<ShiftSlot> allShifts = [];
      
      for (var schedule in schedules) {
        // Check if schedule overlaps with period
        if (schedule.endDate.isBefore(periodStart) || schedule.startDate.isAfter(periodEnd)) {
          continue;
        }
        
        // Get shifts from schedule's template (if available)
        // For now, we'll extract from assignments directly
        final assignments = schedule.assignments.where((a) =>
          a.workerId == workerId &&
          !a.date.isBefore(periodStart) &&
          !a.date.isAfter(periodEnd)
        ).toList();
        
        relevantAssignments.addAll(assignments);
      }
      
      if (relevantAssignments.isEmpty) {
        debugPrint('No assignments found for worker $workerId in period');
        return null;
      }
      
      // 3. Get shift definitions from templates (or use default assumptions)
      final templates = await _scheduleService.getTemplates();
      for (var template in templates) {
        allShifts.addAll(template.availableSlots);
      }
      
      // 4. Calculate hours
      return _calculateFromSchedule(
        relevantAssignments,
        allShifts,
        periodStart,
        periodEnd,
      );
      
    } catch (e) {
      debugPrint('Error in getWorkedHours: $e');
      return null;
    }
  }
  
  /// Calculate hours from schedule assignments
  WorkHoursBreakdown _calculateFromSchedule(
    List<WorkerAssignment> assignments,
    List<ShiftSlot> shifts,
    DateTime periodStart,
    DateTime periodEnd,
  ) {
    double diurnalHours = 0.0;
    double mixedHours = 0.0;
    double nightHours = 0.0;
    List<DailyHours> dailyBreakdown = [];
    
    for (var assignment in assignments) {
      if (assignment.slotId == null || assignment.isVacation) continue;
      
      // Find the shift slot
      ShiftSlot? shift;
      try {
        shift = shifts.firstWhere((s) => s.id == assignment.slotId);
      } catch (e) {
        // If shift not found, use default 8-hour diurnal assumption
        debugPrint('Shift ${assignment.slotId} not found, using default 8h diurnal');
        diurnalHours += 8.0;
        dailyBreakdown.add(DailyHours(
          date: assignment.date,
          shiftName: 'Unknown',
          hours: 8.0,
          shiftType: 'diurnal',
        ));
        continue;
      }
      
      final hours = shift.endTime.difference(shift.startTime).inHours.toDouble();
      
      // Classify by shift type based on start time
      // Panama Labor Code definitions:
      // - Diurnal (Diurna): 6:00 AM - 6:00 PM
      // - Mixed (Mixta): Partially in night hours
      // - Night (Nocturna): 6:00 PM - 6:00 AM
      final startHour = shift.startTime.hour;
      final endHour = shift.endTime.hour;
      
      String shiftType;
      if (startHour >= 6 && endHour <= 18) {
        // Fully diurnal
        diurnalHours += hours;
        shiftType = 'diurnal';
      } else if (startHour >= 18 || endHour <= 6) {
        // Fully nocturnal
        nightHours += hours;
        shiftType = 'night';
      } else {
        // Mixed (crosses boundaries)
        mixedHours += hours;
        shiftType = 'mixed';
      }
      
      dailyBreakdown.add(DailyHours(
        date: assignment.date,
        shiftName: shift.name,
        hours: hours,
        shiftType: shiftType,
      ));
    }
    
    final totalHours = diurnalHours + mixedHours + nightHours;
    
    // Calculate overtime (if any)
    // Panama: Normal is 48h/week or ~208h/month
    double overtimeHours = 0.0;
    final periodDays = periodEnd.difference(periodStart).inDays + 1;
    if (periodDays <= 7) {
      // Weekly period
      if (totalHours > 48) overtimeHours = totalHours - 48;
    } else if (periodDays <= 16) {
      // Bi-weekly period
      if (totalHours > 104) overtimeHours = totalHours - 104;
    } else {
      // Monthly period
      if (totalHours > 208) overtimeHours = totalHours - 208;
    }
    
    return WorkHoursBreakdown(
      diurnalHours: diurnalHours,
      mixedHours: mixedHours,
      nightHours: nightHours,
      totalHours: totalHours,
      overtimeHours: overtimeHours,
      daysWorked: assignments.length,
      periodStart: periodStart,
      periodEnd: periodEnd,
      dailyBreakdown: dailyBreakdown,
    );
  }
  
  /// Get recommended period based on payment frequency
  static PeriodDates getCurrentPeriod(PayrollFrequency frequency) {
    final now = DateTime.now();
    
    switch (frequency) {
      case PayrollFrequency.quincenal:
        // First or second fortnight
        if (now.day <= 15) {
          return PeriodDates(DateTime(now.year, now.month, 1), DateTime(now.year, now.month, 15));
        } else {
          final lastDay = DateTime(now.year, now.month + 1, 0).day;
          return PeriodDates(DateTime(now.year, now.month, 16), DateTime(now.year, now.month, lastDay));
        }
        
      case PayrollFrequency.mensual:
        return PeriodDates(DateTime(now.year, now.month, 1), DateTime(now.year, now.month + 1, 0));
        
      case PayrollFrequency.semanal:
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        return PeriodDates(weekStart, weekStart.add(const Duration(days: 6)));
    }
  }
}

/// Simple period dates class (replacement for record syntax)
class PeriodDates {
  final DateTime start;
  final DateTime end;
  const PeriodDates(this.start, this.end);
}
