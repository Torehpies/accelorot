// lib/data/services/firebase/firestore_batch_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../contracts/batch_service.dart';

/// Firestore implementation of BatchService
/// Handles all batch-related operations and user/team queries
class FirestoreBatchService implements BatchService {
  final FirebaseFirestore _firestore;

  FirestoreBatchService(this._firestore);

  // ===== COLLECTION REFERENCES =====
  
  CollectionReference get _batches => _firestore.collection('batches');
  CollectionReference get _users => _firestore.collection('users');
  CollectionReference get _machines => _firestore.collection('machines');

  // ===== CONSTANTS =====
  
  static const int firestoreWhereinLimit = 10;

  // ===== BATCH OPERATIONS =====

  @override
  Future<String?> getBatchId(String userId, String machineId) async {
    try {
      final batchQuery = await _batches
          .where('userId', isEqualTo: userId)
          .where('machineId', isEqualTo: machineId)
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();

      if (batchQuery.docs.isNotEmpty) {
        return batchQuery.docs.first.id;
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error getting batch ID: $e');
      rethrow;
    }
  }

  @override
  Future<String> createBatch(
    String userId,
    String machineId,
    int batchNumber,
  ) async {
    try {
      final batchId = '${machineId}_batch_$batchNumber';
      final batchRef = _batches.doc(batchId);

      // Get user's teamId
      final teamId = await getUserTeamId(userId);

      await batchRef.set({
        'userId': userId,
        'machineId': machineId,
        'batchNumber': batchNumber,
        'isActive': true,
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
        'teamId': teamId,
      });

      debugPrint('✅ Created batch: $batchId with teamId: $teamId');
      return batchId;
    } catch (e) {
      debugPrint('❌ Error creating batch: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateBatchTimestamp(String batchId) async {
    try {
      await _batches.doc(batchId).update({
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      debugPrint('❌ Error updating batch timestamp: $e');
      rethrow;
    }
  }

  // ===== USER & TEAM QUERIES =====

  @override
  Future<String?> getUserTeamId(String userId) async {
    try {
      final userDoc = await _users.doc(userId).get();

      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>?;
        return data?['teamId'] as String?;
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error getting user teamId: $e');
      return null;
    }
  }

  @override
  Future<List<String>> getTeamMachineIds(String teamId) async {
    try {
      final machinesSnapshot = await _machines
          .where('teamId', isEqualTo: teamId)
          .get();

      return machinesSnapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      debugPrint('❌ Error getting team machines: $e');
      return [];
    }
  }

  // ===== BATCH QUERIES FOR MULTI-STEP FETCH =====

  /// Get all active batches for a list of machine IDs
  /// Handles Firestore's whereIn limit of 10 items by chunking
  @override
  Future<List<QueryDocumentSnapshot>> getBatchesForMachines(
    List<String> machineIds,
  ) async {
    if (machineIds.isEmpty) return [];

    try {
      // If under Firestore's whereIn limit, query normally
      if (machineIds.length <= firestoreWhereinLimit) {
        final snapshot = await _batches
            .where('machineId', whereIn: machineIds)
            .where('isActive', isEqualTo: true)
            .get();

        debugPrint('✅ Found ${snapshot.docs.length} batches for ${machineIds.length} machines');
        return snapshot.docs;
      }

      // Split into chunks of 10 for large teams
      final List<List<String>> chunks = [];
      for (int i = 0; i < machineIds.length; i += firestoreWhereinLimit) {
        final end = (i + firestoreWhereinLimit < machineIds.length)
            ? i + firestoreWhereinLimit
            : machineIds.length;
        chunks.add(machineIds.sublist(i, end));
      }

      // Query each chunk in parallel
      final futures = chunks.map((chunk) =>
        _batches
          .where('machineId', whereIn: chunk)
          .where('isActive', isEqualTo: true)
          .get()
      );

      final results = await Future.wait(futures);
      final allDocs = results.expand((snapshot) => snapshot.docs).toList();

      debugPrint('✅ Found ${allDocs.length} batches for ${machineIds.length} machines (${chunks.length} queries)');
      return allDocs;
    } catch (e) {
      debugPrint('❌ Error getting batches for machines: $e');
      return [];
    }
  }
}