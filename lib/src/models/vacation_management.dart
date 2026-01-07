import 'package:flutter/material.dart';

/// Vacation status enumeration
enum VacationStatus {
  pending,    // Eligible but not approved yet
  approved,   // Approved, waiting to be taken
  taken,      // Already taken
  expired,    // Eligibility expired without being used
  cancelled,  // Cancelled after approval
}

/// Tracks eligibility for vacation based on hire date
class VacationEligibility {
  final String id;
  final DateTime eligibleDate;     // Date when employee became eligible
  final int yearOfService;         // 1st year, 2nd year, etc.
  final int daysEarned;            // Days earned (30 base + 1 every 3 years)
  final bool isApproved;
  final DateTime? approvalDate;
  final String? approvedBy;        // User ID who approved
  final VacationStatus status;
  
  const VacationEligibility({
    required this.id,
    required this.eligibleDate,
    required this.yearOfService,
    required this.daysEarned,
    required this.isApproved,
    this.approvalDate,
    this.approvedBy,
    required this.status,
  });
  
  /// Calculate days earned based on years of service
  /// Panama law: 30 days + 1 day for each 3 years worked
  static int calculateDaysEarned(int yearsOfService) {
    final baseDays = 30;
    final bonusDays = (yearsOfService / 3).floor();
    return baseDays + bonusDays;
  }
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'eligibleDate': eligibleDate.toIso8601String(),
    'yearOfService': yearOfService,
    'daysEarned': daysEarned,
    'isApproved': isApproved,
    'approvalDate': approvalDate?.toIso8601String(),
    'approvedBy': approvedBy,
    'status': status.index,
  };
  
  factory VacationEligibility.fromJson(Map<String, dynamic> json) {
    return VacationEligibility(
      id: json['id'],
      eligibleDate: DateTime.parse(json['eligibleDate']),
      yearOfService: json['yearOfService'],
      daysEarned: json['daysEarned'],
      isApproved: json['isApproved'],
      approvalDate: json['approvalDate'] != null ? DateTime.parse(json['approvalDate']) : null,
      approvedBy: json['approvedBy'],
      status: VacationStatus.values[json['status'] ?? 0],
    );
  }
}

/// Detailed vacation calculation record
class VacationCalculation {
  final String id;
  final String workerId;
  final String workerName;
  final DateTime calculationDate;
  final DateTime periodStart;
  final DateTime periodEnd;
  
  // Calculation details
  final double baseMonthlyAverage;   // Average from selected months
  final int daysToCalculate;
  final double totalAmount;
  final double dailyRate;
  
  // Payroll history used
  final List<SalaryMonth> monthsIncluded;
  final List<String> monthsExcluded;
  
  // Metadata
  final bool isApproved;
  final DateTime? approvalDate;
  final String? notes;
  
  const VacationCalculation({
    required this.id,
    required this.workerId,
    required this.workerName,
    required this.calculationDate,
    required this.periodStart,
    required this.periodEnd,
    required this.baseMonthlyAverage,
    required this.daysToCalculate,
    required this.totalAmount,
    required this.dailyRate,
    required this.monthsIncluded,
    required this.monthsExcluded,
    required this.isApproved,
    this.approvalDate,
    this.notes,
  });
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'workerId': workerId,
    'workerName': workerName,
    'calculationDate': calculationDate.toIso8601String(),
    'periodStart': periodStart.toIso8601String(),
    'periodEnd': periodEnd.toIso8601String(),
    'baseMonthlyAverage': baseMonthlyAverage,
    'daysToCalculate': daysToCalculate,
    'totalAmount': totalAmount,
    'dailyRate': dailyRate,
    'monthsIncluded': monthsIncluded.map((m) => m.toJson()).toList(),
    'monthsExcluded': monthsExcluded,
    'isApproved': isApproved,
    'approvalDate': approvalDate?.toIso8601String(),
    'notes': notes,
  };
  
  factory VacationCalculation.fromJson(Map<String, dynamic> json) {
    return VacationCalculation(
      id: json['id'],
      workerId: json['workerId'],
      workerName: json['workerName'],
      calculationDate: DateTime.parse(json['calculationDate']),
      periodStart: DateTime.parse(json['periodStart']),
      periodEnd: DateTime.parse(json['periodEnd']),
      baseMonthlyAverage: (json['baseMonthlyAverage'] as num).toDouble(),
      daysToCalculate: json['daysToCalculate'],
      totalAmount: (json['totalAmount'] as num).toDouble(),
      dailyRate: (json['dailyRate'] as num).toDouble(),
      monthsIncluded: (json['monthsIncluded'] as List)
          .map((m) => SalaryMonth.fromJson(m))
          .toList(),
      monthsExcluded: List<String>.from(json['monthsExcluded'] ?? []),
      isApproved: json['isApproved'],
      approvalDate: json['approvalDate'] != null 
          ? DateTime.parse(json['approvalDate']) 
          : null,
      notes: json['notes'],
    );
  }
}

/// Monthly salary record for vacation calculation
class SalaryMonth {
  final int year;
  final int month;
  final double grossSalary;
  final bool wasIncluded;
  final String? exclusionReason;
  
  const SalaryMonth({
    required this.year,
    required this.month,
    required this.grossSalary,
    required this.wasIncluded,
    this.exclusionReason,
  });
  
  Map<String, dynamic> toJson() => {
    'year': year,
    'month': month,
    'grossSalary': grossSalary,
    'wasIncluded': wasIncluded,
    'exclusionReason': exclusionReason,
  };
  
  factory SalaryMonth.fromJson(Map<String, dynamic> json) {
    return SalaryMonth(
      year: json['year'],
      month: json['month'],
      grossSalary: (json['grossSalary'] as num).toDouble(),
      wasIncluded: json['wasIncluded'],
      exclusionReason: json['exclusionReason'],
    );
  }
}
