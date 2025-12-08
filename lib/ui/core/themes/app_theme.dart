import 'package:flutter/material.dart';

// --- 2. Theme Data Definition ---
final ThemeData appTheme = ThemeData(
  // Global Scaffold Background
  useMaterial3: true,
  fontFamily: 'dm-sans',
  scaffoldBackgroundColor: AppColors.background,

  // Defines the default color palette using the modern ColorScheme
  colorScheme: ColorScheme.fromSeed(seedColor: AppColors.green100),
  //colorScheme: const ColorScheme.light(
  //  primary: AppColors.green100,
  //  secondary: AppColors.green200,
  //  tertiary: AppColors.green300,
  //  surface: AppColors.background,
  //  onSurface: AppColors.textPrimary,
  //  error: AppColors.error,
  //),

  // --- Typography ---
  textTheme: const TextTheme(
    // Used for main headings (e.g., "Welcome Back!")
    headlineLarge: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: AppColors.textPrimary,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      color: AppColors.textPrimary, // Use the dark text color
    ),
    // Used for secondary text (e.g., "Sign in to continue")
    bodyLarge: TextStyle(fontSize: 16, color: AppColors.textPrimary),
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
      textStyle: const TextStyle(fontWeight: FontWeight.bold),
      padding:
          EdgeInsets.zero, // Often used for small links like "Forgot Password?"
    ),
  ),

  // Custom button styling for PrimaryButton component (if needed)
  // elevatedButtonTheme: ElevatedButtonThemeData(...)
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      // The background color of the button (the filled part)
      backgroundColor: AppColors.green100, // This is Teal
      // The foreground color (the text color)
      foregroundColor: AppColors.background, // Set this to white for contrast
      // Optional: Increase minimum size
      //minimumSize: const Size(
      //  double.infinity,
      //  48,
      //), // Full width, standard height
      // Optional: Customize shape
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
  static const Color background = Color(0xFFE0F2FE);
  static const Color background1 = Color(0xFFE0F2FE);
  static const Color background2 = Colors.white;
  static const Color textPrimary = Color(0xFF374151);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color error = Color(0xFF2D552F);
}
