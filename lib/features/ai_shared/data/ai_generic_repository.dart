import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/ai_generic_output.dart';
import '../domain/ai_shared_types.dart';

class AiGenericRepository {
  // We'll use one key but maybe filter in memory, or use keys per type.
  // For simplicity, let's use keys per type.
  
  String _getKey(AiFeatureType type) => 'ai_generic_saved_${type.name}';

  Future<void> save(AiFeatureType type, AiGenericOutput output) async {
    final prefs = await SharedPreferences.getInstance();
    final saved = await list(type);
    
    // limit to 30 items per type
    if (saved.length >= 30) saved.removeLast();
    
    saved.insert(0, output);
    
    final List<String> encoded = saved.map((o) => jsonEncode(o.toJson())).toList();
    await prefs.setStringList(_getKey(type), encoded);
  }

  Future<List<AiGenericOutput>> list(AiFeatureType type) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? encoded = prefs.getStringList(_getKey(type));
    if (encoded == null) return [];
    
    return encoded.map((s) => AiGenericOutput.fromJson(jsonDecode(s))).toList();
  }

  Future<void> delete(AiFeatureType type, String id) async {
    final prefs = await SharedPreferences.getInstance();
    final saved = await list(type);
    saved.removeWhere((o) => o.id == id);
    
    final List<String> encoded = saved.map((o) => jsonEncode(o.toJson())).toList();
    await prefs.setStringList(_getKey(type), encoded);
  }
}
