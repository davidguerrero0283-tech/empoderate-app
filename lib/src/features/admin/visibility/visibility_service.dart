import 'package:shared_preferences/shared_preferences.dart';
import 'app_sections_registry.dart';

class VisibilityService {
  static final VisibilityService _instance = VisibilityService._internal();
  static VisibilityService get instance => _instance;

  VisibilityService._internal();

  late SharedPreferences _prefs;
  final Map<String, bool> _visibilityState = {};
  static const String _storageKeyPrefix = 'visibility_';

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _prefs = await SharedPreferences.getInstance();
    
    // Load state with Auto-Repair
    await _ensureVisibilityConfigComplete();
    
    _initialized = true;
  }

  Future<void> _ensureVisibilityConfigComplete() async {
    bool hasChanges = false;
    for (var section in AppSectionsRegistry.allSections) {
      final key = '$_storageKeyPrefix${section.id}';
      
      if (!_prefs.containsKey(key)) {
        // Missing key -> Restore default
        _visibilityState[section.id] = section.enabledByDefault;
        // Don't await here for speed, just fire and forget or batch? Better to await to be safe.
        // Actually for init speed we can just set memory state and persist async
        _prefs.setBool(key, section.enabledByDefault); 
        hasChanges = true;
      } else {
        // Existing key -> Load valid value
        _visibilityState[section.id] = _prefs.getBool(key) ?? section.enabledByDefault;
      }
    }
    
    if (hasChanges) {
       // Optional: Log repair
       // print('Visibility Config Repaired');
    }
    _initialized = true;
  }

  bool isVisible(String id) {
    if (!_initialized) return true; // Fail safe open if not init
    return _visibilityState[id] ?? false; 
  }

  Future<void> toggle(String id) async {
    final current = isVisible(id);
    await setVisible(id, !current);
  }

  Future<void> setVisible(String id, bool visible) async {
    _visibilityState[id] = visible;
    await _prefs.setBool('$_storageKeyPrefix$id', visible);
  }

  Future<void> applyMVPMode() async {
    // MVP Definition:
    // ON: Accounting, HR, Marketing, Tramites, Calculators, Audit, Blog (maybe)
    // OFF: Library, Courses, Pro Guide, Mini Games
    
    final enableIds = [
      'home.accounting',
      'home.hr',
      'home.marketing',
      'home.my_business',
      'home.tramites_check', // Requisitos
      'tools.calculators',
      'tools.chatbot',
      'tools.audit',
      'home.blog',      // Content is key
      'tools.blog_mini'
    ];

    for (var section in AppSectionsRegistry.allSections) {
      final shouldEnable = enableIds.contains(section.id);
      await setVisible(section.id, shouldEnable);
    }
  }

  Future<void> applyAllOn() async {
    for (var section in AppSectionsRegistry.allSections) {
      await setVisible(section.id, true);
    }
  }

  Future<void> restoreEssentials() async {
    // Restore Essentials: Main Groups + Advanced Tools
    final essentialGroups = [
      AppSectionsRegistry.groupHomeMain,
      AppSectionsRegistry.groupAdvanced,
      AppSectionsRegistry.groupHomeSecondary // Includes Blog & Games
    ];

    for (var section in AppSectionsRegistry.allSections) {
      if (essentialGroups.contains(section.group) && section.enabledByDefault) {
         await setVisible(section.id, true);
      }
      // Force enable Advanced Tools specifically requested
      if (section.group == AppSectionsRegistry.groupAdvanced) {
         await setVisible(section.id, true);
      }
    }
  }
}
