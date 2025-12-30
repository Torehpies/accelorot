// lib/ui/core/themes/web_text_styles.dart

import 'package:flutter/material.dart';
import 'web_colors.dart';

/// Reusable text styles for web UI
class WebTextStyles {
  // Section / table titles
  static const sectionTitle = TextStyle(
    fontFamily: 'dm-sans',
    fontSize: 18,
    fontWeight: FontWeight.w900,
    color: WebColors.textHeading,
  );

  static const label = TextStyle(
    fontFamily: 'dm-sans',
    fontSize: 13,
    fontWeight: FontWeight.w600, // headers & labels
    color: WebColors.textLabel,
  );

  static const body = TextStyle(
    fontFamily: 'dm-sans',
    fontSize: 13,
    fontWeight: FontWeight.w400, // main body text
    color: WebColors.textPrimary,
  );

  static const bodyMedium = TextStyle(
    fontFamily: 'dm-sans',
    fontSize: 13,
    fontWeight: FontWeight.w500, // buttons & dropdowns
    color: WebColors.textSecondary,
  );

  static const bodyMediumGray = TextStyle(
    fontFamily: 'dm-sans',
    fontSize: 13,
    fontWeight: FontWeight.w500, // hints & secondary
    color: WebColors.textLabel,
  );

  static const bodyActive = TextStyle(
    fontFamily: 'dm-sans',
    fontSize: 13,
    fontWeight: FontWeight.w500, // active/selected
    color: WebColors.textSecondary,
  );
}
