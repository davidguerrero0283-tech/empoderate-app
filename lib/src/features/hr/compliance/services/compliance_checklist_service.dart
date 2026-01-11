/// Compliance Checklist Service with Persistence
/// Manages checklist items and progress state using SharedPreferences

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ChecklistItem {
  final String id;
  final String title;
  final String category;
  bool isCompleted;

  ChecklistItem({
    required this.id,
    required this.title,
    required this.category,
    this.isCompleted = false,
  });

  factory ChecklistItem.fromJson(Map<String, dynamic> json) {
    return ChecklistItem(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      category: json['category'] ?? 'general',
      isCompleted: json['isCompleted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'category': category,
        'isCompleted': isCompleted,
      };
}

class ComplianceProgress {
  final int total;
  final int completed;
  final double percent;

  ComplianceProgress({
    required this.total,
    required this.completed,
  }) : percent = total == 0 ? 0.0 : completed / total;
}

class ComplianceChecklistService {
  static final ComplianceChecklistService _instance = ComplianceChecklistService._();
  factory ComplianceChecklistService() => _instance;
  ComplianceChecklistService._();

  static const String _keyItems = 'compliance_checklist_items_json';
  static const String _keyLastUpdated = 'compliance_checklist_last_updated';

  List<ChecklistItem>? _cachedItems;

  /// Default checklist items based on Panama labor compliance requirements
  static final List<ChecklistItem> _defaultItems = [
    // Planilla y Pagos
    ChecklistItem(id: 'planilla_mensual', title: 'Planilla Mensual Generada', category: 'planilla'),
    ChecklistItem(id: 'sipe_presentado', title: 'SIPE Presentado en CSS', category: 'seguro_social'),
    ChecklistItem(id: 'css_pagado', title: 'Pago CSS Realizado', category: 'seguro_social'),
    ChecklistItem(id: 'decimo_calculado', title: 'Décimo Tercer Mes Calculado', category: 'pagos'),
    
    // Documentación
    ChecklistItem(id: 'contratos_firmados', title: 'Contratos Laborales Firmados', category: 'documentos'),
    ChecklistItem(id: 'reglamento_interno', title: 'Reglamento Interno Actualizado', category: 'documentos'),
    
    // Permisos y Licencias
    ChecklistItem(id: 'licencias_revisadas', title: 'Licencias/Permisos al Día', category: 'permisos'),
    ChecklistItem(id: 'vacaciones_programadas', title: 'Vacaciones Programadas', category: 'vacaciones'),
    
    // Cumplimiento Legal
    ChecklistItem(id: 'mitradel_ok', title: 'Registro MITRADEL Activo', category: 'legal'),
    ChecklistItem(id: 'paz_salvo', title: 'Paz y Salvo CSS Vigente', category: 'legal'),
  ];

  Future<List<ChecklistItem>> loadItems() async {
    if (_cachedItems != null) return _cachedItems!;

    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_keyItems);

      if (jsonStr != null && jsonStr.isNotEmpty) {
        final List<dynamic> jsonList = jsonDecode(jsonStr);
        _cachedItems = jsonList.map((e) => ChecklistItem.fromJson(e)).toList();
      } else {
        // First time: initialize with defaults
        _cachedItems = List.from(_defaultItems);
        await _saveItems();
      }
    } catch (e) {
      print('ComplianceChecklistService: Error loading items: $e');
      _cachedItems = List.from(_defaultItems);
    }

    return _cachedItems!;
  }

  Future<void> toggleItem(String itemId, bool value) async {
    final items = await loadItems();
    final index = items.indexWhere((i) => i.id == itemId);
    if (index != -1) {
      items[index].isCompleted = value;
      await _saveItems();
    }
  }

  Future<void> markAllCompleted(bool value) async {
    final items = await loadItems();
    for (var item in items) {
      item.isCompleted = value;
    }
    await _saveItems();
  }

  Future<void> resetAll() async {
    _cachedItems = List.from(_defaultItems);
    await _saveItems();
  }

  Future<ComplianceProgress> getProgress() async {
    final items = await loadItems();
    final completed = items.where((i) => i.isCompleted).length;
    return ComplianceProgress(total: items.length, completed: completed);
  }

  Future<void> _saveItems() async {
    if (_cachedItems == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = jsonEncode(_cachedItems!.map((e) => e.toJson()).toList());
      await prefs.setString(_keyItems, jsonStr);
      await prefs.setString(_keyLastUpdated, DateTime.now().toIso8601String());
    } catch (e) {
      print('ComplianceChecklistService: Error saving items: $e');
    }
  }
}
