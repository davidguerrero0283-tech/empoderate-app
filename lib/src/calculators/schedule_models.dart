import 'package:uuid/uuid.dart';

class ShiftSlot {
  final String id;
  final String name; // e.g., "Apertura", "Rush Almuerzo", "Cierre"
  final DateTime startTime; // Only time part matters for template
  final DateTime endTime;
  final bool isRush;

  ShiftSlot({
    String? id,
    required this.name,
    required this.startTime,
    required this.endTime,
    this.isRush = false,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'startTime': startTime.toIso8601String(),
    'endTime': endTime.toIso8601String(),
    'isRush': isRush,
  };

  factory ShiftSlot.fromJson(Map<String, dynamic> json) => ShiftSlot(
    id: json['id'],
    name: json['name'],
    startTime: DateTime.parse(json['startTime']),
    endTime: DateTime.parse(json['endTime']),
    isRush: json['isRush'] ?? false,
  );
}

class DailyDemand {
  final int dayOfWeek; // 1-7 (Monday-Sunday)
  final List<SlotRequirement> requirements;

  DailyDemand({required this.dayOfWeek, required this.requirements});

  Map<String, dynamic> toJson() => {
    'dayOfWeek': dayOfWeek,
    'requirements': requirements.map((e) => e.toJson()).toList(),
  };

  factory DailyDemand.fromJson(Map<String, dynamic> json) => DailyDemand(
    dayOfWeek: json['dayOfWeek'],
    requirements: (json['requirements'] as List).map((e) => SlotRequirement.fromJson(e)).toList(),
  );
}

class SlotRequirement {
  final String slotId;
  final int employeeCount;

  SlotRequirement({required this.slotId, required this.employeeCount});

  Map<String, dynamic> toJson() => {
    'slotId': slotId,
    'employeeCount': employeeCount,
  };

  factory SlotRequirement.fromJson(Map<String, dynamic> json) => SlotRequirement(
    slotId: json['slotId'],
    employeeCount: json['employeeCount'],
  );
}

class ScheduleTemplate {
  final String id;
  final String name; // e.g., "Temporada Alta - Diciembre", "Estandar"
  final List<ShiftSlot> availableSlots;
  final List<DailyDemand> weeklyDemand;
  final int minDaysOffPerWeek;
  final String? department;

  ScheduleTemplate({
    String? id,
    required this.name,
    required this.availableSlots,
    required this.weeklyDemand,
    this.minDaysOffPerWeek = 1,
    this.department,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'availableSlots': availableSlots.map((e) => e.toJson()).toList(),
    'weeklyDemand': weeklyDemand.map((e) => e.toJson()).toList(),
    'minDaysOffPerWeek': minDaysOffPerWeek,
    'department': department,
  };

  factory ScheduleTemplate.fromJson(Map<String, dynamic> json) => ScheduleTemplate(
    id: json['id'],
    name: json['name'],
    availableSlots: (json['availableSlots'] as List).map((e) => ShiftSlot.fromJson(e)).toList(),
    weeklyDemand: (json['weeklyDemand'] as List).map((e) => DailyDemand.fromJson(e)).toList(),
    minDaysOffPerWeek: json['minDaysOffPerWeek'] ?? 1,
    department: json['department'],
  );
}

class WorkerAssignment {
  final String workerId;
  final String workerName;
  final DateTime date;
  final String? slotId; // null if day off
  final bool isVacation;

  WorkerAssignment({
    required this.workerId,
    required this.workerName,
    required this.date,
    this.slotId,
    this.isVacation = false,
  });

  Map<String, dynamic> toJson() => {
    'workerId': workerId,
    'workerName': workerName,
    'date': date.toIso8601String(),
    'slotId': slotId,
    'isVacation': isVacation,
  };

  factory WorkerAssignment.fromJson(Map<String, dynamic> json) => WorkerAssignment(
    workerId: json['workerId'],
    workerName: json['workerName'],
    date: DateTime.parse(json['date']),
    slotId: json['slotId'],
    isVacation: json['isVacation'] ?? false,
  );
}

class WeeklySchedule {
  final String id;
  final String? templateId;
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final List<WorkerAssignment> assignments;
  final String? department;
  final List<ShiftChangeLog>? logs;

