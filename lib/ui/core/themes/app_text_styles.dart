// lib/ui/core/themes/app_text_styles.dart
import 'package:flutter/material.dart';
import 'app_theme.dart';

/// Simplified text styles - only the essentials
class AppTextStyles {
  // ===== HEADINGS =====
  
  /// Page titles (24px, bold)
  static const heading1 = TextStyle(
    fontFamily: 'dm-sans',
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.2,
  );
  
  /// Section titles (18px, semi-bold)
  static const heading2 = TextStyle(
    fontFamily: 'dm-sans',
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  // ===== BODY =====
  
  /// Main body text (14px, regular)
  static const body = TextStyle(
    fontFamily: 'dm-sans',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.5,
  );
  
  /// Emphasized body text (14px, medium)
  static const bodyBold = TextStyle(
    fontFamily: 'dm-sans',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    height: 1.5,
  );
  
  /// Secondary/muted text (14px, regular, gray)
  static const bodySecondary = TextStyle(
    fontFamily: 'dm-sans',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  // ===== SMALL TEXT =====
  
  /// Small text for timestamps, captions (12px)
  static const caption = TextStyle(
    fontFamily: 'dm-sans',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.3,
  );

  // ===== INPUTS =====
  
  /// Input field text (14px)
  static const input = TextStyle(
    fontFamily: 'dm-sans',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.4,
  );
  
  /// Placeholder/hint text (14px, gray)
  static const hint = TextStyle(
    fontFamily: 'dm-sans',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  // ===== BUTTONS =====
  
  /// Button text (14px, semi-bold)
  static const button = TextStyle(
    fontFamily: 'dm-sans',
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    height: 1.2,
  );

  // ===== ERROR =====
  
  /// Error text (12px, red)
  static const error = TextStyle(
    fontFamily: 'dm-sans',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.error,
    height: 1.3,
  );

  // ===== INTRO SECTION (NEW) =====
  
  /// Intro hero heading - mobile (36px, bold)
  static const introHeroMobile = TextStyle(
    fontFamily: 'dm-sans',
    fontSize: 36,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    height: 1.2,
  );
  
  /// Intro hero heading - tablet (44px, bold)
  static const introHeroTablet = TextStyle(
    fontFamily: 'dm-sans',
    fontSize: 44,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    height: 1.2,
  );
  
  /// Intro hero heading - desktop (56px, bold)
  static const introHeroDesktop = TextStyle(
    fontFamily: 'dm-sans',
    fontSize: 56,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    height: 1.2,
  );
  
  /// Intro subtitle - mobile (16px)
  static const introSubtitleMobile = TextStyle(
    fontFamily: 'dm-sans',
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.6,
  );
  
  /// Intro subtitle - tablet (17px)
  static const introSubtitleTablet = TextStyle(
    fontFamily: 'dm-sans',
    fontSize: 17,
    fontWeight: FontWeight.w400,
    height: 1.6,
  );
  
  /// Intro subtitle - desktop (18px)
  static const introSubtitleDesktop = TextStyle(
    fontFamily: 'dm-sans',
    fontSize: 18,
    fontWeight: FontWeight.w400,
    height: 1.6,
  );
}