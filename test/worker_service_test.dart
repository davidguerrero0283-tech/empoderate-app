import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:proyecto_empoderate/src/services/worker_service.dart';
import 'package:proyecto_empoderate/src/calculators/salario_models.dart';
import 'dart:convert';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('WorkerService Deduplication Tests', () {
    late WorkerService workerService;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      workerService = WorkerService();
    });

    test('getWorkers should remove duplicate IDs', () async {
      final prefs = await SharedPreferences.getInstance();
      
      final workersJson = [
        {
          'id': '1',
          'name': 'Worker 1',
          'position': 'Pos 1',
          'department': 'Dept 1',
          'paymentMode': 0,
          'basePayment': 1000.0,
        },
        {
          'id': '2',
          'name': 'Worker 2',
          'position': 'Pos 2',
          'department': 'Dept 2',
          'paymentMode': 0,
          'basePayment': 2000.0,
        },
        {
          'id': '1', // DUPLICATE ID
          'name': 'Worker 1 Alternate',
          'position': 'Pos 1 Alt',
          'department': 'Dept 1 Alt',
          'paymentMode': 0,
          'basePayment': 1500.0,
        }
      ];

      await prefs.setString('saved_workers_v1', jsonEncode(workersJson));

      final workers = await workerService.getWorkers();

      expect(workers.length, 2);
      expect(workers[0].id, '1');
      expect(workers[1].id, '2');
      // Should preserve the first one encountered
      expect(workers[0].name, 'Worker 1');
    });

    test('getWorkers should handle empty storage', () async {
      final workers = await workerService.getWorkers();
      expect(workers, isEmpty);
    });
  });
}
