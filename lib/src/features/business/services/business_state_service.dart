import 'package:shared_preferences/shared_preferences.dart';

class BusinessStateService {
  static const String _keySelectedRubro = 'selected_rubro_id';
  static const String _keyIsPremium = 'is_premium_user';

  // Singleton pattern
  static final BusinessStateService _instance = BusinessStateService._internal();
  factory BusinessStateService() => _instance;
  BusinessStateService._internal();

  /// Gets the currently selected rubro ID from local storage.
  /// Returns null if no rubro is selected.
  Future<String?> getSelectedRubro() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keySelectedRubro);
  }

  /// Sets the selected rubro ID.
  /// This should be called when the user successfully selects a rubro.
  Future<void> setSelectedRubro(String rubroId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySelectedRubro, rubroId);
  }

  /// Checks if the user has a Premium plan.
  /// Defaults to false if not set.
  Future<bool> isPremium() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsPremium) ?? false;
  }
  
  /// FOR DEBUGGING: Toggle premium status
  Future<void> setPremium(bool isPremium) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsPremium, isPremium);
  }

  /// Clears the selected rubro (e.g., if user resets or deletes business).
  Future<void> clearSelectedRubro() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keySelectedRubro);
  }
  
  /// Verifies if a user can switch to a NEW rubro.
  /// Returns TRUE if allowed (Same rubro OR Premium user).
  /// Returns FALSE if blocked (Different rubro AND Free user).
  Future<bool> canSelectRubro(String newRubroId) async {
    final currentRubro = await getSelectedRubro();
    final premium = await isPremium();
    
    // 1. If no rubro selected yet -> ALLOW
    if (currentRubro == null) return true;
    
    // 2. If selecting the SAME rubro -> ALLOW
    if (currentRubro == newRubroId) return true;
    
    // 3. If switching to DIFFERENT rubro:
    //    - If Premium -> ALLOW
    //    - If Free -> BLOCK
    return premium;
  }
}
