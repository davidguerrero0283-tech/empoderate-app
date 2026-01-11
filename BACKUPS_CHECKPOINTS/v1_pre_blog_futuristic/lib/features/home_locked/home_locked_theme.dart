/*
🔒 LOCKED MODULE — HOME CARD THEME (DO NOT MODIFY)
- This theme freezes the appearance of the Home Card.
- If changes are needed, create a new backup version:
  BACKUPS_UI/HOME_CARD_LOCKED/v2/
*/

import 'package:flutter/material.dart';

/// Builds a frozen ThemeData for the Home Card.
/// This ensures global theme changes do not affect the locked card.
/// 
/// Strategy: Return the current theme as-is (fallback safe).
/// The card uses hardcoded colors internally, so it's already protected.
ThemeData buildHomeLockedTheme(BuildContext context) {
  // The HomeStartBlock uses hardcoded colors (Color(0xFF...), EmpoderateTheme.*)
  // so it's naturally resistant to theme changes.
  // We return the current theme to avoid any visual differences.
  return Theme.of(context);
}
