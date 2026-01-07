import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/ai_customer_output.dart';

class AiCustomersRepository {
  static const String _storageKey = 'ai_customers_saved';

  Future<void> save(AiCustomerOutput output) async {
    final prefs = await SharedPreferences.getInstance();
    final saved = await list();
    
    // limit to 50 items
    if (saved.length >= 50) saved.removeLast();
    
    saved.insert(0, output);
    
    final List<String> encoded = saved.map((o) => jsonEncode(o.toJson())).toList();
    await prefs.setStringList(_storageKey, encoded);
  }

  Future<List<AiCustomerOutput>> list() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? encoded = prefs.getStringList(_storageKey);
    if (encoded == null) return [];
    
    return encoded.map((s) => AiCustomerOutput.fromJson(jsonDecode(s))).toList();
  }

  Future<void> delete(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final saved = await list();
    saved.removeWhere((o) => o.id == id);
    
    final List<String> encoded = saved.map((o) => jsonEncode(o.toJson())).toList();
    await prefs.setStringList(_storageKey, encoded);
  }
}
