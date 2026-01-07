import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/checklist_model.dart';
import '../../navigation/app_routes.dart';
import '../../navigation/app_routes.dart';
import '../../logic/business_progress_engine.dart';
import 'business_signals_loader.dart';

class ChecklistRepository {
  // Singleton
  static final ChecklistRepository _instance = ChecklistRepository._internal();
  factory ChecklistRepository() => _instance;
  ChecklistRepository._internal();

  final _dashboardController = StreamController<BusinessProgressModel>.broadcast();
  Stream<BusinessProgressModel> get watchDashboard => _dashboardController.stream;

  final _itemsController = StreamController<List<ChecklistItem>>.broadcast();
  Stream<List<ChecklistItem>> get watchItems => _itemsController.stream;
  List<ChecklistItem> get currentItems => List.unmodifiable(_items);

  List<ChecklistItem> _items = [];
  bool _initialized = false;
  
  // Cache for instant access without awaiting stream
  BusinessProgressModel _currentDashboard = BusinessProgressModel.empty;
  BusinessProgressModel get currentDashboard => _currentDashboard;

  Future<void> init() async {
    if (_initialized) return;
    await _loadFromSignals();
    _initialized = true;
  }

  /// Forces a reload of signals from repositories (Real Data).
  Future<void> refresh() async {
    await _loadFromSignals();
  }

  // --- CRUD ---

  // Legacy toggle removed. New implementation generic handles persistence.

  Future<void> upsertItem(ChecklistItem item) async {
    // Legacy support or if we really need to inject items.
    // With Signals loader, this is less relevant unless we store custom items.
    // For now, ignorable or we just reload.
    await _loadFromSignals();
  }
  
  Future<void> upsertItems(List<ChecklistItem> newItems) async {
    await _loadFromSignals();
  }

  // --- Logic ---

  static const Map<ProgressArea, double> weights = {
    ProgressArea.start: 0.40,
    ProgressArea.payroll: 0.20,
    ProgressArea.accounting: 0.20,
    ProgressArea.marketing: 0.20,
  };

  Future<void> _loadFromSignals() async {
     final prefs = await SharedPreferences.getInstance();
     final loader = BusinessSignalsLoader(prefs);
     
     // 1. Load Base Signals
     var loadedItems = await loader.loadAllSignals();
     
     // 2. Apply Manual Overrides (checklist_done_map)
     final doneMapString = prefs.getString('checklist_done_map');
     if (doneMapString != null) {
       try {
         final Map<String, dynamic> doneMap = json.decode(doneMapString);
         // Apply to items
         loadedItems = loadedItems.map((item) {
           if (doneMap.containsKey(item.id)) {
              return item.copyWith(done: doneMap[item.id] as bool);
           }
           return item;
         }).toList();
       } catch (e) {
         print("Error parsing checklist_done_map: $e");
       }
     }
     
     _items = loadedItems;
     _recalculate();
  }

  Future<void> toggleItemDone(String id) async {
    final prefs = await SharedPreferences.getInstance();
    
    // 1. Get current map
    Map<String, bool> doneMap = {};
    final doneMapString = prefs.getString('checklist_done_map');
    if (doneMapString != null) {
      try {
        doneMap = Map<String, bool>.from(json.decode(doneMapString));
      } catch (_) {}
    }
    
    // 2. Determine new state
    // We need to know current state. Find item in memory.
    final itemIndex = _items.indexWhere((i) => i.id == id);
    if (itemIndex == -1) return; // Item not found
    
    final newItemState = !_items[itemIndex].done;
    
    // 3. Update Map
    doneMap[id] = newItemState;
    
    // 4. Save Map
    await prefs.setString('checklist_done_map', json.encode(doneMap));
    
    // 5. Update Memory & Notify (Optimistic)
    // We could just call _loadFromSignals again, but that's expensive. 
    // Let's update in-place then recalculate.
    _items[itemIndex] = _items[itemIndex].copyWith(done: newItemState);
    _recalculate();
  }

  void _recalculate() {
     // Use Engine
     _currentDashboard = BusinessProgressEngine.buildSummary(
       startItems: _items.where((i) => i.area == ProgressArea.start).toList(), 
       payrollItems: _items.where((i) => i.area == ProgressArea.payroll).toList(), 
       accountingItems: _items.where((i) => i.area == ProgressArea.accounting).toList(), 
       marketingItems: _items.where((i) => i.area == ProgressArea.marketing).toList()
     );
    
    _dashboardController.add(_currentDashboard);
    _itemsController.add(_items);
  }

  // Dropped _findNextGlobalPending in favor of Engine logic.

  // Dropped _saveToPrefs / _loadFromPrefs json logic in favor of Signals.
}
