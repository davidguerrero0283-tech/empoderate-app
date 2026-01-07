import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EmpoderateTheme {
  // --- COLORS ---
  static const Color primaryBlue = Color(0xFF001B3A); // Deep Navy
  static const Color deepBlue = Color(0xFF021222);    // Darker Background
  static const Color background = Color(0xFF070A10);  // Global Dark
  
  static const Color gold = Color(0xFFF5D98A);        // Soft Gold
  static const Color goldStrong = Color(0xFFD4AF37);  // Classic Premium Gold
  
  static const Color cyanAccent = Color(0xFF00E5FF);  // Neon Cyan
  static const Color purpleAccent = Color(0xFF8A4DFF);// Neon Purple
  static const Color pinkNeon = Color(0xFFFF00CC);    // Neon Pink
  static const Color greenNeon = Color(0xFF00FF99);   // Neon Green
  
  static const Color white = Color(0xFFEDEFF5);       // Off-white text
  static const Color glass = Color(0x0DFFFFFF);       // 5% White Glass

  // --- GRADIENTS ---
  static const LinearGradient gradientHeader = LinearGradient(
    colors: [Color(0xFF05070D), Color(0xFF101929)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient gradientCard = LinearGradient(
    colors: [Color(0xCC050914), Color(0x990A1020)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient gradientGold = LinearGradient(
    colors: [goldStrong, Color(0xFFFFD700)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // --- TEXT STYLES ---
  static TextStyle get titleStyle => GoogleFonts.outfit(
    color: goldStrong,
    fontSize: 22,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.0,
  );
  
  static TextStyle get subtitleStyle => GoogleFonts.outfit(
    color: white.withOpacity(0.8),
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );
  
  static TextStyle get bodyStyle => GoogleFonts.outfit(
    color: white.withOpacity(0.9),
    fontSize: 16,
  );

  static TextStyle get badgeStyle => GoogleFonts.outfit(
    color: Colors.black,
    fontSize: 12,
    fontWeight: FontWeight.bold,
  );

  // --- DECORATIONS ---
  static BoxDecoration premiumCardDecoration = BoxDecoration(
    color: glass,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: Colors.white.withOpacity(0.08)),
  );

  static BoxDecoration outlineGlowGold = BoxDecoration(
    color: Colors.transparent,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: goldStrong.withOpacity(0.5)),
    boxShadow: [BoxShadow(color: goldStrong.withOpacity(0.1), blurRadius: 8)],
  );
  
  static BoxDecoration outlineGlowCyan = BoxDecoration(
    color: Colors.transparent,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: cyanAccent.withOpacity(0.5)),
    boxShadow: [BoxShadow(color: cyanAccent.withOpacity(0.1), blurRadius: 8)],
  );

  // --- NEW CENTRALIZED STYLES (TOKENS) ---
  
  // 1. Gold CTA Button Style
  static ButtonStyle get primaryButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: goldStrong,
    foregroundColor: Colors.black, // Dark text on gold
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    textStyle: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1),
    elevation: 4,
    shadowColor: goldStrong.withOpacity(0.4),
  );

  // 2. Premium Glass Card Decoration
  static BoxDecoration get premiumGlassCard => BoxDecoration(
    color: const Color(0xFF15151A), // Matte Dark
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: goldStrong.withOpacity(0.3)), // Subtle Gold Border
    boxShadow: [
      BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4)),
      BoxShadow(color: goldStrong.withOpacity(0.05), blurRadius: 20, spreadRadius: 0), // Subtle Glow
    ],
  );
  // 3. Helper for Safe Circular Decoration (Prevention)
  static BoxDecoration circle({
    required Color color, 
    Border? border, 
    List<BoxShadow>? boxShadow
  }) {
    return BoxDecoration(
      color: color,
      shape: BoxShape.circle,
      borderRadius: null, // EXPLICIT SAFETY: Never allow radius with circle
      border: border,
      boxShadow: boxShadow,
    );
  }

  // 4. Helper for Rounded Decoration
  static BoxDecoration rounded({
    required Color color,
    double radius = 16,
    Border? border,
    List<BoxShadow>? boxShadow,
  }) {
    return BoxDecoration(
      color: color,
      shape: BoxShape.rectangle, // Default
      borderRadius: BorderRadius.circular(radius), // Safe
      border: border,
      boxShadow: boxShadow,
    );
  }

  // 5. UNIVERSAL SAFE GUARD (As requested)
  static BoxDecoration safeBoxDecoration({
    BoxShape shape = BoxShape.rectangle,
    BorderRadius? borderRadius,
    Color? color,
    Gradient? gradient,
    BoxBorder? border,
    List<BoxShadow>? boxShadow,
  }) {
    // Logic: If circle, force radius to null. 
    final safeRadius = (shape == BoxShape.circle) ? null : borderRadius;
    return BoxDecoration(
      shape: shape,
      borderRadius: safeRadius,
      color: color,
      gradient: gradient,
      border: border,
      boxShadow: boxShadow,
    );
  }

  // 6. INPUT DECORATION HELPER
  static InputDecoration inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.outfit(color: Colors.white38, fontSize: 13),
      filled: true,
      fillColor: Colors.white.withOpacity(0.05),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white12),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white12),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: goldStrong),
      ),
    );
  }
}
