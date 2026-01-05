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

  // Hero section heading - 48px
  static const heroHeading = TextStyle(
    fontFamily: 'dm-sans',
    fontSize: 48,
    fontWeight: FontWeight.bold,
    color: WebColors.textHeading,
    height: 1.2,
  );

  // Section heading with accent - 40px (for CTA section)
  static const sectionHeadingLarge = TextStyle(
    fontFamily: 'dm-sans',
    fontSize: 40,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    height: 1.3,
  );

  // Subtitle for hero - 16px
  static const heroSubtitle = TextStyle(
    fontFamily: 'dm-sans',
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: WebColors.textSecondary,
    height: 1.6,
  );

  // Button text
  static const buttonText = TextStyle(
    fontFamily: 'dm-sans',
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: WebColors.tealAccent,
  );

  static const bodyText = TextStyle(
  fontFamily: 'dm-sans',
  fontSize: 16,
  fontWeight: FontWeight.w400,
  color: WebColors.textPrimary, // or textSecondary if you prefer
  height: 1.6,
);
}