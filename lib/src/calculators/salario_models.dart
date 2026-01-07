import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import '../features/payroll/domain/payroll_record.dart'; // Import new domain
import 'pa_recargo_rules.dart';
import 'liquidacion_models.dart'; // For SalaryHistoryEntry
import 'vacation_models.dart'; // For VacationRecord
import 'decimo_models.dart'; // For DecimoRecord
import 'shift_models.dart'; // For WorkPeriod

enum PayrollFrequency {
  mensual,
  quincenal,
  semanal,
}

enum WorkerContractType {
  indefinido,
  definido,
  obraDeterminada,
}

enum PaymentType {
  base,    // Salario base fijo (mensual/quincenal)
  hourly,  // Por hora (calculado según horas trabajadas)
}

// Panama Labor Law - Work Shift Types
enum JornadaTipo {
  diurna,    // 8 hours/day - Divisor: 208
  mixta,     // 7.5 hours/day - Divisor: 195
  nocturna,  // 7 hours/day - Divisor: 182
}

// Panama Labor Law - Payment Types
enum TipoPago {
  regular,           // Regular salary: CSS 9.75%, SE 1.25%
  decimoTercerMes,   // XIII month: CSS 7.25%, SE 0%
  vacaciones,        // Vacations: CSS 9.75%, SE 1.25%
}

class SalarioInputModel {
  // General
  String workerName;
  String position;
  String companyName;
  DateTime periodStart;
  DateTime periodEnd;

  double baseSalary;
  PayrollFrequency frequency;
  double workHoursPerDay; 
  
  // Panama Labor Law - NEW FIELDS
  JornadaTipo jornadaTipo;  // Work shift type (affects hourly rate divisor)
  TipoPago tipoPago;        // Payment type (affects CSS/SE rates)
  
  // --- HORAS ORDINARIAS (Con Equivalencias) ---
  DiaTipo diaTipo; // Normal, Domingo, o Fiesta
  
  double horasDiurnasOrd;    // Jornada 8h
  double horasMixtasOrd;     // Jornada 7.5h -> equiv 8h
  double horasNocturnasOrd;  // Jornada 7h -> equiv 8h

  // --- HORAS EXTRAS (Recargos Art. 33 + Art. 50) ---
  double horasExtraDiurna;          // +25%
  double horasExtraNocturna;        // +50%
  double horasExtraMixtaNocturna;   // +75% (Prolongación)

  // Additional Income
  double commissions;
  double bonuses;
  double otherIncome;
  
  // Direct Amount Inputs (Optional overrides instead of hours)
  double sundayAmount;
  double holidayAmount;
  double nightSurchargeAmount;
  

  // Manual Deductions
  double otherDeductions;
  
  // Conditional fields for specific payment types (UI only)
  int mesesDecimo;         // Months worked (for XIII calculation display)
  double acumuladoVacaciones;  // Accumulated income (for Vacation calculation display)
  
  // Vacation integration
  int vacationDays; 
  double vacationAmount;
  
  // Salary History for tracking and analysis
  List<SalaryHistoryEntry> salaryHistory;

  SalarioInputModel({
    this.workerName = '',
    this.position = '',
    this.companyName = '',
    DateTime? periodStart,
    DateTime? periodEnd,
    this.baseSalary = 0.0,
    this.frequency = PayrollFrequency.quincenal,
    this.workHoursPerDay = 8,
    
    // Panama Law defaults
    this.jornadaTipo = JornadaTipo.diurna,
    this.tipoPago = TipoPago.regular,
    
    this.diaTipo = DiaTipo.normal,
    this.horasDiurnasOrd = 0.0,
    this.horasMixtasOrd = 0.0,
    this.horasNocturnasOrd = 0.0,
    
    this.horasExtraDiurna = 0.0,
    this.horasExtraNocturna = 0.0,
    this.horasExtraMixtaNocturna = 0.0,

    this.commissions = 0.0,
    this.bonuses = 0.0,
    this.otherIncome = 0.0,
    this.sundayAmount = 0.0,
    this.holidayAmount = 0.0,
    this.nightSurchargeAmount = 0.0,
    this.otherDeductions = 0.0,
    
    // Conditional fields
    this.mesesDecimo = 0,
    this.acumuladoVacaciones = 0.0,
    this.vacationDays = 0,
    this.vacationAmount = 0.0,
    
    // Salary history
    List<SalaryHistoryEntry>? salaryHistory,
    this.customDeductions = const [],
  }) : 
    periodStart = periodStart ?? DateTime.now(),
    periodEnd = periodEnd ?? DateTime.now(),
    salaryHistory = salaryHistory ?? [];

