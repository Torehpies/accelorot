// lib/ui/core/themes/web_text_styles.dart

import 'package:flutter/material.dart';
import 'web_colors.dart';

/// Reusable text styles for web UI
class WebTextStyles {
  static const label = TextStyle(
    fontFamily: 'dm-sans',
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: WebColors.textLabel,
  );

  static const body = TextStyle(
    fontFamily: 'dm-sans',
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: WebColors.textPrimary,
  );

  static const bodyMedium = TextStyle(
    fontFamily: 'dm-sans',
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: WebColors.textSecondary,
  );

  static const bodyMediumGray = TextStyle(
    fontFamily: 'dm-sans',
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: WebColors.textLabel,
  );

  static const bodyActive = TextStyle(
    fontFamily: 'dm-sans',
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: WebColors.textSecondary,
  );

  static const h3 = TextStyle(
    fontFamily: 'dm-sans',
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: WebColors.textHeading,
  );

  static const h2 = TextStyle(
    fontFamily: 'dm-sans',
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: WebColors.textHeading,
  );

  static const h1 = TextStyle(
    fontFamily: 'dm-sans',
    fontSize: 36,
    fontWeight: FontWeight.bold,
    color: WebColors.textHeading,
  );

  static const subtitle = TextStyle(
    fontFamily: 'dm-sans',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: WebColors.textSecondary,
  );

  static const caption = TextStyle(
    fontFamily: 'dm-sans',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: WebColors.textMuted,
  );
}
