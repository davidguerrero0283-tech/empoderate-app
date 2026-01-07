import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../calculators/salario_models.dart';
import '../calculators/vacation_models.dart';
import 'package:flutter/foundation.dart';

class WorkerService {
  static final WorkerService _instance = WorkerService._internal();
  factory WorkerService() => _instance;
  WorkerService._internal();

  static const String _storageKey = 'saved_workers_v1';

  Future<List<WorkerProfile>> getWorkers() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_storageKey);
    if (jsonString == null) return [];

    try {
      final List<dynamic> decoded = jsonDecode(jsonString);
      final Map<String, WorkerProfile> uniqueWorkers = {};
      int duplicateCount = 0;
      
      for (var item in decoded) {
        try {
          if (item != null) {
            final worker = WorkerProfile.fromJson(item);
            if (uniqueWorkers.containsKey(worker.id)) {
              duplicateCount++;
              // Optionally choose latest if updatedAt exists, but for now preserve first
              continue; 
            }
            uniqueWorkers[worker.id] = worker;
          }
        } catch (e) {
          debugPrint('Error parsing worker: $e');
        }
      }

      if (duplicateCount > 0 && kDebugMode) {
        debugPrint('⚠️ Warning: Found and removed $duplicateCount duplicate WorkerProfile entries in storage.');
      }

      return uniqueWorkers.values.toList();
    } catch (e) {
      debugPrint('Critical error loading workers: $e');
      return [];
    }
  }

  Future<WorkerProfile?> getWorkerById(String id) async {
    final workers = await getWorkers();
    try {
      return workers.firstWhere((w) => w.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> saveWorker(WorkerProfile worker) async {
    final workers = await getWorkers();
    
    // Check if exists to update
    final index = workers.indexWhere((w) => w.id == worker.id);
    if (index >= 0) {
      workers[index] = worker;
    } else {
      workers.add(worker);
    }
    
    await _persist(workers);
  }

  Future<void> deleteWorker(String id) async {
    final workers = await getWorkers();
    workers.removeWhere((w) => w.id == id);
    await _persist(workers);
  }

  Future<void> _persist(List<WorkerProfile> workers) async {
    final prefs = await SharedPreferences.getInstance();
    final String jsonString = jsonEncode(workers.map((w) => w.toJson()).toList());
    await prefs.setString(_storageKey, jsonString);
  }

  /// Seeds 10 test employees for testing purposes
  Future<void> seedTestWorkers() async {
    final testWorkers = [
      WorkerProfile(
        id: 'test_001',
        name: 'María García López',
        cedula: '8-123-4567',
        position: 'Gerente de Ventas',
        department: 'Ventas',
        basePayment: 2500.00,
        paymentType: PaymentType.base,
        paymentMode: PayrollFrequency.quincenal,
        contractType: WorkerContractType.indefinido,
        startDate: DateTime(2020, 3, 15),
        notes: 'Empleada del mes - Enero 2026',
      ),
      WorkerProfile(
        id: 'test_002',
        name: 'Carlos Rodríguez Pérez',
        cedula: '8-234-5678',
        position: 'Supervisor de Turno',
        department: 'Operaciones',
        basePayment: 1800.00,
        paymentType: PaymentType.base,
        paymentMode: PayrollFrequency.quincenal,
        contractType: WorkerContractType.indefinido,
        startDate: DateTime(2021, 6, 1),
        notes: '',
      ),
      WorkerProfile(
        id: 'test_003',
        name: 'Ana Martínez Sánchez',
        cedula: '8-345-6789',
        position: 'Cajera',
        department: 'Ventas',
        basePayment: 0.0,
        paymentType: PaymentType.hourly,
        hourlyRate: 5.50,
        paymentMode: PayrollFrequency.quincenal,
        contractType: WorkerContractType.definido,
        startDate: DateTime(2024, 1, 10),
        notes: 'Contrato hasta Diciembre 2026',
      ),
      WorkerProfile(
        id: 'test_004',
        name: 'José Hernández Díaz',
        cedula: '8-456-7890',
        position: 'Cocinero Principal',
        department: 'Cocina',
        basePayment: 1500.00,
        paymentType: PaymentType.base,
        paymentMode: PayrollFrequency.quincenal,
        contractType: WorkerContractType.indefinido,
        startDate: DateTime(2019, 8, 20),
        notes: 'Certificado en manipulación de alimentos',
      ),
      WorkerProfile(
        id: 'test_005',
        name: 'Laura Jiménez Torres',
        cedula: '8-567-8901',
        position: 'Asistente Administrativo',
        department: 'Administración',
        basePayment: 1200.00,
        paymentType: PaymentType.base,
        paymentMode: PayrollFrequency.mensual,
        contractType: WorkerContractType.indefinido,
        startDate: DateTime(2022, 2, 14),
        notes: '',
      ),
      WorkerProfile(
        id: 'test_006',
        name: 'Pedro Morales Ruiz',
        cedula: '8-678-9012',
        position: 'Mesero',
        department: 'Servicio',
        basePayment: 0.0,
        paymentType: PaymentType.hourly,
        hourlyRate: 4.75,
        paymentMode: PayrollFrequency.quincenal,
        contractType: WorkerContractType.definido,
        startDate: DateTime(2025, 6, 1),
        notes: 'Período de prueba',
      ),
      WorkerProfile(
        id: 'test_007',
        name: 'Sofía Castillo Mendoza',
        cedula: '8-789-0123',
        position: 'Contadora',
        department: 'Finanzas',
        basePayment: 2800.00,
        paymentType: PaymentType.base,
        paymentMode: PayrollFrequency.mensual,
        contractType: WorkerContractType.indefinido,
        startDate: DateTime(2018, 11, 5),
        notes: 'CPA Certificada',
      ),
      WorkerProfile(
        id: 'test_008',
        name: 'Diego Vargas Luna',
        cedula: '8-890-1234',
        position: 'Seguridad',
        department: 'Operaciones',
        basePayment: 900.00,
        paymentType: PaymentType.base,
        paymentMode: PayrollFrequency.quincenal,
        contractType: WorkerContractType.indefinido,
        startDate: DateTime(2023, 4, 18),
        notes: 'Turno nocturno',
      ),
      WorkerProfile(
        id: 'test_009',
        name: 'Valeria Núñez Castro',
        cedula: '8-901-2345',
        position: 'Auxiliar de Cocina',
        department: 'Cocina',
        basePayment: 0.0,
        paymentType: PaymentType.hourly,
        hourlyRate: 4.25,
        paymentMode: PayrollFrequency.quincenal,
        contractType: WorkerContractType.definido,
        startDate: DateTime(2025, 9, 1),
        notes: '',
      ),
      WorkerProfile(
        id: 'test_010',
        name: 'Roberto Aguilar Vega',
        cedula: '8-012-3456',
        position: 'Repartidor',
        department: 'Logística',
        basePayment: 800.00,
        paymentType: PaymentType.base,
        paymentMode: PayrollFrequency.quincenal,
        contractType: WorkerContractType.indefinido,
        startDate: DateTime(2024, 7, 22),
        notes: 'Licencia de conducir vigente',
      ),
      WorkerProfile(
        id: 'test_011',
        name: 'Juan Pérez Test',
        cedula: '8-999-9999',
        position: 'Analista de Integración',
        department: 'Tecnología',
        basePayment: 3000.00,
        paymentType: PaymentType.base,
        paymentMode: PayrollFrequency.quincenal,
        contractType: WorkerContractType.indefinido,
        startDate: DateTime(2022, 1, 1),
        vacationHistory: [
          VacationRecord(
            id: 'vac_001',
            startDate: DateTime(2026, 1, 5),
            endDate: DateTime(2026, 1, 15),
            daysTaken: 11,
            amountPaid: 1100.0,
            createdAt: DateTime.now(),
          ),
        ],
        notes: 'Worker for integration verification. Has vacations in Jan 2026.',
      ),
    ];

    final workers = await getWorkers();
    for (var testWorker in testWorkers) {
      final index = workers.indexWhere((w) => w.id == testWorker.id);
      if (index >= 0) {
        workers[index] = testWorker;
      } else {
        workers.add(testWorker);
      }
    }
    await _persist(workers);
  }

  /// Removes all test workers (IDs starting with 'test_')
  Future<void> clearTestWorkers() async {
    final workers = await getWorkers();
    workers.removeWhere((w) => w.id.startsWith('test_'));
    await _persist(workers);
  }
}
