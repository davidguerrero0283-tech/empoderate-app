import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../components/neon_widgets.dart'; // For colors if needed, or just store strings

class BusinessArea {
  final String name;
  final String status; // 'Sin iniciar', 'En proceso', 'Completado'
  final String priority; // 'Alta', 'Media', 'Baja'
  final String? note;

  BusinessArea({
    required this.name,
    required this.status,
    required this.priority,
    this.note,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'status': status,
    'priority': priority,
    'note': note,
  };

  factory BusinessArea.fromJson(Map<String, dynamic> json) => BusinessArea(
    name: json['name'],
    status: json['status'],
    priority: json['priority'],
    note: json['note'],
  );
}

class AuditoriaService {
  static final AuditoriaService instance = AuditoriaService._();
  AuditoriaService._();

  static const String _storageKey = 'audit_data_v1';
  List<BusinessArea> _areas = [];
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    await _loadData();
    _initialized = true;
  }

  Future<void> _loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? data = prefs.getString(_storageKey);
      
      if (data != null) {
        final List<dynamic> decoded = json.decode(data);
        _areas = decoded.map((e) => BusinessArea.fromJson(e)).toList();
      } else {
        // Initial / Default Data
        _areas = [
          BusinessArea(name: 'Legal', status: 'En proceso', priority: 'Alta'),
          BusinessArea(name: 'Marketing', status: 'Sin iniciar', priority: 'Media'),
          BusinessArea(name: 'Contabilidad', status: 'En proceso', priority: 'Alta'),
          BusinessArea(name: 'RRHH', status: 'Completado', priority: 'Baja'),
          BusinessArea(name: 'Operaciones', status: 'Completado', priority: 'Baja'),
        ];
        await _saveData();
      }
    } catch (e) {
      print('Error loading audit data: $e');
    }
  }

  Future<void> _saveData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, json.encode(_areas.map((e) => e.toJson()).toList()));
    } catch (e) {
      print('Error saving audit data: $e');
    }
  }

  List<BusinessArea> getAreas() {
    return List.from(_areas);
  }

  Future<void> updateArea(String name, String status, String priority) async {
    final index = _areas.indexWhere((a) => a.name == name);
    if (index != -1) {
      _areas[index] = BusinessArea(
        name: name,
        status: status,
        priority: priority,
        note: _areas[index].note,
      );
      await _saveData();
    }
  }
}
