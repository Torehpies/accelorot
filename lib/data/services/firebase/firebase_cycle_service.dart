// lib/data/services/firebase/firestore_cycle_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../contracts/cycle_service.dart';
import '../contracts/batch_service.dart';
import '../../models/cycle_recommendation.dart';

/// Firestore implementation of CycleService
/// Handles cycle recommendation queries with team-aware logic
class FirestoreCycleService implements CycleService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final BatchService _batchService;

  FirestoreCycleService({
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
  Future<List<CycleRecommendation>> fetchTeamCycles() async {
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

      // Fetch team-wide cycles
      final allCycles = await _fetchTeamCycles(teamId);

      // Sort by timestamp descending (newest first)
      allCycles.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      debugPrint('✅ Fetched ${allCycles.length} cycles');
      return allCycles;
    } catch (e) {
      debugPrint('❌ Error fetching cycles: $e');
      throw Exception('Failed to fetch cycles: $e');
    }
  }

  /// Fetch cycles for team users (multi-step query)
  Future<List<CycleRecommendation>> _fetchTeamCycles(String teamId) async {
    final List<CycleRecommendation> allCycles = [];
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

    // Fetch cycles from each batch's subcollection in parallel
    final futures = batches.map((batchDoc) async {
      try {
        // batches/{batchId}/cyclesRecom
        final cyclesSnapshot = await _firestore
            .collection('batches')
            .doc(batchDoc.id)
            .collection('cyclesRecom')
            .orderBy('timestamp', descending: true)
            .get();

        final cycles = cyclesSnapshot.docs
            .map((doc) => CycleRecommendation.fromFirestore(doc))
            .toList();

        return {'success': true, 'cycles': cycles};
      } catch (e) {
        debugPrint('⚠️ Error fetching cycles from batch ${batchDoc.id}: $e');
        return {'success': false, 'cycles': <CycleRecommendation>[]};
      }
    });

    final results = await Future.wait(futures);

    for (var result in results) {
      if (result['success'] as bool) {
        allCycles.addAll(result['cycles'] as List<CycleRecommendation>);
        successCount++;
      } else {
        failureCount++;
      }
    }

    debugPrint('📊 Fetched cycles from $successCount/${batches.length} batches ($failureCount failures)');
    return allCycles;
  }
}