import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../contracts/cycle_service.dart';
import '../contracts/batch_service.dart';
import '../../models/cycle_recommendation.dart';

class FirestoreCycleService implements CycleService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final BatchService _batchService;

  FirestoreCycleService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    required BatchService batchService,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance,
       _batchService = batchService;

  String? get currentUserId => _auth.currentUser?.uid;

  // ===== PRIVATE HELPER: GET EXISTING MAIN CYCLE DOCUMENT =====

  Future<String?> _getExistingMainCycleDocId(String batchId) async {
    final cyclesSnapshot = await _firestore
        .collection('batches')
        .doc(batchId)
        .collection('cyclesRecom')
        .limit(1)
        .get();

    if (cyclesSnapshot.docs.isNotEmpty) {
      return cyclesSnapshot.docs.first.id;
    }

    return null;
  }

  Future<String> _createMainCycleDocId(String batchId) async {
    final cycleRef = await _firestore
        .collection('batches')
        .doc(batchId)
        .collection('cyclesRecom')
        .add({'category': 'cycles', 'createdAt': Timestamp.now()});

    debugPrint('✅ Created main cycle document: ${cycleRef.id}');
    return cycleRef.id;
  }

  // ===== FETCH TEAM CYCLES =====

  @override
  Future<List<CycleRecommendation>> fetchTeamCycles() async {
    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }

    try {
      final teamId = await _batchService.getUserTeamId(currentUserId!);

      if (teamId == null || teamId.isEmpty) {
        debugPrint('⚠️ User has no team assigned');
        return [];
      }

      final allCycles = await _fetchTeamCycles(teamId);
      allCycles.sort(
        (a, b) => (b.timestamp ?? DateTime.now()).compareTo(
          a.timestamp ?? DateTime.now(),
        ),
      );

      debugPrint('✅ Fetched ${allCycles.length} cycles');
      return allCycles;
    } catch (e) {
      debugPrint('❌ Error fetching cycles: $e');
      throw Exception('Failed to fetch cycles: $e');
    }
  }

  Future<List<CycleRecommendation>> _fetchTeamCycles(String teamId) async {
    final List<CycleRecommendation> allCycles = [];

    final teamMachineIds = await _batchService.getTeamMachineIds(teamId);

    if (teamMachineIds.isEmpty) {
      debugPrint('ℹ️ No machines found for team: $teamId');
      return [];
    }

    final batches = await _batchService.getBatchesForMachines(teamMachineIds);

    if (batches.isEmpty) {
      debugPrint('ℹ️ No batches found for team machines');
      return [];
    }

    final futures = batches.map((batchDoc) async {
      try {
        final cyclesSnapshot = await _firestore
            .collection('batches')
            .doc(batchDoc.id)
            .collection('cyclesRecom')
            .get();

        final cycles = <CycleRecommendation>[];

        for (var cycleDoc in cyclesSnapshot.docs) {
          final drumSnapshot = await _firestore
              .collection('batches')
              .doc(batchDoc.id)
              .collection('cyclesRecom')
              .doc(cycleDoc.id)
              .collection('drum_controller')
              .limit(1)
              .get();

          if (drumSnapshot.docs.isNotEmpty) {
            cycles.add(
              CycleRecommendation.fromFirestore(drumSnapshot.docs.first),
            );
          }

          final aeratorSnapshot = await _firestore
              .collection('batches')
              .doc(batchDoc.id)
              .collection('cyclesRecom')
              .doc(cycleDoc.id)
              .collection('aerator')
              .limit(1)
              .get();

          if (aeratorSnapshot.docs.isNotEmpty) {
            cycles.add(
              CycleRecommendation.fromFirestore(aeratorSnapshot.docs.first),
            );
          }
        }

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
      }
    }

    return allCycles;
  }

  // ===== GET DRUM CONTROLLER =====

  @override
  Future<CycleRecommendation?> getDrumController({
    required String batchId,
  }) async {
    try {
      final cycleDocId = await _getExistingMainCycleDocId(batchId);

      if (cycleDocId == null) {
        debugPrint('ℹ️ No cycle document found for batch $batchId');
        return null;
      }

      final drumSnapshot = await _firestore
          .collection('batches')
          .doc(batchId)
          .collection('cyclesRecom')
          .doc(cycleDocId)
          .collection('drum_controller')
          .limit(1)
          .get();

      if (drumSnapshot.docs.isEmpty) return null;

      return CycleRecommendation.fromFirestore(drumSnapshot.docs.first);
    } catch (e) {
      debugPrint('❌ Error getting drum controller: $e');
      return null;
    }
  }

  // ===== GET AERATOR =====

  @override
  Future<CycleRecommendation?> getAerator({required String batchId}) async {
    try {
      final cycleDocId = await _getExistingMainCycleDocId(batchId);

      if (cycleDocId == null) {
        debugPrint('ℹ️ No cycle document found for batch $batchId');
        return null;
      }

      final aeratorSnapshot = await _firestore
          .collection('batches')
          .doc(batchId)
          .collection('cyclesRecom')
          .doc(cycleDocId)
          .collection('aerator')
          .limit(1)
          .get();

      if (aeratorSnapshot.docs.isEmpty) return null;

      return CycleRecommendation.fromFirestore(aeratorSnapshot.docs.first);
    } catch (e) {
      debugPrint('❌ Error getting aerator: $e');
      return null;
    }
  }

  // ===== START DRUM CONTROLLER =====

  @override
  Future<String> startDrumController({
    required String batchId,
    required String machineId,
    required String userId,
    required int activeMinutes,
    required int restMinutes,
  }) async {
    try {
      String cycleDocId =
          await _getExistingMainCycleDocId(batchId) ??
          await _createMainCycleDocId(batchId);

      final drumRef = await _firestore
          .collection('batches')
          .doc(batchId)
          .collection('cyclesRecom')
          .doc(cycleDocId)
          .collection('drum_controller')
          .add({
            'category': 'cycles',
            'controllerType': 'drum_controller',
            'machineId': machineId,
            'userId': userId,
            'batchId': batchId,
            'activeMinutes': activeMinutes,
            'restMinutes': restMinutes,
            'currentPhase': 'active', // Start in active phase
            'phaseStartTime': FieldValue.serverTimestamp(), // Critical for countdown sync
            'status': 'running',
            'startedAt': FieldValue.serverTimestamp(),
            'timestamp': FieldValue.serverTimestamp(),
            'totalRuntimeSeconds': 0,
          });

      await _firestore.collection('machines').doc(machineId).update({
        'drumActive': true,
        'drumStartedAt': FieldValue.serverTimestamp(),
        'drumActiveMinutes': activeMinutes,
        'drumRestMinutes': restMinutes,
      });

      debugPrint('✅ Started drum controller: ${drumRef.id} (${activeMinutes}min/${restMinutes}min)');
      return drumRef.id;
    } catch (e) {
      debugPrint('❌ Error starting drum controller: $e');
      rethrow;
    }
  }

  @override
  Future<void> completeDrumController({required String batchId}) async {
    try {
      final cycleDocId = await _getExistingMainCycleDocId(batchId);
      if (cycleDocId == null) {
        debugPrint('⚠️ No cycle document to complete');
        return;
      }

      final drumSnapshot = await _firestore
          .collection('batches')
          .doc(batchId)
          .collection('cyclesRecom')
          .doc(cycleDocId)
          .collection('drum_controller')
          .limit(1)
          .get();

      if (drumSnapshot.docs.isEmpty) return;

      final drumData = drumSnapshot.docs.first.data();
      final machineId = drumData['machineId'] as String?;

      await drumSnapshot.docs.first.reference.update({
        'status': 'completed',
        'completedAt': Timestamp.now(),
      });

      if (machineId != null) {
        await _firestore.collection('machines').doc(machineId).update({
          'drumActive': false,
          'drumStartedAt': null,
          'drumActiveMinutes': null,
          'drumRestMinutes': null,
        });
      }

      debugPrint('✅ Completed drum controller');
    } catch (e) {
      debugPrint('❌ Error completing drum controller: $e');
      throw Exception('Failed to complete drum controller: $e');
    }
  }

  // ===== START AERATOR =====

  @override
  Future<String> startAerator({
    required String batchId,
    required String machineId,
    required String userId,
    required int activeMinutes,
    required int restMinutes,
  }) async {
    try {
      String cycleDocId =
          await _getExistingMainCycleDocId(batchId) ??
          await _createMainCycleDocId(batchId);

      final aeratorRef = await _firestore
          .collection('batches')
          .doc(batchId)
          .collection('cyclesRecom')
          .doc(cycleDocId)
          .collection('aerator')
          .add({
            'category': 'cycles',
            'controllerType': 'aerator',
            'machineId': machineId,
            'userId': userId,
            'batchId': batchId,
            'activeMinutes': activeMinutes,
            'restMinutes': restMinutes,
            'currentPhase': 'active', // Start in active phase
            'phaseStartTime': FieldValue.serverTimestamp(), // Critical for countdown sync
            'status': 'running',
            'startedAt': FieldValue.serverTimestamp(),
            'timestamp': FieldValue.serverTimestamp(),
            'totalRuntimeSeconds': 0,
          });

      await _firestore.collection('machines').doc(machineId).update({
        'aeratorActive': true,
        'aeratorStartedAt': FieldValue.serverTimestamp(),
        'aeratorActiveMinutes': activeMinutes,
        'aeratorRestMinutes': restMinutes,
      });

      debugPrint('✅ Started aerator: ${aeratorRef.id} (${activeMinutes}min/${restMinutes}min)');
      return aeratorRef.id;
    } catch (e) {
      debugPrint('❌ Error starting aerator: $e');
      rethrow;
    }
  }

  @override
  Future<void> completeAerator({required String batchId}) async {
    try {
      final cycleDocId = await _getExistingMainCycleDocId(batchId);
      if (cycleDocId == null) {
        debugPrint('⚠️ No cycle document to complete');
        return;
      }

      final aeratorSnapshot = await _firestore
          .collection('batches')
          .doc(batchId)
          .collection('cyclesRecom')
          .doc(cycleDocId)
          .collection('aerator')
          .limit(1)
          .get();

      if (aeratorSnapshot.docs.isEmpty) return;

      final aeratorData = aeratorSnapshot.docs.first.data();
      final machineId = aeratorData['machineId'] as String?;

      await aeratorSnapshot.docs.first.reference.update({
        'status': 'completed',
        'completedAt': Timestamp.now(),
      });

      if (machineId != null) {
        await _firestore.collection('machines').doc(machineId).update({
          'aeratorActive': false,
          'aeratorStartedAt': null,
          'aeratorActiveMinutes': null,
          'aeratorRestMinutes': null,
        });
      }

      debugPrint('✅ Completed aerator');
    } catch (e) {
      debugPrint('❌ Error completing aerator: $e');
      throw Exception('Failed to complete aerator: $e');
    }
  }

  // ===== UPDATE PHASE (for countdown synchronization) =====

  Future<void> updateDrumPhase({
    required String batchId,
    required String newPhase, // 'active' or 'resting'
  }) async {
    try {
      final cycleDocId = await _getExistingMainCycleDocId(batchId);
      if (cycleDocId == null) {
        debugPrint('⚠️ No cycle document to update');
        return;
      }

      final drumSnapshot = await _firestore
          .collection('batches')
          .doc(batchId)
          .collection('cyclesRecom')
          .doc(cycleDocId)
          .collection('drum_controller')
          .limit(1)
          .get();

      if (drumSnapshot.docs.isEmpty) return;

      final drumData = drumSnapshot.docs.first.data();
      final machineId = drumData['machineId'] as String?;

      // Update cycle document
      await drumSnapshot.docs.first.reference.update({
        'currentPhase': newPhase,
        'phaseStartTime': FieldValue.serverTimestamp(), // Reset countdown
      });

      // Update machine document to control hardware
      if (machineId != null) {
        await _firestore.collection('machines').doc(machineId).update({
          'drumActive': newPhase == 'active', // TRUE for active, FALSE for resting
        });
      }

      debugPrint('✅ Updated drum phase to: $newPhase (drumActive: ${newPhase == 'active'})');
    } catch (e) {
      debugPrint('❌ Error updating drum phase: $e');
      throw Exception('Failed to update drum phase: $e');
    }
  }

  Future<void> updateAeratorPhase({
    required String batchId,
    required String newPhase, // 'active' or 'resting'
  }) async {
    try {
      final cycleDocId = await _getExistingMainCycleDocId(batchId);
      if (cycleDocId == null) {
        debugPrint('⚠️ No cycle document to update');
        return;
      }

      final aeratorSnapshot = await _firestore
          .collection('batches')
          .doc(batchId)
          .collection('cyclesRecom')
          .doc(cycleDocId)
          .collection('aerator')
          .limit(1)
          .get();

      if (aeratorSnapshot.docs.isEmpty) return;

      final aeratorData = aeratorSnapshot.docs.first.data();
      final machineId = aeratorData['machineId'] as String?;

      // Update cycle document
      await aeratorSnapshot.docs.first.reference.update({
        'currentPhase': newPhase,
        'phaseStartTime': FieldValue.serverTimestamp(), // Reset countdown
      });

      // Update machine document to control hardware
      if (machineId != null) {
        await _firestore.collection('machines').doc(machineId).update({
          'aeratorActive': newPhase == 'active', // TRUE for active, FALSE for resting
        });
      }

      debugPrint('✅ Updated aerator phase to: $newPhase (aeratorActive: ${newPhase == 'active'})');
    } catch (e) {
      debugPrint('❌ Error updating aerator phase: $e');
      throw Exception('Failed to update aerator phase: $e');
    }
  }

  // ===== FETCH CYCLE BY ID =====

  @override
  Future<CycleRecommendation?> fetchCycleById(String cycleId) async {
    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }

    try {
      final teamId = await _batchService.getUserTeamId(currentUserId!);

      if (teamId == null || teamId.isEmpty) {
        debugPrint('⚠️ User has no team assigned');
        return null;
      }

      final teamMachineIds = await _batchService.getTeamMachineIds(teamId);

      if (teamMachineIds.isEmpty) {
        debugPrint('ℹ️ No machines found for team: $teamId');
        return null;
      }

      final batches = await _batchService.getBatchesForMachines(teamMachineIds);

      if (batches.isEmpty) {
        debugPrint('ℹ️ No batches found for team machines');
        return null;
      }

      for (var batchDoc in batches) {
        try {
          final cyclesSnapshot = await _firestore
              .collection('batches')
              .doc(batchDoc.id)
              .collection('cyclesRecom')
              .get();

          for (var cycleDoc in cyclesSnapshot.docs) {
            final drumDoc = await _firestore
                .collection('batches')
                .doc(batchDoc.id)
                .collection('cyclesRecom')
                .doc(cycleDoc.id)
                .collection('drum_controller')
                .doc(cycleId)
                .get();

            if (drumDoc.exists) {
              debugPrint('✅ Found drum controller: $cycleId');
              return CycleRecommendation.fromFirestore(drumDoc);
            }

            final aeratorDoc = await _firestore
                .collection('batches')
                .doc(batchDoc.id)
                .collection('cyclesRecom')
                .doc(cycleDoc.id)
                .collection('aerator')
                .doc(cycleId)
                .get();

            if (aeratorDoc.exists) {
              debugPrint('✅ Found aerator: $cycleId');
              return CycleRecommendation.fromFirestore(aeratorDoc);
            }
          }
        } catch (e) {
          debugPrint('⚠️ Error checking batch ${batchDoc.id}: $e');
          continue;
        }
      }

      debugPrint('ℹ️ Cycle not found: $cycleId');
      return null;
    } catch (e) {
      debugPrint('❌ Error fetching cycle by ID: $e');
      throw Exception('Failed to fetch cycle: $e');
    }
  }
}