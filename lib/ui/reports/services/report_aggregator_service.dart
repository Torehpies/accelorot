// lib/ui/reports/services/report_aggregator_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../data/models/report.dart';
import '../../../data/repositories/report_repository.dart';

/// Service to aggregate and manage report data
class ReportAggregatorService {
  final ReportRepository _reportRepo;
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  ReportAggregatorService({
    required ReportRepository reportRepo,
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  }) : _reportRepo = reportRepo,
       _auth = auth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance;

  // ===== USER MANAGEMENT =====

  /// Check if a user is currently logged in
  Future<bool> isUserLoggedIn() async {
    final userId = _auth.currentUser?.uid;
    return userId != null && userId.isNotEmpty;
  }

  // ===== FETCH METHODS =====

  /// Fetch all reports for the team.
  /// If the current user is an operator, only returns their own reports.
  Future<List<Report>> getReports() async {
    try {
      final reports = await _reportRepo.getTeamReports();

      // Sort by creation date descending (newest first)
      reports.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      // Operator role: only show their own reports
      final uid = _auth.currentUser?.uid;
      if (uid != null) {
        final userDoc = await _firestore.collection('users').doc(uid).get();
        final teamRole = (userDoc.data()?['teamRole'] as String?)?.toLowerCase();
        if (teamRole == 'operator') {
          return reports.where((r) => r.userId == uid).toList();
        }
      }

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
