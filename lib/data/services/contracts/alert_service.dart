// lib/data/services/contracts/alert_service.dart

import '../../models/alert.dart';

/// Abstract interface for alert operations
/// Implementation: FirestoreAlertService
abstract class AlertService {
  /// Fetch all alerts for a team
  Future<List<Alert>> fetchTeamAlerts(String teamId);
  
  /// Fetch alerts for a specific batch (for other features)
  Future<List<Alert>> fetchAlertsForBatch(String batchId);
  
  /// Stream real-time alerts for a batch
  Stream<List<Alert>> streamAlerts(String batchId);
}