  WeeklySchedule({
    String? id,
    this.templateId,
    this.name = 'Horario General',
    required this.startDate,
    required this.endDate,
    required this.assignments,
    this.department,
    this.logs,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() => {
    'id': id,
    'templateId': templateId,
    'name': name,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate.toIso8601String(),
    'assignments': assignments.map((e) => e.toJson()).toList(),
    'department': department,
    'logs': logs?.map((e) => e.toJson()).toList(),
  };

  factory WeeklySchedule.fromJson(Map<String, dynamic> json) => WeeklySchedule(
    id: json['id'],
    templateId: json['templateId'],
    name: json['name'] ?? 'Horario General',
    startDate: DateTime.parse(json['startDate']),
    endDate: DateTime.parse(json['endDate']),
    assignments: (json['assignments'] as List).map((e) => WorkerAssignment.fromJson(e)).toList(),
    department: json['department'],
    logs: json['logs'] != null ? (json['logs'] as List).map((e) => ShiftChangeLog.fromJson(e)).toList() : [],
  );
}


/// Types of shift change requests
/// Based on Panama Labor Code requirements
enum ChangeType { 
  swapShift,      // Intercambio de turno
  coverShift,     // Cobertura de turno
  permission,     // Permiso (cita médica, asunto personal)
  daySwap,        // Cambio de día
  sickLeave,      // Incapacidad temporal
  maternityLeave, // Licencia maternidad Art 107: 14 semanas (6 pre + 8 post)
  paternityLeave, // Licencia paternidad: 3 días
  lactancia,      // Lactancia Art 114: 15min cada 3h o 2x30min
  bereavement,    // Duelo (fallecimiento familiar)
  vacation,       // Vacaciones
  medicalFollow,  // Seguimiento médico (chequeos embarazo)
}

class ShiftChangeLog {
  final String id;
  final ChangeType type;
  final String requesterId;
  final String requesterName;
  final String? targetId;
  final String? targetName;
  final DateTime date;          // Fecha inicio
  final DateTime? endDate;      // Fecha fin (para rangos: incapacidad, maternidad, etc.)
  final String? originalSlotId; // Turno original (para intercambios)
  final String? newSlotId;      // Nuevo turno (para intercambios)
  final String reason;
  final DateTime timestamp;

  ShiftChangeLog({
    String? id,
    required this.type,
    required this.requesterId,
    required this.requesterName,
    this.targetId,
    this.targetName,
    required this.date,
    this.endDate,
    this.originalSlotId,
    this.newSlotId,
    required this.reason,
    DateTime? timestamp,
  }) : id = id ?? const Uuid().v4(), timestamp = timestamp ?? DateTime.now();

  /// Get duration in days (for multi-day leaves)
  int get durationDays {
    if (endDate == null) return 1;
    return endDate!.difference(date).inDays + 1;
  }

  /// Get preset durations for specific leave types (Panama labor code)
  static int getDefaultDuration(ChangeType type) {
    switch (type) {
      case ChangeType.maternityLeave: return 98; // 14 weeks (Art 107)
      case ChangeType.paternityLeave: return 3;  // 3 days
      case ChangeType.bereavement: return 3;     // Up to 3 days
      default: return 1;
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.toString(),
    'requesterId': requesterId,
    'requesterName': requesterName,
    'targetId': targetId,
    'targetName': targetName,
    'date': date.toIso8601String(),
    'endDate': endDate?.toIso8601String(),
    'originalSlotId': originalSlotId,
    'newSlotId': newSlotId,
    'reason': reason,
    'timestamp': timestamp.toIso8601String(),
  };

  factory ShiftChangeLog.fromJson(Map<String, dynamic> json) => ShiftChangeLog(
    id: json['id'],
    type: ChangeType.values.firstWhere((e) => e.toString() == json['type'], orElse: () => ChangeType.permission),
    requesterId: json['requesterId'],
    requesterName: json['requesterName'],
    targetId: json['targetId'],
    targetName: json['targetName'],
    date: DateTime.parse(json['date']),
    endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
    originalSlotId: json['originalSlotId'],
    newSlotId: json['newSlotId'],
    reason: json['reason'],
    timestamp: DateTime.parse(json['timestamp']),
  );
}

