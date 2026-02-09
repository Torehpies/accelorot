import '../../models/cycle_recommendation.dart';

/// Abstract interface for cycle recommendation data operations
abstract class CycleService {
  /// Fetch all cycle recommendations for the current user's team
  /// [limit] - Maximum number of cycles to fetch (null = fetch all)
  /// [cutoffDate] - Only fetch cycles newer than this date (null = no filter)
  Future<List<CycleRecommendation>> fetchTeamCycles({int? limit, DateTime? cutoffDate});

  /// Get drum controller for a batch
  /// [cutoffDate] - Only fetch cycles newer than this date (null = no filter)
  Future<List<CycleRecommendation>> getDrumControllers({
    required String batchId,
    DateTime? cutoffDate,
  });
  
  /// Get aerators for a batch
  /// [cutoffDate] - Only fetch cycles newer than this date (null = no filter)
  Future<List<CycleRecommendation>> getAerators({
    required String batchId,
    DateTime? cutoffDate,
  });
  
  /// Start drum controller
  Future<String> startDrumController({
    required String batchId,
    required String machineId,
    required String userId,
    required int cycles,
    required String duration,
  });

  /// Update drum controller progress
  Future<void> updateDrumProgress({
    required String batchId,
    required int completedCycles,
    required Duration totalRuntime,
  });

  /// Complete drum controller
  Future<void> completeDrumController({required String batchId});

  /// Start aerator
  Future<String> startAerator({
    required String batchId,
    required String machineId,
    required String userId,
    required int cycles,
    required String duration,
  });

  /// Update aerator progress
  Future<void> updateAeratorProgress({
    required String batchId,
    required int completedCycles,
    required Duration totalRuntime,
  });

  /// Complete aerator
  Future<void> completeAerator({required String batchId});

  /// Stop drum controller (different from complete - for manual stop)
  Future<void> stopDrumController({
    required String batchId,
    required int totalRuntimeSeconds,
  });

  /// Stop aerator (different from complete - for manual stop)
  Future<void> stopAerator({
    required String batchId,
    required int totalRuntimeSeconds,
  });

  /// Pause drum controller
  Future<void> pauseDrumController({
    required String batchId,
    required int accumulatedRuntimeSeconds,
  });

  /// Resume drum controller
  Future<void> resumeDrumController({required String batchId});

  /// Pause aerator
  Future<void> pauseAerator({
    required String batchId,
    required int accumulatedRuntimeSeconds,
  });

  /// Resume aerator
  Future<void> resumeAerator({required String batchId});

  Future<CycleRecommendation?> fetchCycleById(String cycleId);

  /// Stream all cycles for the team's batches with real-time updates
  Stream<List<CycleRecommendation>> streamTeamCycles();
}
