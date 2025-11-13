// lib/services/firestore/firestore_upload.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/mock_data_service.dart';
import 'firestore_collections.dart';
import 'firestore_helpers.dart';

class FirestoreUpload {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Utility to determine which user ID to use.
  /// CRITICAL: This method expects the userId to ALREADY be resolved by the service layer
  /// It should NEVER be null when called - the service layer handles resolution
  static String _resolveUserId(String? userId) {
    if (userId == null || userId.isEmpty) {
      throw Exception(
        'User ID must be provided. This is a programming error - FirestoreActivityService should always resolve the user ID before calling upload methods.',
      );
    }
    return userId;
  }

  static Future<String> _getOrCreateBatch(
    String userId,
    String machineId,
  ) async {
    try {
      // Look for latest batch for this user+machine (by batchNumber)
      final batchQuery = await FirestoreCollections.getBatchesCollection()
          .where('userId', isEqualTo: userId)
          .where('machineId', isEqualTo: machineId)
          .orderBy('batchNumber', descending: true)
          .limit(1)
          .get();

      if (batchQuery.docs.isNotEmpty) {
        final doc = batchQuery.docs.first;
        final data = doc.data() as Map<String, dynamic>? ?? {};
        final isActive = data['isActive'] == true;
        final lastBatchNumber = (data['batchNumber'] is int)
            ? data['batchNumber'] as int
            : 1;

        // If there's an active batch, reuse it
        if (isActive) {
          return doc.id;
        }

        // Otherwise create a new incremented batch id for this machine
        final newBatchNumber = lastBatchNumber + 1;
        final newBatchId = '${machineId}_batch_$newBatchNumber';
        final newBatchRef = FirestoreCollections.getBatchesCollection().doc(
          newBatchId,
        );

        await newBatchRef.set({
          'userId': userId,
          'machineId': machineId,
          'createdAt': Timestamp.now(),
          'isActive': true,
          'updatedAt': Timestamp.now(),
          'batchNumber': newBatchNumber,
        });

        return newBatchId;
      }

      // No prior batch found -> create first batch for this machine
      final firstBatchId = '${machineId}_batch_1';
      final firstBatchRef = FirestoreCollections.getBatchesCollection().doc(
        firstBatchId,
      );

      await firstBatchRef.set({
        'userId': userId,
        'machineId': machineId,
        'createdAt': Timestamp.now(),
        'isActive': true,
        'updatedAt': Timestamp.now(),
        'batchNumber': 1,
      });

      return firstBatchId;
    } catch (e) {
      debugPrint('Error getting/creating batch: $e');
      rethrow;
    }
  }

  /// Upload substrate mock data to Firestore.
  static Future<void> uploadSubstrates([String? targetUserId]) async {
    try {
      final userId = _resolveUserId(targetUserId);

      final substrates = MockDataService.getSubstrates();

      // Group substrates by machine (you may need to add machineId to mock data)
      // For now, using a default batch
      final batchId = await _getOrCreateBatch(userId, 'default_machine');

      final batch = _firestore.batch();

      for (var s in substrates) {
        final docId = '${s.timestamp.millisecondsSinceEpoch}_$userId';
        final docRef = FirestoreCollections.getSubstratesCollection(
          batchId,
          userId,
        ).doc(docId);

        batch.set(docRef, {
          'title': s.title,
          'value': s.value,
          'statusColor': s.statusColor,
          'icon': s.icon.codePoint,
          'description': s.description,
          'category': s.category,
          'timestamp': s.timestamp,
          'userId': userId,
        });
      }

      await batch.commit();
    } catch (e) {
      rethrow;
    }
  }

  /// Upload alert mock data.
  static Future<void> uploadAlerts([String? targetUserId]) async {
    try {
      final userId = _resolveUserId(targetUserId);

      final alerts = MockDataService.getAlerts();
      final batch = _firestore.batch();

      for (var a in alerts) {
        final docId = '${a.timestamp.millisecondsSinceEpoch}_$userId';
        final docRef = FirestoreCollections.getAlertsCollection(
          userId,
        ).doc(docId);

        batch.set(docRef, {
          'title': a.title,
          'value': a.value,
          'statusColor': a.statusColor,
          'icon': a.icon.codePoint,
          'description': a.description,
          'category': a.category,
          'timestamp': a.timestamp,
          'userId': userId,
        });
      }

      await batch.commit();
    } catch (e) {
      rethrow;
    }
  }

  /// Upload cycles & recommendations mock data.

