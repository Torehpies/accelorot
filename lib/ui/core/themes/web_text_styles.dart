// lib/ui/core/themes/web_text_styles.dart

import 'package:flutter/material.dart';

/// Reusable text styles for web activity logs
/// Uses 'dm-sans' font family from app_theme.dart
class WebTextStyles {
  // Header/Label styles (heavier weight, used for column headers and labels)
  static const label = TextStyle(
    fontFamily: 'dm-sans',
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: Color(0xFF6B7280), // Gray text
  );

  // Body text styles (regular weight, used for table cells and content)
  static const body = TextStyle(
    fontFamily: 'dm-sans',
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: Color(0xFF111827), // Dark text
  );

  // Medium weight body text (used for dropdown text, buttons)
  static const bodyMedium = TextStyle(
    fontFamily: 'dm-sans',
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: Color(0xFF374151), // Medium gray
  );

  // Medium weight with gray color (used for hints and secondary text)
  static const bodyMediumGray = TextStyle(
    fontFamily: 'dm-sans',
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: Color(0xFF6B7280), // Gray text
  );

  // Active/selected text (teal color)
  static const bodyActive = TextStyle(
    fontFamily: 'dm-sans',
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: Color(0xFF374151), // Dark text for active items
  );
}
