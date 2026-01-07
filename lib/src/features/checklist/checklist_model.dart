import 'dart:convert';

enum ChecklistCategory {
  legal,
  fiscal,
  municipal,
  laboral, // RRHH
  operativo
}

extension ChecklistCategoryExtension on ChecklistCategory {
  String get label {
    switch (this) {
      case ChecklistCategory.legal: return 'Legal / Corporativo';
      case ChecklistCategory.fiscal: return 'DGI / Fiscal';
      case ChecklistCategory.municipal: return 'Municipio / Alcaldía';
      case ChecklistCategory.laboral: return 'Laboral (CSS/Mitradel)';
      case ChecklistCategory.operativo: return 'Operativo / Permisos';
    }
  }
}

class ChecklistItem {
  final String id;
  final String title;
  final String description;
  final ChecklistCategory category;
  final String frequency; // 'Único', 'Mensual', 'Anual'
  bool isCompleted;
  final String? toolRoute; // Optional link to internal tool
  final String? rubroId; // Optional: 'restaurante', 'retail', 'servicios'

  ChecklistItem({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.frequency,
    this.isCompleted = false,
    this.toolRoute,
    this.rubroId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category.index,
      'frequency': frequency,
      'isCompleted': isCompleted,
      'toolRoute': toolRoute,
      'rubroId': rubroId,
    };
  }

  factory ChecklistItem.fromMap(Map<String, dynamic> map) {
    return ChecklistItem(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      category: ChecklistCategory.values[map['category']],
      frequency: map['frequency'],
      isCompleted: map['isCompleted'] ?? false,
      toolRoute: map['toolRoute'],
      rubroId: map['rubroId'],
    );
  }
  
  String toJson() => json.encode(toMap());
  factory ChecklistItem.fromJson(String source) => ChecklistItem.fromMap(json.decode(source));
}
