/// Service for fetching, caching, and managing RRHH Obligaciones updates.
/// Uses SharedPreferences for local cache and http for remote fetching.

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../data/obligaciones_update_models.dart';
import '../data/obligaciones_default_content.dart';

class ObligacionesUpdatesService {
  // ====== CONFIG ======
  /// Remote URL for updates JSON. Change this to your hosted JSON URL.
  static const String updatesUrl = 'https://your-domain.com/api/rrhh_obligaciones_updates.json';
  
  /// How often to auto-refresh (default: 24 hours)
  static const Duration refreshInterval = Duration(hours: 24);

  // ====== CACHE KEYS ======
  static const String _keyCachedJson = 'rrhh_obl_cached_json';
  static const String _keyLastFetchAt = 'rrhh_obl_last_fetch_at';
  static const String _keyCachedBundleVersion = 'rrhh_obl_cached_bundle_version';
  static const String _keySeenVersions = 'rrhh_obl_seen_module_versions_json';

  // Singleton
  static final ObligacionesUpdatesService _instance = ObligacionesUpdatesService._();
  factory ObligacionesUpdatesService() => _instance;
  ObligacionesUpdatesService._();

  ObligacionesUpdateBundle? _cachedBundle;

  // ====== PUBLIC METHODS ======

  /// Fetch remote bundle. If force=false, uses cache if <24h old.
  Future<ObligacionesUpdateBundle?> fetchRemoteBundle({bool force = false}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Check cache validity
      if (!force) {
        final lastFetchStr = prefs.getString(_keyLastFetchAt);
        if (lastFetchStr != null) {
          final lastFetch = DateTime.tryParse(lastFetchStr);
          if (lastFetch != null && DateTime.now().difference(lastFetch) < refreshInterval) {
            // Use cached
            final cachedJson = prefs.getString(_keyCachedJson);
            if (cachedJson != null) {
              _cachedBundle = ObligacionesUpdateBundle.fromJson(jsonDecode(cachedJson));
              return _cachedBundle;
            }
          }
        }
      }

      // Fetch remote
      final response = await http.get(Uri.parse(updatesUrl)).timeout(
        const Duration(seconds: 10),
        onTimeout: () => http.Response('', 408),
      );

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final bundle = ObligacionesUpdateBundle.fromJson(json);

        // Save to cache
        await prefs.setString(_keyCachedJson, response.body);
        await prefs.setString(_keyLastFetchAt, DateTime.now().toIso8601String());
        await prefs.setString(_keyCachedBundleVersion, bundle.bundleVersion);

        _cachedBundle = bundle;
        return bundle;
      }
    } catch (e) {
      // Silently fail, return null
      print('ObligacionesUpdatesService: fetchRemoteBundle error: $e');
    }
    return null;
  }

  /// Get a specific module. Falls back to default content if remote unavailable.
  Future<ObligacionesModuleUpdate> getModule(String moduleId, {bool force = false}) async {
    final bundle = await fetchRemoteBundle(force: force);
    
    // Try remote first
    if (bundle != null) {
      final remote = bundle.getModule(moduleId);
      if (remote != null) return remote;
    }

    // Fallback to default
    return defaultObligacionesContent[moduleId] ?? _emptyModule(moduleId);
  }

  /// Check which modules have updates not yet seen by user.
  /// Returns map: moduleId -> hasNewUpdate
  Future<Map<String, bool>> checkForModuleUpdates() async {
    final result = <String, bool>{'css': false, 'permisos': false, 'calendario': false};
    
    try {
      final bundle = await fetchRemoteBundle(force: false);
      if (bundle == null) return result;

      final prefs = await SharedPreferences.getInstance();
      final seenJson = prefs.getString(_keySeenVersions);
      final seen = seenJson != null ? Map<String, String>.from(jsonDecode(seenJson)) : <String, String>{};

      for (final module in bundle.modules) {
        final seenVersion = seen[module.moduleId];
        result[module.moduleId] = seenVersion != module.version;
      }
    } catch (e) {
      print('ObligacionesUpdatesService: checkForModuleUpdates error: $e');
    }

    return result;
  }

  /// Mark a module version as "seen" by user (to dismiss badge).
  Future<void> markModuleSeen(String moduleId, String version) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final seenJson = prefs.getString(_keySeenVersions);
      final seen = seenJson != null ? Map<String, String>.from(jsonDecode(seenJson)) : <String, String>{};
      
      seen[moduleId] = version;
      await prefs.setString(_keySeenVersions, jsonEncode(seen));
    } catch (e) {
      print('ObligacionesUpdatesService: markModuleSeen error: $e');
    }
  }

  /// Force refresh from remote (ignores cache).
  Future<void> forceRefresh() async {
    await fetchRemoteBundle(force: true);
  }

  /// Check if currently using offline/default content.
  Future<bool> isUsingOfflineContent() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedJson = prefs.getString(_keyCachedJson);
    return cachedJson == null || cachedJson.isEmpty;
  }

  // ====== PRIVATE HELPERS ======
  ObligacionesModuleUpdate _emptyModule(String moduleId) {
    return ObligacionesModuleUpdate(
      moduleId: moduleId,
      version: '0.0.0',
      lastReviewed: 'N/A',
      summary: 'Contenido no disponible.',
      keyPoints: [],
      sources: [],
      toolConfig: {},
    );
  }
}
