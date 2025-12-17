// lib/data/services/firebase/firebase_batch_service.dart

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
      final querySnapshot = await _batches
          .where('userId', isEqualTo: userId)
          .where('machineId', isEqualTo: machineId)
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return null;
      }

      return querySnapshot.docs.first.id;
    } catch (e) {
      debugPrint('Error getting batch ID: $e');
      return null;
    }
  }

  @override
  Future<String> createBatch(
    String userId,
    String machineId,
    int batchNumber,
  ) async {
    try {
      final docRef = await _batches.add({
        'userId': userId,
        'machineId': machineId,
        'batchNumber': batchNumber,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update machine's currentBatchId
      await _machines.doc(machineId).update({
        'currentBatchId': docRef.id,
        'lastModified': FieldValue.serverTimestamp(),
      });

      return docRef.id;
    } catch (e) {
      debugPrint('Error creating batch: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateBatchTimestamp(String batchId) async {
    try {
      await _batches.doc(batchId).update({
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error updating batch timestamp: $e');
      rethrow;
    }
  }

  @override
  Future<void> completeBatch(
    String batchId, {
    required double finalWeight,
    String? completionNotes,
  }) async {
    try {
      // Get batch to find machineId
      final batchDoc = await _batches.doc(batchId).get();
      final batchData = batchDoc.data() as Map<String, dynamic>?;
      final machineId = batchData?['machineId'] as String?;

      // Update batch to completed
      await _batches.doc(batchId).update({
        'isActive': false,
        'completedAt': FieldValue.serverTimestamp(),
        'finalWeight': finalWeight,
        'completionNotes': completionNotes,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Clear machine's currentBatchId
      if (machineId != null) {
        await _machines.doc(machineId).update({
          'currentBatchId': null,
          'lastModified': FieldValue.serverTimestamp(),
        });
      }

      debugPrint('Batch $batchId completed successfully');
    } catch (e) {
      debugPrint('Error completing batch: $e');
      rethrow;
    }
  }

  // ===== USER & TEAM QUERIES =====

  @override
  Future<String?> getUserTeamId(String userId) async {
    try {
      final userDoc = await _users.doc(userId).get();
      if (!userDoc.exists) return null;

      final data = userDoc.data() as Map<String, dynamic>?;
      return data?['teamId'] as String?;
    } catch (e) {
      debugPrint('Error getting user team ID: $e');
      return null;
    }
  }

  @override
  Future<List<String>> getTeamMachineIds(String teamId) async {
    try {
      final querySnapshot = await _machines
          .where('teamId', isEqualTo: teamId)
          .where('isArchived', isEqualTo: false)
          .get();

      return querySnapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      debugPrint('Error getting team machine IDs: $e');
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
      final List<QueryDocumentSnapshot> allDocs = [];

      // Split into chunks of 10 (Firestore whereIn limit)
      for (int i = 0; i < machineIds.length; i += firestoreWhereinLimit) {
        final chunk = machineIds.skip(i).take(firestoreWhereinLimit).toList();

        final querySnapshot = await _batches
            .where('machineId', whereIn: chunk)
            .where('isActive', isEqualTo: true)
            .orderBy('createdAt', descending: true)
            .get();

        allDocs.addAll(querySnapshot.docs);
      }

      return allDocs;
    } catch (e) {
      debugPrint('Error getting batches for machines: $e');
      return [];
    }
  }
}