// lib/data/repositories/activity_repository.dart

import '../models/activity_item.dart';

/// Abstract repository interface for activity data
/// This allows us to swap implementations (Firestore, local DB, mock, etc.)
abstract class ActivityRepository {
  /// Fetch all activities across all categories
  Future<List<ActivityItem>> getAllActivities({String? viewingOperatorId});

  /// Fetch substrate activities (Greens, Browns, Compost)
  Future<List<ActivityItem>> getSubstrates({String? viewingOperatorId});

  /// Fetch alert activities (Temperature, Moisture, Oxygen)
  Future<List<ActivityItem>> getAlerts({String? viewingOperatorId});

  /// Fetch cycle and recommendation activities
  Future<List<ActivityItem>> getCyclesRecom({String? viewingOperatorId});

  /// Fetch report activities (Maintenance, Observation, Safety)
  Future<List<ActivityItem>> getReports({String? viewingOperatorId});

  /// Check if user is logged in
  Future<bool> isUserLoggedIn();

  /// Get effective user ID for data fetching
  String getEffectiveUserId({String? viewingOperatorId});

  /// Upload mock data (for testing/demo purposes)
  Future<void> uploadMockData();
}