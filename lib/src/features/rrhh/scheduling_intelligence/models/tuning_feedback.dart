import 'package:flutter/foundation.dart';
import 'business_rules_config.dart';

/// Represents a user feedback action on a schedule suggestion
enum TuningAction {
  accept,
  reject,
}

/// Reasons for rejecting a suggestion, used to tune specific weights
enum RejectionReason {
  preference,   // Generally disliked (adjusts preferenceWeight)
  fairness,     // Unfair distribution (adjusts fairnessWeight)
  fatigue,      // Too tiring (adjusts fatigueWeight)
  coverage,     // Bad coverage (adjusts coverage/demand weights if they existed)
  other,        // General penalty
}

/// Model to store a feedback event
class TuningFeedback {
  final String suggestionId;
  final String suggestionType; // e.g., 'optimization', 'fix'
  final TuningAction action;
  final RejectionReason? reason;
  final DateTime timestamp;
  
  // Snapshot of weights AFTER this feedback was applied (for rollback/history)
  final TuningSnapshot? resultingSnapshot;

  TuningFeedback({
    required this.suggestionId,
    required this.suggestionType,
    required this.action,
    this.reason,
    DateTime? timestamp,
    this.resultingSnapshot,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'suggestionId': suggestionId,
    'suggestionType': suggestionType,
    'action': action.index,
    'reason': reason?.index,
    'timestamp': timestamp.toIso8601String(),
    'resultingSnapshot': resultingSnapshot?.toJson(),
  };

  factory TuningFeedback.fromJson(Map<String, dynamic> json) {
    return TuningFeedback(
      suggestionId: json['suggestionId'],
      suggestionType: json['suggestionType'] ?? 'unknown',
      action: TuningAction.values[json['action']],
      reason: json['reason'] != null ? RejectionReason.values[json['reason']] : null,
      timestamp: DateTime.parse(json['timestamp']),
      resultingSnapshot: json['resultingSnapshot'] != null 
          ? TuningSnapshot.fromJson(json['resultingSnapshot'])
          : null,
    );
  }
}

/// Snapshot of configuration weights for history/revert
class TuningSnapshot {
  final DateTime timestamp;
  final double fairnessWeight;
  final double fatigueWeight;
  final double preferenceWeight;

  TuningSnapshot({
    required this.timestamp,
    required this.fairnessWeight,
    required this.fatigueWeight,
    required this.preferenceWeight,
  });

  factory TuningSnapshot.fromConfig(BusinessRulesConfig config) {
    return TuningSnapshot(
      timestamp: DateTime.now(),
      fairnessWeight: config.fairnessWeight,
      fatigueWeight: config.fatigueWeight,
      preferenceWeight: config.preferenceWeight,
    );
  }

  Map<String, dynamic> toJson() => {
    'timestamp': timestamp.toIso8601String(),
    'fairnessWeight': fairnessWeight,
    'fatigueWeight': fatigueWeight,
    'preferenceWeight': preferenceWeight,
  };

  factory TuningSnapshot.fromJson(Map<String, dynamic> json) {
    return TuningSnapshot(
      timestamp: DateTime.parse(json['timestamp']),
      fairnessWeight: (json['fairnessWeight'] as num).toDouble(),
      fatigueWeight: (json['fatigueWeight'] as num).toDouble(),
      preferenceWeight: (json['preferenceWeight'] as num).toDouble(),
    );
  }
}
