// lib/data/repositories/report_repository.dart

import '../models/report.dart';
import '../services/contracts/report_service.dart';

/// Repository for report-related operations
/// Wraps ReportService to provide data access layer
class ReportRepository {
  final ReportService _reportService;

  ReportRepository(this._reportService);

  /// Fetch all reports for the current user's team
  Future<List<Report>> getTeamReports() =>
      _reportService.fetchTeamReports();

  /// Fetch reports for a specific machine
  Future<List<Report>> getReportsForMachine(String machineId) =>
      _reportService.fetchReportsForMachine(machineId);

  /// Submit a new report
  Future<void> submitReport(Map<String, dynamic> reportEntry) =>
      _reportService.submitReport(reportEntry);
}