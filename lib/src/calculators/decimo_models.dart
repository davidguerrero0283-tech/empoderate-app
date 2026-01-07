import 'package:intl/intl.dart';

class DecimoResultModel {
  final double totalEarnings;
  final double decimoAmount;
  final double css; // 7.25%
  final double netDecimo;

  DecimoResultModel({
    required this.totalEarnings,
    required this.decimoAmount,
    required this.css,
    required this.netDecimo,
  });
}

/// Registro de pago de Décimo Tercer Mes
class DecimoRecord {
  final String id;
  final int year;
  final int period; // 1 = Abril, 2 = Agosto, 3 = Diciembre
  final double grossAmount; // Monto bruto
  final double ssDeduction; // Deducción de seguro social (7.25%)
  final double netAmount; // Monto neto recibido
  final DateTime paymentDate;
  final String notes; // Notas adicionales
  final DateTime createdAt;

  DecimoRecord({
    required this.id,
    required this.year,
    required this.period,
    required this.grossAmount,
    required this.ssDeduction,
    required this.netAmount,
    required this.paymentDate,
    this.notes = '',
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'year': year,
    'period': period,
    'grossAmount': grossAmount,
    'ssDeduction': ssDeduction,
    'netAmount': netAmount,
    'paymentDate': paymentDate.toIso8601String(),
    'notes': notes,
    'createdAt': createdAt.toIso8601String(),
  };

  factory DecimoRecord.fromJson(Map<String, dynamic> json) => DecimoRecord(
    id: json['id'] as String,
    year: json['year'] as int,
    period: json['period'] as int,
    grossAmount: (json['grossAmount']).toDouble(),
    ssDeduction: (json['ssDeduction']).toDouble(),
    netAmount: (json['netAmount']).toDouble(),
    paymentDate: DateTime.parse(json['paymentDate'] as String),
    notes: json['notes'] as String? ?? '',
    createdAt: DateTime.parse(json['createdAt'] as String),
  );

  String get periodLabel {
    String month;
    switch (period) {
      case 1:
        month = 'Abril';
        break;
      case 2:
        month = 'Agosto';
        break;
      case 3:
        month = 'Diciembre';
        break;
      default:
        month = 'Desconocido';
    }
    return '$month $year';
  }

  String get periodRange {
    switch (period) {
      case 1:
        return 'Ene-Abr $year';
      case 2:
        return 'May-Ago $year';
      case 3:
        return 'Sep-Dic $year';
      default:
        return 'N/A';
    }
  }
}
