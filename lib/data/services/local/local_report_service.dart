import '../../models/report_model.dart';
import '../contracts/report_service.dart';

/// TODO: Future local database for offline use
class LocalReportService implements ReportService {
  @override
  Future<List<ReportModel>> fetchReportsByTeam(String teamId) {
    throw UnimplementedError('Local database not yet implemented');
  }

  @override
  Future<List<ReportModel>> fetchReportsByMachine(String machineId) {
    throw UnimplementedError('Local database not yet implemented');
  }

  @override
  Future<ReportModel?> fetchReportById(String machineId, String reportId) {
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
  Stream<List<ReportModel>> watchReportsByTeam(String teamId) {
    throw UnimplementedError('Local database not yet implemented');
  }

  @override
  Stream<List<ReportModel>> watchReportsByMachine(String machineId) {
    throw UnimplementedError('Local database not yet implemented');
  }
}