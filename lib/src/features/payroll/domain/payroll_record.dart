
class PayrollRecord {
  final String id;
  final String periodKey;       // "2025-01" or "2025-01-Q1"
  final String periodLabel;     // "Enero 2025" or "1ra quincena Ene 2025"
  final DateTime createdAt;
  final DateTime updatedAt;
  
  final Map<String, dynamic> inputSnapshot;   // Full inputs for editing/recalculating
  final Map<String, dynamic> resultSnapshot;  // Full results for display/receipt

  final String? notes;

  PayrollRecord({
    required this.id,
    required this.periodKey,
    required this.periodLabel,
    required this.createdAt,
    required this.updatedAt,
    required this.inputSnapshot,
    required this.resultSnapshot,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'periodKey': periodKey,
    'periodLabel': periodLabel,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'inputSnapshot': inputSnapshot,
    'resultSnapshot': resultSnapshot,
    'notes': notes,
  };

  factory PayrollRecord.fromJson(Map<String, dynamic> json) {
    return PayrollRecord(
      id: json['id'],
      periodKey: json['periodKey'],
      periodLabel: json['periodLabel'] ?? json['periodKey'], // Fallback
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      inputSnapshot: Map<String, dynamic>.from(json['inputSnapshot'] ?? {}),
      resultSnapshot: Map<String, dynamic>.from(json['resultSnapshot'] ?? {}),
      notes: json['notes'],
    );
  }
  
  // Helper to get Net Salary quickly for lists
  double get netSalary => (resultSnapshot['netSalary'] as num?)?.toDouble() ?? 0.0;
  double get grossSalary => (resultSnapshot['totalDevengado'] as num?)?.toDouble() ?? 0.0;
  double get totalDeducciones => (resultSnapshot['totalDeducciones'] as num?)?.toDouble() ?? 0.0;

  DateTime get periodStart => DateTime.parse(inputSnapshot['periodStart']);
  DateTime get periodEnd => DateTime.parse(inputSnapshot['periodEnd']);
}