  // Custom Deductions (Full list for persistence)
  List<Map<String, dynamic>> customDeductions;

  double get hourlyRate {
    // Panama Law: Divisor depends on work shift type (Art. 30-31)
    double divisor;
    if (jornadaTipo == JornadaTipo.diurna) {
      divisor = 208.0; // 8 hours/day
    } else if (jornadaTipo == JornadaTipo.mixta) {
      divisor = 195.0; // 7.5 hours/day
    } else {
      divisor = 182.0; // 7 hours/day (nocturna)
    }
    return baseSalary / divisor;
  }

  // Calculate total from salary history
  double get totalHistoricalEarnings {
    return salaryHistory
        .where((e) => e.includedInCalculation)
        .fold(0.0, (sum, entry) => sum + entry.amount);
  }

  Map<String, dynamic> toJson() => {
    'workerName': workerName,
    'position': position,
    'companyName': companyName,
    'periodStart': periodStart.toIso8601String(),
    'periodEnd': periodEnd.toIso8601String(),
    'baseSalary': baseSalary,
    'frequency': frequency.index,
    'workHoursPerDay': workHoursPerDay,
    'jornadaTipo': jornadaTipo.index,
    'tipoPago': tipoPago.index,
    'diaTipo': diaTipo.index,
    'horasDiurnasOrd': horasDiurnasOrd,
    'horasMixtasOrd': horasMixtasOrd,
    'horasNocturnasOrd': horasNocturnasOrd,
    'horasExtraDiurna': horasExtraDiurna,
    'horasExtraNocturna': horasExtraNocturna,
    'horasExtraMixtaNocturna': horasExtraMixtaNocturna,
    'commissions': commissions,
    'bonuses': bonuses,
    'otherIncome': otherIncome,
    'otherDeductions': otherDeductions,
    'mesesDecimo': mesesDecimo,
    'acumuladoVacaciones': acumuladoVacaciones,
    'vacationDays': vacationDays,
    'vacationAmount': vacationAmount,
    'customDeductions': customDeductions,
  };

  factory SalarioInputModel.fromJson(Map<String, dynamic> json) {
    return SalarioInputModel(
      workerName: json['workerName'] ?? '',
      position: json['position'] ?? '',
      companyName: json['companyName'] ?? '',
      periodStart: DateTime.parse(json['periodStart']),
      periodEnd: DateTime.parse(json['periodEnd']),
      baseSalary: (json['baseSalary'] as num).toDouble(),
      frequency: PayrollFrequency.values[json['frequency'] ?? 0],
      workHoursPerDay: (json['workHoursPerDay'] as num).toDouble(),
      jornadaTipo: JornadaTipo.values[json['jornadaTipo'] ?? 0],
      tipoPago: TipoPago.values[json['tipoPago'] ?? 0],
      diaTipo: DiaTipo.values[json['diaTipo'] ?? 0],
      horasDiurnasOrd: (json['horasDiurnasOrd'] as num).toDouble(),
      horasMixtasOrd: (json['horasMixtasOrd'] as num).toDouble(),
      horasNocturnasOrd: (json['horasNocturnasOrd'] as num).toDouble(),
      horasExtraDiurna: (json['horasExtraDiurna'] as num).toDouble(),
      horasExtraNocturna: (json['horasExtraNocturna'] as num).toDouble(),
      horasExtraMixtaNocturna: (json['horasExtraMixtaNocturna'] as num?)?.toDouble() ?? 0.0,
      commissions: (json['commissions'] as num).toDouble(),
      bonuses: (json['bonuses'] as num).toDouble(),
      otherIncome: (json['otherIncome'] as num).toDouble(),
      otherDeductions: (json['otherDeductions'] as num).toDouble(),
      mesesDecimo: (json['mesesDecimo'] as num?)?.toInt() ?? 0,
      acumuladoVacaciones: (json['acumuladoVacaciones'] as num?)?.toDouble() ?? 0.0,
      vacationDays: (json['vacationDays'] as num?)?.toInt() ?? 0,
      vacationAmount: (json['vacationAmount'] as num?)?.toDouble() ?? 0.0,
      customDeductions: List<Map<String, dynamic>>.from(json['customDeductions'] ?? []),
    );
  }
}

