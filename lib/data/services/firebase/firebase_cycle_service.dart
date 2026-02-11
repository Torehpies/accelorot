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
  Future<List<CycleRecommendation>> fetchTeamCycles({
    int? limit,
    DateTime? cutoffDate,
  }) async {
    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }

    try {
      final teamId = await _batchService.getUserTeamId(currentUserId!);

      if (teamId == null || teamId.isEmpty) {
        debugPrint('⚠️ User has no team assigned');
        return [];
      }

      // ✅ NEW: Pass cutoffDate to _fetchTeamCycles
      var allCycles = await _fetchTeamCycles(teamId, cutoffDate: cutoffDate);

      // Sort by timestamp descending (newest first)
      allCycles.sort(
        (a, b) => (b.timestamp ?? DateTime.now()).compareTo(
          a.timestamp ?? DateTime.now(),
        ),
      );

      // ❌ REMOVED: No longer need in-memory date filtering
      // Cutoff is now applied at the Firestore query level

      // Apply limit if specified
      if (limit != null && allCycles.length > limit) {
        allCycles = allCycles.sublist(0, limit);
        debugPrint('📄 Limited cycles: ${allCycles.length} items');
      }

      debugPrint('✅ Fetched ${allCycles.length} cycles');
      return allCycles;
    } catch (e) {
      debugPrint('❌ Error fetching cycles: $e');
      throw Exception('Failed to fetch cycles: $e');
    }
  }

  Future<List<CycleRecommendation>> _fetchTeamCycles(
    String teamId, {
    DateTime? cutoffDate,
  }) async {
    final stopwatch = Stopwatch()..start();
    final List<CycleRecommendation> allCycles = [];

    final teamMachineIds = await _batchService.getTeamMachineIds(teamId);
    if (teamMachineIds.isEmpty) return [];

    final batches = await _batchService.getBatchesForMachines(teamMachineIds);
    if (batches.isEmpty) return [];

    //debugPrint(
    //  '🟣 Fetching cycles from ${batches.length} batches in parallel...',
    //);

    final futures = batches.map((batchDoc) async {
      final batchId = batchDoc.id;

      // ✅ Parallel sub-queries per batch
      final results = await Future.wait([
        getDrumControllers(batchId: batchId, cutoffDate: cutoffDate),
        getAerators(batchId: batchId, cutoffDate: cutoffDate),
      ]);

      return [...results[0], ...results[1]];
    });

    final results = await Future.wait(futures);

    for (var result in results) {
      allCycles.addAll(result);
    }

    // Sort by timestamp descending (latest first)
    allCycles.sort(
      (a, b) => (b.startedAt ?? DateTime(1970)).compareTo(
        a.startedAt ?? DateTime(1970),
      ),
    );

    stopwatch.stop();
    debugPrint(
      '✅ Fetched ${allCycles.length} cycles from ${batches.length} batches (Parallel Strategy) in ${stopwatch.elapsedMilliseconds}ms',
    );

    return allCycles;
  }

  // ===== GET DRUM CONTROLLER =====

  @override
  Future<List<CycleRecommendation>> getDrumControllers({
    required String batchId,
    DateTime? cutoffDate, // ✅ NEW: Add cutoff parameter
  }) async {
    try {
      final cycleDocId = await _getExistingMainCycleDocId(batchId);
      if (cycleDocId == null) return [];

      var query = _firestore
          .collection('batches')
          .doc(batchId)
          .collection('cyclesRecom')
          .doc(cycleDocId)
          .collection('drum_controller')
          .orderBy('startedAt', descending: true); // Latest first

      // ✅ NEW: Apply timestamp filter at Firestore query level
      if (cutoffDate != null) {
        query = query.where(
          'startedAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(cutoffDate),
        );
      }

      final drumSnapshot = await query.get();

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
    DateTime? cutoffDate, // ✅ NEW: Add cutoff parameter
  }) async {
    try {
      final cycleDocId = await _getExistingMainCycleDocId(batchId);
      if (cycleDocId == null) return [];

      var query = _firestore
          .collection('batches')
          .doc(batchId)
          .collection('cyclesRecom')
          .doc(cycleDocId)
          .collection('aerator')
          .orderBy('startedAt', descending: true);

      // ✅ NEW: Apply timestamp filter at Firestore query level
      if (cutoffDate != null) {
        query = query.where(
          'startedAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(cutoffDate),
        );
      }

      final aeratorSnapshot = await query.get();

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

      // Create a reference for the new drum controller document
      final drumConfigRef = _firestore
          .collection('batches')
          .doc(batchId)
          .collection('cyclesRecom')
          .doc(cycleDocId)
          .collection('drum_controller')
          .doc();

      final machineRef = _firestore.collection('machines').doc(machineId);

      final result = await _firestore.runTransaction<String>((transaction) async {
        // 1. READ: Get machine state
        final machineSnapshot = await transaction.get(machineRef);
        if (!machineSnapshot.exists) {
          return 'ERROR:Machine not found';
        }

        final drumActive = machineSnapshot.data()?['drumActive'] ?? false;
        
        // 2. CHECK: Ensure machine is not already running
        if (drumActive == true) {
          return 'ERROR:Machine is already running';
        }

        // 3. WRITE: Update machine state to RUNNING
        transaction.update(machineRef, {
          'drumActive': true,
          'drumPaused': false,
          'lastModified': FieldValue.serverTimestamp(),
        });

        // 4. WRITE: Create new cycle log
        transaction.set(drumConfigRef, {
          'category': 'cycles',
          'controllerType': 'drum_controller',
          'action': 'started',
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
        return 'OK';
      });

      if (result.startsWith('ERROR:')) {
        throw Exception(result.substring(6));
      }

      debugPrint('✅ Started drum controller: ${drumConfigRef.id}');
      return drumConfigRef.id;
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

  // ===== STOP DRUM CONTROLLER (Manual stop, not completion) =====

  @override
  Future<void> stopDrumController({
    required String batchId,
    required int totalRuntimeSeconds,
  }) async {
    try {
      final cycleDocId = await _getExistingMainCycleDocId(batchId);
      if (cycleDocId == null) {
        throw Exception('No cycle document found for batch: $batchId');
      }

      final drumSnapshot = await _firestore
          .collection('batches')
          .doc(batchId)
          .collection('cyclesRecom')
          .doc(cycleDocId)
          .collection('drum_controller')
          .orderBy('startedAt', descending: true)
          .limit(1)
          .get();

      if (drumSnapshot.docs.isEmpty) {
        throw Exception('No drum controller found to stop');
      }

      final drumDoc = drumSnapshot.docs.first;
      final existingData = drumDoc.data();
      final machineId = existingData['machineId'] as String?;

      if (machineId == null) {
        throw Exception('Machine ID not found in cycle document');
      }

      final machineRef = _firestore.collection('machines').doc(machineId);

      // Create a new document for the stop action
      final stopDocRef = _firestore
          .collection('batches')
          .doc(batchId)
          .collection('cyclesRecom')
          .doc(cycleDocId)
          .collection('drum_controller')
          .doc();

      final result = await _firestore.runTransaction<String>((transaction) async {
        // 1. READ: Get machine state
        final machineSnapshot = await transaction.get(machineRef);
        final drumActive = machineSnapshot.data()?['drumActive'] ?? false;
        final drumPaused = machineSnapshot.data()?['drumPaused'] ?? false;

        // 2. CHECK: Ensure machine is not already fully stopped (can stop if running OR paused)
        if (!drumActive && !drumPaused) {
          return 'ERROR:Machine is already stopped';
        }

        // 3. UPDATE: Update machine to STOPPED
        transaction.update(machineRef, {
          'drumActive': false,
          'drumPaused': false,
          'lastModified': FieldValue.serverTimestamp(),
        });

        // 4. CREATE: New document for stop activity
        transaction.set(stopDocRef, {
          'category': 'cycles',
          'controllerType': 'drum_controller',
          'action': 'stopped',
          'status': 'stopped',
          'machineId': machineId,
          'batchId': batchId,
          'duration': existingData['duration'],
          'cycles': existingData['cycles'],
          'totalRuntimeSeconds': totalRuntimeSeconds,
          'timestamp': FieldValue.serverTimestamp(),
          'startedAt': FieldValue.serverTimestamp(),
        });

        return 'OK';
      });

      if (result.startsWith('ERROR:')) {
        throw Exception(result.substring(6));
      }

      debugPrint('✅ Drum controller stopped successfully (Atomic)');
    } catch (e) {
      debugPrint('❌ Error stopping drum controller: $e');
      rethrow;
    }
  }

  // ===== STOP AERATOR (Manual stop, not completion) =====

  @override
  Future<void> stopAerator({
    required String batchId,
    required int totalRuntimeSeconds,
  }) async {
    try {
      final cycleDocId = await _getExistingMainCycleDocId(batchId);
      if (cycleDocId == null) {
        throw Exception('No cycle document found for batch: $batchId');
      }

      final aeratorSnapshot = await _firestore
          .collection('batches')
          .doc(batchId)
          .collection('cyclesRecom')
          .doc(cycleDocId)
          .collection('aerator')
          .orderBy('startedAt', descending: true)
          .limit(1)
          .get();

      if (aeratorSnapshot.docs.isEmpty) {
        throw Exception('No aerator found to stop');
      }

      final aeratorDoc = aeratorSnapshot.docs.first;
      final existingData = aeratorDoc.data();
      final machineId = existingData['machineId'] as String?;

      if (machineId == null) {
        throw Exception('Machine ID not found in cycle document');
      }

      final machineRef = _firestore.collection('machines').doc(machineId);

      // Create a new document for the stop action
      final stopDocRef = _firestore
          .collection('batches')
          .doc(batchId)
          .collection('cyclesRecom')
          .doc(cycleDocId)
          .collection('aerator')
          .doc();

      final result = await _firestore.runTransaction<String>((transaction) async {
        // 1. READ: Get machine state
        final machineSnapshot = await transaction.get(machineRef);
        final aeratorActive = machineSnapshot.data()?['aeratorActive'] ?? false;
        final aeratorPaused = machineSnapshot.data()?['aeratorPaused'] ?? false;

        // 2. CHECK: Ensure machine is not already fully stopped (can stop if running OR paused)
        if (!aeratorActive && !aeratorPaused) {
          return 'ERROR:Aerator is already stopped';
        }

        // 3. UPDATE: Update machine to STOPPED
        transaction.update(machineRef, {
          'aeratorActive': false,
          'aeratorPaused': false,
          'lastModified': FieldValue.serverTimestamp(),
        });

        // 4. CREATE: New document for stop activity
        transaction.set(stopDocRef, {
          'category': 'cycles',
          'controllerType': 'aerator',
          'action': 'stopped',
          'status': 'stopped',
          'machineId': machineId,
          'batchId': batchId,
          'duration': existingData['duration'],
          'cycles': existingData['cycles'],
          'totalRuntimeSeconds': totalRuntimeSeconds,
          'timestamp': FieldValue.serverTimestamp(),
          'startedAt': FieldValue.serverTimestamp(),
        });

        return 'OK';
      });

      if (result.startsWith('ERROR:')) {
        throw Exception(result.substring(6));
      }

      debugPrint('✅ Aerator stopped successfully (Atomic)');
    } catch (e) {
      debugPrint('❌ Error stopping aerator: $e');
      rethrow;
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

      // Create a reference for the new aerator document
      final aeratorRef = _firestore
          .collection('batches')
          .doc(batchId)
          .collection('cyclesRecom')
          .doc(cycleDocId)
          .collection('aerator')
          .doc();

      final machineRef = _firestore.collection('machines').doc(machineId);

      final result = await _firestore.runTransaction<String>((transaction) async {
        // 1. READ: Get machine state
        final machineSnapshot = await transaction.get(machineRef);
        if (!machineSnapshot.exists) {
          return 'ERROR:Machine not found';
        }

        final aeratorActive = machineSnapshot.data()?['aeratorActive'] ?? false;

        // 2. CHECK: Ensure aerator is not already running
        if (aeratorActive == true) {
          return 'ERROR:Aerator is already running';
        }

        // 3. WRITE: Update machine state to RUNNING
        transaction.update(machineRef, {
          'aeratorActive': true,
          'aeratorPaused': false,
          'lastModified': FieldValue.serverTimestamp(),
        });

        // 4. WRITE: Create new cycle log
        transaction.set(aeratorRef, {
          'category': 'cycles',
          'controllerType': 'aerator',
          'action': 'started',
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
        return 'OK';
      });

      if (result.startsWith('ERROR:')) {
        throw Exception(result.substring(6));
      }

      debugPrint('✅ Started aerator (Atomic): ${aeratorRef.id}');
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

  // ===== PAUSE DRUM CONTROLLER =====

  @override
  Future<void> pauseDrumController({
    required String batchId,
    required int accumulatedRuntimeSeconds,
  }) async {
    try {
      final cycleDocId = await _getExistingMainCycleDocId(batchId);
      if (cycleDocId == null) {
        throw Exception('No cycle document found for batch: $batchId');
      }

      final drumSnapshot = await _firestore
          .collection('batches')
          .doc(batchId)
          .collection('cyclesRecom')
          .doc(cycleDocId)
          .collection('drum_controller')
          .orderBy('startedAt', descending: true)
          .limit(1)
          .get();

      if (drumSnapshot.docs.isEmpty) {
        throw Exception('No drum controller found to pause');
      }

      final drumDoc = drumSnapshot.docs.first;
      final existingData = drumDoc.data();
      final machineId = existingData['machineId'] as String?;

      if (machineId == null) {
        throw Exception('Machine ID not found in cycle document');
      }

      final machineRef = _firestore.collection('machines').doc(machineId);

      // Create a new document for the pause action
      final pauseDocRef = _firestore
          .collection('batches')
          .doc(batchId)
          .collection('cyclesRecom')
          .doc(cycleDocId)
          .collection('drum_controller')
          .doc();

      final result = await _firestore.runTransaction<String>((transaction) async {
        // 1. READ: Get machine state
        final machineSnapshot = await transaction.get(machineRef);
        final drumActive = machineSnapshot.data()?['drumActive'] ?? false;
        final drumPaused = machineSnapshot.data()?['drumPaused'] ?? false;

        // 2. CHECK: Ensure machine is actually running (not already paused/stopped)
        if (!drumActive || drumPaused) {
          return 'ERROR:Machine is not running - cannot pause';
        }

        // 3. UPDATE: Update machine to PAUSED
        transaction.update(machineRef, {
          'drumActive': false,
          'drumPaused': true,
          'lastModified': FieldValue.serverTimestamp(),
        });

        // 4. CREATE: New document for pause activity
        transaction.set(pauseDocRef, {
          'category': 'cycles',
          'controllerType': 'drum_controller',
          'action': 'paused',
          'status': 'paused',
          'machineId': machineId,
          'batchId': batchId,
          'duration': existingData['duration'],
          'cycles': existingData['cycles'],
          'totalRuntimeSeconds': accumulatedRuntimeSeconds,
          'timestamp': FieldValue.serverTimestamp(),
          'startedAt': FieldValue.serverTimestamp(),
        });

        return 'OK';
      });

      if (result.startsWith('ERROR:')) {
        throw Exception(result.substring(6));
      }

      debugPrint('✅ Drum controller paused successfully (Atomic)');
    } catch (e) {
      debugPrint('❌ Error pausing drum controller: $e');
      rethrow;
    }
  }

  // ===== RESUME DRUM CONTROLLER =====

  @override
  Future<void> resumeDrumController({required String batchId}) async {
    try {
      final cycleDocId = await _getExistingMainCycleDocId(batchId);
      if (cycleDocId == null) {
        throw Exception('No cycle document found for batch: $batchId');
      }

      final drumSnapshot = await _firestore
          .collection('batches')
          .doc(batchId)
          .collection('cyclesRecom')
          .doc(cycleDocId)
          .collection('drum_controller')
          .orderBy('startedAt', descending: true)
          .limit(1)
          .get();

      if (drumSnapshot.docs.isEmpty) {
        throw Exception('No drum controller found to resume');
      }

      final drumDoc = drumSnapshot.docs.first;
      final existingData = drumDoc.data();
      final machineId = existingData['machineId'] as String?;

      if (machineId == null) {
        throw Exception('Machine ID not found in cycle document');
      }

      final machineRef = _firestore.collection('machines').doc(machineId);

      // Create a new document for the resume action
      final resumeDocRef = _firestore
          .collection('batches')
          .doc(batchId)
          .collection('cyclesRecom')
          .doc(cycleDocId)
          .collection('drum_controller')
          .doc();

      final result = await _firestore.runTransaction<String>((transaction) async {
        // 1. READ: Get machine state
        final machineSnapshot = await transaction.get(machineRef);
        final drumActive = machineSnapshot.data()?['drumActive'] ?? false;
        final drumPaused = machineSnapshot.data()?['drumPaused'] ?? false;

        // 2. CHECK: Ensure machine is actually paused
        if (drumActive || !drumPaused) {
          return 'ERROR:Machine is not paused - cannot resume';
        }

        // 3. UPDATE: Update machine to RUNNING
        transaction.update(machineRef, {
          'drumActive': true,
          'drumPaused': false,
          'lastModified': FieldValue.serverTimestamp(),
        });

        // 4. CREATE: New document for resume activity
        transaction.set(resumeDocRef, {
          'category': 'cycles',
          'controllerType': 'drum_controller',
          'action': 'resumed',
          'status': 'resumed',
          'machineId': machineId,
          'batchId': batchId,
          'duration': existingData['duration'],
          'cycles': existingData['cycles'],
          'totalRuntimeSeconds': existingData['totalRuntimeSeconds'] ?? existingData['accumulatedRuntimeSeconds'] ?? 0,
          'timestamp': FieldValue.serverTimestamp(),
          'startedAt': FieldValue.serverTimestamp(),
        });

        return 'OK';
      });

      if (result.startsWith('ERROR:')) {
        throw Exception(result.substring(6));
      }

      debugPrint('✅ Drum controller resumed successfully (Atomic)');
    } catch (e) {
      debugPrint('❌ Error resuming drum controller: $e');
      rethrow;
    }
  }

  // ===== PAUSE AERATOR =====

  @override
  Future<void> pauseAerator({
    required String batchId,
    required int accumulatedRuntimeSeconds,
  }) async {
    try {
      final cycleDocId = await _getExistingMainCycleDocId(batchId);
      if (cycleDocId == null) {
        throw Exception('No cycle document found for batch: $batchId');
      }

      final aeratorSnapshot = await _firestore
          .collection('batches')
          .doc(batchId)
          .collection('cyclesRecom')
          .doc(cycleDocId)
          .collection('aerator')
          .orderBy('startedAt', descending: true)
          .limit(1)
          .get();

      if (aeratorSnapshot.docs.isEmpty) {
        throw Exception('No aerator found to pause');
      }

      final aeratorDoc = aeratorSnapshot.docs.first;
      final existingData = aeratorDoc.data();
      final machineId = existingData['machineId'] as String?;

      if (machineId == null) {
        throw Exception('Machine ID not found in cycle document');
      }

      final machineRef = _firestore.collection('machines').doc(machineId);

      // Create a new document for the pause action
      final pauseDocRef = _firestore
          .collection('batches')
          .doc(batchId)
          .collection('cyclesRecom')
          .doc(cycleDocId)
          .collection('aerator')
          .doc();

      final result = await _firestore.runTransaction<String>((transaction) async {
        // 1. READ: Get machine state
        final machineSnapshot = await transaction.get(machineRef);
        final aeratorActive = machineSnapshot.data()?['aeratorActive'] ?? false;
        final aeratorPaused = machineSnapshot.data()?['aeratorPaused'] ?? false;

        // 2. CHECK: Ensure aerator is actually running (not already paused/stopped)
        if (!aeratorActive || aeratorPaused) {
          return 'ERROR:Aerator is not running - cannot pause';
        }

        // 3. UPDATE: Update machine to PAUSED
        transaction.update(machineRef, {
          'aeratorActive': false,
          'aeratorPaused': true,
          'lastModified': FieldValue.serverTimestamp(),
        });

        // 4. CREATE: New document for pause activity
        transaction.set(pauseDocRef, {
          'category': 'cycles',
          'controllerType': 'aerator',
          'action': 'paused',
          'status': 'paused',
          'machineId': machineId,
          'batchId': batchId,
          'duration': existingData['duration'],
          'cycles': existingData['cycles'],
          'totalRuntimeSeconds': accumulatedRuntimeSeconds,
          'timestamp': FieldValue.serverTimestamp(),
          'startedAt': FieldValue.serverTimestamp(),
        });

        return 'OK';
      });

      if (result.startsWith('ERROR:')) {
        throw Exception(result.substring(6));
      }

      debugPrint('✅ Aerator paused successfully (Atomic)');
    } catch (e) {
      debugPrint('❌ Error pausing aerator: $e');
      rethrow;
    }
  }

  // ===== RESUME AERATOR =====

  @override
  Future<void> resumeAerator({required String batchId}) async {
    try {
      final cycleDocId = await _getExistingMainCycleDocId(batchId);
      if (cycleDocId == null) {
        throw Exception('No cycle document found for batch: $batchId');
      }

      final aeratorSnapshot = await _firestore
          .collection('batches')
          .doc(batchId)
          .collection('cyclesRecom')
          .doc(cycleDocId)
          .collection('aerator')
          .orderBy('startedAt', descending: true)
          .limit(1)
          .get();

      if (aeratorSnapshot.docs.isEmpty) {
        throw Exception('No aerator found to resume');
      }

      final aeratorDoc = aeratorSnapshot.docs.first;
      final existingData = aeratorDoc.data();
      final machineId = existingData['machineId'] as String?;

      if (machineId == null) {
        throw Exception('Machine ID not found in cycle document');
      }

      final machineRef = _firestore.collection('machines').doc(machineId);

      // Create a new document for the resume action
      final resumeDocRef = _firestore
          .collection('batches')
          .doc(batchId)
          .collection('cyclesRecom')
          .doc(cycleDocId)
          .collection('aerator')
          .doc();

      final result = await _firestore.runTransaction<String>((transaction) async {
        // 1. READ: Get machine state
        final machineSnapshot = await transaction.get(machineRef);
        final aeratorActive = machineSnapshot.data()?['aeratorActive'] ?? false;
        final aeratorPaused = machineSnapshot.data()?['aeratorPaused'] ?? false;

        // 2. CHECK: Ensure aerator is actually paused
        if (aeratorActive || !aeratorPaused) {
          return 'ERROR:Aerator is not paused - cannot resume';
        }

        // 3. UPDATE: Update machine to RUNNING
        transaction.update(machineRef, {
          'aeratorActive': true,
          'aeratorPaused': false,
          'lastModified': FieldValue.serverTimestamp(),
        });

        // 4. CREATE: New document for resume activity
        transaction.set(resumeDocRef, {
          'category': 'cycles',
          'controllerType': 'aerator',
          'action': 'resumed',
          'status': 'resumed',
          'machineId': machineId,
          'batchId': batchId,
          'duration': existingData['duration'],
          'cycles': existingData['cycles'],
          'totalRuntimeSeconds': existingData['totalRuntimeSeconds'] ?? existingData['accumulatedRuntimeSeconds'] ?? 0,
          'timestamp': FieldValue.serverTimestamp(),
          'startedAt': FieldValue.serverTimestamp(),
        });

        return 'OK';
      });

      if (result.startsWith('ERROR:')) {
        throw Exception(result.substring(6));
      }

      debugPrint('✅ Aerator resumed successfully (Atomic)');
    } catch (e) {
      debugPrint('❌ Error resuming aerator: $e');
      rethrow;
    }
  }

  @override
  Stream<List<CycleRecommendation>> streamTeamCycles({DateTime? cutoffDate}) async* {
    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }

    // Get team information once
    final teamId = await _batchService.getUserTeamId(currentUserId!);
    if (teamId == null || teamId.isEmpty) {
      debugPrint('⚠️ User has no team assigned');
      yield [];
      return;
    }

    final teamMachineIds = await _batchService.getTeamMachineIds(teamId);
    if (teamMachineIds.isEmpty) {
      debugPrint('ℹ️ No machines found for team: $teamId');
      yield [];
      return;
    }

    final batches = await _batchService.getBatchesForMachines(teamMachineIds);
    if (batches.isEmpty) {
      debugPrint('ℹ️ No batches found for team machines');
      yield [];
      return;
    }

    // Apply default cutoff if not provided (2 days)
    final cutoff = cutoffDate ?? DateTime.now().subtract(const Duration(days: 2));
    debugPrint('🟣 Streaming cycles with cutoff: $cutoff');

    // Emit immediately on first call
    yield await _fetchAllCyclesFromBatches(batches, cutoff);
    
    // Then poll every 1 second for real-time updates
    await for (final _ in Stream.periodic(const Duration(seconds: 1))) {
      try {
        yield await _fetchAllCyclesFromBatches(batches, cutoff);
      } catch (e) {
        debugPrint('❌ Error in streamTeamCycles: $e');
        yield [];
      }
    }
  }
  
  /// Helper to fetch cycles from all batches
  Future<List<CycleRecommendation>> _fetchAllCyclesFromBatches(
    List<QueryDocumentSnapshot> batches,
    DateTime cutoff,
  ) async {
    //debugPrint('🔄 Fetching cycles for ${batches.length} batches...');

    final List<CycleRecommendation> allCycles = [];

    // Fetch cycles from all batches in parallel
    final results = await Future.wait(
      batches.map((batchDoc) async {
        final List<CycleRecommendation> batchCycles = [];

        try {
          final cyclesSnapshot = await _firestore
              .collection('batches')
              .doc(batchDoc.id)
              .collection('cyclesRecom')
              .get();

          for (var cycleDoc in cyclesSnapshot.docs) {
            // Fetch drum_controller and aerator in parallel with cutoff filter
            final futures = await Future.wait([
              _firestore
                  .collection('batches')
                  .doc(batchDoc.id)
                  .collection('cyclesRecom')
                  .doc(cycleDoc.id)
                  .collection('drum_controller')
                  .where('startedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(cutoff))
                  .get(),
              _firestore
                  .collection('batches')
                  .doc(batchDoc.id)
                  .collection('cyclesRecom')
                  .doc(cycleDoc.id)
                  .collection('aerator')
                  .where('startedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(cutoff))
                  .get(),
            ]);

            final drumSnapshot = futures[0];
            final aeratorSnapshot = futures[1];

            // Add drum controller cycles
            for (var drumDoc in drumSnapshot.docs) {
              try {
                batchCycles.add(CycleRecommendation.fromFirestore(drumDoc));
              } catch (e) {
                debugPrint('⚠️ Error parsing drum cycle: $e');
              }
            }

            // Add aerator cycles
            for (var aeratorDoc in aeratorSnapshot.docs) {
              try {
                batchCycles.add(CycleRecommendation.fromFirestore(aeratorDoc));
              } catch (e) {
                debugPrint('⚠️ Error parsing aerator cycle: $e');
              }
            }
          }
        } catch (e) {
          debugPrint('⚠️ Error fetching cycles for batch ${batchDoc.id}: $e');
        }

        return batchCycles;
      }),
    );

    // Combine all cycles from all batches
    for (var cycles in results) {
      allCycles.addAll(cycles);
    }

    // Sort by timestamp descending
    allCycles.sort((a, b) =>
        (b.timestamp ?? DateTime(2000)).compareTo(a.timestamp ?? DateTime(2000)));

    //debugPrint('✅ Stream yielding ${allCycles.length} cycles');
    return allCycles;
  }
}
