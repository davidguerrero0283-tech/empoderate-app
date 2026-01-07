import 'dart:convert';

// --- MODELS ---

class HrObligationCatalog {
  final String id;
  final String title;
  final String description; // Optional explanation
  final String frequency; // 'monthly', 'quarterly', 'annual', 'event'
  final String? dueRule; // e.g. "Day 15", "By March 31"
  final String category; // 'planilla', 'seguridad_social', 'contratos', 'pagos', 'reportes', 'otros'
  final String priority; // 'alta', 'media', 'baja'
  final bool active;
  final String responsible; // e.g. 'Contador', 'RRHH', 'Dueño'

  HrObligationCatalog({
    required this.id,
    required this.title,
    this.description = '',
    required this.frequency,
    this.dueRule,
    required this.category,
    required this.priority,
    this.active = true,
    this.responsible = 'RRHH',
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'frequency': frequency,
    'dueRule': dueRule,
    'category': category,
    'priority': priority,
    'active': active,
    'responsible': responsible,
  };

  factory HrObligationCatalog.fromJson(Map<String, dynamic> json) {
    return HrObligationCatalog(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      frequency: json['frequency'],
      dueRule: json['dueRule'],
      category: json['category'],
      priority: json['priority'],
      active: json['active'] ?? true,
      responsible: json['responsible'] ?? 'RRHH',
    );
  }
}

class HrComplianceRecord {
  final String id;
  final String obligationId;
  final int periodYear;
  final int? periodMonth; // 1-12, null if annual
  
  String status; // 'pending', 'completed', 'overdue', 'skipped'
  DateTime? completedAt;
  String? evidenceNote; 
  // For simplicity MVP: we won't implement full file upload logic here yet, just a note or "true/false" for evidence presence
  // But let's keep a placeholder for file paths if needed later.
  List<String> evidencePaths; 

  HrComplianceRecord({
    required this.id,
    required this.obligationId,
    required this.periodYear,
    this.periodMonth,
    this.status = 'pending',
    this.completedAt,
    this.evidenceNote,
    this.evidencePaths = const [],
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'obligationId': obligationId,
    'periodYear': periodYear,
    'periodMonth': periodMonth,
    'status': status,
    'completedAt': completedAt?.toIso8601String(),
    'evidenceNote': evidenceNote,
    'evidencePaths': evidencePaths,
  };

  factory HrComplianceRecord.fromJson(Map<String, dynamic> json) {
    return HrComplianceRecord(
      id: json['id'],
      obligationId: json['obligationId'],
      periodYear: json['periodYear'],
      periodMonth: json['periodMonth'],
      status: json['status'],
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
      evidenceNote: json['evidenceNote'],
      evidencePaths: List<String>.from(json['evidencePaths'] ?? []),
    );
  }
}
