// lib/data/services/firebase/activity_logs/substrate_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../models/substrate.dart';
import 'firestore_collections.dart';
import 'batch_service.dart';

/// Service for substrate/waste product operations
class SubstrateService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ===== FETCH OPERATIONS =====

  /// Fetch all substrates for a user (includes team-wide if user has teamId)
  static Future<List<Substrate>> fetchSubstrates(String userId) async {
    try {
      userId = BatchService.resolveUserId(userId);

      // Get user's teamId to fetch team-wide activities
      final teamId = await BatchService.getUserTeamId(userId);

      List<Substrate> allSubstrates = [];

      if (teamId != null && teamId.isNotEmpty) {
        // Fetch team-wide substrates
        debugPrint('🔍 Fetching team-wide substrates for teamId: $teamId');

        // Get all machines for this team
        final teamMachineIds = await BatchService.getTeamMachineIds(teamId);

        if (teamMachineIds.isNotEmpty) {
          // Get all batches for these machines
          final batches = await BatchService.getBatchesForMachines(
            teamMachineIds,
          );

          // Fetch substrates from each batch
          for (var batchDoc in batches) {
            final batchData = batchDoc.data() as Map<String, dynamic>?;
            final batchUserId = batchData?['userId'] as String?;

            if (batchUserId != null) {
              try {
                final substratesSnapshot =
                    await FirestoreCollections.getSubstratesCollection(
                      batchDoc.id,
                      batchUserId,
                    ).get();

                final substrates = substratesSnapshot.docs
                    .map((doc) => Substrate.fromFirestore(doc))
                    .toList();

                allSubstrates.addAll(substrates);
              } catch (e) {
                debugPrint(
                  'Error fetching substrates from batch ${batchDoc.id}: $e',
                );
              }
            }
          }
        }
      } else {
        // Fallback: Get only current user's batches
        final batches = await BatchService.getBatchesForUser(userId);

        for (var batchDoc in batches) {
          try {
            final substratesSnapshot =
                await FirestoreCollections.getSubstratesCollection(
                  batchDoc.id,
                  userId,
                ).get();

            final substrates = substratesSnapshot.docs
                .map((doc) => Substrate.fromFirestore(doc))
                .toList();

            allSubstrates.addAll(substrates);
          } catch (e) {
            debugPrint(
              'Error fetching substrates from batch ${batchDoc.id}: $e',
            );
          }
        }
      }

      // Sort by timestamp descending
      allSubstrates.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      debugPrint(
        '✅ Fetched ${allSubstrates.length} substrates for ${teamId != null ? "team: $teamId" : "user: $userId"}',
      );

      return allSubstrates;
    } catch (e) {
      debugPrint('Error fetching substrates: $e');
      rethrow;
    }
  }

  // ===== CREATE OPERATIONS =====

  /// Add a new substrate/waste product
  static Future<void> addSubstrate(Map<String, dynamic> wasteEntry) async {
    try {
      final userId = BatchService.resolveUserId(wasteEntry['userId']);
      final machineId = wasteEntry['machineId'];

      if (machineId == null || machineId.toString().isEmpty) {
        throw Exception('Machine ID is required');
      }

      // Get or create batch for this machine
      final batchId = await BatchService.getOrCreateBatch(userId, machineId);

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

      // Fetch operator name
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

      // Get icon and color based on category
      final category = wasteEntry['category'];
      final iconAndColor = _getWasteIconAndColor(category);

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
        'batchId': batchId,
      };

      await docRef.set(data);

      // Update batch timestamp
      await BatchService.updateBatchTimestamp(batchId);

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

  // ===== HELPERS =====

  /// Get icon and color based on waste category
  static Map<String, dynamic> _getWasteIconAndColor(String category) {
    final lowerCategory = category.toLowerCase();

    int iconCodePoint;
    String statusColor;

    if (lowerCategory == 'greens') {
      iconCodePoint = 0xe3b6; // Icons.eco
      statusColor = 'green';
    } else if (lowerCategory == 'browns') {
      iconCodePoint = 0xe3b7; // Icons.nature
      statusColor = 'brown';
    } else {
      // Default for compost or other categories
      iconCodePoint = 0xe8e0; // Icons.recycling
      statusColor = 'yellow';
    }

    return {'iconCodePoint': iconCodePoint, 'statusColor': statusColor};
  }
}