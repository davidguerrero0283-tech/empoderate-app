import 'package:flutter/material.dart';

/// Central theme definitions for the Empoderate app.
class EmpoderateTheme {
  // Primary gold colors used throughout the app.
  static const Color goldStrong = Color(0xFFD4AF37);
  static const Color gold = Color(0xFFF4D35E);
  static const Color goldLight = Color(0xFFFFE082);

  // Accent colors.
  static const Color cyanAccent = Color(0xFF00E5FF);
  static const Color purpleAccent = Color(0xFF9C27B0);
  static const Color neonBlue = Color(0xFF00BFFF);
  static const Color neonCyan = Color(0xFF00FFFF);
  static const Color neonPink = Color(0xFFFF1493);
  static const Color neonGreen = Color(0xFF39FF14);

  // Helper to create a safe box decoration used in various cards.
  static BoxDecoration safeBoxDecoration({
    Gradient? gradient,
    Color? color,
    BorderRadius? borderRadius,
    Border? border,
    List<BoxShadow>? boxShadow,
  }) {
    return BoxDecoration(
      color: color,
      gradient: gradient,
      borderRadius: borderRadius ?? BorderRadius.circular(12),
      border: border,
      boxShadow: boxShadow ?? [
        BoxShadow(color: Colors.black45, blurRadius: 8, offset: Offset(0, 4)),
      ],
    );
  }

  // Helper to create circular decorations with golden borders
  static BoxDecoration circle({
    Color? color,
    Border? border,
    List<BoxShadow>? boxShadow,
  }) {
    return BoxDecoration(
      color: color,
      shape: BoxShape.circle,
      border: border ?? Border.all(color: goldStrong.withOpacity(0.5), width: 1),
      boxShadow: boxShadow ?? [
        BoxShadow(color: goldStrong.withOpacity(0.3), blurRadius: 8),
      ],
    );
  }

  // Helper for yellow/gold card styling
  static BoxDecoration cardDecoration({
    BorderRadius? borderRadius,
    List<BoxShadow>? boxShadow,
  }) {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [Color(0xFF2A2410), Color(0xFF1A1500)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: borderRadius ?? BorderRadius.circular(16),
      border: Border.all(color: goldStrong, width: 1.5),
      boxShadow: boxShadow ?? [
        BoxShadow(color: goldStrong.withOpacity(0.2), blurRadius: 12, offset: Offset(0, 4)),
        BoxShadow(color: Colors.black45, blurRadius: 8, offset: Offset(0, 2)),
      ],
    );
  }
}

// Export commonly used neon colors for convenience.
const Color kNeonBlue = EmpoderateTheme.neonBlue;
const Color kNeonCyan = EmpoderateTheme.neonCyan;
const Color kNeonPink = EmpoderateTheme.neonPink;
const Color kNeonGreen = EmpoderateTheme.neonGreen;
