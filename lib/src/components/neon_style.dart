// lib/src/components/neon_style.dart

import 'package:flutter/material.dart';

// Primary colors
const Color kPremiumNavy = Color(0xFF001B3A);
const Color kPremiumBlack = Color(0xFF000815);
const Color kGoldBright = Color(0xFFF5D98A);
const Color kGoldDeep = Color(0xFFD4AF37);
const Color kNeonBlue = Color(0xFF00A8FF);
const Color kWhiteSoft = Color(0xFFF2F2F2);
const Color kPlaceholder = Color(0xFFA8B7C9);

// Gradients
const LinearGradient kDiagonalGradient = LinearGradient(
  colors: [kPremiumNavy, kPremiumBlack],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

// Glass decoration helper
BoxDecoration glassDecoration({
  double opacity = 0.12,
  double blur = 12,
  Color borderColor = kGoldDeep,
  double borderWidth = 1.5,
  double borderRadius = 20,
  Color glowColor = kNeonBlue,
}) {
  return BoxDecoration(
    color: Colors.white.withOpacity(opacity),
    borderRadius: BorderRadius.circular(borderRadius),
    border: Border.all(color: borderColor, width: borderWidth),
    boxShadow: [
      BoxShadow(
        color: glowColor.withOpacity(0.25),
        blurRadius: blur,
        spreadRadius: 1,
        offset: const Offset(0, 0),
      ),
    ],
  );
}
