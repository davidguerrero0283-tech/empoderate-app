import 'ai_generic_request.dart';

class AiAction {
  final String label;
  final String taskTitle;
  final String taskDescription;

  AiAction({
    required this.label,
    required this.taskTitle,
    required this.taskDescription,
  });

  Map<String, dynamic> toJson() => {
    'label': label,
    'taskTitle': taskTitle,
    'taskDescription': taskDescription,
  };

  factory AiAction.fromJson(Map<String, dynamic> json) => AiAction(
    label: json['label'],
    taskTitle: json['taskTitle'],
    taskDescription: json['taskDescription'],
  );
}

class AiGenericOutput {
  final String id;
  final DateTime createdAt;
  final AiGenericRequest request;
  final String content;     // Main content
  final String extraInfo;   // Tips, clauses, steps, etc.
  final String actionPlan;  // Next steps
  final List<AiAction> suggestedActions; // New Smart Actions

  AiGenericOutput({
    required this.id,
    required this.createdAt,
    required this.request,
    required this.content,
    required this.extraInfo,
    required this.actionPlan,
    this.suggestedActions = const [],
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'createdAt': createdAt.toIso8601String(),
    'request': request.toJson(),
    'content': content,
    'extraInfo': extraInfo,
    'actionPlan': actionPlan,
    'suggestedActions': suggestedActions.map((a) => a.toJson()).toList(),
  };

  factory AiGenericOutput.fromJson(Map<String, dynamic> json) => AiGenericOutput(
    id: json['id'],
    createdAt: DateTime.parse(json['createdAt']),
    request: AiGenericRequest.fromJson(json['request']),
    content: json['content'],
    extraInfo: json['extraInfo'],
    actionPlan: json['actionPlan'],
    suggestedActions: json['suggestedActions'] != null 
      ? (json['suggestedActions'] as List).map((i) => AiAction.fromJson(i)).toList()
      : [],
  );
}
