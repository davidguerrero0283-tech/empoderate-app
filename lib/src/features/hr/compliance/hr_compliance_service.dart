import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'hr_compliance_models.dart';

class HrComplianceService {
  static final HrComplianceService _instance = HrComplianceService._internal();
  factory HrComplianceService() => _instance;
  HrComplianceService._internal();

  static const String _catalogKey = 'hr_obligation_catalog';
  static const String _contextKey = 'hr_business_context';
  static const String _recordsKey = 'hr_compliance_records';

  // ... existing methods ...

  // --- Business Context ---
  Future<Map<String, dynamic>?> getBusinessContext() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_contextKey);
    if (jsonStr != null) return jsonDecode(jsonStr);
    return null;
  }

  Future<void> saveBusinessContext(Map<String, dynamic> context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_contextKey, jsonEncode(context));
  }

  // --- Manual Creation ---
  Future<void> createManualObligation(HrObligationCatalog item, bool createForCurrentMonth, int year, int month, {bool saveToCatalog = false}) async {
     // If user doesn't want it in catalog for future, mark inactive or 'one-off'
     // We must save it to catalog so the ID reference works for the Record
     if (!saveToCatalog) {
       item = HrObligationCatalog(
         id: item.id,
         title: item.title,
         frequency: 'one_off', // Mark as one-off
         category: item.category,
         priority: item.priority,
         active: false, // Hide from active catalog list
         dueRule: item.dueRule,
         responsible: item.responsible,
       );
     }

     await saveCatalogItem(item);

     // Always create instance for current month if requested (which is always true for manual modal now)
     if (createForCurrentMonth) {
       // Check if instance exists
       final exists = _records.any((r) => r.obligationId == item.id && r.periodYear == year && r.periodMonth == month);
       if (!exists) {
          _records.add(HrComplianceRecord(
            id: _generateId(),
            obligationId: item.id,
            periodYear: year,
            periodMonth: month,
            status: 'pending',
          ));
          await _saveRecords();
       }
     }
  }

  // --- Templates Logic ---
  List<Map<String, dynamic>> getTemplates() {
    return [
      {
        'id': 'general_commerce',
        'name': 'Comercio General',
        'icon': 'store',
        'obligations': [
          {'title': 'Planilla Mensual', 'category': 'planilla', 'frequency': 'monthly', 'dueRule': 'Día 15 y 30', 'priority': 'alta'},
          {'title': 'Pago SIPE (CSS)', 'category': 'seguridad_social', 'frequency': 'monthly', 'dueRule': 'Fin de mes', 'priority': 'alta'},
          {'title': 'Informe DGI 03', 'category': 'reportes', 'frequency': 'monthly', 'dueRule': 'Fin de mes', 'priority': 'media'},
        ]
      },
      {
        'id': 'restaurant',
        'name': 'Restaurante / Bar',
        'icon': 'restaurant',
        'obligations': [
           {'title': 'Carnets de Salud (Renovación)', 'category': 'permisos', 'frequency': 'annual', 'dueRule': 'Anual', 'priority': 'alta'},
           {'title': 'Fumigación / Control Plagas', 'category': 'sanidad', 'frequency': 'event', 'dueRule': 'Trimestral', 'priority': 'alta'},
           {'title': 'Pago Municipales', 'category': 'impuestos', 'frequency': 'monthly', 'dueRule': 'Día 15', 'priority': 'media'},
        ]
      },
      {
        'id': 'professional',
        'name': 'Servicios Profesionales',
        'icon': 'work',
        'obligations': [
           {'title': 'Facturación Electrónica', 'category': 'reportes', 'frequency': 'monthly', 'dueRule': 'Día 15', 'priority': 'alta'},
           {'title': 'Declaración de Renta', 'category': 'impuestos', 'frequency': 'annual', 'dueRule': 'Marzo', 'priority': 'alta'},
        ]
      },
      {
        'id': 'domestic',
        'name': 'Doméstico',
        'icon': 'home',
        'obligations': [
           {'title': 'Pago SIPE (Doméstico)', 'category': 'seguridad_social', 'frequency': 'monthly', 'dueRule': 'Fin de mes', 'priority': 'media'},
           {'title': 'Décimo Tercer Mes', 'category': 'pagos', 'frequency': 'event', 'dueRule': 'Abr/Ago/Dic', 'priority': 'alta'},
        ]
      },
    ];
  }

  Future<int> applyTemplate(String templateId, int year, int month) async {
    if (!_initialized) await init();
    
    final templates = getTemplates();
    final template = templates.firstWhere((t) => t['id'] == templateId, orElse: () => {});
    
    if (template.isEmpty || template['obligations'] == null) return 0;
    
    final List<Map<String, dynamic>> obligations = template['obligations'];
    int addedCount = 0;

    for (var ob in obligations) {
       // Reuse basic creation logic (similar to AI application)
       // 1. Ensure Catalog Item Exists
       var catalogItem = _catalog.firstWhere(
          (c) => c.title.toLowerCase() == ob['title'].toString().toLowerCase(),
          orElse: () => HrObligationCatalog(id: '', title: '', frequency: '', category: '', priority: '', active: false, responsible: '')
       );

       String obligationId = catalogItem.id;
       if (obligationId.isEmpty) {
          obligationId = _generateId();
          final newItem = HrObligationCatalog(
             id: obligationId,
             title: ob['title'],
             category: ob['category'],
             frequency: ob['frequency'],
             priority: ob['priority'],
             dueRule: ob['dueRule'],
             responsible: 'Plantilla',
             active: true 
          );
          _catalog.add(newItem);
          await _saveCatalog();
       }

       // 2. Ensure Instance for this month
       final hasInstance = _records.any((r) => r.obligationId == obligationId && r.periodYear == year && r.periodMonth == month);
       if (!hasInstance) {
          _records.add(HrComplianceRecord(
             id: _generateId(),
             obligationId: obligationId,
             periodYear: year,
             periodMonth: month,
             status: 'pending',
             evidenceNote: 'Aplicado desde plantilla: ${template['name']}'
          ));
          addedCount++;
       }
    }
    
    if (addedCount > 0) await _saveRecords();
    return addedCount;
  }

  // --- AI Logic ---
  Future<List<Map<String, dynamic>>> simulateAiSuggestions(Map<String, dynamic> context, int month) async {
    // Mock AI Logic based on context
    // Returns basic map structures to be reviewed by UI
    await Future.delayed(const Duration(milliseconds: 1500)); // Simulate thinking

    final List<Map<String, dynamic>> suggestions = [];
    final type = context['type'] ?? 'Comercio';
    final hasEmployees = context['has_employees'] == true;
    
    // Base suggestions
    suggestions.add({
       'title': 'Revisión de Extintores',
       'category': 'seguridad',
       'frequency': 'annual', // Ideally check if this month matches, but simplification
       'dueRule': 'Vence este mes',
       'priority': 'alta',
       'reason': 'Obligatorio anualmente para $type'
    });

    if (hasEmployees) {
       suggestions.add({
         'title': 'Pago Voluntario SIPE',
         'category': 'seguridad_social',
         'frequency': 'monthly',
         'dueRule': 'Día 15',
         'priority': 'media',
         'reason': 'Recomendado por tener empleados'
       });
       if (month == 12) {
          suggestions.add({
             'title': 'Cálculo de Aguinaldos',
             'category': 'pagos',
             'frequency': 'event',
             'dueRule': 'Antes del 20',
             'priority': 'alta',
             'reason': 'Diciembre: mes de aguinaldos'
          });
       }
    }
    
    return suggestions;
  }

  Future<int> applyAiSuggestions(List<Map<String, dynamic>> approvedSuggestions, int year, int month) async {
    if (!_initialized) await init();
    int addedCount = 0;

    for (var s in approvedSuggestions) {
       // 1. Dedupe Catalog (by title + category roughly)
       // This is a fuzzy match for the demo
       var catalogItem = _catalog.firstWhere(
          (c) => c.title.toLowerCase() == s['title'].toString().toLowerCase(),
          orElse: () => HrObligationCatalog(id: '', title: '', frequency: '', category: '', priority: '', active: false, responsible: '')
       );

       String obligationId = catalogItem.id;

       if (obligationId.isEmpty) {
          // Create new catalog item
          obligationId = _generateId();
          final newItem = HrObligationCatalog(
             id: obligationId,
             title: s['title'],
             category: s['category'],
             frequency: s['frequency'],
             priority: s['priority'],
             dueRule: s['dueRule'],
             responsible: 'IA Sugerido',
             active: true // Auto-active if approved
          );
          _catalog.add(newItem);
          await _saveCatalog();
       }

       // 2. Check Instance for this month
       final hasInstance = _records.any((r) => r.obligationId == obligationId && r.periodYear == year && r.periodMonth == month);
       if (!hasInstance) {
          _records.add(HrComplianceRecord(
             id: _generateId(),
             obligationId: obligationId,
             periodYear: year,
             periodMonth: month,
             status: 'pending',
             evidenceNote: 'Sugerencia IA: ${s['reason']}'
          ));
          addedCount++;
       }
    }
    
    if (addedCount > 0) await _saveRecords();
    return addedCount;
  }

  List<HrObligationCatalog> _catalog = [];
  List<HrComplianceRecord> _records = [];
  bool _initialized = false;

  String _generateId() {
    return '${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(10000)}';
  }

  Future<void> init() async {
    print('HrComplianceService: init started');
    if (_initialized) {
      print('HrComplianceService: already initialized');
      return;
    }
    await _loadData();
    _initialized = true;
    print('HrComplianceService: init completed');
  }

  Future<void> _loadData() async {
    print('HrComplianceService: _loadData started');
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load Catalog
      final catalogString = prefs.getString(_catalogKey);
      print('HrComplianceService: loaded catalog string: $catalogString');
      if (catalogString != null) {
        final List<dynamic> jsonList = jsonDecode(catalogString);
        _catalog = jsonList.map((e) => HrObligationCatalog.fromJson(e)).toList();
        print('HrComplianceService: parsed ${_catalog.length} catalog items');
      } 

      // Load Records
      final recordsString = prefs.getString(_recordsKey);
      if (recordsString != null) {
        final List<dynamic> jsonList = jsonDecode(recordsString);
        _records = jsonList.map((e) => HrComplianceRecord.fromJson(e)).toList();
      }
    } catch (e) {
      print('HrComplianceService: ERROR loading data: $e');
    }
  }

  Future<void> _saveCatalog() async {
    print('HrComplianceService: _saveCatalog started. Items: ${_catalog.length}');
    try {
      final prefs = await SharedPreferences.getInstance();
      final String data = jsonEncode(_catalog.map((e) => e.toJson()).toList());
      await prefs.setString(_catalogKey, data);
      print('HrComplianceService: _saveCatalog success. Data length: ${data.length}');
    } catch (e) {
      print('HrComplianceService: ERROR saving catalog: $e');
    }
  }

  Future<void> _saveRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final String data = jsonEncode(_records.map((e) => e.toJson()).toList());
    await prefs.setString(_recordsKey, data);
  }

  List<HrObligationCatalog> getCatalog() => _catalog;

  /// Returns records for a specific period. 
  /// If records don't exist, it generates 'pending' records based on the catalog.
  Future<List<HrComplianceRecord>> getRecordsForPeriod(int year, int month) async {
    if (!_initialized) await init();

    if (_catalog.isEmpty) return [];

    // Filter existing
    final existing = _records.where((r) => r.periodYear == year && r.periodMonth == month).toList();
    
    // Check if we miss any active obligation for this month
    final activeMonthly = _catalog.where((o) => o.active && o.frequency == 'monthly').toList();
    // (Ignoring quarterly/annual logic for this MVP simplicity, focused on Monthly view)

    bool changesMade = false;
    for (final ob in activeMonthly) {
      final hasRecord = existing.any((r) => r.obligationId == ob.id);
      if (!hasRecord) {
        final newRecord = HrComplianceRecord(
          id: _generateId(),
          obligationId: ob.id,
          periodYear: year,
          periodMonth: month,
          status: 'pending',
        );
        _records.add(newRecord);
        existing.add(newRecord);
        changesMade = true;
      }
    }

    if (changesMade) await _saveRecords();

    return existing;
  }
  
  Map<String, dynamic> getAnnualStats(int year) {
     // rudimentary stats
     int total = 0;
     int completed = 0;
     
     final yearRecords = _records.where((r) => r.periodYear == year).toList();
     total = yearRecords.length;
     completed = yearRecords.where((r) => r.status == 'completed').length;
     
     return {
       'total': total,
       'completed': completed,
       'percent': total == 0 ? 0.0 : (completed / total),
     };
  }
  
  List<double> getMonthlyCompletionStats(int year) {
    List<double> monthlyStats = List.filled(12, 0.0);
    
    for (int i = 1; i <= 12; i++) {
       final monthRecords = _records.where((r) => r.periodYear == year && r.periodMonth == i).toList();
       if (monthRecords.isEmpty) {
         monthlyStats[i-1] = 0.0;
       } else {
         final completed = monthRecords.where((r) => r.status == 'completed').length;
         monthlyStats[i-1] = completed / monthRecords.length;
       }
    }
    return monthlyStats;
  }

  /// Returns summary for external dashboards (e.g. Accounting)
  /// { 'compliance': 0.8, 'overdue': 2, 'upcoming': 1, 'next_deadline': '15 Oct' }
  Future<Map<String, dynamic>> getDashboardSummary() async {
    if (!_initialized) await init();
    
    final now = DateTime.now();
    final records = await getRecordsForPeriod(now.year, now.month);
    
    int completed = 0;
    int overdue = 0;
    int upcoming = 0;
    String? nextDeadline;

    for (var r in records) {
      if (r.status == 'completed') {
        completed++;
        continue;
      }
      
      // Determine due date from catalog
      final catalogItem = _catalog.firstWhere((c) => c.id == r.obligationId, orElse: () => HrObligationCatalog(id: '?', title: '', frequency: '', category: '', priority: '', active: false, responsible: ''));
      
      // Simple parsing logic for "Día X" or "Fin de mes"
      // This is a basic heuristics for the MVP as requested
      int dueDay = 28; // Default fallback
      
      if (catalogItem.dueRule?.toLowerCase().contains('fin de mes') == true) {
        // Last day of month
        dueDay = DateTime(now.year, now.month + 1, 0).day;
      } else if (catalogItem.dueRule?.contains('Día') == true) {
         // Extract number
         final match = RegExp(r'(\d+)').firstMatch(catalogItem.dueRule ?? '');
         if (match != null) {
           dueDay = int.tryParse(match.group(1)!) ?? 15;
         }
      }
      
      final deadline = DateTime(now.year, now.month, dueDay);
      final diff = deadline.difference(now).inDays;
      
      if (diff < 0) {
        overdue++;
      } else if (diff <= 7) {
        upcoming++;
        // Keep the earliest upcoming deadline
        if (nextDeadline == null) {
           nextDeadline = catalogItem.title; 
        }
      }
    }
    
    // Sorting upcoming logic
    // We want the closest deadline
    int daysUntilNext = 999;
    
    // Sort records by deadline
    records.sort((a, b) {
       // Logic to find deadline date for A and B
       final cA = _catalog.firstWhere((c) => c.id == a.obligationId, orElse: () => HrObligationCatalog(id: '', title: '', frequency: '', category: '', priority: '', active: false, responsible: ''));
       final cB = _catalog.firstWhere((c) => c.id == b.obligationId, orElse: () => HrObligationCatalog(id: '', title: '', frequency: '', category: '', priority: '', active: false, responsible: ''));
       
       // ... simplified date calc ...
       final dA = _calculateDeadline(cA, now.year, now.month);
       final dB = _calculateDeadline(cB, now.year, now.month);
       return dA.compareTo(dB);
    });

    if (records.isNotEmpty) {
       final next = records.firstWhere((r) => r.status != 'completed', orElse: () => records.first);
       if (next.status != 'completed') {
           final cat = _catalog.firstWhere((c) => c.id == next.obligationId, orElse: () => HrObligationCatalog(id: '', title: 'Unknown', frequency: '', category: '', priority: '', active: false, responsible: ''));
           nextDeadline = cat.title;
           final deadlineDate = _calculateDeadline(cat, now.year, now.month);
           daysUntilNext = deadlineDate.difference(now).inDays;
           if (daysUntilNext < 0) daysUntilNext = 0; // Overdue treated as 0 or negative
       }
    }

    return {
      'compliance': records.isEmpty ? 0.0 : (completed / records.length),
      'overdue': overdue,
      'upcoming': upcoming,
      'next_deadline': nextDeadline,
      'days_until': daysUntilNext,
      'total': records.length,
      'has_data': records.isNotEmpty,
    };
  }
  
  DateTime _calculateDeadline(HrObligationCatalog item, int year, int month) {
      int day = 28;
      if (item.dueRule?.toLowerCase().contains('fin de mes') == true) {
         day = DateTime(year, month + 1, 0).day;
      } else if (item.dueRule?.contains('Día') == true) {
         final match = RegExp(r'(\d+)').firstMatch(item.dueRule ?? '');
         if (match != null) day = int.tryParse(match.group(1)!) ?? 15;
      }
      return DateTime(year, month, day);
  }

  Future<List<Map<String, dynamic>>> getUpcomingTasks(int limit) async {
    if (!_initialized) await init();
    final now = DateTime.now();
    final records = await getRecordsForPeriod(now.year, now.month);
    
    // Filter pending
    final pending = records.where((r) => r.status != 'completed').toList();
    
    // Enriched list
    List<Map<String, dynamic>> enriched = [];
    for (var r in pending) {
       final cat = _catalog.firstWhere((c) => c.id == r.obligationId, orElse: () => HrObligationCatalog(id: '', title: 'Unknown', frequency: '', category: '', priority: '', active: false, responsible: ''));
       final deadline = _calculateDeadline(cat, now.year, now.month);
       enriched.add({
         'record': r,
         'catalog': cat,
         'deadline': deadline,
         'days_left': deadline.difference(now).inDays
       });
    }
    
    enriched.sort((a, b) => (a['deadline'] as DateTime).compareTo(b['deadline'] as DateTime));
    return enriched.take(limit).toList();
  }

  Future<void> markAsCompleted(String recordId, {String? note}) async {
    final index = _records.indexWhere((r) => r.id == recordId);
    if (index != -1) {
      final old = _records[index];
      _records[index] = HrComplianceRecord(
        id: old.id,
        obligationId: old.obligationId,
        periodYear: old.periodYear,
        periodMonth: old.periodMonth,
        status: 'completed',
        completedAt: DateTime.now(),
        evidenceNote: note ?? old.evidenceNote,
        evidencePaths: old.evidencePaths,
      );
      await _saveRecords();
    }
  }

  Future<void> attachFile(String recordId, String filePath) async {
    final index = _records.indexWhere((r) => r.id == recordId);
    if (index != -1) {
      final old = _records[index];
      final currentPaths = old.evidencePaths ?? [];
      currentPaths.add(filePath);
      
      _records[index] = HrComplianceRecord(
        id: old.id,
        obligationId: old.obligationId,
        periodYear: old.periodYear,
        periodMonth: old.periodMonth,
        status: old.status,
        completedAt: old.completedAt,
        evidenceNote: old.evidenceNote,
        evidencePaths: currentPaths,
      );
      await _saveRecords();
    }
  }

  Future<void> saveCatalogItem(HrObligationCatalog item) async {
    print('HrComplianceService: saveCatalogItem called for ${item.title} (ID: ${item.id})');
    final index = _catalog.indexWhere((c) => c.id == item.id);
    if (index != -1) {
      _catalog[index] = item;
      print('HrComplianceService: Updated existing item');
    } else {
      _catalog.add(item);
      print('HrComplianceService: Added new item');
    }
    await _saveCatalog();
  }

  Future<void> deleteCatalogItem(String id) async {
    print('HrComplianceService: deleteCatalogItem called for $id');
    _catalog.removeWhere((c) => c.id == id);
    await _saveCatalog();
  }

  Future<void> loadDemoData() async {
    // 1. Setup Demo Catalog
    _catalog = [
      HrObligationCatalog(id: '1', title: 'Planilla Mensual', frequency: 'monthly', category: 'planilla', priority: 'alta', dueRule: 'Día 15 y 30', responsible: 'RRHH'),
      HrObligationCatalog(id: '2', title: 'Pago SIPE (CSS)', frequency: 'monthly', category: 'seguridad_social', priority: 'alta', dueRule: 'Antes del fin de mes', responsible: 'Contador'),
      HrObligationCatalog(id: '3', title: 'Informe DGI 03', frequency: 'monthly', category: 'reportes', priority: 'media', dueRule: 'Fin de mes', responsible: 'Contador'),
      HrObligationCatalog(id: '4', title: 'Décimo Tercer Mes', frequency: 'event', category: 'pagos', priority: 'alta', dueRule: 'Abril/Aug/Dic', responsible: 'RRHH'),
    ];
    await _saveCatalog();

    // 2. Clear old records to simulate fresh start with demo data (or just ensure demo records exist)
    // For MVP demo, lets just clear relevant records
    _records.clear();
    
    // 3. Generate some history for valid charts
    final now = DateTime.now();
    final year = now.year;
    
    // Past months: completed
    for (int m = 1; m < now.month; m++) {
      for (var ob in _catalog.where((c) => c.frequency == 'monthly')) {
         _records.add(HrComplianceRecord(
           id: _generateId(),
           obligationId: ob.id,
           periodYear: year,
           periodMonth: m,
           status: 'completed',
           completedAt: DateTime(year, m, 28),
         ));
      }
    }
    
    // Current month: mixed
    await getRecordsForPeriod(year, now.month); 
    
    await _saveRecords();
  }
}
