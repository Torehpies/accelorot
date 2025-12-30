// lib/ui/reports/services/report_aggregator_service.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../data/models/report.dart';
import '../../../data/repositories/report_repository.dart';

/// Service that aggregates report data and handles authentication.
/// 
/// This is a presentation-layer service that orchestrates data fetching
/// and applies UI-specific transformations for the reports feature.
class ReportAggregatorService {
  final ReportRepository _reportRepo;
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  ReportAggregatorService({
    required ReportRepository reportRepo,
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _reportRepo = reportRepo,
        _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  // ===== USER MANAGEMENT =====

  /// Check if a user is currently logged in
  Future<bool> isUserLoggedIn() async {
    final userId = _auth.currentUser?.uid;
    return userId != null && userId.isNotEmpty;
  }

  /// Get current user's teamId from Firestore
  Future<String?> getCurrentUserTeamId() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      final data = doc.data();
      return data?['teamId'] as String?;
    } catch (e) {
      return null;
    }
  }

  // ===== FETCH METHODS =====

  /// Fetch all reports for the current user's team
  Future<List<Report>> getReports() async {
    final teamId = await getCurrentUserTeamId();
    if (teamId == null) return [];

    try {
      return await _reportRepo.getReportsByTeam(teamId);
    } catch (e) {
      rethrow;
    }
  }

  /// Update a report
  Future<void> updateReport({
    required String machineId,
    required String reportId,
    String? title,
    String? description,
    String? status,
    String? priority,
  }) async {
    try {
      final request = UpdateReportRequest(
        reportId: reportId,
        title: title,
        description: description,
        status: status,
        priority: priority,
      );

      await _reportRepo.updateReport(machineId, request);
    } catch (e) {
      rethrow;
    }
  }
}