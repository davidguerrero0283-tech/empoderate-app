
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'payroll_obligation_model.dart';

class PayrollObligationsRepository {
  // Singleton
  static final PayrollObligationsRepository _instance = PayrollObligationsRepository._internal();
  factory PayrollObligationsRepository() => _instance;
  PayrollObligationsRepository._internal();

  // Key format: payroll.obligations.YYYY-MM
  String _getKey(int year, int month) => 'payroll.obligations.$year-$month';

  Future<List<PayrollObligation>> getMonth(int year, int month) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getKey(year, month);
    final jsonStr = prefs.getString(key);
    
    if (jsonStr == null) return [];

    try {
      final List<dynamic> list = jsonDecode(jsonStr);
      return list.map((e) => PayrollObligation.fromJson(e)).toList();
    } catch (e) {
      print('Error parsing payroll obligations for $key: $e');
      return [];
    }
  }

  Future<void> saveMonth(int year, int month, List<PayrollObligation> obligations) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getKey(year, month);
    final jsonStr = jsonEncode(obligations.map((e) => e.toJson()).toList());
    await prefs.setString(key, jsonStr);
    
    // Also trigger signal update if needed (ChecklistRepo polls or reloads)
    // But ChecklistRepo relies on BusinessSignalsLoader which reads this same key.
    // So usually a refresh elsewhere is needed.
  }

  Future<void> addObligation(int year, int month, PayrollObligation obligation) async {
    final list = await getMonth(year, month);
    list.add(obligation);
    await saveMonth(year, month, list);
  }

  Future<void> updateObligation(int year, int month, PayrollObligation obligation) async {
    final list = await getMonth(year, month);
    final index = list.indexWhere((o) => o.id == obligation.id);
    if (index != -1) {
      list[index] = obligation;
      await saveMonth(year, month, list);
    }
  }

  Future<void> deleteObligation(int year, int month, String id) async {
    final list = await getMonth(year, month);
    list.removeWhere((o) => o.id == id);
    await saveMonth(year, month, list);
  }

  Future<void> toggleDone(int year, int month, String id) async {
    final list = await getMonth(year, month);
    final index = list.indexWhere((o) => o.id == id);
    if (index != -1) {
      final old = list[index];
      list[index] = old.copyWith(
        isDone: !old.isDone,
        updatedAt: DateTime.now(),
      );
      await saveMonth(year, month, list);
    }
  }
}
