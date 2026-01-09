import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/audit_log_model.dart';
import 'package:uuid/uuid.dart'; // Ensure we have a way to gen IDs or use simple timestamp

class AuditLoggerService {
  static final AuditLoggerService instance = AuditLoggerService._();
  AuditLoggerService._();

  static const String _storageKey = 'audit_logs_v1';
  static const int _maxLogs = 500;
  List<AuditLog> _logs = [];
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    await _loadLogs();
    _initialized = true;
  }

  Future<void> _loadLogs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? data = prefs.getString(_storageKey);
      if (data != null) {
        final List<dynamic> decoded = json.decode(data);
        _logs = decoded.map((e) => AuditLog.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint('Error loading audit logs: $e');
    }
  }

  Future<void> _saveLogs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Enforce limit
      if (_logs.length > _maxLogs) {
        // Keep most recent. Logs are appended, so remove from start (oldest) if assumed chronological append
        // Actually we usually prepend new logs for UI, let's decide: 
        // Strategy: Append new logs to end. Keep last 500.
        _logs = _logs.sublist(_logs.length - _maxLogs);
      }
      
      final encoded = json.encode(_logs.map((e) => e.toJson()).toList());
      await prefs.setString(_storageKey, encoded);
    } catch (e) {
      debugPrint('Error saving audit logs: $e');
    }
  }

  Future<void> log(String action, {
    String actor = 'Admin',
    required String entityType,
    required String entityId,
    required String summary,
    Map<String, dynamic>? meta,
    String severity = 'info',
  }) async {
    if (!_initialized) await init();

    final newLog = AuditLog(
      id: DateTime.now().millisecondsSinceEpoch.toString(), // Simple ID
      timestamp: DateTime.now(),
      actor: actor,
      action: action,
      entityType: entityType,
      entityId: entityId,
      summary: summary,
      meta: meta ?? {},
      severity: severity,
    );

    _logs.add(newLog); // Append to end
    await _saveLogs();
    debugPrint('📝 Audit Log: $summary');
  }

  List<AuditLog> getLogs({String? typeFilter, String? severityFilter, String? searchQuery}) {
    // Return copy reversed (newest first)
    var filtered = List<AuditLog>.from(_logs.reversed);

    if (typeFilter != null && typeFilter.isNotEmpty) {
      filtered = filtered.where((l) => l.entityType == typeFilter).toList();
    }
    
    if (severityFilter != null && severityFilter.isNotEmpty) {
      filtered = filtered.where((l) => l.severity == severityFilter).toList();
    }

    if (searchQuery != null && searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      filtered = filtered.where((l) => 
        l.summary.toLowerCase().contains(q) || 
        l.action.toLowerCase().contains(q) ||
        l.entityId.toLowerCase().contains(q)
      ).toList();
    }

    return filtered;
  }

  Future<void> clearLogs() async {
    _logs = [];
    await _saveLogs();
  }
  
  String exportLogsJson() {
    return const JsonEncoder.withIndent('  ').convert(_logs.map((e) => e.toJson()).toList());
  }
}
