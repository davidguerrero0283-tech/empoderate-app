// Repository for Agenda de Trámites
// Handles persistence using SharedPreferences

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../domain/tramite_event.dart';
import '../domain/agenda_rules.dart';

class AgendaRepository {
  static const String _storageKey = 'agenda_tramites_v1';
  static final _uuid = Uuid();

  List<TramiteEvent>? _cache;

  /// Load all tramites from storage
  Future<List<TramiteEvent>> loadAll() async {
    if (_cache != null) {
      return _cache!;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);

      if (jsonString == null || jsonString.isEmpty) {
        await seedDefaultsIfEmpty();
        return _cache!;
      }

      final List<dynamic> jsonList = jsonDecode(jsonString);
      _cache = jsonList.map((json) => TramiteEvent.fromJson(json)).toList();
      
      // Recalculate all tramites to update states
      _cache = _cache!.map((t) => AgendaRules.recalcular(t)).toList();
      await _saveCache();

      return _cache!;
    } catch (e) {
      print('Error loading tramites: $e');
      await seedDefaultsIfEmpty();
      return _cache!;
    }
  }

  /// Save or update a tramite
  Future<void> upsert(TramiteEvent event) async {
    await loadAll(); // Ensure cache is loaded

    final index = _cache!.indexWhere((t) => t.id == event.id);
    if (index >= 0) {
      _cache![index] = event;
    } else {
      _cache!.add(event);
    }

    await _saveCache();
  }

  /// Delete a tramite
  Future<void> delete(String id) async {
    await loadAll(); // Ensure cache is loaded
    _cache!.removeWhere((t) => t.id == id);
    await _saveCache();
  }

  /// Save cache to storage
  Future<void> _saveCache() async {
    if (_cache == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = _cache!.map((t) => t.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      await prefs.setString(_storageKey, jsonString);
    } catch (e) {
      print('Error saving tramites: $e');
    }
  }

  /// Seed default tramites if storage is empty
  Future<void> seedDefaultsIfEmpty() async {
    final now = DateTime.now();
    
    _cache = [
      // 1. Declaración de Renta (DGI) - Anual
      TramiteEvent(
        id: _uuid.v4(),
        titulo: 'Declaración de Renta',
        categoria: CategoriaEntidad.dgi,
        entidad: 'DGI',
        descripcion: 'Declaración anual de impuesto sobre la renta',
        fechaInicio: DateTime(now.year, 3, 1),
        periodicidad: Periodicidad.anual,
        proximaFecha: DateTime(now.year, 3, 1),
        diasAnticipacionAlerta: 30,
        estado: EstadoTramite.pendiente,
        notas: 'Generalmente vence en marzo. Verificar fecha exacta según calendario fiscal.',
        createdAt: now,
        updatedAt: now,
      ),

      // 2. Tributos Municipales - Mensual
      TramiteEvent(
        id: _uuid.v4(),
        titulo: 'Tributos Municipales',
        categoria: CategoriaEntidad.municipio,
        entidad: 'Municipio',
        descripcion: 'Pago mensual de tributos municipales',
        fechaInicio: DateTime(now.year, now.month, 15),
        periodicidad: Periodicidad.mensual,
        proximaFecha: DateTime(now.year, now.month, 15),
        diasAnticipacionAlerta: 7,
        estado: EstadoTramite.pendiente,
        notas: 'Pago mensual. Verificar fecha límite según municipio.',
        createdAt: now,
        updatedAt: now,
      ),

      // 3. Operación Jurada - Anual
      TramiteEvent(
        id: _uuid.v4(),
        titulo: 'Operación Jurada',
        categoria: CategoriaEntidad.municipio,
        entidad: 'Municipio',
        descripcion: 'Declaración jurada de operaciones anuales',
        fechaInicio: DateTime(now.year, 1, 31),
        periodicidad: Periodicidad.anual,
        proximaFecha: DateTime(now.year, 1, 31),
        diasAnticipacionAlerta: 15,
        estado: EstadoTramite.pendiente,
        notas: 'Presentar antes del 31 de enero de cada año.',
        createdAt: now,
        updatedAt: now,
      ),

      // 4. Aviso de Operación
      TramiteEvent(
        id: _uuid.v4(),
        titulo: 'Renovación Aviso de Operación',
        categoria: CategoriaEntidad.municipio,
        entidad: 'Municipio',
        descripcion: 'Renovación anual del aviso de operación',
        fechaInicio: DateTime(now.year, 12, 31),
        periodicidad: Periodicidad.anual,
        proximaFecha: DateTime(now.year, 12, 31),
        diasAnticipacionAlerta: 30,
        estado: EstadoTramite.pendiente,
        notas: 'Renovar anualmente. Verificar requisitos específicos del municipio.',
        createdAt: now,
        updatedAt: now,
      ),

      // 5. CSS/SIPE - Mensual
      TramiteEvent(
        id: _uuid.v4(),
        titulo: 'Pago CSS/SIPE',
        categoria: CategoriaEntidad.css,
        entidad: 'CSS',
        descripcion: 'Pago mensual de cuotas obrero-patronales',
        fechaInicio: DateTime(now.year, now.month, 10),
        periodicidad: Periodicidad.mensual,
        proximaFecha: DateTime(now.year, now.month, 10),
        diasAnticipacionAlerta: 5,
        estado: EstadoTramite.pendiente,
        notas: 'Pago antes del día 10 de cada mes.',
        createdAt: now,
        updatedAt: now,
      ),

      // 6. Carnet de Salud - Anual
      TramiteEvent(
        id: _uuid.v4(),
        titulo: 'Renovación Carnets de Salud',
        categoria: CategoriaEntidad.minsa,
        entidad: 'MINSA',
        descripcion: 'Renovación de carnets de salud de colaboradores',
        fechaInicio: DateTime(now.year, now.month, 1),
        periodicidad: Periodicidad.anual,
        proximaFecha: DateTime(now.year, now.month, 1),
        diasAnticipacionAlerta: 30,
        estado: EstadoTramite.pendiente,
        notas: 'Verificar vencimiento individual de cada colaborador.',
        createdAt: now,
        updatedAt: now,
      ),

      // 7. Fumigación - Cada 90 días
      TramiteEvent(
        id: _uuid.v4(),
        titulo: 'Certificado de Fumigación',
        categoria: CategoriaEntidad.minsa,
        entidad: 'MINSA',
        descripcion: 'Fumigación periódica del establecimiento',
        fechaInicio: now,
        periodicidad: Periodicidad.personalizada,
        cadaXDias: 90,
        proximaFecha: now.add(Duration(days: 90)),
        diasAnticipacionAlerta: 7,
        estado: EstadoTramite.alDia,
        notas: 'Obligatorio para establecimientos. Frecuencia: cada 90 días.',
        createdAt: now,
        updatedAt: now,
      ),

      // 8. Renovación Permisos
      TramiteEvent(
        id: _uuid.v4(),
        titulo: 'Renovación de Permisos',
        categoria: CategoriaEntidad.otro,
        entidad: 'Varios',
        descripcion: 'Renovación de permisos y licencias varias',
        fechaInicio: DateTime(now.year, 12, 31),
        periodicidad: Periodicidad.anual,
        proximaFecha: DateTime(now.year, 12, 31),
        diasAnticipacionAlerta: 30,
        estado: EstadoTramite.pendiente,
        notas: 'Verificar permisos específicos según tipo de negocio.',
        createdAt: now,
        updatedAt: now,
      ),
    ];

    // Recalculate all
    _cache = _cache!.map((t) => AgendaRules.recalcular(t)).toList();
    await _saveCache();
  }
}
