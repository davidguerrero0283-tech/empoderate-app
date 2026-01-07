import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/hr_central_record.dart';

/// Servicio central para gestionar el archivo de registros de RRHH
class HRArchiveService {
  static final HRArchiveService _instance = HRArchiveService._internal();
  factory HRArchiveService() => _instance;
  HRArchiveService._internal();

  static const String _storageKey = 'hr_archive_records_v1';

  /// Obtener todos los registros
  Future<List<HRCentralRecord>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_storageKey);
    if (jsonString == null) return [];

    try {
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded
          .map((item) => HRCentralRecord.fromJson(item))
          .toList()
        ..sort((a, b) => b.eventDate.compareTo(a.eventDate));
    } catch (e) {
      debugPrint('Error loading HR archive: $e');
      return [];
    }
  }

  /// Obtener registros por trabajador
  Future<List<HRCentralRecord>> getByWorker(String workerId) async {
    final all = await getAll();
    return all.where((r) => r.workerId == workerId).toList();
  }

  /// Obtener registros por tipo
  Future<List<HRCentralRecord>> getByType(HRRecordType type) async {
    final all = await getAll();
    return all.where((r) => r.type == type).toList();
  }

  /// Obtener registros por año
  Future<List<HRCentralRecord>> getByYear(int year) async {
    final all = await getAll();
    return all.where((r) => r.eventDate.year == year).toList();
  }

  /// Añadir un nuevo registro
  Future<void> add(HRCentralRecord record) async {
    final records = await getAll();
    records.add(record);
    await _persist(records);
    debugPrint('✅ HR Record añadido: ${record.type.label} - ${record.workerName}');
  }

  /// Eliminar un registro
  Future<void> delete(String recordId) async {
    final records = await getAll();
    records.removeWhere((r) => r.id == recordId);
    await _persist(records);
  }

  /// Guardar registros
  Future<void> _persist(List<HRCentralRecord> records) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(records.map((r) => r.toJson()).toList());
    await prefs.setString(_storageKey, jsonString);
  }

  /// Exportar todo como JSON (para backup)
  Future<String> exportBackupJson() async {
    final records = await getAll();
    return const JsonEncoder.withIndent('  ').convert({
      'exportDate': DateTime.now().toIso8601String(),
      'version': '1.0',
      'recordCount': records.length,
      'records': records.map((r) => r.toJson()).toList(),
    });
  }

  /// Importar desde JSON backup
  Future<int> importFromJson(String jsonString) async {
    try {
      final Map<String, dynamic> data = jsonDecode(jsonString);
      final List<dynamic> recordsJson = data['records'] ?? [];
      final records = recordsJson.map((r) => HRCentralRecord.fromJson(r)).toList();
      
      // Merge with existing (avoid duplicates by ID)
      final existing = await getAll();
      final existingIds = existing.map((r) => r.id).toSet();
      
      int imported = 0;
      for (final record in records) {
        if (!existingIds.contains(record.id)) {
          existing.add(record);
          imported++;
        }
      }
      
      await _persist(existing);
      return imported;
    } catch (e) {
      debugPrint('Error importing backup: $e');
      return -1;
    }
  }

  /// Limpiar todos los registros (con confirmación)
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }

  /// Estadísticas rápidas
  Future<Map<String, dynamic>> getStats() async {
    final records = await getAll();
    final byType = <HRRecordType, int>{};
    double totalAmount = 0;
    
    for (final r in records) {
      byType[r.type] = (byType[r.type] ?? 0) + 1;
      if (r.amount != null) totalAmount += r.amount!;
    }
    
    return {
      'totalRecords': records.length,
      'totalAmount': totalAmount,
      'byType': byType,
      'planillas': byType[HRRecordType.planilla] ?? 0,
      'liquidaciones': byType[HRRecordType.liquidacion] ?? 0,
    };
  }
}
