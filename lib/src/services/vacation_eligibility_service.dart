import 'package:flutter/foundation.dart';
import '../models/vacation_management.dart';
import '../calculators/salario_models.dart';
import '../calculators/vacation_models.dart'; // For VacationRecord
import 'worker_service.dart';

/// Service for managing vacation eligibility tracking
class VacationEligibilityService {
  final WorkerService _workerService = WorkerService();
  
  /// Calculate all eligibility periods for a worker based on hire date
  List<VacationEligibility> calculateEligibility(WorkerProfile worker) {
    if (worker.startDate == null) {
      return [];
    }
    
    final List<VacationEligibility> eligibilities = [];
    final now = DateTime.now();
    final hireDate = worker.startDate!;
    
    // Calculate years of service
    int year = 0;
    DateTime currentEligibleDate = hireDate.add(const Duration(days: 11 * 30)); // First eligibility after 11 months
    
    while (currentEligibleDate.isBefore(now) || currentEligibleDate.isAtSameMomentAs(now)) {
      year++;
      final daysEarned = VacationEligibility.calculateDaysEarned(year);
      
      // Check if already approved in worker's vacation history
      final isAlreadyApproved = worker.vacationHistory.any((v) =>
        v.startDate.year == currentEligibleDate.year &&
        v.isPaid == true
      );
      
      eligibilities.add(VacationEligibility(
        id: '${worker.id}_year_$year',
        eligibleDate: currentEligibleDate,
        yearOfService: year,
        daysEarned: daysEarned,
        isApproved: isAlreadyApproved,
        status: isAlreadyApproved ? VacationStatus.approved : VacationStatus.pending,
      ));
      
      // Next year (12 months later)
      currentEligibleDate = currentEligibleDate.add(const Duration(days: 365));
    }
    
    return eligibilities;
  }
  
  /// Get all workers with pending vacations
  Future<List<MapEntry<WorkerProfile, List<VacationEligibility>>>> getPendingVacations() async {
    final workers = await _workerService.getWorkers();
    final List<MapEntry<WorkerProfile, List<VacationEligibility>>> pending = [];
    
    for (var worker in workers) {
      final eligibilities = calculateEligibility(worker);
      final pendingEligibilities = eligibilities.where((e) => 
        e.status == VacationStatus.pending
      ).toList();
      
      if (pendingEligibilities.isNotEmpty) {
        pending.add(MapEntry(worker, pendingEligibilities));
      }
    }
    
    // Sort by hire date (oldest first - higher priority)
    pending.sort((a, b) => 
      (a.key.startDate ?? DateTime.now()).compareTo(b.key.startDate ?? DateTime.now())
    );
    
    return pending;
  }
  
  /// Approve vacation and create vacation record
  Future<VacationRecord> approveVacation({
    required WorkerProfile worker,
    required VacationEligibility eligibility,
    required DateTime startDate,
    required DateTime endDate,
    required String approvedBy,
  }) async {
    final daysTaken = endDate.difference(startDate).inDays + 1;
    
    if (daysTaken > eligibility.daysEarned) {
      throw Exception('Cannot approve more days (${daysTaken}) than earned (${eligibility.daysEarned})');
    }
    
    // Create vacation record
    final vacationRecord = VacationRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      startDate: startDate,
      endDate: endDate,
      daysTaken: daysTaken,
      amountPaid: 0.0, // Will be calculated later
      isPaid: false,
      notes: 'Approved for year ${eligibility.yearOfService}',
      createdAt: DateTime.now(),
    );
    
    // Add to worker's vacation history
    final updatedWorker = WorkerProfile(
      id: worker.id,
      name: worker.name,
      position: worker.position,
      department: worker.department,
      paymentMode: worker.paymentMode,
      paymentType: worker.paymentType,
      basePayment: worker.basePayment,
      hourlyRate: worker.hourlyRate,
      cedula: worker.cedula,
      startDate: worker.startDate,
      contractType: worker.contractType,
      notes: worker.notes,
      lastCalcTotal: worker.lastCalcTotal,
      lastCalcDate: worker.lastCalcDate,
      payrollHistory: worker.payrollHistory,
      vacationHistory: [...worker.vacationHistory, vacationRecord],
      decimoHistory: worker.decimoHistory,
      shiftPeriods: worker.shiftPeriods,
    );
    
    await _workerService.saveWorker(updatedWorker);
    
    return vacationRecord;
  }
  
  /// Get total pending days (earned - taken) for a worker
  int getTotalPendingDays(WorkerProfile worker) {
    final eligibilities = calculateEligibility(worker);
    final totalEarned = eligibilities.fold<int>(0, (sum, e) => sum + e.daysEarned);
    final totalTaken = worker.vacationHistory.fold<int>(0, (sum, v) => sum + v.daysTaken);
    
    return totalEarned - totalTaken;
  }

  /// Get scheduled vacation days within a specific date range
  int getVacationDaysInRange(WorkerProfile worker, DateTime start, DateTime end) {
    int count = 0;
    for (var vacation in worker.vacationHistory) {
      // Find intersection
      final intersectionStart = vacation.startDate.isAfter(start) ? vacation.startDate : start;
      final intersectionEnd = vacation.endDate.isBefore(end) ? vacation.endDate : end;

      if (intersectionStart.isBefore(intersectionEnd) || intersectionStart.isAtSameMomentAs(intersectionEnd)) {
        count += intersectionEnd.difference(intersectionStart).inDays + 1;
      }
    }
    return count;
  }
}
