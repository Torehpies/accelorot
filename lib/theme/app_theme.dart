import 'package:flutter/material.dart';

// --- 1. Color Palette ---
class AppColors {
  static const Color primary = Colors.teal;
  static const Color primaryLight = Color(0xFF4DB6AC); // Teal 400
  static const Color background = Colors.white;
  static const Color textPrimary = Color(0xFF333333);
  static const Color textSecondary = Color(0xFF757575); // Hint/Placeholder Color
  static const Color error = Color(0xFFD32F2F);
}

// --- 2. Theme Data Definition ---
final ThemeData appTheme = ThemeData(
  // Global Scaffold Background
  scaffoldBackgroundColor: AppColors.background,
  
  // Defines the default color palette using the modern ColorScheme
  colorScheme: const ColorScheme.light(
    primary: AppColors.primary,
    secondary: AppColors.primaryLight,
    surface: AppColors.background,
    onSurface: AppColors.textPrimary,
    error: AppColors.error,
  ),

  // --- Typography ---
  textTheme: const TextTheme(
    // Used for main headings (e.g., "Welcome Back!")
    headlineLarge: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: AppColors.textPrimary,
    ),
    // Used for secondary text (e.g., "Sign in to continue")
    bodyLarge: TextStyle(
      fontSize: 16,
      color: AppColors.textSecondary,
    ),
  ),

  // --- Input Field Styling (Applies to all TextFormFields) ---
  inputDecorationTheme: InputDecorationTheme(
    // Default borders
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.textSecondary),
    ),
    // Border when the field is focused
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.primary, width: 2),
    ),
    // Label color
    labelStyle: const TextStyle(color: AppColors.textSecondary),
    // Error styling
    errorStyle: const TextStyle(color: AppColors.error, fontSize: 12),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.error),
    ),
  ),

  // --- Button Styling ---
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.primary,
      textStyle: const TextStyle(fontWeight: FontWeight.bold),
      padding: EdgeInsets.zero, // Often used for small links like "Forgot Password?"
    ),
  ),
  
  // Custom button styling for PrimaryButton component (if needed)
  // elevatedButtonTheme: ElevatedButtonThemeData(...)
);
