import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/business_rules_config.dart';
import '../models/tuning_feedback.dart';

class AutoTuningService {
  static const String _storageKey = 'schedule_tuning_events';
  static const String _configKey = 'schedule_tuned_config';
  
  // Hyperparameters
  static const double _learningRate = 0.05; // Ajuste del 5% por feedback
  static const double _minWeight = 0.1;
  static const double _maxWeight = 2.0;

  Future<void> saveConfig(BusinessRulesConfig config) async {
    final prefs = await SharedPreferences.getInstance();
    // Save minimal weight set, assuming structure stays same
    final data = {
      'fairness': config.fairnessWeight,
      'fatigue': config.fatigueWeight,
      'preference': config.preferenceWeight,
    };
    await prefs.setString(_configKey, jsonEncode(data));
  }

  Future<BusinessRulesConfig> loadTunedConfig(BusinessRulesConfig defaultConfig) async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_configKey)) return defaultConfig;

    try {
      final data = jsonDecode(prefs.getString(_configKey)!);
      // Create copy with tuned weights
      // Note: Since BusinessRulesConfig fields might be final, we might need to assume 
      // we can construct a new one or that the caller handles the object update. 
      // For now, we return a new object based on default but with overrides.
      return BusinessRulesConfig(
        maxDailyHours: defaultConfig.maxDailyHours,
        maxWeeklyHours: defaultConfig.maxWeeklyHours,
        minRestHoursBetweenShifts: defaultConfig.minRestHoursBetweenShifts,
        maxConsecutiveWorkDays: defaultConfig.maxConsecutiveWorkDays,
        enableFairness: defaultConfig.enableFairness,
        enableFatigueControl: defaultConfig.enableFatigueControl,
        
        // TUNED WEIGHTS
        fairnessWeight: (data['fairness'] as num).toDouble(),
        fatigueWeight: (data['fatigue'] as num).toDouble(),
        preferenceWeight: (data['preference'] as num).toDouble(),
      );
    } catch (e) {
      debugPrint('Error loading tuned config: $e');
      return defaultConfig;
    }
  }

  /// Applies feedback to current config and returns the NEW config.
  Future<BusinessRulesConfig> applyFeedback({
    required BusinessRulesConfig currentConfig,
    required String suggestionId,
    required String suggestionType,
    required TuningAction action,
    RejectionReason? reason,
  }) async {
    
    // 1. Calculate Deltas
    double deltaFairness = 0;
    double deltaFatigue = 0;
    double deltaPreference = 0;

    // Simple Reinforcement Logic
    if (action == TuningAction.accept) {
      // If accepted, slightly reinforce all active weights (positive reinforcement)
      // Assuming general satisfaction means current balance is good or slightly understated
      deltaFairness = _learningRate * 0.5;
      deltaFatigue = _learningRate * 0.5;
      deltaPreference = _learningRate * 0.5;
    } else {
      // If rejected, adjust based on reason
      switch (reason) {
        case RejectionReason.fairness:
          // User says it's unfair -> Increase fairness weight significantly
          deltaFairness = _learningRate * 2.0; 
          break;
        case RejectionReason.fatigue:
           // User says it's tiring -> Increase fatigue weight
          deltaFatigue = _learningRate * 2.0;
          break;
        case RejectionReason.preference:
           // User dislikes it personally -> Increase preference weight
          deltaPreference = _learningRate * 2.0;
          break;
        case RejectionReason.coverage:
           // Not covered here directly as coverge is usually hard constraint or primary goal
           // Could decrease other soft constraints to prioritize coverage?
           // For safety, we do nothing or slightly reduce others.
           deltaFairness = -_learningRate;
           deltaFatigue = -_learningRate;
          break;
        default:
          // Unknown reason, maybe just bad luck. Small penalty/random? 
          // Safest is no op or slight reduction of everything.
          deltaFairness = -_learningRate * 0.5;
          deltaFatigue = -_learningRate * 0.5;
          deltaPreference = -_learningRate * 0.5;
          break;
      }
    }

    // 2. Apply and Clamp
    double newFairness = (currentConfig.fairnessWeight + deltaFairness).clamp(_minWeight, _maxWeight);
    double newFatigue = (currentConfig.fatigueWeight + deltaFatigue).clamp(_minWeight, _maxWeight);
    double newPreference = (currentConfig.preferenceWeight + deltaPreference).clamp(_minWeight, _maxWeight);

    // 3. Create New Config
    final newConfig = BusinessRulesConfig(
      maxDailyHours: currentConfig.maxDailyHours,
      maxWeeklyHours: currentConfig.maxWeeklyHours,
      minRestHoursBetweenShifts: currentConfig.minRestHoursBetweenShifts,
      maxConsecutiveWorkDays: currentConfig.maxConsecutiveWorkDays,
      enableFairness: currentConfig.enableFairness,
      enableFatigueControl: currentConfig.enableFatigueControl,
      fairnessWeight: newFairness,
      fatigueWeight: newFatigue,
      preferenceWeight: newPreference,
    );

    // 4. Record Event (Snapshot)
    final feedback = TuningFeedback(
      suggestionId: suggestionId,
      suggestionType: suggestionType,
      action: action,
      reason: reason,
      resultingSnapshot: TuningSnapshot.fromConfig(newConfig),
    );
    await _saveFeedbackEvent(feedback);

    // 5. Persist Config
    await saveConfig(newConfig);

    return newConfig;
  }

  Future<void> _saveFeedbackEvent(TuningFeedback feedback) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> events = prefs.getStringList(_storageKey) ?? [];
    events.add(jsonEncode(feedback.toJson()));
    // Keep last 100 events only to save space
    if (events.length > 100) events = events.sublist(events.length - 100);
    await prefs.setStringList(_storageKey, events);
  }

  Future<List<TuningFeedback>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> events = prefs.getStringList(_storageKey) ?? [];
    return events.map((e) => TuningFeedback.fromJson(jsonDecode(e))).toList();
  }
  
  /// Reverts to the weights state BEFORE the last event
  Future<BusinessRulesConfig?> revertLastChange(BusinessRulesConfig currentConfig) async {
    final history = await getHistory();
    if (history.isEmpty) return null;

    // Get last event
    final lastEvent = history.last;
    
    // We need the state BEFORE this. 
    // Ideally we'd store "previousSnapshot" but "resultingSnapshot" is what we have.
    // However, we can just load the previous event's resulting snapshot.
    
    if (history.length < 2) {
       // Reset to defaults if only 1 event exists
       return BusinessRulesConfig.panamaDefault();
    }
    
    final prevEvent = history[history.length - 2];
    if (prevEvent.resultingSnapshot == null) return null;
    
    final snapshot = prevEvent.resultingSnapshot!;
    
    // Remove last event
    final prefs = await SharedPreferences.getInstance();
    List<String> events = prefs.getStringList(_storageKey) ?? [];
    if (events.isNotEmpty) {
      events.removeLast();
      await prefs.setStringList(_storageKey, events);
    }

    final newConfig = BusinessRulesConfig(
        maxDailyHours: currentConfig.maxDailyHours,
        maxWeeklyHours: currentConfig.maxWeeklyHours,
        minRestHoursBetweenShifts: currentConfig.minRestHoursBetweenShifts,
        maxConsecutiveWorkDays: currentConfig.maxConsecutiveWorkDays,
        enableFairness: currentConfig.enableFairness,
        enableFatigueControl: currentConfig.enableFatigueControl,
        
        fairnessWeight: snapshot.fairnessWeight,
        fatigueWeight: snapshot.fatigueWeight,
        preferenceWeight: snapshot.preferenceWeight,
    );
    
    await saveConfig(newConfig);
    return newConfig;
  }
}
