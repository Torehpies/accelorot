// lib/data/services/firebase/firestore_substrate_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../contracts/substrate_service.dart';
import '../contracts/batch_service.dart';
import '../../models/substrate.dart';

/// Firestore implementation of SubstrateService
/// Handles substrate CRUD operations with team-aware queries
class FirestoreSubstrateService implements SubstrateService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final BatchService _batchService;

  FirestoreSubstrateService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    required BatchService batchService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _batchService = batchService;

  /// Get current authenticated user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // ===== FETCH OPERATIONS =====

  @override
  Future<List<Substrate>> fetchTeamSubstrates() async {
    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }

    try {
      // Get user's teamId
      final teamId = await _batchService.getUserTeamId(currentUserId!);

      // Team is required - no solo fallback
      if (teamId == null || teamId.isEmpty) {
        debugPrint('⚠️ User has no team assigned');
        return [];
      }

      // Fetch team-wide substrates
      final allSubstrates = await _fetchTeamSubstrates(teamId);

      // Sort by timestamp descending (newest first)
      allSubstrates.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      debugPrint('✅ Fetched ${allSubstrates.length} substrates');
      return allSubstrates;
    } catch (e) {
      debugPrint('❌ Error fetching substrates: $e');
      throw Exception('Failed to fetch substrates: $e');
    }
  }

  /// Fetch substrates for team users (multi-step query)
  Future<List<Substrate>> _fetchTeamSubstrates(String teamId) async {
    final List<Substrate> allSubstrates = [];
    int successCount = 0;
    int failureCount = 0;

    // Get all machines belonging to this team
    final teamMachineIds = await _batchService.getTeamMachineIds(teamId);

    if (teamMachineIds.isEmpty) {
      debugPrint('ℹ️ No machines found for team: $teamId');
      return [];
    }

    // Get all batches for those machines
    final batches = await _batchService.getBatchesForMachines(teamMachineIds);

    if (batches.isEmpty) {
      debugPrint('ℹ️ No batches found for team machines');
      return [];
    }

    // Fetch substrates from each batch's subcollection in parallel
    final futures = batches.map((batchDoc) async {
      try {
        // PATH: batches/{batchId}/substrates
        final substratesSnapshot = await _firestore
            .collection('batches')
            .doc(batchDoc.id)
            .collection('substrates')
            .orderBy('timestamp', descending: true)
            .get();

        final substrates = substratesSnapshot.docs
            .map((doc) => Substrate.fromFirestore(doc))
            .toList();

        return {'success': true, 'substrates': substrates};
      } catch (e) {
        debugPrint('⚠️ Error fetching substrates from batch ${batchDoc.id}: $e');
        return {'success': false, 'substrates': <Substrate>[]};
      }
    });

    final results = await Future.wait(futures);

    for (var result in results) {
      if (result['success'] as bool) {
        allSubstrates.addAll(result['substrates'] as List<Substrate>);
        successCount++;
      } else {
        failureCount++;
      }
    }

    debugPrint('📊 Fetched substrates from $successCount/${batches.length} batches ($failureCount failures)');
    return allSubstrates;
  }

  // ===== CREATE OPERATIONS =====

  @override
  Future<void> addSubstrate(Map<String, dynamic> data) async {
    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }

    final machineId = data['machineId'];
    if (machineId == null || machineId.toString().isEmpty) {
      throw Exception('Machine ID is required');
    }

    try {
      // Get or create batch
      String batchId = await _batchService.getBatchId(currentUserId!, machineId) ??
          await _batchService.createBatch(currentUserId!, machineId, 1);

      // Get teamId
      final teamId = await _batchService.getUserTeamId(currentUserId!);

      // Create document
      final DateTime timestamp = data['timestamp'] as DateTime? ?? DateTime.now();
      final docId = '${timestamp.millisecondsSinceEpoch}_$currentUserId';

      // PATH: batches/{batchId}/substrates
      final docRef = _firestore
          .collection('batches')
          .doc(batchId)
          .collection('substrates')
          .doc(docId);

      await docRef.set({
        ...data,
        'batchId': batchId,
        'teamId': teamId,
        'createdBy': currentUserId, // Only store creator, not batch owner
        'timestamp': Timestamp.fromDate(timestamp),
      });

      // Update batch timestamp
      await _batchService.updateBatchTimestamp(batchId);

      debugPrint('✅ Added substrate to batch: $batchId');
    } catch (e) {
      debugPrint('❌ Error adding substrate: $e');
      throw Exception('Failed to add substrate: $e');
    }
  }
}