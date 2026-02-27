// lib/data/services/firebase/firebase_substrate_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../contracts/substrate_service.dart';
import '../contracts/batch_service.dart';
import '../../models/substrate.dart';
import '../../models/substrate_preset.dart';

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
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
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
        debugPrint(
          '⚠️ Error fetching substrates from batch ${batchDoc.id}: $e',
        );
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

    debugPrint(
      '📊 Fetched substrates from $successCount/${batches.length} batches ($failureCount failures)',
    );
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
      String batchId =
          await _batchService.getBatchId(currentUserId!, machineId) ??
          await _batchService.createBatch(currentUserId!, machineId, 1);

      // Get teamId
      final teamId = await _batchService.getUserTeamId(currentUserId!);

      // Create document
      final Timestamp timestamp =
          data['timestamp'] as Timestamp? ?? Timestamp.now();
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
        'timestamp': timestamp,
      });

      // Update batch timestamp
      await _batchService.updateBatchTimestamp(batchId);

      debugPrint('✅ Added substrate to batch: $batchId');
    } catch (e) {
      debugPrint('❌ Error adding substrate: $e');
      throw Exception('Failed to add substrate: $e');
    }
  }

  // Get a single substrate by ID
  @override
  Future<Substrate?> fetchSubstrateById(String substrateId) async {
    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }

    try {
      // Get user's teamId
      final teamId = await _batchService.getUserTeamId(currentUserId!);

      if (teamId == null || teamId.isEmpty) {
        debugPrint('⚠️ User has no team assigned');
        return null;
      }

      // Get all machines belonging to this team
      final teamMachineIds = await _batchService.getTeamMachineIds(teamId);

      if (teamMachineIds.isEmpty) {
        debugPrint('ℹ️ No machines found for team: $teamId');
        return null;
      }

      // Get all batches for those machines
      final batches = await _batchService.getBatchesForMachines(teamMachineIds);

      if (batches.isEmpty) {
        debugPrint('ℹ️ No batches found for team machines');
        return null;
      }

      // Search each batch for the substrate
      for (var batchDoc in batches) {
        try {
          final substrateDoc = await _firestore
              .collection('batches')
              .doc(batchDoc.id)
              .collection('substrates')
              .doc(substrateId)
              .get();

          if (substrateDoc.exists) {
            debugPrint(
              '✅ Found substrate: $substrateId in batch: ${batchDoc.id}',
            );
            return Substrate.fromFirestore(substrateDoc);
          }
        } catch (e) {
          debugPrint('⚠️ Error checking batch ${batchDoc.id}: $e');
          continue;
        }
      }

      debugPrint('ℹ️ Substrate not found: $substrateId');
      return null;
    } catch (e) {
      debugPrint('❌ Error fetching substrate by ID: $e');
      throw Exception('Failed to fetch substrate: $e');
    }
  }

  @override
  Stream<List<Substrate>> streamSubstratesForBatch(String batchId) {
    return _firestore
        .collection('batches')
        .doc(batchId)
        .collection('substrates')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Substrate.fromFirestore(doc)).toList();
    });
  }

  // ===== PRESET OPERATIONS =====

  @override
  Stream<List<SubstratePreset>> streamTeamPresets() {
    if (currentUserId == null) return Stream.value([]);
    
    return Stream.fromFuture(_batchService.getUserTeamId(currentUserId!)).asyncExpand((teamId) {
      if (teamId == null || teamId.isEmpty) return Stream.value([]);
      return _firestore
          .collection('teams')
          .doc(teamId)
          .collection('substrate_presets')
          .snapshots()
          .map((snapshot) {
            final presets = snapshot.docs.map((doc) => SubstratePreset.fromJson(doc.data(), doc.id)).toList();
            
            // Default "Usual Mix" is required on first load for a team.
            if (presets.isEmpty) {
              _createDefaultPreset(teamId);
              // It will re-trigger the stream once created.
            }
            return presets;
          });
    });
  }

  Future<void> _createDefaultPreset(String teamId) async {
    try {
      final defaultPreset = SubstratePreset(
        id: 'default_usual_mix',
        name: 'Usual Mix',
        icon: 'usual_mix',
        materials: [
          const SubstrateMaterial(label: 'Vegetable Scraps', isNitrogenRich: true),
          const SubstrateMaterial(label: 'Fruit Scraps', isNitrogenRich: true),
          const SubstrateMaterial(label: 'Chicken Manure', isNitrogenRich: true),
          const SubstrateMaterial(label: 'Sawdust', isNitrogenRich: false),
          const SubstrateMaterial(label: 'Cardboard', isNitrogenRich: false),
          const SubstrateMaterial(label: 'Dry Grass', isNitrogenRich: false),
        ],
        teamId: teamId,
        createdBy: 'system',
        createdAt: DateTime.now(),
        isDefault: true,
      );
      
      await _firestore
          .collection('teams')
          .doc(teamId)
          .collection('substrate_presets')
          .doc('default_usual_mix')
          .set(defaultPreset.toJson());
      debugPrint('✅ Created default preset for team $teamId');
    } catch (e) {
      debugPrint('❌ Error creating default preset: $e');
    }
  }

  @override
  Future<void> savePreset(SubstratePreset preset) async {
    if (currentUserId == null) throw Exception('User not authenticated');
    final teamId = preset.teamId ?? await _batchService.getUserTeamId(currentUserId!);
    if (teamId == null || teamId.isEmpty) throw Exception('User has no team assigned');

    final docRef = _firestore.collection('teams').doc(teamId).collection('substrate_presets').doc(preset.id);
    
    final presetToSave = preset.copyWith(
      teamId: teamId,
      createdBy: preset.createdBy ?? currentUserId,
    );

    await docRef.set(presetToSave.toJson(), SetOptions(merge: true));
  }

  @override
  Future<void> deletePreset(String presetId) async {
    if (currentUserId == null) throw Exception('User not authenticated');
    final teamId = await _batchService.getUserTeamId(currentUserId!);
    if (teamId == null || teamId.isEmpty) throw Exception('User has no team assigned');

    await _firestore
        .collection('teams')
        .doc(teamId)
        .collection('substrate_presets')
        .doc(presetId)
        .delete();
  }

  // ===== CUSTOM MATERIALS OPERATIONS =====

  @override
  Stream<List<SubstrateMaterial>> streamTeamCustomMaterials() {
    if (currentUserId == null) return Stream.value([]);

    return Stream.fromFuture(_batchService.getUserTeamId(currentUserId!)).asyncExpand((teamId) {
      if (teamId == null || teamId.isEmpty) return Stream.value([]);
      return _firestore
          .collection('teams')
          .doc(teamId)
          .collection('custom_materials')
          .snapshots()
          .map((snapshot) {
            return snapshot.docs.map((doc) => SubstrateMaterial.fromJson(doc.data())).toList();
          });
    });
  }

  @override
  Future<void> saveCustomMaterial(SubstrateMaterial material) async {
    if (currentUserId == null) throw Exception('User not authenticated');
    final teamId = await _batchService.getUserTeamId(currentUserId!);
    if (teamId == null || teamId.isEmpty) throw Exception('User has no team assigned');

    // Use the label (lowercase/no-spaces) as ID to avoid duplicates
    final docId = material.label.toLowerCase().replaceAll(' ', '_');

    await _firestore
        .collection('teams')
        .doc(teamId)
        .collection('custom_materials')
        .doc(docId)
        .set(material.toJson(), SetOptions(merge: true));
  }

  // ===== CUSTOM ADDITIVES OPERATIONS =====

  @override
  Stream<List<String>> streamTeamCustomAdditives() {
    if (currentUserId == null) return Stream.value([]);

    return Stream.fromFuture(_batchService.getUserTeamId(currentUserId!)).asyncExpand((teamId) {
      if (teamId == null || teamId.isEmpty) return Stream.value([]);
      return _firestore
          .collection('teams')
          .doc(teamId)
          .collection('custom_additives')
          .snapshots()
          .map((snapshot) {
            return snapshot.docs.map((doc) => doc.data()['label'] as String).toList();
          });
    });
  }

  @override
  Future<void> saveCustomAdditive(String additive) async {
    if (currentUserId == null) throw Exception('User not authenticated');
    final teamId = await _batchService.getUserTeamId(currentUserId!);
    if (teamId == null || teamId.isEmpty) throw Exception('User has no team assigned');

    // Use the label (lowercase/no-spaces) as ID to avoid duplicates
    final docId = additive.toLowerCase().replaceAll(' ', '_');

    await _firestore
        .collection('teams')
        .doc(teamId)
        .collection('custom_additives')
        .doc(docId)
        .set({'label': additive}, SetOptions(merge: true));
  }
}
