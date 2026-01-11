/// Models for RRHH Obligaciones Auto-Update System
/// These models represent the structure of the remote JSON updates.

class OfficialSource {
  final String title;
  final String url;

  OfficialSource({required this.title, required this.url});

  factory OfficialSource.fromJson(Map<String, dynamic> json) {
    return OfficialSource(
      title: json['title'] ?? '',
      url: json['url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'title': title, 'url': url};
}

class ObligacionesModuleUpdate {
  final String moduleId; // 'css' | 'permisos' | 'calendario'
  final String version;  // e.g., "2026.01.10"
  final String lastReviewed; // "YYYY-MM-DD"
  final String summary;
  final List<String> keyPoints;
  final List<OfficialSource> sources;
  final Map<String, dynamic> toolConfig;

  ObligacionesModuleUpdate({
    required this.moduleId,
    required this.version,
    required this.lastReviewed,
    required this.summary,
    required this.keyPoints,
    required this.sources,
    required this.toolConfig,
  });

  factory ObligacionesModuleUpdate.fromJson(Map<String, dynamic> json) {
    return ObligacionesModuleUpdate(
      moduleId: json['moduleId'] ?? '',
      version: json['version'] ?? '1.0.0',
      lastReviewed: json['lastReviewed'] ?? 'N/A',
      summary: json['summary'] ?? '',
      keyPoints: List<String>.from(json['keyPoints'] ?? []),
      sources: (json['sources'] as List<dynamic>?)
              ?.map((s) => OfficialSource.fromJson(s as Map<String, dynamic>))
              .toList() ??
          [],
      toolConfig: Map<String, dynamic>.from(json['toolConfig'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
        'moduleId': moduleId,
        'version': version,
        'lastReviewed': lastReviewed,
        'summary': summary,
        'keyPoints': keyPoints,
        'sources': sources.map((s) => s.toJson()).toList(),
        'toolConfig': toolConfig,
      };
}

class ObligacionesUpdateBundle {
  final String bundleVersion;
  final String generatedAt;
  final List<ObligacionesModuleUpdate> modules;

  ObligacionesUpdateBundle({
    required this.bundleVersion,
    required this.generatedAt,
    required this.modules,
  });

  factory ObligacionesUpdateBundle.fromJson(Map<String, dynamic> json) {
    return ObligacionesUpdateBundle(
      bundleVersion: json['bundleVersion'] ?? '1.0.0',
      generatedAt: json['generatedAt'] ?? '',
      modules: (json['modules'] as List<dynamic>?)
              ?.map((m) => ObligacionesModuleUpdate.fromJson(m as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  ObligacionesModuleUpdate? getModule(String moduleId) {
    try {
      return modules.firstWhere((m) => m.moduleId == moduleId);
    } catch (_) {
      return null;
    }
  }
}