class SalarioResultModel {
  // Income Breakdown
  final double baseIncome; // Salario 'Base' contractual del periodo
  
  // New: Specific Breakdown
  final double pagoOrdinario; // Incluye recargos de domingo/fiesta en horas normales
  final double pagoExtras;    // Suma de extras
  
  // Breakdown Maps for Display
  final Map<String, dynamic> factoresAplicados; // Snapshots of applied multipliers

  // Legacy/Detailed Fields for UI
  final double overtimeDaytimeAmount;
  final double overtimeNightAmount;
  final double overtimeMixedAmount;
  final double sundayAmount;
  final double holidayAmount;
  final double nightSurchargeAmount;
  
  final double commissionsAmount;
  final double bonusesAmount;
  final double otherIncomeAmount;
  
  final double totalDevengado;

  // Deductions (Employee)
  final double css; // 9.75%
  final double se;  // 1.25%
  final double isr;
  final double otherDeductions;
  
  final double totalDeducciones;
  final double netSalary;

  // Employer Costs
  final double ssPatrono; // 12.25%
  final double sePatrono; // 1.50%
  final double riesgos;   // 2.10%
  final double costoTotalEmpresa;

  // Provisions (Optional/Estimated)
  final double decimoTercerMes;
  final double vacaciones;
  final double primaAntiguedad;
  final double totalPrestaciones;
  final double vacationPayment; // Actual amount paid in this period

  // Intermediate values for debugging/display
  final double rentaNetaGravable;

  // New: List of custom deductions applied
  final List<Map<String, dynamic>> customDeductions;

  SalarioResultModel({
    required this.baseIncome,
    required this.pagoOrdinario,
    required this.pagoExtras,
    required this.factoresAplicados,
    required this.overtimeDaytimeAmount,
    required this.overtimeNightAmount,
    required this.overtimeMixedAmount,
    required this.commissionsAmount,
    required this.bonusesAmount,
    this.otherIncomeAmount = 0.0,
    required this.totalDevengado,
    required this.css,
    required this.se,
    required this.isr,
    required this.otherDeductions,
    required this.totalDeducciones,
    required this.netSalary,
    required this.ssPatrono,
    required this.sePatrono,
    required this.riesgos,
    required this.costoTotalEmpresa,
    required this.decimoTercerMes,
    required this.vacaciones,
    required this.primaAntiguedad,
    required this.totalPrestaciones,
    this.vacationPayment = 0.0,
    required this.rentaNetaGravable,
    this.customDeductions = const [],
    this.sundayAmount = 0.0,
    this.holidayAmount = 0.0,
    this.nightSurchargeAmount = 0.0,
  });

