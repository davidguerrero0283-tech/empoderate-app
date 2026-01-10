import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../ruta_exito/data/ruta_content.dart';
import '../../ruta_exito/models/ruta_step.dart';

class BusinessArea {
  final String name;
  final String status; // 'Sin iniciar', 'En proceso', 'Completado'
  final String priority; // 'Alta', 'Media', 'Baja'
  final String? note;
  final int completedSteps;
  final int totalSteps;

  BusinessArea({
    required this.name,
    required this.status,
    required this.priority,
    this.note,
    this.completedSteps = 0,
    this.totalSteps = 0,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'status': status,
    'priority': priority,
    'note': note,
    'completedSteps': completedSteps,
    'totalSteps': totalSteps,
  };

  factory BusinessArea.fromJson(Map<String, dynamic> json) => BusinessArea(
    name: json['name'],
    status: json['status'],
    priority: json['priority'],
    note: json['note'],
    completedSteps: json['completedSteps'] ?? 0,
    totalSteps: json['totalSteps'] ?? 0,
  );
}

class AuditRecommendation {
  final int stepId;
  final String title;
  final String description;
  final String area;
  final int phase;
  final String? toolRoute;
  final String? toolLabel;

  AuditRecommendation({
    required this.stepId,
    required this.title,
    required this.description,
    required this.area,
    required this.phase,
    this.toolRoute,
    this.toolLabel,
  });
}

class AuditoriaService {
  static final AuditoriaService instance = AuditoriaService._();
  AuditoriaService._();

  static const String _rutaStorageKey = 'ruta_completed_steps';
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
  }

  Future<Set<int>> _getCompletedRutaSteps() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dynamic data = prefs.get(_rutaStorageKey);
      
      if (data == null) return {};
      
      if (data is List<String>) {
        return data.map((e) => int.tryParse(e)).whereType<int>().toSet();
      } else if (data is List) {
        return data.map((e) => int.tryParse(e.toString())).whereType<int>().toSet();
      }
      return {};
    } catch (e) {
      print('Error loading completed steps: $e');
      return {};
    }
  }

  List<RutaStep> _getAllSteps() {
    final List<RutaStep> allSteps = [];
    for (var phase in rutaPhases) {
      for (var step in phase.steps) {
        allSteps.add(step);
      }
    }
    return allSteps;
  }

  Future<List<BusinessArea>> getAreas() async {
    final completedIds = await _getCompletedRutaSteps();
    final allSteps = _getAllSteps();
    
    final Map<String, List<RutaStep>> grouped = {};
    for (var step in allSteps) {
      final area = step.area ?? 'Otros';
      grouped.putIfAbsent(area, () => []).add(step);
    }

    final areasOrdered = ['Legal', 'Marketing', 'Contabilidad', 'RRHH', 'Operaciones'];
    final List<BusinessArea> results = [];

    for (var areaName in areasOrdered) {
      final steps = grouped[areaName] ?? [];
      if (steps.isEmpty) continue;

      final doneCount = steps.where((s) => completedIds.contains(s.id)).length;
      final totalCount = steps.length;

      String status = 'Sin iniciar';
      if (doneCount == totalCount) {
        status = 'Completado';
      } else if (doneCount > 0) {
        status = 'En proceso';
      }

      String priority = 'Baja';
      if (status != 'Completado') {
        final nextStep = steps.firstWhere((s) => !completedIds.contains(s.id));
        if (nextStep.id <= 10) {
          priority = 'Alta';
        } else if (nextStep.id <= 20) {
          priority = 'Media';
        } else {
          priority = 'Baja';
        }
      }

      results.add(BusinessArea(
        name: areaName,
        status: status,
        priority: priority,
        completedSteps: doneCount,
        totalSteps: totalCount,
      ));
    }

    return results;
  }

  Future<AuditRecommendation?> getRecommendationsForArea(String areaName) async {
    final completedIds = await _getCompletedRutaSteps();
    final allSteps = _getAllSteps();
    
    final areaSteps = allSteps.where((s) => s.area == areaName).toList();
    if (areaSteps.isEmpty) return null;

    final pendingSteps = areaSteps.where((s) => !completedIds.contains(s.id)).toList();

    if (pendingSteps.isEmpty) {
      return AuditRecommendation(
        stepId: 0,
        title: 'Área completada ✅',
        description: 'Has completado todos los pasos de esta categoría en La Ruta del Éxito.',
        area: areaName,
        phase: 3,
      );
    }

    final next = pendingSteps.first;
    int phase = 1;
    if (next.id > 20) phase = 3;
    else if (next.id > 10) phase = 2;

    return AuditRecommendation(
      stepId: next.id,
      title: next.title,
      description: next.description,
      area: areaName,
      phase: phase,
      toolRoute: next.toolRoute,
      toolLabel: next.toolLabel,
    );
  }

  // Deprecated updateArea since it's now driven by Ruta
  Future<void> updateArea(String name, String status, String priority) async {
    // No-op or log that this is now dynamic
    print('Manual update of $name ignored. Driven by Ruta del Éxito progress.');
  }
}
