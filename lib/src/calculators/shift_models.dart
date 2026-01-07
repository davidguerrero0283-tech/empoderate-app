import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

enum ShiftType {
  regular,
  extra25, // Extra Diurna
  extra50, // Extra Nocturna
  extra75, // Extra Mixta/Nocturna
  holiday, // Feriado / Día Nacional (+150%)
  sunday,  // Domingo (+50%)
}

class ShiftRecord {
  final String id;
  final DateTime date;
  final double regularHours;
  final double extraDiurna;
  final double extraNocturna;
  final double extraMixta;
  final bool isHoliday;
  final bool isSunday;
  final String notes;

  ShiftRecord({
    String? id,
    required this.date,
    this.regularHours = 0,
    this.extraDiurna = 0,
    this.extraNocturna = 0,
    this.extraMixta = 0,
    this.isHoliday = false,
    this.isSunday = false,
    this.notes = '',
  }) : this.id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date.toIso8601String(),
    'regularHours': regularHours,
    'extraDiurna': extraDiurna,
    'extraNocturna': extraNocturna,
    'extraMixta': extraMixta,
    'isHoliday': isHoliday,
    'isSunday': isSunday,
    'notes': notes,
  };

  factory ShiftRecord.fromJson(Map<String, dynamic> json) => ShiftRecord(
    id: json['id'],
    date: DateTime.parse(json['date']),
    regularHours: (json['regularHours'] ?? 0).toDouble(),
    extraDiurna: (json['extraDiurna'] ?? 0).toDouble(),
    extraNocturna: (json['extraNocturna'] ?? 0).toDouble(),
    extraMixta: (json['extraMixta'] ?? 0).toDouble(),
    isHoliday: json['isHoliday'] ?? false,
    isSunday: json['isSunday'] ?? false,
    notes: json['notes'] ?? '',
  );

  String get dayLabel => DateFormat('EEEE d MMMM yyyy').format(date);
}

class WorkPeriod {
  final String id;
  final String workerId;
  final DateTime startDate;
  final DateTime endDate;
  final List<ShiftRecord> shifts;

  WorkPeriod({
    String? id,
    required this.workerId,
    required this.startDate,
    required this.endDate,
    this.shifts = const [],
  }) : this.id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() => {
    'id': id,
    'workerId': workerId,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate.toIso8601String(),
    'shifts': shifts.map((s) => s.toJson()).toList(),
  };

  factory WorkPeriod.fromJson(Map<String, dynamic> json) => WorkPeriod(
    id: json['id'],
    workerId: json['workerId'],
    startDate: DateTime.parse(json['startDate']),
    endDate: DateTime.parse(json['endDate']),
    shifts: (json['shifts'] as List? ?? [])
        .map((s) => ShiftRecord.fromJson(s))
        .toList(),
  );

  // Totals
  double get totalRegular => shifts.fold(0, (sum, s) => sum + s.regularHours);
  double get totalExtraDiurna => shifts.fold(0, (sum, s) => sum + s.extraDiurna);
  double get totalExtraNocturna => shifts.fold(0, (sum, s) => sum + s.extraNocturna);
  double get totalExtraMixta => shifts.fold(0, (sum, s) => sum + s.extraMixta);
  
  // Specific day-based logic for payroll integration
  double get totalHolidayHours => shifts.where((s) => s.isHoliday).fold(0, (sum, s) => sum + s.regularHours);
  double get totalSundayHours => shifts.where((s) => s.isSunday).fold(0, (sum, s) => sum + s.regularHours);
}
