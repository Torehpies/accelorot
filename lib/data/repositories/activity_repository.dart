// lib/data/repositories/activity_repository.dart

import '../../ui/activity_logs/models/activity_log_item.dart';

/// Abstract repository interface for activity data
/// This allows us to swap implementations (Firestore, local DB, mock, etc.)
abstract class ActivityRepository {
  /// Fetch all activities across all categories
  Future<List<ActivityLogItem>> getAllActivities({String? viewingOperatorId});

  /// Fetch substrate activities (Greens, Browns, Compost)
  Future<List<ActivityLogItem>> getSubstrates({String? viewingOperatorId});

  /// Fetch alert activities (Temperature, Moisture, Oxygen)
  Future<List<ActivityLogItem>> getAlerts({String? viewingOperatorId});

  /// Fetch cycle and recommendation activities
  Future<List<ActivityLogItem>> getCyclesRecom({String? viewingOperatorId});

  /// Fetch report activities (Maintenance, Observation, Safety)
  Future<List<ActivityLogItem>> getReports({String? viewingOperatorId});

  /// Check if user is logged in
  Future<bool> isUserLoggedIn();
}