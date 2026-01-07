import 'package:flutter/material.dart';
import '../calculators/schedule_models.dart';
import '../calculators/shift_models.dart';
import '../calculators/salario_models.dart';
import '../services/worker_service.dart';
import 'dart:math';

class ScheduleAnalyticsMetrics {
  final double totalHours;
  final double laborCostEstimate; // Estimado basado en salario/hora promedio o real
  final double coverageScore; // % de turnos cubiertos vs demanda
  final double efficiencyScore; // Based on optimization rules
  final Map<String, double> hoursPerDay; // Mon-Sun
  final Map<String, double> costPerDay;
  final int totalShifts;

  ScheduleAnalyticsMetrics({
    required this.totalHours,
    required this.laborCostEstimate,
    required this.coverageScore,
    required this.efficiencyScore,
    required this.hoursPerDay,
    required this.costPerDay,
    required this.totalShifts,
  });
}

class ScheduleAnalyticsService {

  ScheduleAnalyticsMetrics calculateMetrics({
    required List<WorkerProfile> workers,
    required Map<String, Map<int, String?>> assignments,
    required List<ShiftSlot> shifts,
    required List<bool> operatingDays,
    double averageHourlyRate = 3.50, // Default estimate if salary not available
  }) {
    double totalMinutes = 0;
    Map<String, double> dayMinutes = {
      'Lun': 0, 'Mar': 0, 'Mié': 0, 'Jue': 0, 'Vie': 0, 'Sáb': 0, 'Dom': 0
    };
    final dayKeys = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    int shiftCount = 0;

    final shiftMap = {for (var s in shifts) s.id: s};

    // Calculate Hours
    for (var worker in workers) {
      final workerAssignments = assignments[worker.id];
      if (workerAssignments == null) continue;

      double workerRate = worker.basePayment > 0 
          ? (worker.paymentMode == PayrollFrequency.mensual ? worker.basePayment / 208 : worker.basePayment)
          : averageHourlyRate;

      for (int i = 0; i < 7; i++) {
        final slotId = workerAssignments[i];
        if (slotId != null && shiftMap.containsKey(slotId)) {
          final shift = shiftMap[slotId]!;
          int start = shift.startTime.hour * 60 + shift.startTime.minute;
          int end = shift.endTime.hour * 60 + shift.endTime.minute;
          if (end <= start) end += 24 * 60;
          
          final duration = end - start;
          totalMinutes += duration;
          dayMinutes[dayKeys[i]] = (dayMinutes[dayKeys[i]] ?? 0) + duration;
          shiftCount++;
        }
      }
    }

    double totalHours = totalMinutes / 60;
    
    // Estimate Cost (Simple model: hours * avg rate)
    // Could be improved with real worker rates if available
    double estimatedCost = totalHours * averageHourlyRate;
    
    // Coverage Score (Simple: active days covered vs total operating days needed)
    // Assuming ideal = at least 1 person per open day
    int openDaysCount = operatingDays.where((d) => d).length;
    int coveredDaysCount = 0;
    for(int i=0; i<7; i++) {
      if(operatingDays[i] && dayMinutes[dayKeys[i]]! > 0) coveredDaysCount++;
    }
    double coverage = openDaysCount > 0 ? (coveredDaysCount / openDaysCount) * 100 : 0;

    // Efficiency Score (Mock logic for now - could be deeper)
    // Based on optimized distribution
    double efficiency = 85.0; 
    if (totalHours > 40 * workers.length) efficiency -= 10; // Overtime penalty
    if (coveredDaysCount < openDaysCount) efficiency -= 20; // Understaffing penalty

    return ScheduleAnalyticsMetrics(
      totalHours: totalHours,
      laborCostEstimate: estimatedCost,
      coverageScore: coverage,
      efficiencyScore: efficiency.clamp(0, 100),
      hoursPerDay: dayMinutes.map((k, v) => MapEntry(k, v / 60)),
      costPerDay: dayMinutes.map((k, v) => MapEntry(k, (v / 60) * averageHourlyRate)),
      totalShifts: shiftCount,
    );
  }
}
