// lib/data/services/firebase/activity_logs/report_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../models/report.dart';

/// Service for report operations
class ReportService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ===== FETCH OPERATIONS =====

  /// Fetch all reports from all machines the user can access
  static Future<List<Report>> fetchReports() async {
    try {
      // Fetch all machines (reports are stored per machine)
      final machinesSnapshot = await _firestore
          .collection('machines')
          .get();

      List<Report> allReports = [];

      // Fetch reports from each machine
      for (var machineDoc in machinesSnapshot.docs) {
        try {
          final reportsSnapshot = await _firestore
              .collection('machines')
              .doc(machineDoc.id)
              .collection('reports')
              .orderBy('createdAt', descending: true)
              .get();

          final reports = reportsSnapshot.docs
              .map((doc) => Report.fromFirestore(doc))
              .toList();

          allReports.addAll(reports);
        } catch (e) {
          debugPrint('Error fetching reports for machine ${machineDoc.id}: $e');
        }
      }

      // Sort by timestamp descending
      allReports.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      debugPrint('✅ Fetched ${allReports.length} reports across all machines');

      return allReports;
    } catch (e) {
      debugPrint('❌ Error fetching reports: $e');
      rethrow;
    }
  }

  /// Fetch reports for a specific machine
  static Future<List<Report>> fetchReportsForMachine(String machineId) async {
    try {
      final reportsSnapshot = await _firestore
          .collection('machines')
          .doc(machineId)
          .collection('reports')
          .orderBy('createdAt', descending: true)
          .get();

      return reportsSnapshot.docs
          .map((doc) => Report.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint('Error fetching reports for machine $machineId: $e');
      return [];
    }
  }

  // ===== CREATE OPERATIONS =====

  /// Submit a new report
  static Future<void> submitReport(Map<String, dynamic> reportEntry) async {
    try {
      final userId = reportEntry['userId'];
      if (userId == null || userId.toString().isEmpty) {
        throw Exception('User ID is required');
      }

      final machineId = reportEntry['machineId'];
      if (machineId == null || machineId.toString().isEmpty) {
        throw Exception('Machine ID is required');
      }

      final reportType = reportEntry['reportType'];
      final priority = reportEntry['priority'];
      final timestamp = reportEntry['timestamp'] as DateTime;

      // Fetch machine name
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
        debugPrint('Error fetching machine name: $e');
      }

      // Fetch user name and role
      String userName = 'Unknown';
      String userRole = 'Unknown';
      try {
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
      } catch (e) {
        debugPrint('Error fetching user info: $e');
      }

      // Get icon and color based on report type and priority
      final iconAndColor = _getReportIconAndColor(reportType);
      final priorityColor = _getPriorityColor(priority);

      // Create document ID: {reportType}_{timestamp}
      final docId = '${reportType}_${timestamp.millisecondsSinceEpoch}';

      // Reference to machines/{machineId}/reports/{docId}
      final docRef = _firestore
          .collection('machines')
          .doc(machineId)
          .collection('reports')
          .doc(docId);

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
        'statusColor': priorityColor,
        'icon': iconAndColor['iconCodePoint'],
        'createdAt': Timestamp.fromDate(timestamp),
        'resolvedAt': null,
        'resolvedBy': null,
      };

      await docRef.set(data);

      await Future.delayed(const Duration(milliseconds: 300));

      final verify = await docRef.get();
      if (!verify.exists) throw Exception('Report not saved');

      debugPrint('✅ Report submitted successfully');
      debugPrint('   ReportId: $docId');
      debugPrint('   Machine: ${machineName ?? 'Unknown'} ($machineId)');
      debugPrint('   Submitted by: $userName ($userRole)');
      debugPrint('   Priority: $priority');
    } catch (e) {
      debugPrint('❌ Error submitting report: $e');
      rethrow;
    }
  }

  // ===== HELPERS =====

  /// Get icon and color for report types
  static Map<String, dynamic> _getReportIconAndColor(String? reportType) {
    switch (reportType?.toLowerCase()) {
      case 'maintenance_issue':
        return {'iconCodePoint': 0xe5d9}; // Icons.build
      case 'observation':
        return {'iconCodePoint': 0xe8f4}; // Icons.visibility
      case 'safety_concern':
        return {'iconCodePoint': 0xe002}; // Icons.warning
      default:
        return {'iconCodePoint': 0xe160}; // Icons.report
    }
  }

  /// Get color based on priority level
  static int _getPriorityColor(String? priority) {
    switch (priority?.toLowerCase()) {
      case 'low':
        return 0xFF4CAF50; // Green
      case 'medium':
        return 0xFFFFC107; // Amber/Yellow
      case 'high':
        return 0xFFFF9800; // Orange
      case 'critical':
        return 0xFFF44336; // Red
      default:
        return 0xFF9E9E9E; // Gray
    }
  }
}