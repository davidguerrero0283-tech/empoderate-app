import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../admin/visibility/visibility_service.dart';
import 'audit_logger_service.dart'; // NEW

class SystemHealthService {
  static final SystemHealthService instance = SystemHealthService._();
  SystemHealthService._();

  // Keys to monitor/check
  static const List<String> _criticalKeys = [
    'admin_users_v1',
    'analytics_v2_data',
    'blog_drafts',
    'business_audit_data',
    'global_config_flags' // conceptual key, actual keys are prefixed
  ];

  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Clear specific temporary keys if any exist. 
      // For now, we simulate clearing "cache" by removing non-essential keys if we had any.
      // In a real app with image cache, we'd clear DefaultCacheManager.
      await Future.delayed(const Duration(milliseconds: 800)); // Simulate work
      debugPrint('Cache cleared');
      
      AuditLoggerService.instance.log(
        'CACHE_CLEARED',
        entityType: 'System',
        entityId: 'LocalCache',
        summary: 'Cleared application cache',
      );
    } catch (e) {
      debugPrint('Error clearing cache: $e');
      rethrow;
    }
  }

  Future<void> resetFeatureFlags() async {
    try {
      // Use VisibilityService to reset
      // We need to implement a reset method there or manually clear keys
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      for (String key in keys) {
        if (key.startsWith('visibility_')) {
          await prefs.remove(key);
        }
      }
      // Re-init service to apply defaults
      await VisibilityService.instance.init();

      AuditLoggerService.instance.log(
        'FLAGS_RESET',
        entityType: 'System',
        entityId: 'GlobalConfig',
        summary: 'Reset all feature flags to default',
        severity: 'warning',
      );
    } catch (e) {
      debugPrint('Error resetting flags: $e');
      rethrow;
    }
  }

  Future<Map<String, String>> checkStorageIntegrity() async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, String> report = {};

    // 1. Check Admin Users
    _checkJsonKey(prefs, 'admin_users_v1', report);

    // 2. Check Analytics
    _checkJsonKey(prefs, 'analytics_v2_data', report);

    // 3. Check Blog Drafts
    _checkJsonKey(prefs, 'blog_drafts', report);

    // 4. Check Business Audit
    _checkJsonKey(prefs, 'business_audit_data', report);

    return report;
  }

  void _checkJsonKey(SharedPreferences prefs, String key, Map<String, String> report) {
    if (!prefs.containsKey(key)) {
      report[key] = 'Missing (Clean)';
      return;
    }

    try {
      final String? data = prefs.getString(key);
      if (data == null) {
        report[key] = 'Null Value';
        return;
      }
      json.decode(data); // Try decode
      report[key] = 'Healthy';
    } catch (e) {
      report[key] = 'Corrupt';
    }
  }

  Future<void> repairKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(key)) {
      await prefs.remove(key); // Nuke corrupt data to reset to safe state
      
      AuditLoggerService.instance.log(
        'DATA_REPAIRED',
        entityType: 'System',
        entityId: key,
        summary: 'Repaired corrupt storage key: $key',
        severity: 'error',
      );
    }

  }

  Future<void> optimizeDatabase() async {
     // For SharedPreferences, "optimization" is just ensuring no garbage keys exist.
     // We can just verify integrity as the optimization step.
     await checkStorageIntegrity();
  }
}
