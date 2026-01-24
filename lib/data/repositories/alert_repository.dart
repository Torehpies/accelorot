// lib/data/repositories/alert_repository.dart

import '../models/alert.dart';
import '../services/contracts/alert_service.dart';

/// Repository for alert-related operations
/// Wraps AlertService to provide data access layer
class AlertRepository {
  final AlertService _alertService;

  AlertRepository(this._alertService);

  /// Fetch all alerts for the current user's team
  Future<List<Alert>> getTeamAlerts() => _alertService.fetchTeamAlerts();

  /// Fetch alerts for a specific batch
  Future<List<Alert>> getAlertsForBatch(String batchId) =>
      _alertService.fetchAlertsForBatch(batchId);

  /// Stream alerts for real-time updates
  Stream<List<Alert>> streamAlerts(String batchId) =>
      _alertService.streamAlerts(batchId);

  ///Fetch a single alert by ID
  Future<Alert?> getAlert(String id) => _alertService.fetchAlertById(id);
}
