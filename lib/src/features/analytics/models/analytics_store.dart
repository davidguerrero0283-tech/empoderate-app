import 'dart:convert';

class AnalyticsStore {
  int totalScreenViews;
  int sessionsCount;
  String? lastSeenAt;
  String? firstSeenAt;
  String? currentSessionId;
  String? lastSessionAt;
  Map<String, int> viewsByRoute;
  Map<String, int> viewsByModule;
  Map<String, int> dailyActivity; // Format: YYYY-MM-DD
  Map<String, int> eventsCountByName;

  AnalyticsStore({
    this.totalScreenViews = 0,
    this.sessionsCount = 0,
    this.lastSeenAt,
    this.firstSeenAt,
    this.currentSessionId,
    this.lastSessionAt,
    this.viewsByRoute = const {},
    this.viewsByModule = const {},
    this.dailyActivity = const {},
    this.eventsCountByName = const {},
  });

  factory AnalyticsStore.fromJson(Map<String, dynamic> json) {
    return AnalyticsStore(
      totalScreenViews: json['totalScreenViews'] ?? 0,
      sessionsCount: json['sessionsCount'] ?? 0,
      lastSeenAt: json['lastSeenAt'],
      firstSeenAt: json['firstSeenAt'],
      currentSessionId: json['currentSessionId'],
      lastSessionAt: json['lastSessionAt'],
      viewsByRoute: Map<String, int>.from(json['viewsByRoute'] ?? {}),
      viewsByModule: Map<String, int>.from(json['viewsByModule'] ?? {}),
      dailyActivity: Map<String, int>.from(json['dailyActivity'] ?? {}),
      eventsCountByName: Map<String, int>.from(json['eventsCountByName'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalScreenViews': totalScreenViews,
      'sessionsCount': sessionsCount,
      'lastSeenAt': lastSeenAt,
      'firstSeenAt': firstSeenAt,
      'currentSessionId': currentSessionId,
      'lastSessionAt': lastSessionAt,
      'viewsByRoute': viewsByRoute,
      'viewsByModule': viewsByModule,
      'dailyActivity': dailyActivity,
      'eventsCountByName': eventsCountByName,
    };
  }

  AnalyticsStore copyWith({
    int? totalScreenViews,
    int? sessionsCount,
    String? lastSeenAt,
    String? firstSeenAt,
    String? currentSessionId,
    String? lastSessionAt,
    Map<String, int>? viewsByRoute,
    Map<String, int>? viewsByModule,
    Map<String, int>? dailyActivity,
    Map<String, int>? eventsCountByName,
  }) {
    return AnalyticsStore(
      totalScreenViews: totalScreenViews ?? this.totalScreenViews,
      sessionsCount: sessionsCount ?? this.sessionsCount,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
      firstSeenAt: firstSeenAt ?? this.firstSeenAt,
      currentSessionId: currentSessionId ?? this.currentSessionId,
      lastSessionAt: lastSessionAt ?? this.lastSessionAt,
      viewsByRoute: viewsByRoute ?? this.viewsByRoute,
      viewsByModule: viewsByModule ?? this.viewsByModule,
      dailyActivity: dailyActivity ?? this.dailyActivity,
      eventsCountByName: eventsCountByName ?? this.eventsCountByName,
    );
  }
}