  Map<String, dynamic> toJson() => {
    'baseIncome': baseIncome,
    'pagoOrdinario': pagoOrdinario,
    'pagoExtras': pagoExtras,
    'factoresAplicados': factoresAplicados,
    'overtimeDaytimeAmount': overtimeDaytimeAmount,
    'overtimeNightAmount': overtimeNightAmount,
    'overtimeMixedAmount': overtimeMixedAmount,
    'sundayAmount': sundayAmount,
    'holidayAmount': holidayAmount,
    'nightSurchargeAmount': nightSurchargeAmount,
    'commissionsAmount': commissionsAmount,
    'bonusesAmount': bonusesAmount,
    'otherIncomeAmount': otherIncomeAmount,
    'totalDevengado': totalDevengado,
    'css': css,
    'se': se,
    'isr': isr,
    'otherDeductions': otherDeductions,
    'totalDeducciones': totalDeducciones,
    'netSalary': netSalary,
    'ssPatrono': ssPatrono,
    'sePatrono': sePatrono,
    'riesgos': riesgos,
    'costoTotalEmpresa': costoTotalEmpresa,
    'decimoTercerMes': decimoTercerMes,
    'vacaciones': vacaciones,
    'primaAntiguedad': primaAntiguedad,
    'totalPrestaciones': totalPrestaciones,
    'vacationPayment': vacationPayment,
    'rentaNetaGravable': rentaNetaGravable,
    'customDeductions': customDeductions,
  };

  factory SalarioResultModel.fromJson(Map<String, dynamic> json) {
    return SalarioResultModel(
      baseIncome: (json['baseIncome'] as num).toDouble(),
      pagoOrdinario: (json['pagoOrdinario'] as num).toDouble(),
      pagoExtras: (json['pagoExtras'] as num).toDouble(),
      factoresAplicados: json['factoresAplicados'] ?? {},
      overtimeDaytimeAmount: (json['overtimeDaytimeAmount'] as num).toDouble(),
      overtimeNightAmount: (json['overtimeNightAmount'] as num).toDouble(),
      overtimeMixedAmount: (json['overtimeMixedAmount'] as num?)?.toDouble() ?? 0.0,
      sundayAmount: (json['sundayAmount'] as num).toDouble(),
      holidayAmount: (json['holidayAmount'] as num).toDouble(),
      nightSurchargeAmount: (json['nightSurchargeAmount'] as num).toDouble(),
      commissionsAmount: (json['commissionsAmount'] as num).toDouble(),
      bonusesAmount: (json['bonusesAmount'] as num).toDouble(),
      otherIncomeAmount: (json['otherIncomeAmount'] as num?)?.toDouble() ?? 0.0,
      totalDevengado: (json['totalDevengado'] as num).toDouble(),
      css: (json['css'] as num).toDouble(),
      se: (json['se'] as num).toDouble(),
      isr: (json['isr'] as num).toDouble(),
      otherDeductions: (json['otherDeductions'] as num).toDouble(),
      totalDeducciones: (json['totalDeducciones'] as num).toDouble(),
      netSalary: (json['netSalary'] as num).toDouble(),
      ssPatrono: (json['ssPatrono'] as num).toDouble(),
      sePatrono: (json['sePatrono'] as num).toDouble(),
      riesgos: (json['riesgos'] as num).toDouble(),
      costoTotalEmpresa: (json['costoTotalEmpresa'] as num).toDouble(),
      decimoTercerMes: (json['decimoTercerMes'] as num).toDouble(),
      vacaciones: (json['vacaciones'] as num).toDouble(),
      primaAntiguedad: (json['primaAntiguedad'] as num).toDouble(),
      totalPrestaciones: (json['totalPrestaciones'] as num).toDouble(),
      vacationPayment: (json['vacationPayment'] as num?)?.toDouble() ?? 0.0,
      rentaNetaGravable: (json['rentaNetaGravable'] as num).toDouble(),
    );
  }
}

class WorkerProfile {
  final String id;
  final String name;
  final String position;
  final String department;
  final PayrollFrequency paymentMode;
  final PaymentType paymentType;      // NUEVO: Base o Por Hora
  final double basePayment;
  final double? hourlyRate;  // Salario por hora (opcional)
  // Enhanced Fields (V1.5)
  String? cedula;
  DateTime? startDate;
  WorkerContractType contractType;
  String? notes;
  DateTime? contractEnd;
  
