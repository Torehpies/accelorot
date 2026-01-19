// lib/ui/core/themes/app_text_styles.dart
import 'package:flutter/material.dart';
import 'app_theme.dart';

/// Reusable text styles for mobile UI
/// Aligned with app design system and AppColors
class AppTextStyles {
  // ===== HEADINGS =====
  
  /// Large page heading (28px, bold)
  /// Usage: Main screen titles, page headers
  static const h1 = TextStyle(
    fontFamily: 'dm-sans',
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.2,
  );
  
  /// Medium heading (20px, bold)
  /// Usage: Section titles, card headers
  static const h2 = TextStyle(
    fontFamily: 'dm-sans',
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.3,
  );
  
  /// Small heading (18px, semi-bold)
  /// Usage: Subsection titles, drawer headers
  static const h3 = TextStyle(
    fontFamily: 'dm-sans',
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.3,
  );
  
  /// Extra small heading (16px, semi-bold)
  /// Usage: List section headers, group titles
  static const h4 = TextStyle(
    fontFamily: 'dm-sans',
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  // ===== BODY TEXT =====
  
  /// Large body text (16px, regular)
  /// Usage: Main content, descriptions, paragraphs
  static const bodyLarge = TextStyle(
    fontFamily: 'dm-sans',
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.5,
  );
  
  /// Medium body text (14px, regular)
  /// Usage: Card content, list items, secondary text
  static const bodyMedium = TextStyle(
    fontFamily: 'dm-sans',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.5,
  );
  
  /// Small body text (13px, regular)
  /// Usage: Compact lists, dense information
  static const bodySmall = TextStyle(
    fontFamily: 'dm-sans',
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.4,
  );
  
  /// Medium body with semi-bold weight (14px, medium)
  /// Usage: Emphasized content, important info
  static const bodyMediumBold = TextStyle(
    fontFamily: 'dm-sans',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  // ===== LABELS & CAPTIONS =====
  
  /// Label text (13px, medium)
  /// Usage: Form labels, field titles, metadata
  static const label = TextStyle(
    fontFamily: 'dm-sans',
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    height: 1.4,
  );
  
  /// Bold label (13px, semi-bold)
  /// Usage: Emphasized labels, status labels
  static const labelBold = TextStyle(
    fontFamily: 'dm-sans',
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
  );
  
  /// Caption text (12px, regular)
  /// Usage: Timestamps, helper text, footnotes
  static const caption = TextStyle(
    fontFamily: 'dm-sans',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.3,
  );
  
  /// Small caption (11px, regular)
  /// Usage: Tiny metadata, micro text
  static const captionSmall = TextStyle(
    fontFamily: 'dm-sans',
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.3,
  );

  // ===== INPUT & SEARCH =====
  
  /// Input field text (14px, regular)
  /// Usage: TextField, TextFormField input text
  static const inputText = TextStyle(
    fontFamily: 'dm-sans',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.4,
  );
  
  /// Hint/placeholder text (14px, regular, muted)
  /// Usage: TextField hints, search placeholders
  static const hintText = TextStyle(
    fontFamily: 'dm-sans',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.4,
  );
  
  /// Search bar text (14px, regular)
  /// Usage: Search input fields
  static const searchText = TextStyle(
    fontFamily: 'dm-sans',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  // ===== BUTTONS =====
  
  /// Primary button text (16px, semi-bold)
  /// Usage: Primary action buttons
  static const buttonPrimary = TextStyle(
    fontFamily: 'dm-sans',
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    height: 1.2,
  );
  
  /// Secondary button text (14px, semi-bold)
  /// Usage: Secondary buttons, text buttons
  static const buttonSecondary = TextStyle(
    fontFamily: 'dm-sans',
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.green100,
    height: 1.2,
  );
  
  /// Small button text (13px, medium)
  /// Usage: Compact buttons, chips
  static const buttonSmall = TextStyle(
    fontFamily: 'dm-sans',
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: Colors.white,
    height: 1.2,
  );

  // ===== SPECIAL USE CASES =====
  
  /// Error message text (12px, regular, red)
  /// Usage: Form validation errors, error states
  static const error = TextStyle(
    fontFamily: 'dm-sans',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.error,
    height: 1.3,
  );
  
  /// Success message text (12px, medium, green)
  /// Usage: Success notifications, confirmations
  static const success = TextStyle(
    fontFamily: 'dm-sans',
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.green100,
    height: 1.3,
  );
  
  /// Link text (14px, medium, green)
  /// Usage: Clickable links, actions
  static const link = TextStyle(
    fontFamily: 'dm-sans',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.green100,
    decoration: TextDecoration.underline,
    height: 1.4,
  );
  
  /// Badge/chip text (11px, semi-bold)
  /// Usage: Status badges, chips, tags
  static const badge = TextStyle(
    fontFamily: 'dm-sans',
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.2,
  );
  
  /// Stat number (24px, bold)
  /// Usage: Large numbers, statistics, counts
  static const statNumber = TextStyle(
    fontFamily: 'dm-sans',
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.2,
  );
  
  /// Stat label (12px, medium)
  /// Usage: Labels for statistics
  static const statLabel = TextStyle(
    fontFamily: 'dm-sans',
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    height: 1.3,
  );

  // ===== LIST STYLES =====
  
  /// List title (15px, medium)
  /// Usage: ListTile title, card titles
  static const listTitle = TextStyle(
    fontFamily: 'dm-sans',
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    height: 1.4,
  );
  
  /// List subtitle (13px, regular, secondary)
  /// Usage: ListTile subtitle, supporting text
  static const listSubtitle = TextStyle(
    fontFamily: 'dm-sans',
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  // ===== APP BAR =====
  
  /// App bar title (18px, semi-bold)
  /// Usage: AppBar title, header titles
  static const appBarTitle = TextStyle(
    fontFamily: 'dm-sans',
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.2,
  );
  
  /// Tab bar text (14px, medium)
  /// Usage: TabBar labels
  static const tabText = TextStyle(
    fontFamily: 'dm-sans',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.2,
  );
}