import 'package:flutter/material.dart';

enum TerminationType {
  renunciaVoluntaria,
  despidoJustificado,
  despidoInjustificado,
  mutuoAcuerdo,
  terminacionContratoDefinido, // New
  abandonoTrabajo, // New
  incapacidadProlongada, // New
  fallecimiento, // New
  otrasCausas,
}

enum MutualAgreementProposer {
  empleado,
  empresa,
  ambos,
}

enum ContractType {
  indefinido,
  definido,
}

enum PaymentFrequency {
  mensual,
  quincenal,
  semanal,
  diario,
  porHora,
}

// Salary History Entry for tracking historical earnings
class SalaryHistoryEntry {
  final int year;
  final int month; // 1-12
  double amount;
  bool includedInCalculation;
  final bool? isQuincenal; // Optional: Indicates if this is a quincenal period
  final String? periodLabel; // Optional: Original label from payroll (e.g., "1ª Enero 2025")

  SalaryHistoryEntry({
    required this.year,
    required this.month,
    this.amount = 0.0,
    this.includedInCalculation = true,
    this.isQuincenal,
    this.periodLabel,
  });

  String get monthName {
    const months = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 
                    'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
    return months[month - 1];
  }

  Map<String, dynamic> toJson() => {
    'year': year,
    'month': month,
    'amount': amount,
    'includedInCalculation': includedInCalculation,
    'isQuincenal': isQuincenal,
    'periodLabel': periodLabel,
  };

  factory SalaryHistoryEntry.fromJson(Map<String, dynamic> json) =>
      SalaryHistoryEntry(
        year: json['year'] as int,
        month: json['month'] as int,
        amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
        includedInCalculation: json['includedInCalculation'] as bool? ?? true,
        isQuincenal: json['isQuincenal'] as bool?,
        periodLabel: json['periodLabel'] as String?,
      );
}

class LiquidacionInputModel {
  // General Data
  String workerName;
  String workerId;
  String companyName;
  String? department; // New
  String? notes; // New
  String? position;
  String? companyLogoPath; // Path for local file
  String? companyLogoUrl;  // URL for remote image
  bool includeCompanyHeader; // Toggle for header
  // Extended Company Data
  String companyRuc;
  String companyAddress;
  String companyPhone;
  String companyEmail;
  String companyRep;
  String companyRepPosition;
  
  // Labor Data
  double salary; // Used as base if Monthly/Quincenal
  PaymentFrequency paymentFrequency;
  
  // Specific Rate Inputs
  double? weeklySalary;
  double? dailySalaryInput;
  double? hourlyRate;
  double? hoursPerDay;
  double? daysPerWeek;

  // Contract Info
  ContractType contractType;
  DateTime? contractEndDate; // For defined contracts

  DateTime startDate;
  DateTime endDate;
  TerminationType terminationType;
  
  // Rights
  bool hasVacationsExpired;
  int vacacionesExpiredDays;
  bool hasVacationsNotEnjoyed;
  int vacacionesNotEnjoyedDays;
  bool hasDecimoAdeudado;
  // Mutual agreement proposer (only relevant when terminationType == mutuoAcuerdo)
  MutualAgreementProposer? mutualProposer;
  
  // Extras
  double overtimeAmount;
  double unpaidHolidaysAmount;
  double pendingBonuses;
  double otherSums;
  
  // Deductions
  double loans;
  double advances;
  double otherDeductions;
  
  // New: Detailed Others
  String otherDeductionName;
  double otherDeductionAmount;
  
  // Strict Calculation Fields (Panama Law)
  double accumulatedIncomeVacations; // Base for Vacations (Earnings since last vacation)
  double accumulatedIncomeDecimo; // Base for Decimo (Earnings in current period)
  double totalHistoricEarnings; // Base for Prima Antiguedad
  
  // Internal (Legacy or fallback)
  int? accumulatedIncomeVacacionesDias; // Days for proportional calculation

  bool gavePreaviso; // New field
  
  // Salary History Log (NEW - Professional tracking)
  List<SalaryHistoryEntry> salaryHistory;

  // Deductions Configuration
  bool applyDeductions;
  bool deductFromSalarios;
  bool deductFromVacaciones;
  bool deductFromDecimo;
  bool deductFromIndemnizacion;
  bool deductFromPreaviso;
  // bool deductOnlyEducationFromDecimo; // Implicit: Decimo only pays CSS/SE, but usually 1.25% SE is always deducting. SE is mandatory. CSS depends.
  bool applyISRToIndemnizacion; // Indemnización is usually tax free up to limit, but optional check.

