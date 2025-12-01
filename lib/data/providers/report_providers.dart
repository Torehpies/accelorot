import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/firebase/firebase_report_service.dart';
import '../repositories/report_repository.dart';
import '../models/report_model.dart';

// Service Provider
final reportServiceProvider = Provider<FirebaseReportService>((ref) {
  return FirebaseReportService();
});

// Repository Provider
final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  final service = ref.watch(reportServiceProvider);
  return ReportRepository(service);
});

// Provider for reports by team
final reportsStreamProvider = StreamProvider.family<List<ReportModel>, String>(
  (ref, teamId) {
    final repository = ref.watch(reportRepositoryProvider);
    return repository.watchReportsByTeam(teamId);
  },
);

// Provider for reports by machine
final machineReportsStreamProvider = StreamProvider.family<List<ReportModel>, String>(
  (ref, machineId) {
    final repository = ref.watch(reportRepositoryProvider);
    return repository.watchReportsByMachine(machineId);
  },
);

// FutureProvider for single report
final reportByIdProvider = FutureProvider.family<ReportModel?, ({String machineId, String reportId})>(
  (ref, params) async {
    final repository = ref.watch(reportRepositoryProvider);
    return repository.getReportById(params.machineId, params.reportId);
  },
);