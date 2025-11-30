// lib/data/repositories/activity_repository.dart

import '../models/activity_item.dart';
import '../services/firebase/firestore_activity_service.dart';

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

/// Firestore implementation of ActivityRepository
/// Wraps existing Firestore services and converts data to ActivityItem models
class FirestoreActivityRepository implements ActivityRepository {
  @override
  Future<List<ActivityItem>> getAllActivities({String? viewingOperatorId}) async {
    try {
      return await FirestoreActivityService.getAllActivities(
        viewingOperatorId: viewingOperatorId,
      );
    } catch (e) {
      throw ActivityRepositoryException('Failed to fetch all activities: $e');
    }
  }

  @override
  Future<List<ActivityItem>> getSubstrates({String? viewingOperatorId}) async {
    try {
      return await FirestoreActivityService.getSubstrates(
        viewingOperatorId: viewingOperatorId,
      );
    } catch (e) {
      throw ActivityRepositoryException('Failed to fetch substrates: $e');
    }
  }

  @override
  Future<List<ActivityItem>> getAlerts({String? viewingOperatorId}) async {
    try {
      return await FirestoreActivityService.getAlerts(
        viewingOperatorId: viewingOperatorId,
      );
    } catch (e) {
      throw ActivityRepositoryException('Failed to fetch alerts: $e');
    }
  }

  @override
  Future<List<ActivityItem>> getCyclesRecom({String? viewingOperatorId}) async {
    try {
      return await FirestoreActivityService.getCyclesRecom(
        viewingOperatorId: viewingOperatorId,
      );
    } catch (e) {
      throw ActivityRepositoryException('Failed to fetch cycles/recommendations: $e');
    }
  }

  @override
  Future<List<ActivityItem>> getReports({String? viewingOperatorId}) async {
    try {
      return await FirestoreActivityService.getReports(
        viewingOperatorId: viewingOperatorId,
      );
    } catch (e) {
      throw ActivityRepositoryException('Failed to fetch reports: $e');
    }
  }

  @override
  Future<bool> isUserLoggedIn() async {
    try {
      final userId = FirestoreActivityService.getCurrentUserId();
      return userId != null && userId.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  @override
  String getEffectiveUserId({String? viewingOperatorId}) {
    return FirestoreActivityService.getEffectiveUserId(viewingOperatorId);
  }

  @override
  Future<void> uploadMockData() async {
    try {
      await FirestoreActivityService.uploadAllMockData();
    } catch (e) {
      throw ActivityRepositoryException('Failed to upload mock data: $e');
    }
  }
}

/// Custom exception for repository errors
class ActivityRepositoryException implements Exception {
  final String message;
  ActivityRepositoryException(this.message);

  @override
  String toString() => 'ActivityRepositoryException: $message';
}
