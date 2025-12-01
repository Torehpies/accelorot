import '../../models/report_model.dart';

abstract class ReportService {
  /// Fetch all reports for a specific team
  Future<List<ReportModel>> fetchReportsByTeam(String teamId);
  
  /// Fetch reports for a specific machine
  Future<List<ReportModel>> fetchReportsByMachine(String machineId);
  
  /// Fetch a single report by ID
  Future<ReportModel?> fetchReportById(String machineId, String reportId);
  
  /// Create a new report
  Future<void> createReport(String machineId, CreateReportRequest request);
  
  /// Update an existing report
  Future<void> updateReport(String machineId, UpdateReportRequest request);
  
  /// Delete a report
  Future<void> deleteReport(String machineId, String reportId);
  
  /// Stream of reports for real-time updates
  Stream<List<ReportModel>> watchReportsByTeam(String teamId);
  
  /// Stream of reports for a specific machine
  Stream<List<ReportModel>> watchReportsByMachine(String machineId);
}