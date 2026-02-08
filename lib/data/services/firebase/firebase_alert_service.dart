// lib/data/services/firebase/firebase_alert_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../contracts/alert_service.dart';
import '../contracts/batch_service.dart';
import '../../models/alert.dart';

/// Firestore implementation of AlertService
/// Handles alert queries with team-aware logic
class FirestoreAlertService implements AlertService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final BatchService _batchService;

  FirestoreAlertService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    required BatchService batchService,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance,
       _batchService = batchService;

  /// Get current authenticated user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // ===== FETCH OPERATIONS =====

  @override
  Future<List<Alert>> fetchTeamAlerts() async {
    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }

    try {
      // Get user's teamId
      final teamId = await _batchService.getUserTeamId(currentUserId!);

      if (teamId == null || teamId.isEmpty) {
        debugPrint('⚠️ User has no team assigned');
        return [];
      }

      // 1. Get all machines for the team
      final teamMachineIds = await _batchService.getTeamMachineIds(teamId);

      if (teamMachineIds.isEmpty) {
        debugPrint('ℹ️ No machines found for team: $teamId');
        return [];
      }

      // 2. Get all batches for these machines
      final batches = await _batchService.getBatchesForMachines(teamMachineIds);

      if (batches.isEmpty) {
        return [];
      }

      final List<Alert> allAlerts = [];

      // 3. For each batch, fetch its alerts
      await Future.wait(batches.map((batchDoc) async {
        try {
          // Extract dates to handle phantom documents
          // We can't list the 'date' documents because they might not exist (phantom)
          final data = batchDoc.data() as Map<String, dynamic>;
          final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
          final completedAt = (data['completedAt'] as Timestamp?)?.toDate();
          final machineId = data['machineId'] as String?;

          final batchAlerts = await fetchAlertsForBatch(
            batchDoc.id, 
            start: createdAt, 
            end: completedAt,
            machineId: machineId,
          );
          allAlerts.addAll(batchAlerts);
        } catch (e) {
          debugPrint('⚠️ Error fetching alerts for batch ${batchDoc.id}: $e');
        }
      }));

      // Sort by timestamp descending
      allAlerts.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      debugPrint('✅ Fetched ${allAlerts.length} alerts for team');
      return allAlerts;
    } catch (e) {
      debugPrint('❌ Error fetching team alerts: $e');
      throw Exception('Failed to fetch alerts: $e');
    }
  }

  @override
  Future<List<Alert>> fetchAlertsForBatch(
    String batchId, {
    DateTime? start,
    DateTime? end,
    String? machineId,
  }) async {
    try {
      // If dates or machineId are not provided, we must fetch the batch
      if (start == null || machineId == null) {
        final batchDoc = await _firestore.collection('batches').doc(batchId).get();
        if (!batchDoc.exists) return [];
        final data = batchDoc.data() as Map<String, dynamic>;
        
        start ??= (data['createdAt'] as Timestamp?)?.toDate();
        end ??= (data['completedAt'] as Timestamp?)?.toDate();
        machineId ??= data['machineId'] as String?;
      }

      if (start == null) return []; // Should not happen for valid batches

      final endDate = end ?? DateTime.now();
      // Pad by 1 day to handle timezone diffs between ESP and App
      final List<String> datePaths = _generateDatePaths(
        start.subtract(const Duration(days: 1)), 
        endDate.add(const Duration(days: 1))
      );

      final List<Alert> allBatchAlerts = [];

      // Parallel fetch of all potential date paths
      await Future.wait(datePaths.map((dateStr) async {
        try {
          // PATH: batches/{batchId}/alerts/{dateStr}/time
          final timeSnapshot = await _firestore
              .collection('batches')
              .doc(batchId)
              .collection('alerts')
              .doc(dateStr)
              .collection('time')
              .get();
              
          if (timeSnapshot.docs.isNotEmpty) {
             final alerts = timeSnapshot.docs.map((d) {
               final alert = Alert.fromFirestore(d);
               // Inject machineId if provided and missing in alert
               if (machineId != null && alert.machineId.isEmpty) {
                 return alert.copyWith(machineId: machineId);
               }
               return alert;
             });
             allBatchAlerts.addAll(alerts);
          }
        } catch (e) {
          // Ignore errors for non-existent paths
        }
      }));

      // Sort local results
      allBatchAlerts.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      
      return allBatchAlerts;
    } catch (e) {
      debugPrint('❌ Error fetching batch alerts: $e');
      throw Exception('Failed to fetch batch alerts: $e');
    }
  }

  /// Helper to generate yyyy-MM-dd strings
  List<String> _generateDatePaths(DateTime start, DateTime end) {
    final List<String> paths = [];
    // Remove time components for strict day comparison
    DateTime current = DateTime(start.year, start.month, start.day);
    final DateTime last = DateTime(end.year, end.month, end.day);

    while (!current.isAfter(last)) {
       final month = current.month.toString().padLeft(2, '0');
       final day = current.day.toString().padLeft(2, '0');
       paths.add("${current.year}-$month-$day");
       current = current.add(const Duration(days: 1));
    }
    return paths;
  }

  @override
  Stream<List<Alert>> streamAlerts(String batchId) {
    // Note: True real-time streaming of dynamically created "date" collections 
    
    return Stream.fromFuture(fetchAlertsForBatch(batchId));
  }

  @override
  Future<Alert?> fetchAlertById(String alertId) async {
     if (currentUserId == null) {
      throw Exception('User not authenticated');
    }

    try {
      
      final teamId = await _batchService.getUserTeamId(currentUserId!);
      if (teamId == null) return null;

      final teamMachineIds = await _batchService.getTeamMachineIds(teamId);
      if (teamMachineIds.isEmpty) return null;

      final batches = await _batchService.getBatchesForMachines(teamMachineIds);
      
      for (var batchDoc in batches) {

         
         final data = batchDoc.data() as Map<String, dynamic>;
         final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
         final completedAt = (data['completedAt'] as Timestamp?)?.toDate();

         final alerts = await fetchAlertsForBatch(batchDoc.id, start: createdAt, end: completedAt);
         try {
           return alerts.firstWhere((a) => a.id == alertId);
         } catch (_) {
           continue;
         }
      }
      
      return null;
    } catch (e) {
       debugPrint('❌ Error fetching alert by ID: $e');
       return null;
    }
  }
}
