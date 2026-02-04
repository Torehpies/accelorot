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
  if (teamMachineIds.isEmpty) return [];

  final batches = await _batchService.getBatchesForMachines(teamMachineIds);
  if (batches.isEmpty) return [];

  final futures = batches.map((batchDoc) async {
    final batchId = batchDoc.id;
    
    // Get ALL drum controllers for this batch
    final drumControllers = await getDrumControllers(batchId: batchId);
    
    // Get ALL aerators for this batch
    final aerators = await getAerators(batchId: batchId);
    
    return [...drumControllers, ...aerators];
  });

  final results = await Future.wait(futures);

  for (var result in results) {
    allCycles.addAll(result);
  }

  // Sort by timestamp descending (latest first)
  allCycles.sort((a, b) => 
    (b.startedAt ?? DateTime(1970)).compareTo(a.startedAt ?? DateTime(1970))
  );

  return allCycles;
}

  // ===== GET DRUM CONTROLLER =====

  @override
Future<List<CycleRecommendation>> getDrumControllers({
  required String batchId,
}) async {
  try {
    final cycleDocId = await _getExistingMainCycleDocId(batchId);
    if (cycleDocId == null) return [];

    final drumSnapshot = await _firestore
        .collection('batches')
        .doc(batchId)
        .collection('cyclesRecom')
        .doc(cycleDocId)
        .collection('drum_controller')
        .orderBy('startedAt', descending: true) // Latest first
        .get();

    if (drumSnapshot.docs.isEmpty) return [];

    return drumSnapshot.docs
        .map((doc) => CycleRecommendation.fromFirestore(doc))
        .toList();
  } catch (e) {
    debugPrint('Error getting drum controllers: $e');
    return [];
  }
}

  // ===== GET AERATOR =====

  @override
Future<List<CycleRecommendation>> getAerators({
  required String batchId,
}) async {
  try {
    final cycleDocId = await _getExistingMainCycleDocId(batchId);
    if (cycleDocId == null) return [];

    final aeratorSnapshot = await _firestore
        .collection('batches')
        .doc(batchId)
        .collection('cyclesRecom')
        .doc(cycleDocId)
        .collection('aerator')
        .orderBy('startedAt', descending: true)
        .get();

    if (aeratorSnapshot.docs.isEmpty) return [];

    return aeratorSnapshot.docs
        .map((doc) => CycleRecommendation.fromFirestore(doc))
        .toList();
  } catch (e) {
    debugPrint('Error getting aerators: $e');
    return [];
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
            'cycles': cycles,
            'duration': duration,
            'completedCycles': 0,
            'status': 'running',
            'startedAt': FieldValue.serverTimestamp(),
            'timestamp': FieldValue.serverTimestamp(),
            'totalRuntimeSeconds': 0,
          });

      debugPrint('✅ Started drum controller: ${drumRef.id}');
      return drumRef.id;
    } catch (e) {
      debugPrint('❌ Error starting drum controller: $e');
      rethrow;
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
            'cycles': cycles,
            'duration': duration,
            'completedCycles': 0,
            'status': 'running',
            'startedAt': FieldValue.serverTimestamp(),
            'timestamp': FieldValue.serverTimestamp(),
            'totalRuntimeSeconds': 0,
          });

      debugPrint('✅ Started aerator: ${aeratorRef.id}');
      return aeratorRef.id;
    } catch (e) {
      debugPrint('❌ Error starting aerator: $e');
      rethrow;
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

  // Get cycle by ID
  @override
  Future<CycleRecommendation?> fetchCycleById(String cycleId) async {
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

      // Search each batch for the cycle in both controller types
      for (var batchDoc in batches) {
        try {
          // Get the main cycle doc(s)
          final cyclesSnapshot = await _firestore
              .collection('batches')
              .doc(batchDoc.id)
              .collection('cyclesRecom')
              .get();

          // Search in each cycle doc's subcollections
          for (var cycleDoc in cyclesSnapshot.docs) {
            // Check drum_controller
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

            // Check aerator
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