  static Future<void> uploadCyclesRecom([String? targetUserId]) async {
    try {
      final userId = _resolveUserId(targetUserId);

      final cycles = MockDataService.getCyclesRecom();
      final batch = _firestore.batch();

      for (var c in cycles) {
        final docId = '${c.timestamp.millisecondsSinceEpoch}_$userId';
        final docRef = FirestoreCollections.getCyclesRecomCollection(
          userId,
        ).doc(docId);

        batch.set(docRef, {
          'title': c.title,
          'value': c.value,
          'statusColor': c.statusColor,
          'icon': c.icon.codePoint,
          'description': c.description,
          'category': c.category,
          'timestamp': c.timestamp,
          'userId': userId,
        });
      }

      await batch.commit();
    } catch (e) {
      rethrow;
    }
  }

  /// Upload all mock data (if not already present).
  static Future<void> uploadAllMockData([String? targetUserId]) async {
    try {
      final userId = _resolveUserId(targetUserId);
      final exists = await FirestoreCollections.dataExists(userId);
      if (exists) return;

      await uploadSubstrates(userId);
      await uploadAlerts(userId);
      await uploadCyclesRecom(userId);
    } catch (e) {
      rethrow;
    }
  }

  /// Force re-upload all mock data (deletes existing first).
  static Future<void> forceUploadAllMockData([String? targetUserId]) async {
    try {
      final userId = _resolveUserId(targetUserId);
      await FirestoreCollections.deleteUserData(userId);

      await uploadSubstrates(userId);
      await uploadAlerts(userId);
      await uploadCyclesRecom(userId);
    } catch (e) {
      rethrow;
    }
  }

  /// Add a single waste product (manual entry)
  /// This is what gets called when creating new activity logs
  /// Now fetches machine and operator details from Firestore
  static Future<void> addWasteProduct(
    Map<String, dynamic> wasteEntry, [
    String? targetUserId,
  ]) async {
    try {
      final userId = _resolveUserId(targetUserId);
      final machineId = wasteEntry['machineId'];

      if (machineId == null || machineId.toString().isEmpty) {
        throw Exception('Machine ID is required');
      }

      // Get or create batch for this machine
      final batchId = await _getOrCreateBatch(userId, machineId);

      // Fetch machine name from machines collection
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

      // Fetch operator name from users collection using userId
      String operatorName = 'Unknown';
      try {
        final userDoc = await _firestore.collection('users').doc(userId).get();

        if (userDoc.exists) {
          final userData = userDoc.data();
          final firstName = userData?['firstname'] ?? '';
          final lastName = userData?['lastname'] ?? '';
          operatorName = '$firstName $lastName'.trim();

          if (operatorName.isEmpty) {
            operatorName = userData?['email'] ?? 'Unknown';
          }
        }
      } catch (e) {
        debugPrint('Error fetching user name: $e');
      }

      final category = wasteEntry['category'];
      final iconAndColor = FirestoreHelpers.getWasteIconAndColor(category);

      final timestamp = wasteEntry['timestamp'] as DateTime;

      final docId = '${timestamp.millisecondsSinceEpoch}_$userId';
      final docRef = FirestoreCollections.getSubstratesCollection(
        batchId,
        userId,
      ).doc(docId);

      final data = {
        'title': wasteEntry['plantTypeLabel'],
        'value': '${wasteEntry['quantity']}kg',
        'statusColor': iconAndColor['statusColor'],
        'icon': iconAndColor['iconCodePoint'],
        'description': wasteEntry['description'],
        'category': category,
        'timestamp': Timestamp.fromDate(timestamp),
        'userId': userId,
        'machineId': machineId,
        'machineName': machineName ?? 'Unknown Machine',
        'operatorName': operatorName,
        'batchId': batchId, // Add batchId reference
      };

      await docRef.set(data);

      // Update batch's updatedAt timestamp
      await FirestoreCollections.getBatchesCollection().doc(batchId).update({
        'updatedAt': Timestamp.now(),
      });

      await Future.delayed(const Duration(milliseconds: 300));

      final verify = await docRef.get();
      if (!verify.exists) throw Exception('Document not saved');

      debugPrint('✅ Waste product added successfully');
      debugPrint('   BatchId: $batchId');
      debugPrint('   Machine: ${machineName ?? 'Unknown'} ($machineId)');
      debugPrint('   Operator: $operatorName');
    } catch (e) {
      debugPrint('❌ Error adding waste product: $e');
      rethrow;
    }
  }

  /// Submit a machine report (maintenance, observation, safety)
  /// Stores in machines/{machineId}/reports/{reportId}
  static Future<void> submitReport(
    Map<String, dynamic> reportEntry, [
    String? targetUserId,
  ]) async {
    try {
      final userId = _resolveUserId(targetUserId);
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
      final iconAndColor = FirestoreHelpers.getReportIconAndColor(reportType);
      final priorityColor = FirestoreHelpers.getPriorityColor(priority);

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
        'status': 'open', // Default status
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
}
