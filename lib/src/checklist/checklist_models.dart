class ChecklistCategory {
  final String id;
  final String title;
  final String description;
  final List<ChecklistTask> tasks;
  ChecklistCategory({required this.id, required this.title, required this.description, required this.tasks});
}

class ChecklistTask {
  final String id;
  final String title;
  final String description;
  final bool isMandatory;
  bool isCompleted;
  ChecklistTask({
    required this.id,
    required this.title,
    required this.description,
    this.isMandatory = false,
    this.isCompleted = false,
  });
}

class PlanAccionItem {
  final String id;
  final String title;
  final String description;
  final String categoryId;
  final int priority; // 1 = Alta, 2 = Media, 3 = Baja
  bool isCompleted;
  PlanAccionItem({
    required this.id,
    required this.title,
    required this.description,
    required this.categoryId,
    this.priority = 2,
    this.isCompleted = false,
  });
}
