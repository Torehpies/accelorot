// lib/ui/reports/services/report_aggregator_service.dart

import 'package:firebase_auth/firebase_auth.dart';
import '../../../data/models/report.dart';
import '../../../data/repositories/report_repository.dart';

/// Service to aggregate and manage report data
class ReportAggregatorService {
  final ReportRepository _reportRepo;
  final FirebaseAuth _auth;

  ReportAggregatorService({
    required ReportRepository reportRepo,
    FirebaseAuth? auth,
  })  : _reportRepo = reportRepo,
        _auth = auth ?? FirebaseAuth.instance;

  // ===== USER MANAGEMENT =====

  /// Check if a user is currently logged in
  Future<bool> isUserLoggedIn() async {
    final userId = _auth.currentUser?.uid;
    return userId != null && userId.isNotEmpty;
  }

  // ===== FETCH METHODS =====

  /// Fetch all reports for the team
  Future<List<Report>> getReports() async {
    try {
      final reports = await _reportRepo.getTeamReports();
      
      // Sort by creation date descending (newest first)
      reports.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      return reports;
    } catch (e) {
      rethrow;
    }
  }

  // ===== UPDATE METHODS =====

  /// Update an existing report
  Future<void> updateReport({
    required String machineId,
    required UpdateReportRequest request,
  }) async {
    try {
      await _reportRepo.updateReport(machineId, request);
    } catch (e) {
      rethrow;
    }
  }
}