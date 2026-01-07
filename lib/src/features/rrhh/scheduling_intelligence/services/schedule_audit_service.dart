import '../models/audit_event.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Service for logging and retrieving audit events
class ScheduleAuditService {
  static const String _storageKey = 'schedule_audit_log';
  
  Future<void> logEvent(AuditEvent event) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> logs = prefs.getStringList(_storageKey) ?? [];
    
    logs.insert(0, jsonEncode(event.toJson())); // Newest first
    
    // Limit to last 100 events
    if (logs.length > 100) {
      logs.removeRange(100, logs.length);
    }
    
    await prefs.setStringList(_storageKey, logs);
  }
  
  Future<List<AuditEvent>> getLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> logs = prefs.getStringList(_storageKey) ?? [];
    
    return logs.map((s) => AuditEvent.fromJson(jsonDecode(s) as Map<String, dynamic>)).toList().cast<AuditEvent>();
  }
}
