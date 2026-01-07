import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/ai_text_output.dart';

class AiTextsRepository {
  static const String _storageKey = 'empoderate_ai_texts';

  Future<void> save(AiTextOutput output) async {
    final prefs = await SharedPreferences.getInstance();
    final items = await list();
    items.insert(0, output); // Add to beginning
    
    // Limit storage to last 50 items to avoid bloating SharedPreferences
    final limitedItems = items.take(50).toList();
    
    final jsonList = limitedItems.map((i) => jsonEncode(i.toJson())).toList();
    await prefs.setStringList(_storageKey, jsonList);
  }

  Future<List<AiTextOutput>> list() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_storageKey) ?? [];
    return jsonList.map((j) => AiTextOutput.fromJson(jsonDecode(j))).toList();
  }

  Future<void> delete(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final items = await list();
    items.removeWhere((i) => i.id == id);
    final jsonList = items.map((i) => jsonEncode(i.toJson())).toList();
    await prefs.setStringList(_storageKey, jsonList);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}
