import 'package:intl/intl.dart';

/// Registro de vacaciones tomadas o pagadas por un empleado
class VacationRecord {
  final String id;
  final DateTime startDate;
  final DateTime endDate;
  final int daysTaken;
  final double amountPaid; // Si se pagó en lugar de tomar
  final bool isPaid; // true si se pagó, false si se tomó
  final String notes; // Notas adicionales
  final DateTime createdAt;

  VacationRecord({
    required this.id,
    required this.startDate,
    required this.endDate,
    required this.daysTaken,
    this.amountPaid = 0,
    this.isPaid = false,
    this.notes = '',
    required this.createdAt,
  });

  // Duración en días
  int get duration => endDate.difference(startDate).inDays + 1;

  Map<String, dynamic> toJson() => {
    'id': id,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate.toIso8601String(),
    'daysTaken': daysTaken,
    'amountPaid': amountPaid,
    'isPaid': isPaid,
    'notes': notes,
    'createdAt': createdAt.toIso8601String(),
  };

  factory VacationRecord.fromJson(Map<String, dynamic> json) => VacationRecord(
    id: json['id'] as String,
    startDate: DateTime.parse(json['startDate'] as String),
    endDate: DateTime.parse(json['endDate'] as String),
    daysTaken: json['daysTaken'] as int,
    amountPaid: (json['amountPaid'] ?? 0).toDouble(),
    isPaid: json['isPaid'] as bool? ?? false,
    notes: json['notes'] as String? ?? '',
    createdAt: DateTime.parse(json['createdAt'] as String),
  );

  String get periodLabel {
    final fmt = DateFormat('dd/MM/yyyy');
    return '${fmt.format(startDate)} - ${fmt.format(endDate)}';
  }
}

/// Resultado del cálculo de vacaciones
class VacationResult {
  final double monthlySalary;
  final double dailySalary;
  final int days;
  final double basePay;
  final double decimoProporcional;
  final double totalPay;
  
  VacationResult({
    required this.monthlySalary,
    required this.dailySalary,
    required this.days,
    required this.basePay,
    required this.decimoProporcional,
    required this.totalPay,
  });
}

// ============================================================================
// MODELOS LEGALES (Art. 54 Código de Trabajo de Panamá)
// ============================================================================

/// Entrada para cálculo legal de vacaciones
class VacationCalculationInput {
  final DateTime serviceStartDate;
  final DateTime serviceEndDate;
  final String payrollFrequency; // 'monthly', 'biweekly', 'weekly', 'daily', 'hourly'
  final double lastBaseSalary;
  final bool hasVariableComponents;
  final List<double> last11MonthsOrdinary;
  final List<double> last11MonthsExtraordinary;
  final int ordinaryWorkdaysLast11Months;
  
  VacationCalculationInput({
    required this.serviceStartDate,
    required this.serviceEndDate,
    required this.payrollFrequency,
    required this.lastBaseSalary,
    this.hasVariableComponents = false,
    this.last11MonthsOrdinary = const [],
    this.last11MonthsExtraordinary = const [],
    this.ordinaryWorkdaysLast11Months = 0,
  });
}

/// Resultado de cálculo legal de vacaciones
class LegalVacationResult {
  final double daysAccrued;
  final double vacationPay;
  final String calculationMethod;
  final DateTime calculatedAt;
  
  LegalVacationResult({
    required this.daysAccrued,
    required this.vacationPay,
    required this.calculationMethod,
    DateTime? calculatedAt,
  }) : calculatedAt = calculatedAt ?? DateTime.now();
  
  Map<String, dynamic> toJson() => {
    'daysAccrued': daysAccrued,
    'vacationPay': vacationPay,
    'calculationMethod': calculationMethod,
    'calculatedAt': calculatedAt.toIso8601String(),
  };
}
