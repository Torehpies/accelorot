// lib/data/services/firebase/activity_logs/batch_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'firestore_collections.dart';

/// Service for batch and team-related operations
/// Handles shared logic across all activity services
class BatchService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ===== USER & TEAM RESOLUTION =====

  /// Validate and resolve user ID
  static String resolveUserId(String? userId) {
    if (userId == null || userId.isEmpty) {
      throw Exception('User ID must be provided');
    }
    return userId;
  }

  /// Get user's team ID
  static Future<String?> getUserTeamId(String userId) async {
    try {
      final userDoc = await _firestore
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        return userDoc.data()?['teamId'] as String?;
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching user teamId: $e');
      return null;
    }
  }

  /// Get all machine IDs for a team
  static Future<List<String>> getTeamMachineIds(String teamId) async {
    try {
      final machinesSnapshot = await _firestore
          .collection('machines')
          .where('teamId', isEqualTo: teamId)
          .get();

      return machinesSnapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      debugPrint('Error fetching team machine IDs: $e');
      return [];
    }
  }

  /// Get all batches for given machine IDs
  static Future<List<DocumentSnapshot>> getBatchesForMachines(
    List<String> machineIds,
  ) async {
    if (machineIds.isEmpty) return [];

    try {
      final batchesSnapshot = await FirestoreCollections.getBatchesCollection()
          .where('machineId', whereIn: machineIds)
          .get();

      return batchesSnapshot.docs;
    } catch (e) {
      debugPrint('Error fetching batches for machines: $e');
      return [];
    }
  }

  /// Get all batches for a specific user
  static Future<List<DocumentSnapshot>> getBatchesForUser(String userId) async {
    try {
      final batchesSnapshot = await FirestoreCollections.getBatchesCollection()
          .where('userId', isEqualTo: userId)
          .get();

      return batchesSnapshot.docs;
    } catch (e) {
      debugPrint('Error fetching batches for user: $e');
      return [];
    }
  }

  // ===== BATCH MANAGEMENT =====

  /// Get or create a batch for a user and machine
  static Future<String> getOrCreateBatch(
    String userId,
    String machineId,
  ) async {
    try {
      // Look for latest batch for this user+machine
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

        // Otherwise create a new incremented batch
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

      // No prior batch found -> create first batch
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

  /// Update batch timestamp
  static Future<void> updateBatchTimestamp(String batchId) async {
    try {
      await FirestoreCollections.getBatchesCollection().doc(batchId).update({
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      debugPrint('Error updating batch timestamp: $e');
    }
  }
}