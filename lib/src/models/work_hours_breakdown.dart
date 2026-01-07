import 'package:flutter/material.dart';

/// Breakdown of hours worked by shift type
class WorkHoursBreakdown {
  final double diurnalHours;   // 6am-6pm (Normal rate)
  final double mixedHours;     // 6pm-10pm (1.25x rate)
  final double nightHours;     // 10pm-6am (1.50x rate)
  final double totalHours;
  final double overtimeHours;  // Hours beyond normal limit
  
  // Metadata
  final int daysWorked;
  final DateTime periodStart;
  final DateTime periodEnd;
  final List<DailyHours> dailyBreakdown;

  const WorkHoursBreakdown({
    required this.diurnalHours,
    required this.mixedHours,
    required this.nightHours,
    required this.totalHours,
    required this.overtimeHours,
    required this.daysWorked,
    required this.periodStart,
    required this.periodEnd,
    required this.dailyBreakdown,
  });

  /// Calculate base pay for given hourly rate
  double calculateBasePay(double hourlyRate) {
    return (diurnalHours * hourlyRate) +
           (mixedHours * hourlyRate * 1.25) +
           (nightHours * hourlyRate * 1.50);
  }

  @override
  String toString() {
    return 'WorkHoursBreakdown(total: ${totalHours}h, diurnal: ${diurnalHours}h, mixed: ${mixedHours}h, night: ${nightHours}h)';
  }
}

/// Daily hours worked by a worker
class DailyHours {
  final DateTime date;
  final String shiftName;
  final double hours;
  final String shiftType; // 'diurnal', 'mixed', 'night'
  
  const DailyHours({
    required this.date,
    required this.shiftName,
    required this.hours,
    required this.shiftType,
  });
}