  LiquidacionInputModel({
    this.workerName = '',
    this.workerId = '',
    this.companyName = '',
    this.department,
    this.notes,
    this.position,
    this.companyLogoPath,
    this.companyLogoUrl,
    this.includeCompanyHeader = false,
    this.companyRuc = '',
    this.companyAddress = '',
    this.companyPhone = '',
    this.companyEmail = '',
    this.companyRep = '',
    this.companyRepPosition = '',
    this.salary = 0.0,
    this.paymentFrequency = PaymentFrequency.quincenal, // Default
    this.weeklySalary,
    this.dailySalaryInput,
    this.hourlyRate,
    this.hoursPerDay,
    this.daysPerWeek,
    this.contractType = ContractType.indefinido,
    this.contractEndDate,
    required this.startDate,
    required this.endDate,
    this.terminationType = TerminationType.renunciaVoluntaria,
    this.hasVacationsExpired = false,
    this.vacacionesExpiredDays = 0,
    this.hasVacationsNotEnjoyed = false,
    this.vacacionesNotEnjoyedDays = 0,
    this.hasDecimoAdeudado = true,
    this.mutualProposer = null,
    this.overtimeAmount = 0.0,
    this.unpaidHolidaysAmount = 0.0,
    this.pendingBonuses = 0.0,
    this.otherSums = 0.0,
    this.loans = 0.0,
    this.advances = 0.0,
    this.otherDeductions = 0.0,
    this.otherDeductionName = '',
    this.otherDeductionAmount = 0.0,
    this.accumulatedIncomeVacations = 0.0,
    this.accumulatedIncomeVacacionesDias,
    this.accumulatedIncomeDecimo = 0.0,
    this.totalHistoricEarnings = 0.0,
    this.gavePreaviso = false,
    List<SalaryHistoryEntry>? salaryHistory,
    
    // Deductions defaults
    this.applyDeductions = false,
    this.deductFromSalarios = true, // Wages always taxed
    this.deductFromVacaciones = true, // Vacations always taxed
    this.deductFromDecimo = true, // Decimo taxed (7.25% CSS + 1.25% SE usually, but we have standard toggles)
    this.deductFromIndemnizacion = false, // Usually exempt
    this.deductFromPreaviso = true, // Viewed as salary replacement, usually taxed
    this.applyISRToIndemnizacion = false,
  }) : salaryHistory = salaryHistory ?? [];

  // Helper logic to get standard base for calculations
  double get monthlySalary {
    switch (paymentFrequency) {
      case PaymentFrequency.mensual:
        return salary;
      case PaymentFrequency.quincenal:
        return salary * 2;
      case PaymentFrequency.semanal:
         // 52 weeks / 12 months = 4.3333
        return (weeklySalary ?? 0) * 4.3333;
      case PaymentFrequency.diario:
        return (dailySalaryInput ?? 0) * 30;
      case PaymentFrequency.porHora:
        // rate * hours * days * weeks/month
        double rate = hourlyRate ?? 0;
        double hours = hoursPerDay ?? 8;
        double days = daysPerWeek ?? 5; // Standard guess if not set? Or use 6. Prompt says days is input.
        return rate * hours * days * 4.3333;
    }
  }

  double get dailySalary => monthlySalary / 30;
  
  // Calculate total from checked salary history entries
  double get totalHistoricEarningsFromHistory {
    return salaryHistory
        .where((e) => e.includedInCalculation)
        .fold(0.0, (sum, entry) => sum + entry.amount);
  }
}

class LiquidacionResultModel {
  final double salarioAdeudado;
  final double vacacionesVencidas;
  final double vacacionesProporcionales;
  final double decimoProporcional;
  final double primaAntiguedad;
  final double indemnizacion;
  final double preaviso; // New field
  final double subtotalDevengos;
  final double totalDeducciones;
  final double totalPagar;
  
  // Breakdown for letter
  final int yearsWorked;
  final int monthsWorked;
  final int daysWorked;

  // Generic Totals
  final double css;
  final double se;
  final double isr;
  final double otherDeductionsDetailed;

  // Detailed Deductions (New)
  // Deduction Details
  final double cssSalario;
  final double seSalario;
  final double cssVacaciones;
  final double seVacaciones;
  final double cssDecimo;
  final double seDecimo;
  final double cssPreaviso; // New
  final double sePreaviso; // New
  final double isrPreaviso; // New

  // Advanced Details (Prompt #40)
  final String? salarioAdeudadoDetalle;
  final String? vacacionesVencidasDetalle;
  final String? vacacionesProporcionalesDetalle;

  LiquidacionResultModel({
    required this.salarioAdeudado,
    required this.vacacionesVencidas,
    required this.vacacionesProporcionales,
    required this.decimoProporcional,
    required this.primaAntiguedad,
    required this.indemnizacion,
    required this.preaviso, // New field for result
    required this.subtotalDevengos,
    required this.totalDeducciones,
    required this.totalPagar,
    required this.yearsWorked,
    required this.monthsWorked,
    required this.daysWorked,
    this.css = 0.0,
    this.se = 0.0,
    this.isr = 0.0,
    this.otherDeductionsDetailed = 0.0,
    this.cssSalario = 0.0,
    this.seSalario = 0.0,
    this.cssVacaciones = 0.0,
    this.seVacaciones = 0.0,
    this.cssDecimo = 0.0,
    this.seDecimo = 0.0,
    this.cssPreaviso = 0.0,
    this.sePreaviso = 0.0,
    this.isrPreaviso = 0.0,
    this.salarioAdeudadoDetalle,
    this.vacacionesVencidasDetalle,
    this.vacacionesProporcionalesDetalle,
    this.netoPagar = 0.0, // New: Final Net
  });
  
  final double netoPagar;
}
