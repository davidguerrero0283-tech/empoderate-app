class RutaStep {
  final int id;
  final String title;
  final String description;
  final String content;
  final String? toolRoute;
  final String? toolLabel;
  bool isCompleted;

  RutaStep({
    required this.id,
    required this.title,
    required this.description,
    required this.content,
    this.toolRoute,
    this.toolLabel,
    this.isCompleted = false,
  });
}

class RutaPhase {
  final int id;
  final String title;
  final String subtitle;
  final int color; // Store as int for Color(value)
  final List<RutaStep> steps;

  RutaPhase({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.steps,
  });

  int get completedCount => steps.where((s) => s.isCompleted).length;
  int get totalCount => steps.length;
  double get progress => totalCount > 0 ? completedCount / totalCount : 0.0;
}
