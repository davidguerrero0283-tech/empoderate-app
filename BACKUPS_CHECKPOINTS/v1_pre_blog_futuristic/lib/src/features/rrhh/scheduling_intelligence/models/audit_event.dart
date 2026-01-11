/// Audit record for scheduling decisions
class AuditEvent {
  final String id;
  final String userId; // Who made the change
  final DateTime timestamp;
  final String actionType;
  final String description;
  final double scoreBefore;
  final double scoreAfter;
  final List<String> violationsTriggered;

  AuditEvent({
    required this.id,
    required this.userId,
    required this.timestamp,
    required this.actionType,
    required this.description,
    this.scoreBefore = 0,
    this.scoreAfter = 0,
    this.violationsTriggered = const [],
  });
  
  // Json conversion for storage
  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'timestamp': timestamp.toIso8601String(),
    'actionType': actionType,
    'description': description,
    'scoreBefore': scoreBefore,
    'scoreAfter': scoreAfter,
    'violationsTriggered': violationsTriggered,
  };

  factory AuditEvent.fromJson(Map<String, dynamic> json) {
    return AuditEvent(
      id: json['id'],
      userId: json['userId'],
      timestamp: DateTime.parse(json['timestamp']),
      actionType: json['actionType'],
      description: json['description'],
      scoreBefore: (json['scoreBefore'] as num).toDouble(),
      scoreAfter: (json['scoreAfter'] as num).toDouble(),
      violationsTriggered: List<String>.from(json['violationsTriggered'] ?? []),
    );
  }
}
