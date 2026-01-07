import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'fixed_costs_models.dart';
import 'package:uuid/uuid.dart';

class FixedCostsLogic {
  static const String _storageKey = 'fixed_costs_scenarios';

  // --- CRUD Operations ---
  
  static Future<List<FixedCostsScenario>> loadScenarios() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_storageKey);
    if (data == null) return [];
    
    try {
      final List<dynamic> decoded = json.decode(data);
      return decoded.map((e) => FixedCostsScenario.fromMap(e)).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<void> saveScenario(FixedCostsScenario scenario) async {
    final scenarios = await loadScenarios();
    final index = scenarios.indexWhere((s) => s.id == scenario.id);
    
    if (index >= 0) {
      scenarios[index] = scenario;
    } else {
      scenarios.add(scenario);
    }
    
    await _persistList(scenarios);
  }

  static Future<void> deleteScenario(String id) async {
    final scenarios = await loadScenarios();
    scenarios.removeWhere((s) => s.id == id);
    await _persistList(scenarios);
  }

  static Future<void> _persistList(List<FixedCostsScenario> list) async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = json.encode(list.map((e) => e.toMap()).toList());
    await prefs.setString(_storageKey, encoded);
  }

  // --- Helpers ---

  static FixedCostsScenario createNewScenario(String name) {
    return FixedCostsScenario(
      id: const Uuid().v4(),
      name: name,
      items: [],
      lastUpdated: DateTime.now(),
    );
  }
}
