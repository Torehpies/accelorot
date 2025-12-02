// lib/data/services/firebase/firestore_report_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../contracts/report_service.dart';
import '../contracts/batch_service.dart';
import '../../models/report.dart';

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

  CollectionReference get _reportsCollection =>
      _firestore.collection('reports');

  @override
  Future<List<Report>> fetchTeamReports() async {
    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }

    final teamId = await _getTeamId(currentUserId!);

    try {
      final snapshot = await _reportsCollection
          .where('teamId', isEqualTo: teamId)
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Report.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch reports: $e');
    }
  }

  @override
  Future<List<Report>> fetchReportsForMachine(String machineId) async {
    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }

    try {
      final snapshot = await _reportsCollection
          .where('machineId', isEqualTo: machineId)
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Report.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch machine reports: $e');
    }
  }

  @override
  Future<void> submitReport(Map<String, dynamic> reportEntry) async {
    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }

    try {
      await _reportsCollection.add({
        ...reportEntry,
        'createdBy': currentUserId,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to submit report: $e');
    }
  }

  /// Helper: Get team ID for the current user
  Future<String> _getTeamId(String userId) async {
    final teamId = await _batchService.getUserTeamId(userId);
    if (teamId == null || teamId.isEmpty) {
      throw Exception('User is not part of any team');
    }
    return teamId;
  }
}