  // Last calculation snapshot
  double? lastCalcTotal;
  DateTime? lastCalcDate;
  
  // History of saved payrolls (New Feature v2)
  List<PayrollRecord> payrollHistory;
  
  // New History Features (v3) - Vacation & Decimo Tracking
  List<VacationRecord> vacationHistory;
  List<DecimoRecord> decimoHistory;
  List<WorkPeriod> shiftPeriods;
  
  // Legacy History (Deprecated but kept for now)
  // List<PayrollHistoryRecord> history;

  WorkerProfile({
    required this.id,
    required this.name,
    required this.position,
    required this.department,
    required this.paymentMode,
    this.paymentType = PaymentType.base,  // Default: Base
    required this.basePayment,
    this.hourlyRate,
    this.cedula,
    this.startDate,
    this.contractType = WorkerContractType.indefinido,
    this.contractEnd,
    this.notes,
    this.lastCalcTotal,
    this.lastCalcDate,
    this.payrollHistory = const [],
    this.vacationHistory = const [],
    this.decimoHistory = const [],
    this.shiftPeriods = const [],
  });

  WorkerProfile copyWith({
    String? id,
    String? name,
    String? position,
    String? department,
    PayrollFrequency? paymentMode,
    PaymentType? paymentType,
    double? basePayment,
    double? hourlyRate,
    String? cedula,
    DateTime? startDate,
    WorkerContractType? contractType,
    DateTime? contractEnd,
    String? notes,
    double? lastCalcTotal,
    DateTime? lastCalcDate,
    List<PayrollRecord>? payrollHistory,
    List<VacationRecord>? vacationHistory,
    List<DecimoRecord>? decimoHistory,
    List<WorkPeriod>? shiftPeriods,
  }) {
    return WorkerProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      position: position ?? this.position,
      department: department ?? this.department,
      paymentMode: paymentMode ?? this.paymentMode,
      paymentType: paymentType ?? this.paymentType,
      basePayment: basePayment ?? this.basePayment,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      cedula: cedula ?? this.cedula,
      startDate: startDate ?? this.startDate,
      contractType: contractType ?? this.contractType,
      contractEnd: contractEnd ?? this.contractEnd,
      notes: notes ?? this.notes,
      lastCalcTotal: lastCalcTotal ?? this.lastCalcTotal,
      lastCalcDate: lastCalcDate ?? this.lastCalcDate,
      payrollHistory: payrollHistory ?? this.payrollHistory,
      vacationHistory: vacationHistory ?? this.vacationHistory,
      decimoHistory: decimoHistory ?? this.decimoHistory,
      shiftPeriods: shiftPeriods ?? this.shiftPeriods,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'position': position,
    'department': department,
    'paymentMode': paymentMode.index,
    'paymentType': paymentType.index,
    'basePayment': basePayment,
    'hourlyRate': hourlyRate,
    'cedula': cedula,
    'startDate': startDate?.toIso8601String(),
    'contractType': contractType.index,
    'contractEnd': contractEnd?.toIso8601String(),
    'notes': notes,
    'lastCalcTotal': lastCalcTotal,
    'lastCalcDate': lastCalcDate?.toIso8601String(),
    'payrollHistory': payrollHistory.map((e) => e.toJson()).toList(),
    'vacationHistory': vacationHistory.map((e) => e.toJson()).toList(),
    'decimoHistory': decimoHistory.map((e) => e.toJson()).toList(),
    'shiftPeriods': shiftPeriods.map((e) => e.toJson()).toList(),
  };

