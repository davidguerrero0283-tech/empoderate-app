
enum ProgressArea {
  start,
  payroll,
  accounting,
  marketing,
}

class ChecklistItem {
  final String id;
  final ProgressArea area;
  final String title;
  final bool done;
  final int order;
  final String? description;
  final String? autoRuleKey;
  final bool isOptional;
  final int priority; // 1 (low) to 5 (high)
  final String? route;
  final DateTime updatedAt;

  const ChecklistItem({
    required this.id,
    required this.area,
    required this.title,
    this.description,
    this.done = false,
    required this.order,
    this.route,
    this.autoRuleKey,
    this.isOptional = false,
    this.priority = 3,
    required this.updatedAt,
  });

  ChecklistItem copyWith({
    String? id,
    ProgressArea? area,
    String? title,
    String? description,
    bool? done,
    int? order,
    String? route,
    String? autoRuleKey,
    bool? isOptional,
    int? priority,
    DateTime? updatedAt,
  }) {
    return ChecklistItem(
      id: id ?? this.id,
      area: area ?? this.area,
      title: title ?? this.title,
      description: description ?? this.description,
      done: done ?? this.done,
      order: order ?? this.order,
      route: route ?? this.route,
      autoRuleKey: autoRuleKey ?? this.autoRuleKey,
      isOptional: isOptional ?? this.isOptional,
      priority: priority ?? this.priority,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'area': area.index,
      'title': title,
      'description': description,
      'done': done,
      'order': order,
      'route': route,
      'autoRuleKey': autoRuleKey,
      'isOptional': isOptional,
      'priority': priority,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory ChecklistItem.fromJson(Map<String, dynamic> json) {
    return ChecklistItem(
      id: json['id'],
      area: ProgressArea.values[json['area'] ?? 0],
      title: json['title'],
      description: json['description'],
      done: json['done'] ?? false,
      order: json['order'] ?? 0,
      route: json['route'],
      autoRuleKey: json['autoRuleKey'],
      isOptional: json['isOptional'] ?? false,
      priority: json['priority'] ?? 3,
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }
}

class ProgressSummary {
  final double percent; // 0.0 to 1.0
  final int done;
  final int total;
  final String? nextTitle;
  final String? nextRoute;
  final bool configured; // New field from Prompt 75

  const ProgressSummary({
    required this.percent,
    required this.done,
    required this.total,
    this.nextTitle,
    this.nextRoute,
    this.configured = true,
  });
  
  static const empty = ProgressSummary(percent: 0, done: 0, total: 0, configured: false, nextTitle: 'Sin configurar');
}

class BusinessProgressModel {
  final ProgressSummary overall;
  final Map<ProgressArea, ProgressSummary> byArea;
  final DateTime updatedAt;

  const BusinessProgressModel({
    required this.overall,
    required this.byArea,
    required this.updatedAt,
  });
  
  static final empty = BusinessProgressModel(
    overall: ProgressSummary.empty, 
    byArea: {
      ProgressArea.start: ProgressSummary.empty,
      ProgressArea.payroll: ProgressSummary.empty,
      ProgressArea.accounting: ProgressSummary.empty,
      ProgressArea.marketing: ProgressSummary.empty,
    },
    updatedAt: DateTime.now(),
  );
}
