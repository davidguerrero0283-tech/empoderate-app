import 'package:flutter/material.dart';
import 'color_palette.dart';
import 'text_styles.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // UNIFIED PREMIUM DARK THEME
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.textPrimary,
    scaffoldBackgroundColor: AppColors.background,
    fontFamily: GoogleFonts.inter().fontFamily,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      elevation: 0,
      iconTheme: IconThemeData(color: AppColors.textPrimary),
      titleTextStyle: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold),
    ),
    cardColor: AppColors.surface,
    textTheme: TextTheme(
      headlineLarge: AppTextStyles.h1.copyWith(color: AppColors.textPrimary),
      headlineMedium: AppTextStyles.h2.copyWith(color: AppColors.textPrimary),
      headlineSmall: AppTextStyles.h3.copyWith(color: AppColors.textPrimary),
      bodyLarge: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
      bodySmall: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
    ),
    colorScheme: const ColorScheme.dark(
      primary: AppColors.textPrimary,
      secondary: AppColors.neonBlue, 
      surface: AppColors.surface,
      background: AppColors.background,
    ),
  );

  // LIGHT THEME - Professional White & Gold
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: const Color(0xFF1A1A2E), // Dark blue-gray
    scaffoldBackgroundColor: const Color(0xFFF5F5F5), // Light gray
    fontFamily: GoogleFonts.inter().fontFamily,
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFFFFFFF), // Pure white
      elevation: 0,
      iconTheme: IconThemeData(color: Color(0xFFD4AF37)), // Gold icons
      titleTextStyle: TextStyle(
        color: Color(0xFF1A1A2E), 
        fontSize: 20, 
        fontWeight: FontWeight.bold
      ),
    ),
    cardColor: const Color(0xFFFFFFFF), // Pure white cards
    textTheme: TextTheme(
      headlineLarge: AppTextStyles.h1.copyWith(color: const Color(0xFF1A1A2E)),
      headlineMedium: AppTextStyles.h2.copyWith(color: const Color(0xFF2C2C54)),
      headlineSmall: AppTextStyles.h3.copyWith(color: const Color(0xFF3D3D6B)),
      bodyLarge: AppTextStyles.body.copyWith(color: const Color(0xFF4A4A6D)),
      bodySmall: AppTextStyles.caption.copyWith(color: const Color(0xFF6C6C80)),
    ),
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF1A1A2E), // Dark text
      secondary: Color(0xFFD4AF37), // Gold accent
      tertiary: Color(0xFFE5C158), // Light gold
      surface: Color(0xFFFFFFFF), // White
      background: Color(0xFFF5F5F5), // Light gray
      onPrimary: Colors.white,
      onSecondary: Color(0xFF1A1A2E), // Dark text on gold
      onSurface: Color(0xFF1A1A2E),
      onBackground: Color(0xFF2C2C54),
      error: Color(0xFFD32F2F),
      onError: Colors.white,
    ),
    dividerColor: const Color(0xFFD4AF37), // Gold divider
    iconTheme: const IconThemeData(color: Color(0xFFD4AF37)), // Gold icons
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFD4AF37), // Gold buttons
        foregroundColor: const Color(0xFF1A1A2E), // Dark text
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: Color(0xFFD4AF37), width: 1),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFFD4AF37),
        side: const BorderSide(color: Color(0xFFD4AF37), width: 1.5),
      ),
    ),
  );
}
