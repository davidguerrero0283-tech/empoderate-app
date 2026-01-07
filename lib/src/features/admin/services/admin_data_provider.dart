import 'package:flutter/material.dart';

class AdminDataProvider extends ChangeNotifier {
  static final AdminDataProvider instance = AdminDataProvider._internal();
  AdminDataProvider._internal();

  // Mock Data for KPI
  Map<String, dynamic> getDashboardKPIs() {
    return {
      'activeUsers': 1240,
      'sessions': 8500,
      'errors': 12,
      'retention': '68%',
      'mau': 450,
      'dau': 85,
    };
  }

  // Mock Data for Usage Chart
  List<Map<String, dynamic>> getModuleUsageStats() {
    return [
      {'label': 'Trámites', 'value': 45},
      {'label': 'RRHH', 'value': 30},
      {'label': 'Contabilidad', 'value': 60},
      {'label': 'Marketing', 'value': 25},
      {'label': 'Calculadoras', 'value': 80},
    ];
  }

  // Mock Data for Audit Logs
  List<Map<String, dynamic>> getAuditLogs() {
    return [
      {'time': '10:05 AM', 'user': 'Admin', 'action': 'TOGGLED_FLAG', 'details': 'Enable Chatbot'},
      {'time': '09:30 AM', 'user': 'System', 'action': 'AUTO_REPAIR', 'details': 'Restored visibility configs'},
      {'time': 'Yesterday', 'user': 'Editor', 'action': 'UPDATE_GUIDE', 'details': 'Guía Rápida v2'},
      {'time': 'Yesterday', 'user': 'Admin', 'action': 'ACCESS', 'details': 'Login to Admin Panel'},
    ];
  }

  // Mock Data for System Health
  Map<String, dynamic> getSystemHealth() {
    return {
      'storageUsage': '1.2 MB / 50 MB',
      'lastBackup': 'Does not apply (Local)',
      'version': '1.0.2 (Beta)',
      'status': 'Healthy', 
    };
  }

  // --- NEW METHODS FOR ANALYTICS SCREEN ---
  List<Map<String, dynamic>> getAnalyticsDetail() {
    return [
      {'module': 'Contabilidad', 'visits': 1200, 'avgTime': '5m 30s', 'bounce': '20%'},
      {'module': 'RRHH', 'visits': 850, 'avgTime': '3m 15s', 'bounce': '35%'},
      {'module': 'Marketing', 'visits': 600, 'avgTime': '4m 00s', 'bounce': '25%'},
      {'module': 'Legal', 'visits': 450, 'avgTime': '2m 45s', 'bounce': '40%'},
      {'module': 'Ruta Éxito', 'visits': 300, 'avgTime': '8m 20s', 'bounce': '10%'},
    ];
  }

  // --- NEW METHODS FOR USERS SCREEN ---
  List<Map<String, dynamic>> getUsersList() {
    return [
      {'id': '1', 'name': 'Juan Pérez', 'email': 'juan@empoderate.com', 'role': 'Admin', 'status': 'Active', 'joined': '2025-01-10'},
      {'id': '2', 'name': 'Maria López', 'email': 'maria@user.com', 'role': 'Pro', 'status': 'Active', 'joined': '2025-02-15'},
      {'id': '3', 'name': 'Carlos Ruiz', 'email': 'carlos@user.com', 'role': 'Free', 'status': 'Active', 'joined': '2025-03-01'},
      {'id': '4', 'name': 'Ana Torres', 'email': 'ana@user.com', 'role': 'Free', 'status': 'Suspended', 'joined': '2025-03-05'},
      {'id': '5', 'name': 'Pedro Diaz', 'email': 'pedro@user.com', 'role': 'Pro', 'status': 'Active', 'joined': '2025-03-10'},
      // ... more users
    ];
  }

  // --- NEW METHODS FOR CONTENT SCREEN ---
  Map<String, dynamic> getContentStats() {
    return {
      'totalArticles': 24,
      'totalGuides': 12,
      'drafts': 3,
      'published': 33,
    };
  }
}
