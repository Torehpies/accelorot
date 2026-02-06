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

      // 3. Parallel Fetch: Process all batches concurrently
      // Use efficient Future.wait with type-safe results list
      final List<List<Alert>> results = await Future.wait(
        batches.map((batchDoc) async {
          try {
            final data = batchDoc.data() as Map<String, dynamic>;
            final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
            final completedAt = (data['completedAt'] as Timestamp?)?.toDate();
            final machineId = data['machineId'] as String?;

            // Fetch alerts for this specific batch
            return await fetchAlertsForBatch(
              batchDoc.id, 
              start: createdAt, 
              end: completedAt,
              machineId: machineId,
            );
          } catch (e) {
            debugPrint('⚠️ Error fetching alerts for batch ${batchDoc.id}: $e');
            return <Alert>[];
          }
        }),
      );
      
      // Flatten results
      for (var batchAlerts in results) {
        allAlerts.addAll(batchAlerts);
      }

      // Sort by timestamp descending
      allAlerts.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      debugPrint('✅ Fetched ${allAlerts.length} alerts for team (Parallel Batch Strategy)');
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

      // Parallel fetch of all potential date paths
      final List<List<Alert>> results = await Future.wait(
        datePaths.map((dateStr) async {
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
               return timeSnapshot.docs.map((d) {
                 final alert = Alert.fromFirestore(d);
                 // Inject machineId if provided and missing in alert
                 // Critical for data integrity since alert docs don't have it
                 if (machineId != null && alert.machineId.isEmpty) {
                   return alert.copyWith(machineId: machineId!);
                 }
                 return alert;
               }).toList();
            }
            return <Alert>[];
          } catch (e) {
            // Ignore errors for non-existent paths
            return <Alert>[];
          }
        }),
      );

      final List<Alert> allBatchAlerts = [];
      for (var dayAlerts in results) {
        allBatchAlerts.addAll(dayAlerts);
      }

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
    // is complex without collectionGroup. 
    // For simplicity, we convert the fetch to a Stream that emits regularly or just once.
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
      
      // Parallel search of all batches to find the ID as fast as possible
      final List<Alert?> foundAlerts = await Future.wait(
        batches.map((batchDoc) async {
           try {
             final data = batchDoc.data() as Map<String, dynamic>;
             final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
             final completedAt = (data['completedAt'] as Timestamp?)?.toDate();
             final machineId = data['machineId'] as String?;

             final alerts = await fetchAlertsForBatch(
               batchDoc.id, 
               start: createdAt, 
               end: completedAt,
               machineId: machineId
             );
             
             return alerts.firstWhere((a) => a.id == alertId);
           } catch (_) {
             return null;
           }
        })
      );
      
      // Return first non-null match
      try {
        return foundAlerts.firstWhere((a) => a != null);
      } catch (_) {
        return null;
      }

    } catch (e) {
       debugPrint('❌ Error fetching alert by ID: $e');
       return null;
    }
  }
}
