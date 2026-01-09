
class AuditLog {
  final String id;
  final DateTime timestamp;
  final String actor; // e.g. "Admin", "System", "User"
  final String action; // e.g. "USER_CREATED", "CACHE_CLEARED"
  final String entityType; // e.g. "User", "Content", "System"
  final String entityId; // ID of the affected entity
  final String summary; // Human readable description
  final Map<String, dynamic> meta; // Extra details
  final String severity; // "info", "warning", "error"
  // Enrichment Fields (V1.1)
  final String? sessionId;
  final String? route;
  final String? module;

  AuditLog({
    required this.id,
    required this.timestamp,
    required this.actor,
    required this.action,
    required this.entityType,
    required this.entityId,
    required this.summary,
    this.meta = const {},
    this.severity = 'info',
    this.sessionId,
    this.route,
    this.module,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'actor': actor,
      'action': action,
      'entityType': entityType,
      'entityId': entityId,
      'summary': summary,
      'meta': meta,
      'severity': severity,
      if (sessionId != null) 'sessionId': sessionId,
      if (route != null) 'route': route,
      if (module != null) 'module': module,
    };
  }

  factory AuditLog.fromJson(Map<String, dynamic> json) {
    return AuditLog(
      id: json['id'],
      timestamp: DateTime.parse(json['timestamp']),
      actor: json['actor'],
      action: json['action'],
      entityType: json['entityType'],
      entityId: json['entityId'],
      summary: json['summary'],
      meta: Map<String, dynamic>.from(json['meta'] ?? {}),
      severity: json['severity'] ?? 'info',
      sessionId: json['sessionId'],
      route: json['route'],
      module: json['module'],
    );
  }
}
