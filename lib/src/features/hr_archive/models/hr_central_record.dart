import 'package:uuid/uuid.dart';

/// Tipos de registros en el archivo central de RRHH
enum HRRecordType {
  planilla,      // Pago de quincena/mes
  liquidacion,   // Liquidación laboral
  despido,       // Despido (justificado/injustificado)
  renuncia,      // Renuncia voluntaria
  vacaciones,    // Periodo de vacaciones tomadas
  permiso,       // Permisos/Licencias
  aumento,       // Aumento de salario
  contratacion,  // Nueva contratación
  otro,          // Otros eventos
}

extension HRRecordTypeX on HRRecordType {
  String get label {
    switch (this) {
      case HRRecordType.planilla: return 'Planilla';
      case HRRecordType.liquidacion: return 'Liquidación';
      case HRRecordType.despido: return 'Despido';
      case HRRecordType.renuncia: return 'Renuncia';
      case HRRecordType.vacaciones: return 'Vacaciones';
      case HRRecordType.permiso: return 'Permiso';
      case HRRecordType.aumento: return 'Aumento';
      case HRRecordType.contratacion: return 'Contratación';
      case HRRecordType.otro: return 'Otro';
    }
  }

  String get icon {
    switch (this) {
      case HRRecordType.planilla: return '💰';
      case HRRecordType.liquidacion: return '📋';
      case HRRecordType.despido: return '🚪';
      case HRRecordType.renuncia: return '👋';
      case HRRecordType.vacaciones: return '🏖️';
      case HRRecordType.permiso: return '📝';
      case HRRecordType.aumento: return '📈';
      case HRRecordType.contratacion: return '🤝';
      case HRRecordType.otro: return '📌';
    }
  }
}

/// Registro central de RRHH - representa cualquier evento laboral
class HRCentralRecord {
  final String id;
  final String workerId;
  final String workerName;
  final HRRecordType type;
  final DateTime eventDate;
  final String description;
  final double? amount;  // Monto asociado (neto, total, etc.)
  final Map<String, dynamic> data;  // Datos específicos del tipo
  final DateTime createdAt;

  HRCentralRecord({
    String? id,
    required this.workerId,
    required this.workerName,
    required this.type,
    required this.eventDate,
    required this.description,
    this.amount,
    this.data = const {},
    DateTime? createdAt,
  }) : this.id = id ?? const Uuid().v4(),
       this.createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'workerId': workerId,
    'workerName': workerName,
    'type': type.index,
    'eventDate': eventDate.toIso8601String(),
    'description': description,
    'amount': amount,
    'data': data,
    'createdAt': createdAt.toIso8601String(),
  };

  factory HRCentralRecord.fromJson(Map<String, dynamic> json) => HRCentralRecord(
    id: json['id'],
    workerId: json['workerId'],
    workerName: json['workerName'] ?? 'Desconocido',
    type: HRRecordType.values[json['type'] ?? 0],
    eventDate: DateTime.parse(json['eventDate']),
    description: json['description'] ?? '',
    amount: (json['amount'] as num?)?.toDouble(),
    data: Map<String, dynamic>.from(json['data'] ?? {}),
    createdAt: DateTime.parse(json['createdAt']),
  );

  /// Helper para mostrar en listas
  String get displayTitle => '${type.icon} ${type.label}';
  String get displayAmount => amount != null ? '\$${amount!.toStringAsFixed(2)}' : '';
}
