import '../../models/report.dart';
import '../contracts/report_service.dart';

class LocalReportService implements ReportService {
  @override
  Future<List<Report>> fetchTeamReports() {
    throw UnimplementedError('Local database not yet implemented');
  }

  @override
  Future<List<Report>> fetchReportsByTeam(String teamId) {
    throw UnimplementedError('Local database not yet implemented');
  }

  @override
  Future<List<Report>> fetchReportsForMachine(String machineId) {
    throw UnimplementedError('Local database not yet implemented');
  }

  @override
  Future<Report?> fetchReportById(String machineId, String reportId) {
    throw UnimplementedError('Local database not yet implemented');
  }

  @override
  Future<void> createReport(String machineId, CreateReportRequest request) {
    throw UnimplementedError('Local database not yet implemented');
  }

  @override
  Future<void> updateReport(String machineId, UpdateReportRequest request) {
    throw UnimplementedError('Local database not yet implemented');
  }

  @override
  Future<void> deleteReport(String machineId, String reportId) {
    throw UnimplementedError('Local database not yet implemented');
  }

  @override
  Stream<List<Report>> watchReportsByTeam(String teamId) {
    throw UnimplementedError('Local database not yet implemented');
  }

  @override
  Stream<List<Report>> watchReportsByMachine(String machineId) {
    throw UnimplementedError('Local database not yet implemented');
  }
}