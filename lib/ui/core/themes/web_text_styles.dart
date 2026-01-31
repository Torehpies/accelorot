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

  // Hero section heading
  static const heroHeading = TextStyle(
    fontFamily: 'dm-sans',
    fontSize: 48,
    fontWeight: FontWeight.bold,
    color: WebColors.textHeading,
    height: 1.2,
  );

  // Section heading with accent
  static const sectionHeadingLarge = TextStyle(
    fontFamily: 'dm-sans',
    fontSize: 40,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    height: 1.3,
  );

  // Subtitle for hero
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
    color: WebColors.greenAccent,
  );

  static const bodyText = TextStyle(
    fontFamily: 'dm-sans',
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: WebColors.textPrimary,
    height: 1.6,
  );

  // New text styles for landing page cards
  // Step card title - compact and bold
  static const stepCardTitle = TextStyle(
    fontFamily: 'dm-sans',
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: WebColors.textHeading,
    height: 1.2,
  );

  // Step card description - smaller body text
  static const stepCardDescription = TextStyle(
    fontFamily: 'dm-sans',
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: WebColors.textLabel,
    height: 1.5,
  );

  // Step number - large and light
  static const stepNumber = TextStyle(
    fontFamily: 'dm-sans',
    fontSize: 48,
    fontWeight: FontWeight.w300,
    color: WebColors.greenAccent,
    height: 1.0,
  );

  // Feature card title
  static const featureCardTitle = TextStyle(
    fontFamily: 'dm-sans',
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: WebColors.textHeading,
    height: 1.3,
  );

  // Feature card description
  static const featureCardDescription = TextStyle(
    fontFamily: 'dm-sans',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: WebColors.textSecondary,
    height: 1.6,
  );

  // Impact stat value - large number
  static const impactStatValue = TextStyle(
    fontFamily: 'dm-sans',
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: WebColors.greenAccent,
    height: 1.2,
  );

  // Impact stat label
  static const impactStatLabel = TextStyle(
    fontFamily: 'dm-sans',
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: WebColors.textSecondary,
    height: 1.4,
  );

  // Section subtitle - for "How it works" type sections
  static const sectionSubtitle = TextStyle(
    fontFamily: 'dm-sans',
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: WebColors.textSecondary,
    height: 1.5,
  );

  // FAQ section title (e.g., "Frequently Asked Questions")
  static const faqSectionTitle = TextStyle(
    fontFamily: 'dm-sans',
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: WebColors.textHeading,
    height: 1.3,
  );

  // FAQ section subtitle (description under title)
  static const faqSectionSubtitle = TextStyle(
    fontFamily: 'dm-sans',
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: WebColors.textSecondary,
    height: 1.5,
  );

  // FAQ question text (in _FaqCard)
  static const faqQuestion = TextStyle(
    fontFamily: 'dm-sans',
    fontSize: 16,
    fontWeight: FontWeight.w500, // normal weight when collapsed, bold when expanded (handled in widget)
    color: WebColors.textHeading,
  );

  // FAQ answer text
  static const faqAnswer = TextStyle(
    fontFamily: 'dm-sans',
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: WebColors.textPrimary,
    height: 1.5,
  );
}
