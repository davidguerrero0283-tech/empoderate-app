import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AnalyticsService {
  // Singleton pattern
  static final AnalyticsService _instance = AnalyticsService._internal();
  static AnalyticsService get instance => _instance; // Accessor

  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  late SharedPreferences _prefs;
  static const String _storageKeyPrefix = 'analytics_';

  // In-memory storage for MVP
  final Map<String, int> _screenViews = {};
  final Map<String, int> _actions = {};
  final Map<String, int> _blogReads = {};
  final Map<String, int> _toolUsage = {};
  
  /// Initialize service and load data from prefs
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _loadMap('screenViews', _screenViews);
    _loadMap('actions', _actions);
    _loadMap('blogReads', _blogReads);
    _loadMap('toolUsage', _toolUsage);
  }

  void _loadMap(String keySuffix, Map<String, int> targetMap) {
    final String? jsonString = _prefs.getString('$_storageKeyPrefix$keySuffix');
    if (jsonString != null) {
      try {
        final Map<String, dynamic> decoded = jsonDecode(jsonString);
        targetMap.clear();
        decoded.forEach((key, value) {
          if (value is int) targetMap[key] = value;
        });
      } catch (e) {
        print('Error loading analytics $keySuffix: $e');
      }
    }
  }

  Future<void> _saveMap(String keySuffix, Map<String, int> sourceMap) async {
    final String jsonString = jsonEncode(sourceMap);
    await _prefs.setString('$_storageKeyPrefix$keySuffix', jsonString);
  }

  // -- TRACKING METHODS --

  void trackScreenView(String screenName) {
    _screenViews.update(screenName, (value) => value + 1, ifAbsent: () => 1);
    _saveMap('screenViews', _screenViews);
    
    // Auto-categorize screens into sections for broader analysis
    String? category = _getCategoryForScreen(screenName);
    if (category != null) {
       // Could track section visits separately if needed
    }
  }

  void trackAction(String actionName, {Map<String, dynamic>? extra}) {
    _actions.update(actionName, (value) => value + 1, ifAbsent: () => 1);
    _saveMap('actions', _actions);

    // Specific logic for categorization
    if (actionName.startsWith('usar_calculadora_')) {
      String tool = actionName.replaceAll('usar_calculadora_', '');
      _toolUsage.update(tool, (value) => value + 1, ifAbsent: () => 1);
      _saveMap('toolUsage', _toolUsage);
    }
    
    if (actionName == 'leer_articulo_blog' && extra != null && extra.containsKey('articleTitle')) {
      String article = extra['articleTitle'] as String;
      _blogReads.update(article, (value) => value + 1, ifAbsent: () => 1);
      _saveMap('blogReads', _blogReads);
    }
  }

  // -- GETTERS FOR DASHBOARD --

  Map<String, String> getGeneralStats() {
    int totalTools = _toolUsage.values.fold(0, (sum, val) => sum + val);
    int totalReads = _blogReads.values.fold(0, (sum, val) => sum + val);
    int totalDocs = (_actions['exportar_pdf'] ?? 0) + 
                    (_actions['generar_carta_despido'] ?? 0) + 
                    (_actions['generar_comprobante_liquidacion'] ?? 0);
    
    return {
      'activeUsers': '1', // Simulated for local
      'totalTools': totalTools.toString(),
      'totalReads': totalReads.toString(),
      'totalDocs': totalDocs.toString(),
    };
  }

  Map<String, int> getToolUsage() => Map.fromEntries(
    _toolUsage.entries.toList()..sort((a, b) => b.value.compareTo(a.value))
  );

  Map<String, int> getSectionVisits() => Map.fromEntries(
    _screenViews.entries.toList()..sort((a, b) => b.value.compareTo(a.value))
  );

  Map<String, int> getTopArticles() {
    final sorted = _blogReads.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return Map.fromEntries(sorted.take(5));
  }

  // Helper
  String? _getCategoryForScreen(String screen) {
    if (screen.contains('Calculadora')) return 'Herramientas';
    if (screen.contains('Blog')) return 'Blog';
    if (screen.contains('Recursos')) return 'RRHH';
    if (screen.contains('Tramites')) return 'Trámites';
    return null;
  }
}
