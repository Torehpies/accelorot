import '../models/report_model.dart';
import '../services/contracts/report_service.dart';

class ReportRepository {
  final ReportService _reportService;

  ReportRepository(this._reportService);

  Future<List<ReportModel>> getReportsByTeam(String teamId) =>
      _reportService.fetchReportsByTeam(teamId);

  Future<List<ReportModel>> getReportsByMachine(String machineId) =>
      _reportService.fetchReportsByMachine(machineId);

  Future<ReportModel?> getReportById(String machineId, String reportId) =>
      _reportService.fetchReportById(machineId, reportId);

  Future<void> createReport(String machineId, CreateReportRequest request) =>
      _reportService.createReport(machineId, request);

  Future<void> updateReport(String machineId, UpdateReportRequest request) =>
      _reportService.updateReport(machineId, request);

  Future<void> deleteReport(String machineId, String reportId) =>
      _reportService.deleteReport(machineId, reportId);

  Stream<List<ReportModel>> watchReportsByTeam(String teamId) =>
      _reportService.watchReportsByTeam(teamId);

  Stream<List<ReportModel>> watchReportsByMachine(String machineId) =>
      _reportService.watchReportsByMachine(machineId);
}