import 'package:flutter/material.dart';

class AppColors {
  // PREMIUM BLUE PALETTE (Intense Blue Theme - DARK MODE)
  static const Color background = Color(0xFF0D1B2E);        // Intense Blue Base
  static const Color backgroundAlt = Color(0xFF1A2F4F);     // Lighter Blue Variant
  static const Color surface = Color(0xFF1A3A5C);           // Blue-tinted Surface (Glass base)
  static const Color textPrimary = Color(0xFFEDEFF5);       // Soft White
  static const Color textSecondary = Color(0xFFB0B6C5);
  static const Color border = Color(0xFF1E2433);
  
  // PREMIUM ACCENTS
  static const Color premiumGold = Color(0xFFD4AF37);       // Main Gold
  static const Color neonCyan = Color(0xFF00E5FF);          // Tools/Digital
  static const Color premiumPurple = Color(0xFFB14CFF);     // AI/PRO
  
  // LIGHT THEME COLORS - Professional White & Gold
  static const Color lightBackground = Color(0xFFF5F5F5);   // Light gray
  static const Color lightSurface = Color(0xFFFFFFFF);      // Pure white
  static const Color lightTextPrimary = Color(0xFF1A1A2E);  // Dark blue-gray
  static const Color lightTextSecondary = Color(0xFF6C6C80); // Medium gray
  static const Color lightAccent = Color(0xFFD4AF37);       // Gold
  static const Color lightAccentAlt = Color(0xFFE5C158);    // Light gold
  static const Color lightBorder = Color(0xFFE0E0E0);       // Light gray border
  static const Color lightCardBg = Color(0xFFFFFFFF);       // White cards
  static const Color lightFooterBg = Color(0xFF1A1A2E);     // Dark footer
  
  // LEGACY SUPPORT
  static const Color intenseGold = premiumGold;
  static const Color brightGold = premiumGold;
  static const Color neonBlue = neonCyan;
  static const Color deepNavy = background;
  static const Color black = Colors.black;
  static const Color white = Colors.white;
  
  // THEME-AWARE HELPERS
  static Color getAccentColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? premiumGold : lightAccent;
  }
  
  static Color getTextColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? textPrimary : lightTextPrimary;
  }
  
  static Color getSecondaryTextColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? textSecondary : lightTextSecondary;
  }
}
