// lib/data/services/contracts/alert_service.dart

import '../../models/alert.dart';

/// Abstract interface for alert data operations
abstract class AlertService {
  /// Fetch all alerts for the current user's team
  /// Handles authentication and team resolution internally
  Future<List<Alert>> fetchTeamAlerts();
  
  /// Fetch alerts for a specific batch
  /// @param batchId - the batch identifier
  Future<List<Alert>> fetchAlertsForBatch(String batchId);
  
  /// Stream alerts for real-time updates
  /// @param batchId - the batch identifier
  Stream<List<Alert>> streamAlerts(String batchId);

  /// Fetch a single alert by ID
  Future<Alert?> fetchAlertById(String alertId);
}