// lib/ui/core/themes/web_colors.dart

import 'package:flutter/material.dart';
import '../../../ui/activity_logs/models/activity_enums.dart';

/// Centralized color palette for web activity logs
/// All colors used in the activity logs feature should be defined here
class WebColors {
  // ===== BACKGROUNDS =====
  
  /// Main page background - light blue
  static const pageBackground = Color(0xFFF0F8FF);
  
  /// White background for cards and containers
  static const cardBackground = Colors.white;
  
  /// Dialog barrier overlay
  static const dialogBarrier = Colors.black54;
  
  /// Transparent dialog background
  static const dialogBackground = Colors.transparent;
  
  /// Loading skeleton background
  static const skeletonLoader = Color(0xFFF5F5F5); // grey[100]
  
  // ===== BORDERS & DIVIDERS =====
  
  /// Primary border for main container (light blue)
  static const primaryBorder = Color(0xFFBAE6FD);
  
  /// Card borders and general dividers (light gray)
  static const cardBorder = Color(0xFFE5E7EB);
  
  /// Same as cardBorder - for semantic clarity
  static const divider = Color(0xFFE5E7EB);
  
  /// Lighter internal dividers
  static const dividerLight = Color(0xFFF3F4F6);
  
  // ===== TEXT COLORS =====
  
  /// Darkest text for body content
  static const textPrimary = Color(0xFF111827);
  
  /// Dark text for headings and emphasis (stats values)
  static const textHeading = Color(0xFF1F2937);
  
  /// Medium dark text for secondary content
  static const textSecondary = Color(0xFF374151);
  
  /// Gray text for labels and titles
  static const textLabel = Color(0xFF6B7280);
  
  /// Muted gray for subtext and hints
  static const textMuted = Color(0xFF9CA3AF);
  
  // ===== STATUS COLORS =====
  
  /// Error state - red
  static const error = Color(0xFFEF4444);
  
  /// Success state - emerald/green
  static const success = Color(0xFF10B981);
  
  /// Warning state - amber
  static const warning = Color(0xFFF59E0B);
  
  /// Info state - blue
  static const info = Color(0xFF3B82F6);
  
  /// Neutral status - indigo (for "New", "No log yet")
  static const neutralStatus = Color(0xFF4338CA);
  
  // ===== INTERACTIVE ELEMENT COLORS =====
  
  /// Hover background for table rows and interactive elements
  static const hoverBackground = Color(0xFFF9FAFB);
  
  /// Input/dropdown background (light gray)
  static const inputBackground = Color(0xFFF9FAFB);
  
  /// Badge background for neutral/gray badges
  static const badgeBackground = Color(0xFFF3F4F6);
  
  /// Active teal accent for filters and interactive elements
  static const tealAccent = Color(0xFF0D9488);
  
  /// Empty state icon color and disabled elements (lighter gray)
  static const iconDisabled = Color(0xFFD1D5DB);
  
  // ===== STATS CARD COLORS =====
  
  /// Substrates icon color
  static const substratesIcon = Color(0xFF10B981); // emerald-500
  
  /// Substrates background color
  static const substratesBackground = Color(0xFFD1FAE5); // emerald-100
  
  /// Alerts icon color
  static const alertsIcon = Color(0xFFF59E0B); // amber-500
  
  /// Alerts background color
  static const alertsBackground = Color(0xFFFEF3C7); // amber-100
  
  /// Operations icon color
  static const operationsIcon = Color(0xFF3B82F6); // blue-500
  
  /// Operations background color
  static const operationsBackground = Color(0xFFDBEAFE); // blue-100
  
  /// Reports icon color
  static const reportsIcon = Color(0xFF8B5CF6); // violet-500
  
  /// Reports background color
  static const reportsBackground = Color(0xFFEDE9FE); // violet-100
  
  // ===== ACTIVITY TYPE COLORS =====
  // Used for activity type chips and badges
  
  // Substrates
  /// Greens substrate color
  static const greens = Color(0xFF10B981); // emerald-500
  
  /// Browns substrate color
  static const browns = Color(0xFFF59E0B); // amber-500
  
  /// Compost substrate color
  static const compost = Color(0xFF84CC16); // lime-500
  
  // Alerts
  /// Temperature alert color
  static const temperature = Color(0xFFF97316); // orange-500
  
  /// Moisture alert color
  static const moisture = Color(0xFF3B82F6); // blue-500
  
  /// Air quality alert color
  static const airQuality = Color(0xFF8B5CF6); // violet-500
  
  // Reports
  /// Maintenance report color
  static const maintenance = Color(0xFFFBBF24); // amber-400
  
  /// Observation report color
  static const observation = Color(0xFF06B6D4); // cyan-500
  
  /// Safety report color
  static const safety = Color(0xFFEF4444); // red-500
  
  // Cycles
  /// Recommendations cycle color
  static const recoms = Color(0xFF22C55E); // green-500
  
  /// Cycles color
  static const cycles = Color(0xFF14B8A6); // teal-500
  
  /// Neutral/default color
  static const neutral = Color(0xFF9CA3AF); // gray-400
  
  // ===== BUTTON COLORS =====
  
  /// Secondary button background
  static const buttonSecondary = Color(0xFF6B7280);
  
  // ===== SHADOWS =====
  
  /// Subtle card shadow
  static final cardShadow = Colors.black.withValues(alpha: 0.02);
  
  // ===== HELPER METHODS =====
  
  /// Get color for activity type chips based on the type
  /// 
  /// Returns the appropriate color for displaying activity type badges
  static Color getActivityTypeColor(ActivitySubType type) {
    switch (type) {
      case ActivitySubType.greens:
        return greens;
      case ActivitySubType.browns:
        return browns;
      case ActivitySubType.compost:
        return compost;
      case ActivitySubType.temperature:
        return temperature;
      case ActivitySubType.moisture:
        return moisture;
      case ActivitySubType.airQuality:
        return airQuality;
      case ActivitySubType.maintenance:
        return maintenance;
      case ActivitySubType.observation:
        return observation;
      case ActivitySubType.safety:
        return safety;
      case ActivitySubType.recoms:
        return recoms;
      case ActivitySubType.cycles:
        return cycles;
      case ActivitySubType.all:
        return neutral;
    }
  }
}