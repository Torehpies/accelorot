// lib/data/services/firebase/activity_logs/firestore_report_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/report.dart';
import '../contracts/report_service.dart';
import 'firestore_collections.dart';

/// Firestore implementation of ReportService
class FirestoreReportService implements ReportService {
  final FirebaseFirestore _firestore;

  FirestoreReportService(this._firestore);

  @override
  Future<List<Report>> fetchTeamReports(String teamId) async {
    // Get all machines for this team (TEAM-FILTERED!)
    final machinesSnapshot = await FirestoreCollections.machines
        .where('teamId', isEqualTo: teamId)
        .get();

    List<Report> allReports = [];

    // Fetch reports from each team machine
    for (var machineDoc in machinesSnapshot.docs) {
      final reportsSnapshot = await FirestoreCollections.reports(machineDoc.id)
          .orderBy('createdAt', descending: true)
          .get();

      final reports = reportsSnapshot.docs
          .map((doc) => Report.fromFirestore(doc))
          .toList();

      allReports.addAll(reports);
    }

    // Sort by timestamp descending
    allReports.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return allReports;
  }

  @override
  Future<List<Report>> fetchReportsForMachine(String machineId) async {
    final reportsSnapshot = await FirestoreCollections.reports(machineId)
        .orderBy('createdAt', descending: true)
        .get();

    return reportsSnapshot.docs
        .map((doc) => Report.fromFirestore(doc))
        .toList();
  }

  @override
  Future<void> submitReport(Map<String, dynamic> reportEntry) async {
    final userId = reportEntry['userId'];
    final machineId = reportEntry['machineId'];
    final reportType = reportEntry['reportType'];
    final priority = reportEntry['priority'];
    final timestamp = reportEntry['timestamp'] as DateTime;

    // Fetch machine name
    String? machineName;
    final machineDoc = await _firestore.collection('machines').doc(machineId).get();
    if (machineDoc.exists) {
      machineName = machineDoc.data()?['machineName'];
    }

    // Fetch user name and role
    String userName = 'Unknown';
    String userRole = 'Unknown';
    final userDoc = await _firestore.collection('users').doc(userId).get();
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

    // Create document ID
    final docId = '${reportType}_${timestamp.millisecondsSinceEpoch}';
    final docRef = FirestoreCollections.reports(machineId).doc(docId);

    // Save data (NO statusColor or icon)
    final data = {
      'reportType': reportType,
      'title': reportEntry['title'],
      'machineId': machineId,
      'machineName': machineName ?? 'Unknown Machine',
      'userId': userId,
      'userName': userName,
      'userRole': userRole,
      'description': reportEntry['description'] ?? '',
      'priority': priority,
      'status': 'open',
      'createdAt': Timestamp.fromDate(timestamp),
      'resolvedAt': null,
      'resolvedBy': null,
    };

    await docRef.set(data);
  }
}