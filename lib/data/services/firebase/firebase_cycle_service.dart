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

    debugPrint(
      '🟣 Fetching cycles from ${batches.length} batches in parallel...',
    );

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

      final drumDocId = drumSnapshot.docs.first.id;

      // Set status to 'stopped' (not 'completed')
      await _firestore
          .collection('batches')
          .doc(batchId)
          .collection('cyclesRecom')
          .doc(cycleDocId)
          .collection('drum_controller')
          .doc(drumDocId)
          .update({
            'status': 'stopped',
            'totalRuntimeSeconds': totalRuntimeSeconds,
            'stoppedAt': FieldValue.serverTimestamp(),
            'pausedAt': FieldValue.delete(),
            'accumulatedRuntimeSeconds': FieldValue.delete(),
          });

      debugPrint('✅ Drum controller stopped successfully');
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

      final aeratorDocId = aeratorSnapshot.docs.first.id;

      await _firestore
          .collection('batches')
          .doc(batchId)
          .collection('cyclesRecom')
          .doc(cycleDocId)
          .collection('aerator')
          .doc(aeratorDocId)
          .update({
            'status': 'stopped',
            'totalRuntimeSeconds': totalRuntimeSeconds,
            'stoppedAt': FieldValue.serverTimestamp(),
            'pausedAt': FieldValue.delete(),
            'accumulatedRuntimeSeconds': FieldValue.delete(),
          });

      debugPrint('✅ Aerator stopped successfully');
    } catch (e) {
      debugPrint('❌ Error stopping aerator: $e');
      rethrow;
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

      final drumDocId = drumSnapshot.docs.first.id;

      await _firestore
          .collection('batches')
          .doc(batchId)
          .collection('cyclesRecom')
          .doc(cycleDocId)
          .collection('drum_controller')
          .doc(drumDocId)
          .update({
            'status': 'paused',
            'pausedAt': FieldValue.serverTimestamp(),
            'accumulatedRuntimeSeconds': accumulatedRuntimeSeconds,
          });

      debugPrint('✅ Drum controller paused successfully');
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

      final drumDocId = drumSnapshot.docs.first.id;

      await _firestore
          .collection('batches')
          .doc(batchId)
          .collection('cyclesRecom')
          .doc(cycleDocId)
          .collection('drum_controller')
          .doc(drumDocId)
          .update({'status': 'running', 'pausedAt': FieldValue.delete()});

      debugPrint('✅ Drum controller resumed successfully');
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

      final aeratorDocId = aeratorSnapshot.docs.first.id;

      await _firestore
          .collection('batches')
          .doc(batchId)
          .collection('cyclesRecom')
          .doc(cycleDocId)
          .collection('aerator')
          .doc(aeratorDocId)
          .update({
            'status': 'paused',
            'pausedAt': FieldValue.serverTimestamp(),
            'accumulatedRuntimeSeconds': accumulatedRuntimeSeconds,
          });

      debugPrint('✅ Aerator paused successfully');
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

      final aeratorDocId = aeratorSnapshot.docs.first.id;

      await _firestore
          .collection('batches')
          .doc(batchId)
          .collection('cyclesRecom')
          .doc(cycleDocId)
          .collection('aerator')
          .doc(aeratorDocId)
          .update({'status': 'running', 'pausedAt': FieldValue.delete()});

      debugPrint('✅ Aerator resumed successfully');
    } catch (e) {
      debugPrint('❌ Error resuming aerator: $e');
      rethrow;
    }
  }

  @override
  Stream<List<CycleRecommendation>> streamTeamCycles() async* {
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

    // Emit updates every 5 seconds
    await for (final _ in Stream.periodic(const Duration(seconds: 5))) {
      try {
        debugPrint('🔄 Fetching cycles for ${batches.length} batches...');

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
                // Fetch drum_controller and aerator in parallel
                final futures = await Future.wait([
                  _firestore
                      .collection('batches')
                      .doc(batchDoc.id)
                      .collection('cyclesRecom')
                      .doc(cycleDoc.id)
                      .collection('drum_controller')
                      .get(),
                  _firestore
                      .collection('batches')
                      .doc(batchDoc.id)
                      .collection('cyclesRecom')
                      .doc(cycleDoc.id)
                      .collection('aerator')
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
                    batchCycles
                        .add(CycleRecommendation.fromFirestore(aeratorDoc));
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

        debugPrint('✅ Stream yielding ${allCycles.length} cycles');
        yield allCycles;
      } catch (e) {
        debugPrint('❌ Error in streamTeamCycles: $e');
        yield [];
      }
    }
  }
}
