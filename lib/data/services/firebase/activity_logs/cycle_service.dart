// lib/data/services/firebase/activity_logs/cycle_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../models/cycle_recommendation.dart';
import 'batch_service.dart';

/// Service for cycle and recommendation operations
class CycleService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ===== FETCH OPERATIONS =====

  /// Fetch all cycles and recommendations for a user (includes team-wide)
  static Future<List<CycleRecommendation>> fetchCyclesRecom(
    String userId,
  ) async {
    try {
      userId = BatchService.resolveUserId(userId);

      // Get user's teamId to fetch team-wide activities
      final teamId = await BatchService.getUserTeamId(userId);

      List<CycleRecommendation> allCycles = [];

      if (teamId != null && teamId.isNotEmpty) {
        // Fetch team-wide cycles
        debugPrint('🔍 Fetching team-wide cycles for teamId: $teamId');

        // Get all machines for this team
        final teamMachineIds = await BatchService.getTeamMachineIds(teamId);

        if (teamMachineIds.isNotEmpty) {
          // Get all batches for these machines
          final batches = await BatchService.getBatchesForMachines(
            teamMachineIds,
          );

          // Fetch cycles from each batch's cyclesRecom subcollection
          for (var batchDoc in batches) {
            try {
              final cyclesSnapshot = await _firestore
                  .collection('batches')
                  .doc(batchDoc.id)
                  .collection('cyclesRecom')
                  .get();

              final cycles = cyclesSnapshot.docs
                  .map((doc) => CycleRecommendation.fromFirestore(doc))
                  .toList();

              allCycles.addAll(cycles);
            } catch (e) {
              debugPrint('Error fetching cycles from batch ${batchDoc.id}: $e');
            }
          }
        }
      } else {
        // Fallback: Get only current user's batches
        final batches = await BatchService.getBatchesForUser(userId);

        for (var batchDoc in batches) {
          try {
            final cyclesSnapshot = await _firestore
                .collection('batches')
                .doc(batchDoc.id)
                .collection('cyclesRecom')
                .get();

            final cycles = cyclesSnapshot.docs
                .map((doc) => CycleRecommendation.fromFirestore(doc))
                .toList();

            allCycles.addAll(cycles);
          } catch (e) {
            debugPrint('Error fetching cycles from batch ${batchDoc.id}: $e');
          }
        }
      }

      // Sort by timestamp descending
      allCycles.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      debugPrint(
        '✅ Fetched ${allCycles.length} cycles for ${teamId != null ? "team: $teamId" : "user: $userId"}',
      );

      return allCycles;
    } catch (e) {
      debugPrint('Error fetching cycles: $e');
      rethrow;
    }
  }
}