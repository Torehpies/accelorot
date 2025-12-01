// lib/data/services/contracts/report_service.dart

import '../../models/report.dart';

/// Abstract interface for report operations
/// Implementation: FirestoreReportService
abstract class ReportService {
  /// Fetch all reports for a team (team-filtered)
  Future<List<Report>> fetchTeamReports(String teamId);
  
  /// Fetch reports for a specific machine
  Future<List<Report>> fetchReportsForMachine(String machineId);
  
  /// Submit a new report
  Future<void> submitReport(Map<String, dynamic> reportEntry);
}