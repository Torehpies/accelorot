// lib/data/repositories/alert_repository.dart

import '../models/alert.dart';
import '../services/contracts/alert_service.dart';

/// Repository for alert-related operations
/// Wraps AlertService to provide data access layer
class AlertRepository {
  final AlertService _alertService;

  AlertRepository(this._alertService);

  /// Fetch all alerts for the current user's team
  /// [limit] - Maximum number of alerts to fetch (null = fetch all)
  /// [cutoffDate] - Only fetch alerts newer than this date (null = no filter)
  Future<List<Alert>> getTeamAlerts({
    int? limit,
    DateTime? cutoffDate,
  }) =>
      _alertService.fetchTeamAlerts(limit: limit, cutoffDate: cutoffDate);

  /// Fetch alerts for a specific batch
  Future<List<Alert>> getAlertsForBatch(String batchId) =>
      _alertService.fetchAlertsForBatch(batchId);

  /// Stream alerts for real-time updates (single batch)
  Stream<List<Alert>> streamAlerts(String batchId) =>
      _alertService.streamAlerts(batchId);

  /// Stream all alerts for the team with real-time updates
  /// [cutoffDate] - Only fetch alerts newer than this date (defaults to 2 days ago)
  Stream<List<Alert>> streamTeamAlerts({DateTime? cutoffDate}) =>
      _alertService.streamTeamAlerts(cutoffDate: cutoffDate);

  ///Fetch a single alert by ID
  Future<Alert?> getAlert(String id) => _alertService.fetchAlertById(id);
}
