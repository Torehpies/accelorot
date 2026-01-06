import 'package:flutter/material.dart';
import '../../../ui/activity_logs/models/activity_enums.dart';

/// Centralized color palette for web activity logs
class WebColors {
  // Backgrounds
  static const pageBackground = Color(0xFFF0F8FF); // Light blue page background
  static const cardBackground = Colors.white; // Card/container background
  static const dialogBarrier = Colors.black54; // Dialog overlay
  static const dialogBackground = Colors.transparent; // Dialog background
  static const skeletonLoader = Color(0xFFF5F5F5); // Loading skeleton
  
  // Borders & Dividers
  static const primaryBorder = Color(0xFFBAE6FD); // Main container border (light blue)
  static const cardBorder = Color(0xFFE5E7EB); // Card borders
  static const divider = Color(0xFFE5E7EB); // General dividers
  static const dividerLight = Color(0xFFF3F4F6); // Lighter internal dividers
  static const tableBorder = Color(0xFFCBD5E1); // Table borders and row dividers (darker, sharper)
  
  // Text Colors
  static const textPrimary = Color(0xFF111827); // Darkest body text
  static const textHeading = Color(0xFF1F2937); // Headings and emphasis
  static const textSecondary = Color(0xFF374151); // Secondary content
  static const textLabel = Color(0xFF6B7280); // Labels and titles
  static const textMuted = Color(0xFF9CA3AF); // Muted subtext
  
  // Status Colors
  static const error = Color(0xFFEF4444); // Error/danger state
  static const success = Color(0xFF10B981); // Success state
  static const warning = Color(0xFFF59E0B); // Warning state
  static const info = Color(0xFF3B82F6); // Info state
  static const neutralStatus = Color(0xFF4338CA); // Neutral status (New, No log)
  
  // Interactive Elements
  static const hoverBackground = Color(0xFFF9FAFB); // Row hover state
  static const inputBackground = Color(0xFFF9FAFB); // Input/dropdown backgrounds
  static const badgeBackground = Color(0xFFF3F4F6); // Neutral badges
  static const tealAccent = Color(0xFF0D9488); // Active filter accent
  static const iconDisabled = Color(0xFFD1D5DB); // Disabled icons
  
  // Stats Card Colors
  static const substratesIcon = Color(0xFF10B981); // emerald-500
  static const substratesBackground = Color(0xFFD1FAE5); // emerald-100
  static const alertsIcon = Color(0xFFF59E0B); // amber-500
  static const alertsBackground = Color(0xFFFEF3C7); // amber-100
  static const operationsIcon = Color(0xFF3B82F6); // blue-500
  static const operationsBackground = Color(0xFFDBEAFE); // blue-100
  static const reportsIcon = Color(0xFF8B5CF6); // violet-500
  static const reportsBackground = Color(0xFFEDE9FE); // violet-100
  
  // Activity Type Colors (for chips and badges)
  static const greens = Color(0xFF10B981); // emerald-500
  static const browns = Color(0xFFF59E0B); // amber-500
  static const compost = Color(0xFF84CC16); // lime-500
  static const temperature = Color(0xFFF97316); // orange-500
  static const moisture = Color(0xFF3B82F6); // blue-500
  static const airQuality = Color(0xFF8B5CF6); // violet-500
  static const maintenance = Color(0xFFFBBF24); // amber-400
  static const observation = Color(0xFF06B6D4); // cyan-500
  static const safety = Color(0xFFEF4444); // red-500
  static const recoms = Color(0xFF22C55E); // green-500
  static const cycles = Color(0xFF14B8A6); // teal-500
  static const neutral = Color(0xFF9CA3AF); // gray-400
  
  // Buttons
  static const buttonSecondary = Color(0xFF6B7280); // Secondary button
  
  // Shadows
  static final cardShadow = Colors.black.withValues(alpha: 0.02);
  
  // Helper Methods
  static Color getActivityTypeColor(ActivitySubType type) {
    switch (type) {
      case ActivitySubType.greens: return greens;
      case ActivitySubType.browns: return browns;
      case ActivitySubType.compost: return compost;
      case ActivitySubType.temperature: return temperature;
      case ActivitySubType.moisture: return moisture;
      case ActivitySubType.airQuality: return airQuality;
      case ActivitySubType.maintenance: return maintenance;
      case ActivitySubType.observation: return observation;
      case ActivitySubType.safety: return safety;
      case ActivitySubType.recoms: return recoms;
      case ActivitySubType.cycles: return cycles;
      case ActivitySubType.all: return neutral;
    }
  }
}
