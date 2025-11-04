// lib/services/report_services/firestore_report_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../frontend/operator/machine_management/admin_machine/reports/models/report_model.dart';

class FirestoreReportService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get current user ID
  static String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }

  /// Fetch all reports from all machines belonging to a team
  /// 1. Query machines where teamId matches
  /// 2. Fetch reports subcollection from each machine
  /// 3. Combine all reports
  static Future<List<ReportModel>> getTeamReports(String teamId) async {
    try {
      // Step 1: Get all machines with matching teamId (not archived)
      final machinesSnapshot = await _firestore
          .collection('machines')
          .where('teamId', isEqualTo: teamId)
          .where('isArchived', isEqualTo: false)
          .get();

      List<ReportModel> allReports = [];

      // Step 2: Fetch reports from each machine
      for (var machineDoc in machinesSnapshot.docs) {
        final reportsSnapshot = await machineDoc.reference
            .collection('reports')
            .orderBy('createdAt', descending: true)
            .get();

        // Convert each report document to ReportModel
        for (var reportDoc in reportsSnapshot.docs) {
          allReports.add(ReportModel.fromFirestore(reportDoc));
        }
      }

      return allReports;
    } catch (e) {
      throw Exception('Failed to fetch team reports: $e');
    }
  }

  /// Update an existing report
  /// Path: machines/{machineId}/reports/{reportId}
  static Future<void> updateReport({
    required String machineId,
    required String reportId,
    String? title,
    String? description,
    String? status,
    String? priority,
  }) async {
    try {
      final reportRef = _firestore
          .collection('machines')
          .doc(machineId)
          .collection('reports')
          .doc(reportId);

      // Build update map with only non-null fields
      Map<String, dynamic> updates = {};
      if (title != null) updates['title'] = title;
      if (description != null) updates['description'] = description;
      if (status != null) updates['status'] = status;
      if (priority != null) updates['priority'] = priority;

      if (updates.isEmpty) {
        throw Exception('No fields to update');
      }

      await reportRef.update(updates);
      
      // Delay for consistency (like machine updates)
      await Future.delayed(const Duration(milliseconds: 1000));
    } catch (e) {
      throw Exception('Failed to update report: $e');
    }
  }

  /// Get a single report by machineId and reportId
  static Future<ReportModel?> getReportById({
    required String machineId,
    required String reportId,
  }) async {
    try {
      final reportDoc = await _firestore
          .collection('machines')
          .doc(machineId)
          .collection('reports')
          .doc(reportId)
          .get();

      if (reportDoc.exists) {
        return ReportModel.fromFirestore(reportDoc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch report: $e');
    }
  }

  /// Check if user is authenticated
  static bool isAuthenticated() {
    return _auth.currentUser != null;
  }
}