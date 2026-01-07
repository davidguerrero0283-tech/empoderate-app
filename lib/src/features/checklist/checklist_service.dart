import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'checklist_model.dart';
import 'checklist_data.dart';

class ChecklistService {
  static const String _storageKey = 'checklist_status_v1';

  // Load items, merging with saved status
  static Future<List<ChecklistItem>> loadItems({String? rubroId}) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Determine which list to use
    List<ChecklistItem> items;
    
    if (rubroId != null) {
       // Filter rubro specific items
       items = List.from(ChecklistData.rubroItems.where((i) => i.rubroId == rubroId).map((e) => 
        ChecklistItem(
          id: e.id,
          title: e.title,
          description: e.description, 
          category: e.category,
          frequency: e.frequency,
          toolRoute: e.toolRoute,
          rubroId: e.rubroId
        )
      ));
      
    } else {
      // Default Global Items
      items = List.from(ChecklistData.defaultItems.map((e) => 
        ChecklistItem(
          id: e.id,
          title: e.title,
          description: e.description, 
          category: e.category,
          frequency: e.frequency,
          toolRoute: e.toolRoute
        )
      )); 
    }
    
    // Load Saved Status (Global Key for simplicity or specific keys if needed)
    // We use a single large JSON for all IDs to keep it simple.
    final String? savedJson = prefs.getString(_storageKey);
    
    if (savedJson != null) {
      try {
        final Map<String, dynamic> savedStatus = json.decode(savedJson);
        
        for (var item in items) {
          if (savedStatus.containsKey(item.id)) {
            item.isCompleted = savedStatus[item.id];
          }
        }
      } catch (e) {
        print('Error parsing checklist status: $e');
      }
    }
    
    return items;
  }


  static Future<void> saveStatus(List<ChecklistItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, bool> statusMap = {
      for (var item in items) item.id: item.isCompleted
    };
    
    await prefs.setString(_storageKey, json.encode(statusMap));
  }

  static Future<void> resetAll() async {
     final prefs = await SharedPreferences.getInstance();
     await prefs.remove(_storageKey);
  }
}
