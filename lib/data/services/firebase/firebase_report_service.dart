import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../contracts/report_service.dart';
import '../../models/report_model.dart';

class FirebaseReportService implements ReportService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  FirebaseReportService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  @override
  Future<List<ReportModel>> fetchReportsByTeam(String teamId) async {
    try {
      // Get all machines for this team
      final machinesSnapshot = await _firestore
          .collection('machines')
          .where('teamId', isEqualTo: teamId)
          .get();

      final List<ReportModel> allReports = [];

      // Fetch reports for each machine
      for (var machineDoc in machinesSnapshot.docs) {
        final reportsSnapshot = await _firestore
            .collection('machines')
            .doc(machineDoc.id)
            .collection('reports')
            .orderBy('createdAt', descending: true)
            .get();

        final reports = reportsSnapshot.docs
            .map((doc) => ReportModel.fromFirestore(doc))
            .toList();

        allReports.addAll(reports);
      }

      // Sort by creation date (newest first)
      allReports.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return allReports;
    } catch (e) {
      throw Exception('Failed to fetch team reports: $e');
    }
  }

  @override
  Future<List<ReportModel>> fetchReportsByMachine(String machineId) async {
    try {
      final snapshot = await _firestore
          .collection('machines')
          .doc(machineId)
          .collection('reports')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => ReportModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch machine reports: $e');
    }
  }

  @override
  Future<ReportModel?> fetchReportById(String machineId, String reportId) async {
    try {
      final doc = await _firestore
          .collection('machines')
          .doc(machineId)
          .collection('reports')
          .doc(reportId)
          .get();

      if (!doc.exists) return null;
      return ReportModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to fetch report: $e');
    }
  }

  @override
  Future<void> createReport(String machineId, CreateReportRequest request) async {
    if (currentUserId == null) {
      throw Exception('User must be authenticated');
    }

    try {
      await _firestore
          .collection('machines')
          .doc(machineId)
          .collection('reports')
          .add({
        'machineId': machineId,
        'machineName': request.machineName,
        'title': request.title,
        'description': request.description,
        'reportType': request.reportType,
        'status': 'open',
        'priority': request.priority,
        'userName': request.userName,
        'userId': request.userId ?? currentUserId,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to create report: $e');
    }
  }

  @override
  Future<void> updateReport(String machineId, UpdateReportRequest request) async {
    if (currentUserId == null) {
      throw Exception('User must be authenticated');
    }

    try {
      final updates = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (request.title != null) updates['title'] = request.title;
      if (request.description != null) updates['description'] = request.description;
      if (request.status != null) updates['status'] = request.status;
      if (request.priority != null) updates['priority'] = request.priority;
      if (request.metadata != null) updates['metadata'] = request.metadata;

      await _firestore
          .collection('machines')
          .doc(machineId)
          .collection('reports')
          .doc(request.reportId)
          .update(updates);
    } catch (e) {
      throw Exception('Failed to update report: $e');
    }
  }

  @override
  Future<void> deleteReport(String machineId, String reportId) async {
    if (currentUserId == null) {
      throw Exception('User must be authenticated');
    }

    try {
      await _firestore
          .collection('machines')
          .doc(machineId)
          .collection('reports')
          .doc(reportId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete report: $e');
    }
  }

  @override
  Stream<List<ReportModel>> watchReportsByTeam(String teamId) {
    // For now, return a simple implementation
    // You may need to implement a more complex solution for real-time team reports
    return Stream.value([]);
  }

  @override
  Stream<List<ReportModel>> watchReportsByMachine(String machineId) {
    return _firestore
        .collection('machines')
        .doc(machineId)
        .collection('reports')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ReportModel.fromFirestore(doc)).toList());
  }
}