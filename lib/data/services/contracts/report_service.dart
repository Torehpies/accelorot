// lib/data/services/contracts/report_service.dart

import '../../models/report.dart';

/// Abstract interface for report data operations
abstract class ReportService {
  /// Fetch all reports for the current user's team
  /// Handles authentication and team resolution internally
  Future<List<Report>> fetchTeamReports();
  
  /// Fetch reports for a specific machine
  /// @param machineId - the machine identifier
  Future<List<Report>> fetchReportsForMachine(String machineId);
  
  /// Submit a new report
  /// Handles authentication internally
  /// @param reportEntry - report data
  Future<void> submitReport(Map<String, dynamic> reportEntry);
}