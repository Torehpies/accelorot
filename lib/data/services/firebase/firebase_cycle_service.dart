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
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _batchService = batchService;

  String? get currentUserId => _auth.currentUser?.uid;

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
      allCycles.sort((a, b) => b.timestamp.compareTo(a.timestamp));

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
      }
    }

    return allCycles;
  }

  @override
  Future<CycleRecommendation> getOrCreateCycleForBatch({
    required String batchId,
    required String machineId,
    required String userId,
  }) async {
    try {
      // Check if cycle already exists for this batch
      final existingCycles = await _firestore
          .collection('batches')
          .doc(batchId)
          .collection('cyclesRecom')
          .where('category', isEqualTo: 'cycles')
          .limit(1)
          .get();

      if (existingCycles.docs.isNotEmpty) {
        return CycleRecommendation.fromFirestore(existingCycles.docs.first);
      }

      // Create new cycle document
      final cycleData = CycleRecommendation(
        id: '',
        title: 'Cycle Controls',
        value: 'Not Started',
        category: 'cycles',
        description: 'Drum Controller and Aerator Controls',
        timestamp: DateTime.now(),
        machineId: machineId,
        userId: userId,
        batchId: batchId,
      );

      final docRef = await _firestore
          .collection('batches')
          .doc(batchId)
          .collection('cyclesRecom')
          .add(cycleData.toFirestore());

      debugPrint('✅ Created cycle document: ${docRef.id}');
      
      final doc = await docRef.get();
      return CycleRecommendation.fromFirestore(doc);
    } catch (e) {
      debugPrint('❌ Error getting/creating cycle: $e');
      throw Exception('Failed to get/create cycle: $e');
    }
  }

  @override
  Future<void> startDrumController({
    required String batchId,
    required String cycleId,
    required int cycles,
    required String duration,
  }) async {
    try {
      await _firestore
          .collection('batches')
          .doc(batchId)
          .collection('cyclesRecom')
          .doc(cycleId)
          .update({
        'drumCycles': cycles,
        'drumDuration': duration,
        'drumCompletedCycles': 0,
        'drumStatus': 'running',
        'drumStartedAt': Timestamp.now(),
        'drumTotalRuntimeSeconds': 0,
        'timestamp': Timestamp.now(),
      });

      debugPrint('✅ Started drum controller');
    } catch (e) {
      debugPrint('❌ Error starting drum controller: $e');
      throw Exception('Failed to start drum controller: $e');
    }
  }

  @override
  Future<void> updateDrumProgress({
    required String batchId,
    required String cycleId,
    required int completedCycles,
    required Duration totalRuntime,
  }) async {
    try {
      await _firestore
          .collection('batches')
          .doc(batchId)
          .collection('cyclesRecom')
          .doc(cycleId)
          .update({
        'drumCompletedCycles': completedCycles,
        'drumTotalRuntimeSeconds': totalRuntime.inSeconds,
        'timestamp': Timestamp.now(),
      });

      debugPrint('✅ Updated drum progress: $completedCycles cycles');
    } catch (e) {
      debugPrint('❌ Error updating drum progress: $e');
      throw Exception('Failed to update drum progress: $e');
    }
  }

  @override
  Future<void> completeDrumController({
    required String batchId,
    required String cycleId,
  }) async {
    try {
      await _firestore
          .collection('batches')
          .doc(batchId)
          .collection('cyclesRecom')
          .doc(cycleId)
          .update({
        'drumStatus': 'completed',
        'drumCompletedAt': Timestamp.now(),
        'timestamp': Timestamp.now(),
      });

      debugPrint('✅ Completed drum controller');
    } catch (e) {
      debugPrint('❌ Error completing drum controller: $e');
      throw Exception('Failed to complete drum controller: $e');
    }
  }

  @override
  Future<void> startAerator({
    required String batchId,
    required String cycleId,
    required int cycles,
    required String duration,
  }) async {
    try {
      await _firestore
          .collection('batches')
          .doc(batchId)
          .collection('cyclesRecom')
          .doc(cycleId)
          .update({
        'aeratorCycles': cycles,
        'aeratorDuration': duration,
        'aeratorCompletedCycles': 0,
        'aeratorStatus': 'running',
        'aeratorStartedAt': Timestamp.now(),
        'aeratorTotalRuntimeSeconds': 0,
        'timestamp': Timestamp.now(),
      });

      debugPrint('✅ Started aerator');
    } catch (e) {
      debugPrint('❌ Error starting aerator: $e');
      throw Exception('Failed to start aerator: $e');
    }
  }

  @override
  Future<void> updateAeratorProgress({
    required String batchId,
    required String cycleId,
    required int completedCycles,
    required Duration totalRuntime,
  }) async {
    try {
      await _firestore
          .collection('batches')
          .doc(batchId)
          .collection('cyclesRecom')
          .doc(cycleId)
          .update({
        'aeratorCompletedCycles': completedCycles,
        'aeratorTotalRuntimeSeconds': totalRuntime.inSeconds,
        'timestamp': Timestamp.now(),
      });

      debugPrint('✅ Updated aerator progress: $completedCycles cycles');
    } catch (e) {
      debugPrint('❌ Error updating aerator progress: $e');
      throw Exception('Failed to update aerator progress: $e');
    }
  }

  @override
  Future<void> completeAerator({
    required String batchId,
    required String cycleId,
  }) async {
    try {
      await _firestore
          .collection('batches')
          .doc(batchId)
          .collection('cyclesRecom')
          .doc(cycleId)
          .update({
        'aeratorStatus': 'completed',
        'aeratorCompletedAt': Timestamp.now(),
        'timestamp': Timestamp.now(),
      });

      debugPrint('✅ Completed aerator');
    } catch (e) {
      debugPrint('❌ Error completing aerator: $e');
      throw Exception('Failed to complete aerator: $e');
    }
  }
}