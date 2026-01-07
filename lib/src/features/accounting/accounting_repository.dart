
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AccountingRepository {
  static final AccountingRepository _instance = AccountingRepository._internal();
  factory AccountingRepository() => _instance;
  AccountingRepository._internal();

  static const String _keyPrefix = 'accounting.results.';

  // Milestone Types
  static const String typeBudget = 'budget';
  static const String typeCashFlow = 'cashflow';
  static const String typeBreakEven = 'breakeven';
  static const String typeMargin = 'margin';
  static const String typeTax = 'tax';

  Future<void> saveResult(String type, Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_keyPrefix$type.latest';
    
    // Add metadata
    final payload = {
      ...data,
      'updatedAt': DateTime.now().toIso8601String(),
    };

    await prefs.setString(key, jsonEncode(payload));
  }

  Future<Map<String, dynamic>?> getLastResult(String type) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_keyPrefix$type.latest';
    final jsonStr = prefs.getString(key);
    
    if (jsonStr != null) {
      try {
        return jsonDecode(jsonStr);
      } catch (e) {
        print('Error decoding accounting result for $type: $e');
      }
    }
    return null;
  }

  Future<List<String>> getCompletedMilestones() async {
    final prefs = await SharedPreferences.getInstance();
    final milestones = <String>[];
    
    if (prefs.containsKey('${_keyPrefix}$typeBudget.latest')) milestones.add(typeBudget);
    if (prefs.containsKey('${_keyPrefix}$typeCashFlow.latest')) milestones.add(typeCashFlow);
    if (prefs.containsKey('${_keyPrefix}$typeBreakEven.latest')) milestones.add(typeBreakEven);
    if (prefs.containsKey('${_keyPrefix}$typeMargin.latest')) milestones.add(typeMargin);
    // Tax is optional/advanced, might not count for "basic" completion yet, but let's include if present
    if (prefs.containsKey('${_keyPrefix}$typeTax.latest')) milestones.add(typeTax);

    return milestones;
  }
}
