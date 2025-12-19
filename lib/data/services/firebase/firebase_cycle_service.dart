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

  // ===== PRIVATE HELPER: GET EXISTING MAIN CYCLE DOCUMENT =====
  
  /// Gets existing cycle document ID WITHOUT creating one
  /// Returns null if no cycle document exists
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

  /// Creates a new main cycle document
  /// Should only be called when starting a controller
  Future<String> _createMainCycleDocId(String batchId) async {
    final cycleRef = await _firestore
        .collection('batches')
        .doc(batchId)
        .collection('cyclesRecom')
        .add({
      'category': 'cycles',
      'createdAt': Timestamp.now(),
    });

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

        final cycles = <CycleRecommendation>[];

        for (var cycleDoc in cyclesSnapshot.docs) {
          // Get drum_controller
          final drumSnapshot = await _firestore
              .collection('batches')
              .doc(batchDoc.id)
              .collection('cyclesRecom')
              .doc(cycleDoc.id)
              .collection('drum_controller')
              .limit(1)
              .get();

          if (drumSnapshot.docs.isNotEmpty) {
            cycles.add(CycleRecommendation.fromFirestore(drumSnapshot.docs.first));
          }

          // Get aerator
          final aeratorSnapshot = await _firestore
              .collection('batches')
              .doc(batchDoc.id)
              .collection('cyclesRecom')
              .doc(cycleDoc.id)
              .collection('aerator')
              .limit(1)
              .get();

          if (aeratorSnapshot.docs.isNotEmpty) {
            cycles.add(CycleRecommendation.fromFirestore(aeratorSnapshot.docs.first));
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
      // DON'T create - only check if exists
      final cycleDocId = await _getExistingMainCycleDocId(batchId);
      
      // If no cycle doc exists, return null
      if (cycleDocId == null) {
        debugPrint('ℹ️ No cycle document found for batch $batchId');
        return null;
      }

      // Get drum controller
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
  Future<CycleRecommendation?> getAerator({
    required String batchId,
  }) async {
    try {
      // DON'T create - only check if exists
      final cycleDocId = await _getExistingMainCycleDocId(batchId);
      
      // If no cycle doc exists, return null
      if (cycleDocId == null) {
        debugPrint('ℹ️ No cycle document found for batch $batchId');
        return null;
      }

      // Get aerator
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
  required int cycles,
  required String duration,
}) async {
  try {
    // Get existing OR create new main cycle document
    String cycleDocId = await _getExistingMainCycleDocId(batchId) ?? 
                        await _createMainCycleDocId(batchId);

    // Check if drum_controller already exists
    final existingDrumSnapshot = await _firestore
        .collection('batches')
        .doc(batchId)
        .collection('cyclesRecom')
        .doc(cycleDocId)
        .collection('drum_controller')
        .limit(1)
        .get();

    // If drum controller already exists, delete it first
    if (existingDrumSnapshot.docs.isNotEmpty) {
      await existingDrumSnapshot.docs.first.reference.delete();
      debugPrint('🗑️ Deleted existing drum controller');
    }

    // Create drum controller data (CLEANED - no redundant fields)
    final drumData = CycleRecommendation(
      id: '',
      category: 'cycles',
      controllerType: 'drum_controller',
      machineId: machineId,
      userId: userId,
      batchId: batchId,
      cycles: cycles,
      duration: duration,
      completedCycles: 0,
      status: 'running',
      startedAt: DateTime.now(),
      totalRuntimeSeconds: 0,
    );

    // Create drum controller subcollection document
    final drumRef = await _firestore
        .collection('batches')
        .doc(batchId)
        .collection('cyclesRecom')
        .doc(cycleDocId)
        .collection('drum_controller')
        .add(drumData.toFirestore());

    debugPrint('✅ Started drum controller: ${drumRef.id}');
    return drumRef.id;
  } catch (e) {
    debugPrint('❌ Error starting drum controller: $e');
    throw Exception('Failed to start drum controller: $e');
  }
}

  // ===== UPDATE DRUM PROGRESS =====

@override
Future<void> updateDrumProgress({
  required String batchId,
  required int completedCycles,
  required Duration totalRuntime,
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

    await drumSnapshot.docs.first.reference.update({
      'completedCycles': completedCycles,
      'totalRuntimeSeconds': totalRuntime.inSeconds,
      // No timestamp field - we use startedAt
    });

    debugPrint('✅ Updated drum progress: $completedCycles cycles');
  } catch (e) {
    debugPrint('❌ Error updating drum progress: $e');
    throw Exception('Failed to update drum progress: $e');
  }
}

  // ===== COMPLETE DRUM CONTROLLER =====

@override
Future<void> completeDrumController({
  required String batchId,
}) async {
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

    await drumSnapshot.docs.first.reference.update({
      'status': 'completed',
      'completedAt': Timestamp.now(),
      // No timestamp field
    });

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
  required int cycles,
  required String duration,
}) async {
  try {
    // Get existing OR create new main cycle document
    String cycleDocId = await _getExistingMainCycleDocId(batchId) ?? 
                        await _createMainCycleDocId(batchId);

    // Check if aerator already exists
    final existingAeratorSnapshot = await _firestore
        .collection('batches')
        .doc(batchId)
        .collection('cyclesRecom')
        .doc(cycleDocId)
        .collection('aerator')
        .limit(1)
        .get();

    // If aerator already exists, delete it first
    if (existingAeratorSnapshot.docs.isNotEmpty) {
      await existingAeratorSnapshot.docs.first.reference.delete();
      debugPrint('🗑️ Deleted existing aerator');
    }

    // Create aerator data (CLEANED - no redundant fields)
    final aeratorData = CycleRecommendation(
      id: '',
      category: 'cycles',
      controllerType: 'aerator',
      machineId: machineId,
      userId: userId,
      batchId: batchId,
      cycles: cycles,
      duration: duration,
      completedCycles: 0,
      status: 'running',
      startedAt: DateTime.now(),
      totalRuntimeSeconds: 0,
    );

    // Create aerator subcollection document
    final aeratorRef = await _firestore
        .collection('batches')
        .doc(batchId)
        .collection('cyclesRecom')
        .doc(cycleDocId)
        .collection('aerator')
        .add(aeratorData.toFirestore());

    debugPrint('✅ Started aerator: ${aeratorRef.id}');
    return aeratorRef.id;
  } catch (e) {
    debugPrint('❌ Error starting aerator: $e');
    throw Exception('Failed to start aerator: $e');
  }
}


  // ===== UPDATE AERATOR PROGRESS =====

@override
Future<void> updateAeratorProgress({
  required String batchId,
  required int completedCycles,
  required Duration totalRuntime,
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

    await aeratorSnapshot.docs.first.reference.update({
      'completedCycles': completedCycles,
      'totalRuntimeSeconds': totalRuntime.inSeconds,
      // No timestamp field
    });

    debugPrint('✅ Updated aerator progress: $completedCycles cycles');
  } catch (e) {
    debugPrint('❌ Error updating aerator progress: $e');
    throw Exception('Failed to update aerator progress: $e');
  }
}
  // ===== COMPLETE AERATOR =====

@override
Future<void> completeAerator({
  required String batchId,
}) async {
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

    await aeratorSnapshot.docs.first.reference.update({
      'status': 'completed',
      'completedAt': Timestamp.now(),
      // No timestamp field
    });

    debugPrint('✅ Completed aerator');
  } catch (e) {
    debugPrint('❌ Error completing aerator: $e');
    throw Exception('Failed to complete aerator: $e');
  }
}
}