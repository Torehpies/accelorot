// lib/data/services/contracts/report_service.dart

import '../../models/report.dart';

/// Abstract interface for report data operations
abstract class ReportService {
  /// Fetch all reports for the current user's team
  /// Handles authentication and team resolution internally
  /// [limit] - Maximum number of reports to fetch (null = fetch all)
  Future<List<Report>> fetchTeamReports({int? limit});

  /// Fetch all reports for a specific team (admin use)
  /// [limit] - Maximum number of reports to fetch (null = fetch all)
  Future<List<Report>> fetchReportsByTeam(String teamId, {int? limit});

  /// Fetch reports for a specific machine
  /// @param machineId - the machine identifier
  Future<List<Report>> fetchReportsForMachine(String machineId);

  /// Fetch a single report by ID
  Future<Report?> fetchReportById(String machineId, String reportId);

  /// Create a new report
  /// @param machineId - the machine identifier
  /// @param request - report creation data
  Future<void> createReport(String machineId, CreateReportRequest request);

  /// Update an existing report
  /// @param machineId - the machine identifier
  /// @param request - report update data
  Future<void> updateReport(String machineId, UpdateReportRequest request);

  /// Delete a report
  Future<void> deleteReport(String machineId, String reportId);

  /// Stream of reports for real-time updates (team-wide)
  Stream<List<Report>> watchReportsByTeam(String teamId);

  /// Stream of reports for a specific machine
  Stream<List<Report>> watchReportsByMachine(String machineId);
}