  factory WorkerProfile.fromJson(Map<String, dynamic> json) {
    var payrollHistoryList = <PayrollRecord>[];
    if (json['payrollHistory'] != null) {
      payrollHistoryList = (json['payrollHistory'] as List).map((e) => PayrollRecord.fromJson(e)).toList();
    } else if (json['history'] != null) {
       // Migration Strategy: If 'history' exists but 'payrollHistory' doesn't, we could try to migrate
       // But 'PayrollHistoryRecord' might lack full snapshots in older versions. 
       // For now, we just start fresh or leave empty, or map what we can.
       // Let's keep it empty to avoid data corruption of partial records.
    }
    
    // Load vacation history
    var vacationHistoryList = <VacationRecord>[];
    if (json['vacationHistory'] != null) {
      vacationHistoryList = (json['vacationHistory'] as List)
        .map((e) => VacationRecord.fromJson(e))
        .toList();
    }
    
    // Load decimo history
    var decimoHistoryList = <DecimoRecord>[];
    if (json['decimoHistory'] != null) {
      decimoHistoryList = (json['decimoHistory'] as List)
        .map((e) => DecimoRecord.fromJson(e))
        .toList();
    }

    // Load shift periods
    var shiftPeriodsList = <WorkPeriod>[];
    if (json['shiftPeriods'] != null) {
      shiftPeriodsList = (json['shiftPeriods'] as List)
        .map((e) => WorkPeriod.fromJson(e))
        .toList();
    }
  
    return WorkerProfile(
      id: json['id'],
      name: json['name'],
      position: json['position'],
      department: json['department'],
      paymentMode: PayrollFrequency.values[json['paymentMode'] ?? 0],
      paymentType: json['paymentType'] != null ? PaymentType.values[json['paymentType']] : PaymentType.base,
      basePayment: (json['basePayment'] as num).toDouble(),
      hourlyRate: json['hourlyRate'] != null ? (json['hourlyRate'] as num).toDouble() : null,
      cedula: json['cedula'],
      startDate: json['startDate'] != null ? DateTime.parse(json['startDate']) : null,
      contractType: json['contractType'] != null 
          ? WorkerContractType.values[json['contractType']] 
          : WorkerContractType.indefinido,
      contractEnd: json['contractEnd'] != null ? DateTime.parse(json['contractEnd']) : null,
      notes: json['notes'],
      lastCalcTotal: (json['lastCalcTotal'] as num?)?.toDouble(),
      lastCalcDate: json['lastCalcDate'] != null ? DateTime.parse(json['lastCalcDate']) : null,
      payrollHistory: payrollHistoryList,
      vacationHistory: vacationHistoryList,
      decimoHistory: decimoHistoryList,
      shiftPeriods: shiftPeriodsList,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkerProfile &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class PayrollHistoryRecord {
  final String id;
  final String periodId; // e.g. "2025-01"
  final DateTime date;
  final double netSalary;
  // Snapshot of critical values for Liquidación
  final double grossSalary;
  final double decimoAccumulated;
  
  // Full Snapshots for Receipt Reconstruction
  final Map<String, dynamic>? inputSnapshot;
  final Map<String, dynamic>? resultSnapshot;
  
  PayrollHistoryRecord({
    required this.id,
    required this.periodId,
    required this.date,
    required this.netSalary,
    required this.grossSalary,
    this.decimoAccumulated = 0.0,
    this.inputSnapshot,
    this.resultSnapshot,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'periodId': periodId,
    'date': date.toIso8601String(),
    'netSalary': netSalary,
    'grossSalary': grossSalary,
    'decimoAccumulated': decimoAccumulated,
    'inputSnapshot': inputSnapshot,
    'resultSnapshot': resultSnapshot,
  };

  factory PayrollHistoryRecord.fromJson(Map<String, dynamic> json) {
    return PayrollHistoryRecord(
      id: json['id'],
      periodId: json['periodId'],
      date: DateTime.parse(json['date']),
      netSalary: (json['netSalary'] as num).toDouble(),
      grossSalary: (json['grossSalary'] as num).toDouble(),
      decimoAccumulated: (json['decimoAccumulated'] as num?)?.toDouble() ?? 0.0,
      inputSnapshot: json['inputSnapshot'],
      resultSnapshot: json['resultSnapshot'],
    );
  }
}
