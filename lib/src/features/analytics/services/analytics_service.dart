import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AnalyticsService {
  static final AnalyticsService instance = AnalyticsService._();
  AnalyticsService._();

  static const String _storageKey = 'analytics_v2_data';
  
  // Data State
  Map<String, dynamic> _data = {
    'total_views': 0,
    'sessions': 0,
    'last_seen': null,
    'views_by_route': <String, int>{},
    'views_by_module': <String, int>{},
    'daily_activity': <String, int>{},
  };
  
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    await _loadData();
    _registerSession();
    _initialized = true;
  }

  Future<void> _loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? raw = prefs.getString(_storageKey);
      if (raw != null) {
        final decoded = json.decode(raw);
        _data = {
          'total_views': decoded['total_views'] ?? 0,
          'sessions': decoded['sessions'] ?? 0,
          'last_seen': decoded['last_seen'],
          'views_by_route': Map<String, int>.from(decoded['views_by_route'] ?? {}),
          'views_by_module': Map<String, int>.from(decoded['views_by_module'] ?? {}),
          'daily_activity': Map<String, int>.from(decoded['daily_activity'] ?? {}),
        };
      }
    } catch (e) {
      debugPrint('Analytics Load Error: $e');
    }
  }

  Future<void> _saveData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, json.encode(_data));
    } catch (e) {
      debugPrint('Analytics Save Error: $e');
    }
  }

  void _registerSession() {
    // Simple session logic: New session on app init
    _data['sessions'] = (_data['sessions'] as int) + 1;
    _data['last_seen'] = DateTime.now().toIso8601String();
    _saveData();
  }

  Future<void> trackScreenView(String routeName, {String? overrideModule}) async {
    if (!_initialized) await init();

    // 1. Total Views
    _data['total_views'] = (_data['total_views'] as int) + 1;

    // 2. Views by Route
    final routeCounts = _data['views_by_route'] as Map<String, int>;
    routeCounts[routeName] = (routeCounts[routeName] ?? 0) + 1;

    // 3. Views by Module
    final module = overrideModule ?? _determineModule(routeName);
    if (module != 'Other') {
      final moduleCounts = _data['views_by_module'] as Map<String, int>;
      moduleCounts[module] = (moduleCounts[module] ?? 0) + 1;
    }

    // 4. Daily Activity
    final today = DateTime.now().toIso8601String().split('T')[0];
    final dailyCounts = _data['daily_activity'] as Map<String, int>;
    dailyCounts[today] = (dailyCounts[today] ?? 0) + 1;

    // Prune daily activity > 30 days
    if (dailyCounts.length > 30) {
       final sortedKeys = dailyCounts.keys.toList()..sort();
       dailyCounts.remove(sortedKeys.first);
    }

    await _saveData();
  }

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
    _data = {
      'total_views': 0,
      'sessions': 1, // Current session remains
      'last_seen': DateTime.now().toIso8601String(),
      'views_by_route': <String, int>{},
      'views_by_module': <String, int>{},
      'daily_activity': <String, int>{},
    };
    await _saveData();
  }

  Map<String, dynamic> getStats() {
    return _data;
  }

  String exportToJson() {
    return const JsonEncoder.withIndent('  ').convert(_data);
  }
}
