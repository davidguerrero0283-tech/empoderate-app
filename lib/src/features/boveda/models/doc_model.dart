enum DocCategory {
  legal,
  fiscal,
  rrhh,
  otros;

  String get label {
    switch (this) {
      case DocCategory.legal: return 'Legal';
      case DocCategory.fiscal: return 'Fiscal / Impuestos';
      case DocCategory.rrhh: return 'Recusos Humanos';
      case DocCategory.otros: return 'Otros';
    }
  }
}

class DocModel {
  final String id;
  final String title;
  final DocCategory category;
  final String filePath;
  final DateTime dateAdded;
  final int sizeBytes;

  DocModel({
    required this.id,
    required this.title,
    required this.category,
    required this.filePath,
    required this.dateAdded,
    required this.sizeBytes,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category.index,
      'filePath': filePath,
      'dateAdded': dateAdded.toIso8601String(),
      'sizeBytes': sizeBytes,
    };
  }

  factory DocModel.fromJson(Map<String, dynamic> json) {
    return DocModel(
      id: json['id'],
      title: json['title'],
      category: DocCategory.values[json['category'] as int],
      filePath: json['filePath'],
      dateAdded: DateTime.parse(json['dateAdded']),
      sizeBytes: json['sizeBytes'],
    );
  }

  String get sizeLabel {
    if (sizeBytes < 1024) return '$sizeBytes B';
    if (sizeBytes < 1024 * 1024) return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
    return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
