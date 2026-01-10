enum GuideQuestionType { single, multi, scale, number }

class AttributeMapping {
  final String attribute;
  final double weight;
  /// Maps option index (or scale value) to a score impact (0.0 to 1.0 or -1.0 to 1.0)
  /// For multi-select, presence of index triggers impact.
  final Map<int, double>? valueMap; 

  const AttributeMapping({
    required this.attribute,
    this.weight = 1.0,
    this.valueMap,
  });
}

class GuideQuestion {
  final int id;
  final String text;
  final GuideQuestionType type;
  final List<String>? options;
  final List<AttributeMapping> mappings;
  /// 'rapido', 'intermedio', 'avanzado'
  final String priority; 

  const GuideQuestion({
    required this.id,
    required this.text,
    required this.type,
    required this.mappings,
    this.options,
    this.priority = 'avanzado',
  });
}
