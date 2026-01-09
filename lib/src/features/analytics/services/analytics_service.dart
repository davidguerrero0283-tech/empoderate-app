import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../system/services/audit_logger_service.dart';
import '../models/analytics_store.dart';
import 'package:uuid/uuid.dart'; // Just using timestamp or random for now if no uuid pkg

class AnalyticsService {
  static final AnalyticsService instance = AnalyticsService._();
  AnalyticsService._();

  static const String _storageKey = 'analytics_v2_data';
  AnalyticsStore _store = AnalyticsStore();
  bool _initialized = false;
  
  // Track last route for external access/enrichment
  String? _lastRoute;
  String? get currentRoute => _lastRoute;

  Future<void> init() async {
    if (_initialized) return;
    await _loadStore();
    _startSessionIfNeeded();
    _initialized = true;
  }

  Future<void> _loadStore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? raw = prefs.getString(_storageKey);
      if (raw != null) {
        final decoded = json.decode(raw);
        _store = AnalyticsStore.fromJson(decoded);
      } else {
        // First run
        _store = AnalyticsStore(firstSeenAt: DateTime.now().toIso8601String());
      }
    } catch (e) {
      debugPrint('Analytics Load Error: $e');
      _store = AnalyticsStore(); // Fallback
    }
  }

  Future<void> _saveStore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, json.encode(_store.toJson()));
    } catch (e) {
      debugPrint('Analytics Save Error: $e');
    }
  }

  void _startSessionIfNeeded() {
    final now = DateTime.now();
    bool newSession = false;

    if (_store.lastSessionAt == null) {
      newSession = true;
    } else {
      final lastSession = DateTime.parse(_store.lastSessionAt!);
      final difference = now.difference(lastSession);
      if (difference.inMinutes > 30) {
        newSession = true;
      }
    }

    if (newSession) {
      _store.sessionsCount++;
      _store.currentSessionId = now.millisecondsSinceEpoch.toString(); // Simple ID
      _store.lastSessionAt = now.toIso8601String();
      // Usually save here
      _saveStore(); 
    }
  }

  Future<void> trackScreenView(String routeName, {String? overrideModule}) async {
    if (!_initialized) await init();
    _startSessionIfNeeded(); // Check session on every interaction

    _lastRoute = routeName;
    final now = DateTime.now().toIso8601String();

    // Update stats
    _store.totalScreenViews++;
    _store.lastSeenAt = now;
    _store.lastSessionAt = now; // Update session activity

    // Route
    final currentRouteCount = _store.viewsByRoute[routeName] ?? 0;
    _store.viewsByRoute[routeName] = currentRouteCount + 1;

    // Module
    final module = overrideModule ?? _determineModule(routeName);
    if (module != 'Other') {
      final currentModuleCount = _store.viewsByModule[module] ?? 0;
      _store.viewsByModule[module] = currentModuleCount + 1;
    }

    // Daily
    final today = now.split('T')[0];
    final currentDaily = _store.dailyActivity[today] ?? 0;
    _store.dailyActivity[today] = currentDaily + 1;
    _pruneDailyActivity();

    await _saveStore();
  }

  Future<void> trackEvent(String name, {Map<String, dynamic>? meta}) async {
    if (!_initialized) await init();
    _startSessionIfNeeded();

    final count = _store.eventsCountByName[name] ?? 0;
    _store.eventsCountByName[name] = count + 1;
    _store.lastSeenAt = DateTime.now().toIso8601String();
    
    // Also track in daily activity? Usually screen views correspond to engagement, but events do too.
    // user specification said "last7DaysDailyViews" - implying generic views or activity? 
    // Usually daily views. Let's stick to screen views for daily chart to keep it clean.
    
    await _saveStore();
  }

  void _pruneDailyActivity() {
    if (_store.dailyActivity.length > 7) { // 7 days roling as requested
       final sortedKeys = _store.dailyActivity.keys.toList()..sort();
       // Keep strict last 7
       while (_store.dailyActivity.length > 7) {
         _store.dailyActivity.remove(sortedKeys.first);
         sortedKeys.removeAt(0);
       }
    }
  }

  String determineModule(String route) => _determineModule(route); // Public alias

  String _determineModule(String route) {
    if (route.startsWith('/admin')) return 'Admin';
    if (route.startsWith('/hr') || route.startsWith('/human_resources') || route.contains('employee')) return 'RRHH';
    if (route.startsWith('/accounting') || route.contains('finance')) return 'Contabilidad';
    if (route.startsWith('/marketing')) return 'Marketing';
    if (route.startsWith('/tools') || route.contains('calculator')) return 'Herramientas';
    if (route.startsWith('/legal')) return 'Legal';
    if (route.startsWith('/ia') || route.contains('ai')) return 'IA Hub';
    if (route == '/') return 'Home';
    return 'General';
  }

  Future<void> resetAnalytics() async {
    _store = AnalyticsStore(
      firstSeenAt: DateTime.now().toIso8601String(),
      lastSeenAt: DateTime.now().toIso8601String(),
      // Keep session? "reset analytics" usually means clear stats.
      sessionsCount: 0,
    );
    await _saveStore();

    // Audit Log Integration
    AuditLoggerService.instance.log(
      'ANALYTICS_RESET',
      entityType: 'System',
      entityId: 'AnalyticsService',
      summary: 'Reset analytics data to zero',
      severity: 'warning',
    );
  }

  AnalyticsStore getStats() {
    return _store;
  }

  String exportToJson() {
    final jsonStr = const JsonEncoder.withIndent('  ').convert(_store.toJson());
    
    // Audit Log Integration
    AuditLoggerService.instance.log(
      'ANALYTICS_EXPORT',
      entityType: 'System',
      entityId: 'AnalyticsService',
      summary: 'Exported analytics data',
      severity: 'info',
    );
    
    return jsonStr;
  }
}
