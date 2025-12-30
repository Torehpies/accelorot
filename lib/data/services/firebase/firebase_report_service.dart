// lib/data/services/firebase/firebase_report_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../contracts/report_service.dart';
import '../../models/report.dart';

class FirebaseReportService implements ReportService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  FirebaseReportService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  String get _currentUserId {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');
    return user.uid;
  }

  Future<String> _getTeamId() async {
    final userDoc = await _firestore
        .collection('users')
        .doc(_currentUserId)
        .get();
    
    if (!userDoc.exists) throw Exception('User document not found');
    
    final teamId = userDoc.data()?['teamId'];
    if (teamId == null) throw Exception('User has no team assigned');
    
    return teamId as String;
  }

  @override
  Future<List<Report>> fetchTeamReports() async {
    try {
      final teamId = await _getTeamId();
      return fetchReportsByTeam(teamId);
    } catch (e) {
      throw Exception('Failed to fetch team reports: $e');
    }
  }

  @override
  Future<List<Report>> fetchReportsByTeam(String teamId) async {
    try {
      // Get all machines for the team
      final machinesSnapshot = await _firestore
          .collection('machines')
          .where('teamId', isEqualTo: teamId)
          .get();

      final reports = <Report>[];

      // Fetch reports from each machine's subcollection
      for (final machineDoc in machinesSnapshot.docs) {
        final machineReports = await fetchReportsForMachine(machineDoc.id);
        reports.addAll(machineReports);
      }

      // Sort by createdAt descending
      reports.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return reports;
    } catch (e) {
      throw Exception('Failed to fetch reports by team: $e');
    }
  }

  @override
  Future<List<Report>> fetchReportsForMachine(String machineId) async {
    try {
      final snapshot = await _firestore
          .collection('machines')
          .doc(machineId)
          .collection('reports')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Report.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch reports for machine: $e');
    }
  }

  @override
  Future<Report?> fetchReportById(String machineId, String reportId) async {
    try {
      final doc = await _firestore
          .collection('machines')
          .doc(machineId)
          .collection('reports')
          .doc(reportId)
          .get();

      if (!doc.exists) return null;

      return Report.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to fetch report: $e');
    }
  }

  @override
  Future<void> createReport(
    String machineId,
    CreateReportRequest request,
  ) async {
    try {
      final userId = _currentUserId;
      final timestamp = DateTime.now();

      // Fetch machine name
      String machineName = request.machineName ?? 'Unknown Machine';
      if (request.machineName == null) {
        final machineDoc = await _firestore
            .collection('machines')
            .doc(machineId)
            .get();

        if (machineDoc.exists) {
          machineName = machineDoc.data()?['machineName'] ?? 'Unknown Machine';
        }
      }

      // Fetch user info
      String userName = request.userName;
      String userRole = 'Unknown';
      
      if (request.userId != null) {
        final userDoc = await _firestore
            .collection('users')
            .doc(request.userId)
            .get();

        if (userDoc.exists) {
          final userData = userDoc.data();
          userRole = userData?['role'] ?? 'Unknown';
        }
      }

      // Create document ID: {reportType}_{timestamp}
      final docId = '${request.reportType}_${timestamp.millisecondsSinceEpoch}';

      // Create the report
      final report = Report(
        id: docId,
        reportType: request.reportType,
        title: request.title,
        machineId: machineId,
        machineName: machineName,
        userId: request.userId ?? userId,
        userName: userName,
        userRole: userRole,
        description: request.description,
        priority: request.priority,
        status: 'open',
        createdAt: timestamp,
      );

      // Save to machines/{machineId}/reports/{docId}
      await _firestore
          .collection('machines')
          .doc(machineId)
          .collection('reports')
          .doc(docId)
          .set(report.toFirestore());

    } catch (e) {
      throw Exception('Failed to create report: $e');
    }
  }

  @override
  Future<void> updateReport(
    String machineId,
    UpdateReportRequest request,
  ) async {
    try {
      final updateData = <String, dynamic>{
        'updatedAt': Timestamp.now(),
      };

      if (request.title != null) updateData['title'] = request.title;
      if (request.description != null) {
        updateData['description'] = request.description;
      }
      if (request.status != null) {
        updateData['status'] = request.status;
        
        // If closing/resolving, add resolved info
        if (request.status == 'closed' || request.status == 'resolved') {
          updateData['resolvedAt'] = Timestamp.now();
          updateData['resolvedBy'] = _currentUserId;
        }
      }
      if (request.priority != null) updateData['priority'] = request.priority;
      if (request.metadata != null) updateData['metadata'] = request.metadata;

      await _firestore
          .collection('machines')
          .doc(machineId)
          .collection('reports')
          .doc(request.reportId)
          .update(updateData);

    } catch (e) {
      throw Exception('Failed to update report: $e');
    }
  }

  @override
  Future<void> deleteReport(String machineId, String reportId) async {
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
  Stream<List<Report>> watchReportsByTeam(String teamId) {
    // This is complex because we need to watch multiple machine subcollections
    // For now, throwing unimplemented - can be added later if needed
    throw UnimplementedError(
      'Stream watching across multiple machines not yet implemented. Use fetchReportsByTeam() and poll instead.',
    );
  }

  @override
  Stream<List<Report>> watchReportsByMachine(String machineId) {
    // PATH: machines/{machineId}/reports
    return _firestore
        .collection('machines')
        .doc(machineId)
        .collection('reports')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Report.fromFirestore(doc)).toList());
  }
}