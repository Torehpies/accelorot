// lib/data/providers/report_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/firebase/firebase_report_service.dart';
import '../repositories/report_repository.dart';
import '../models/report.dart';

/// Report service provider
final reportServiceProvider = Provider<FirebaseReportService>((ref) {
  return FirebaseReportService();
});

/// Report repository provider
final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  final service = ref.watch(reportServiceProvider);
  return ReportRepository(service);
});

/// Provider for reports by team (real-time stream)
final reportsStreamProvider = StreamProvider.family<List<Report>, String>(
  (ref, teamId) {
    final repository = ref.watch(reportRepositoryProvider);
    return repository.watchReportsByTeam(teamId);
  },
);

/// Provider for reports by machine (real-time stream)
final machineReportsStreamProvider = StreamProvider.family<List<Report>, String>(
  (ref, machineId) {
    final repository = ref.watch(reportRepositoryProvider);
    return repository.watchReportsByMachine(machineId);
  },
);

/// FutureProvider for single report
final reportByIdProvider = FutureProvider.family<Report?, ({String machineId, String reportId})>(
  (ref, params) async {
    final repository = ref.watch(reportRepositoryProvider);
    return repository.getReportById(params.machineId, params.reportId);
  },
);

/// FutureProvider for team reports (one-time fetch)
final teamReportsProvider = FutureProvider<List<Report>>((ref) async {
  final repository = ref.watch(reportRepositoryProvider);
  return repository.getTeamReports();
});

/// FutureProvider for machine reports (one-time fetch)
final machineReportsFutureProvider = FutureProvider.family<List<Report>, String>(
  (ref, machineId) async {
    final repository = ref.watch(reportRepositoryProvider);
    return repository.getReportsForMachine(machineId);
  },
);