// lib/data/services/firebase/firestore_report_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../contracts/report_service.dart';
import '../contracts/batch_service.dart';
import '../../models/report.dart';

/// Firestore implementation of ReportService
/// Handles report queries with team-aware logic
class FirestoreReportService implements ReportService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final BatchService _batchService;

  FirestoreReportService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    required BatchService batchService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _batchService = batchService;

  /// Get current authenticated user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // ===== FETCH OPERATIONS =====

  @override
  Future<List<Report>> fetchTeamReports() async {
    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }

    try {
      // Get user's teamId
      final teamId = await _batchService.getUserTeamId(currentUserId!);

      // Team is required - no solo fallback
      if (teamId == null || teamId.isEmpty) {
        debugPrint('⚠️ User has no team assigned');
        return [];
      }

      // Fetch team-wide reports
      final allReports = await _fetchTeamReports(teamId);

      // Sort by timestamp descending (newest first)
      allReports.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      debugPrint('✅ Fetched ${allReports.length} reports');
      return allReports;
    } catch (e) {
      debugPrint('❌ Error fetching reports: $e');
      throw Exception('Failed to fetch reports: $e');
    }
  }

  /// Fetch reports for team users (multi-step query)
  Future<List<Report>> _fetchTeamReports(String teamId) async {
    final List<Report> allReports = [];
    int successCount = 0;
    int failureCount = 0;

    // Get all machines belonging to this team
    final teamMachineIds = await _batchService.getTeamMachineIds(teamId);

    if (teamMachineIds.isEmpty) {
      debugPrint('ℹ️ No machines found for team: $teamId');
      return [];
    }

    // Fetch reports from each machine's reports subcollection in parallel
    final futures = teamMachineIds.map((machineId) async {
      try {
        // PATH: machines/{machineId}/reports
        final reportsSnapshot = await _firestore
            .collection('machines')
            .doc(machineId)
            .collection('reports')
            .orderBy('createdAt', descending: true)
            .get();

        final reports = reportsSnapshot.docs
            .map((doc) => Report.fromFirestore(doc))
            .toList();

        return {'success': true, 'reports': reports};
      } catch (e) {
        debugPrint('⚠️ Error fetching reports for machine $machineId: $e');
        return {'success': false, 'reports': <Report>[]};
      }
    });

    final results = await Future.wait(futures);

    for (var result in results) {
      if (result['success'] as bool) {
        allReports.addAll(result['reports'] as List<Report>);
        successCount++;
      } else {
        failureCount++;
      }
    }

    debugPrint('📊 Fetched reports from $successCount/${teamMachineIds.length} machines ($failureCount failures)');
    return allReports;
  }

  @override
  Future<List<Report>> fetchReportsForMachine(String machineId) async {
    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }

    try {
      // PATH: machines/{machineId}/reports
      final snapshot = await _firestore
          .collection('machines')
          .doc(machineId)
          .collection('reports')
          .orderBy('createdAt', descending: true)
          .get();

      final reports = snapshot.docs
          .map((doc) => Report.fromFirestore(doc))
          .toList();

      debugPrint('✅ Fetched ${reports.length} reports for machine: $machineId');
      return reports;
    } catch (e) {
      debugPrint('❌ Error fetching machine reports: $e');
      throw Exception('Failed to fetch machine reports: $e');
    }
  }

  @override
  Future<void> submitReport(Map<String, dynamic> reportEntry) async {
    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }

    final machineId = reportEntry['machineId'];
    if (machineId == null || machineId.toString().isEmpty) {
      throw Exception('Machine ID is required');
    }

    try {
      // Get teamId
      final teamId = await _batchService.getUserTeamId(currentUserId!);

      // Get machine name
      String? machineName;
      try {
        final machineDoc = await _firestore
            .collection('machines')
            .doc(machineId)
            .get();

        if (machineDoc.exists) {
          machineName = machineDoc.data()?['machineName'];
        }
      } catch (e) {
        debugPrint('⚠️ Error fetching machine name: $e');
      }

      // Get user info
      String userName = 'Unknown';
      String userRole = 'Unknown';
      try {
        final userDoc = await _firestore
            .collection('users')
            .doc(currentUserId)
            .get();

        if (userDoc.exists) {
          final userData = userDoc.data();
          final firstName = userData?['firstname'] ?? '';
          final lastName = userData?['lastname'] ?? '';
          userName = '$firstName $lastName'.trim();

          if (userName.isEmpty) {
            userName = userData?['email'] ?? 'Unknown';
          }

          userRole = userData?['role'] ?? 'Unknown';
        }
      } catch (e) {
        debugPrint('⚠️ Error fetching user info: $e');
      }

      // Create document
      final reportType = reportEntry['reportType'];
      final timestamp = reportEntry['timestamp'] ?? DateTime.now();
      final docId = '${reportType}_${(timestamp as DateTime).millisecondsSinceEpoch}';

      // PATH: machines/{machineId}/reports/{docId}
      final docRef = _firestore
          .collection('machines')
          .doc(machineId)
          .collection('reports')
          .doc(docId);

      await docRef.set({
        'reportType': reportType,
        'title': reportEntry['title'],
        'machineId': machineId,
        'machineName': machineName ?? 'Unknown Machine',
        'userId': currentUserId,
        'userName': userName,
        'userRole': userRole,
        'description': reportEntry['description'] ?? '',
        'priority': reportEntry['priority'],
        'status': 'open',
        'teamId': teamId,
        'createdAt': Timestamp.fromDate(timestamp),
        'resolvedAt': null,
        'resolvedBy': null,
      });

      debugPrint('✅ Submitted report: $docId for machine: $machineId');
    } catch (e) {
      debugPrint('❌ Error submitting report: $e');
      throw Exception('Failed to submit report: $e');
    }
  }
}