
class PayrollObligation {
  final String id;
  final String title;
  final String? description;
  final DateTime? dueDate;
  final bool isDone;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const PayrollObligation({
    required this.id,
    required this.title,
    this.description,
    this.dueDate,
    this.isDone = false,
    required this.createdAt,
    this.updatedAt,
  });

  PayrollObligation copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    bool? isDone,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PayrollObligation(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      isDone: isDone ?? this.isDone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate?.toIso8601String(),
      'isDone': isDone,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory PayrollObligation.fromJson(Map<String, dynamic> json) {
    return PayrollObligation(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      isDone: json['isDone'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }
}
