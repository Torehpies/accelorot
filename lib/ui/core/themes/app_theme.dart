import 'package:flutter/material.dart';

// --- 2. Theme Data Definition ---
final ThemeData appTheme = ThemeData(
  useMaterial3: true,
  fontFamily: 'dm-sans',
  scaffoldBackgroundColor: AppColors.background,

  colorScheme: ColorScheme.fromSeed(seedColor: AppColors.green100),

  textTheme: const TextTheme(
    headlineLarge: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: AppColors.textPrimary,
    ),
    titleMedium: TextStyle(fontSize: 16, color: AppColors.textPrimary),
    bodyLarge: TextStyle(fontSize: 16, color: AppColors.textPrimary),
    bodyMedium: TextStyle(color: AppColors.textPrimary),
  ),

  // --- Input Field Styling (Applies to all TextFormFields) ---
  inputDecorationTheme: InputDecorationTheme(
    // Default borders
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.textPrimary),
    ),
    // Border when the field is focused
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.green100, width: 2),
    ),
    // Label color
    labelStyle: const TextStyle(color: AppColors.textPrimary),
    // Error styling
    errorStyle: const TextStyle(color: AppColors.error, fontSize: 12),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.error),
    ),
    floatingLabelStyle: const TextStyle(color: AppColors.textPrimary),
  ),

  // --- Button Styling ---
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.textPrimary,
      padding: EdgeInsets.zero,
    ),
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.green100, // This is Teal
      foregroundColor: Colors.white, // Set this to white for contrast
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      //textStyle: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'dm-sans'),
    ),
  ),
);

// --- 1. Color Palette ---
class AppColors {
  static const Color green100 = Color(0xFF22C55E);
  static const Color green200 = Color(0xFF10B981);
  static const Color green300 = Color(0xFF059669);
  static const Color green400 = Color(0xFF047857);
  static const Color green500 = Color(0xFF065F46);

  static const Color grey = Color(0xFFD1DBE0);
  static const Color background = Color(0xFFE0F2FE);
  static const Color background1 = Color(0xFFE0F2FE);
  static const Color background2 = Colors.white;
  static const Color backgroundBorder = Color(0xFFABD1EA);

  static const Color greenBackground = Color(0xFFCCFFD9);
  static const Color greenForeground = Color(0xFF09632C);
  static const Color yellowBackground = Color(0xFFFFFEB7);
  static const Color yellowForeground = Color(0xFFA05E00);
  static const Color redBackground = Color(0xFFFFCCCD);
  static const Color redForeground = Color(0xFF8D1012);
  static const Color blueBackground = Color(0xFFC9E1FC);
  static const Color blueForeground = Color(0xFF374151);

  static const Color textPrimary = Color(0xFF374151);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color error = Colors.red;
}
