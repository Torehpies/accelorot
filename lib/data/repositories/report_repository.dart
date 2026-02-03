// lib/data/repositories/report_repository.dart

import '../models/report.dart';
import '../services/contracts/report_service.dart';

/// Repository for report-related operations
/// Wraps ReportService to provide data access layer
class ReportRepository {
  final ReportService _reportService;

  ReportRepository(this._reportService);

  /// Fetch all reports for the current user's team
  /// Auto-resolves team from current user
  Future<List<Report>> getTeamReports() => _reportService.fetchTeamReports();

  /// Fetch reports for a specific team (admin use)
  Future<List<Report>> getReportsByTeam(String teamId) =>
      _reportService.fetchReportsByTeam(teamId);

  /// Fetch reports for a specific machine
  Future<List<Report>> getReportsForMachine(String machineId) =>
      _reportService.fetchReportsForMachine(machineId);

  /// Fetch a single report by ID
  Future<Report?> getReportById(String machineId, String reportId) =>
      _reportService.fetchReportById(machineId, reportId);

  /// Create a new report
  Future<void> createReport(String machineId, CreateReportRequest request) =>
      _reportService.createReport(machineId, request);

  /// Update an existing report
  Future<void> updateReport(String machineId, UpdateReportRequest request) =>
      _reportService.updateReport(machineId, request);

  /// Delete a report
  Future<void> deleteReport(String machineId, String reportId) =>
      _reportService.deleteReport(machineId, reportId);

  /// Stream of reports for real-time updates (team-wide)
  Stream<List<Report>> watchReportsByTeam(String teamId) =>
      _reportService.watchReportsByTeam(teamId);

  /// Stream of reports for a specific machine
  Stream<List<Report>> watchReportsByMachine(String machineId) =>
      _reportService.watchReportsByMachine(machineId);
}
