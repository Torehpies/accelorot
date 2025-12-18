import '../../models/cycle_recommendation.dart';

/// Abstract interface for cycle recommendation data operations
abstract class CycleService {
  /// Fetch all cycle recommendations for the current user's team
  Future<List<CycleRecommendation>> fetchTeamCycles();

  /// Get or create cycle for a batch
  Future<CycleRecommendation> getOrCreateCycleForBatch({
    required String batchId,
    required String machineId,
    required String userId,
  });

  /// Start drum controller
  Future<void> startDrumController({
    required String batchId,
    required String cycleId,
    required int cycles,
    required String duration,
  });

  /// Update drum controller progress
  Future<void> updateDrumProgress({
    required String batchId,
    required String cycleId,
    required int completedCycles,
    required Duration totalRuntime,
  });

  /// Complete drum controller
  Future<void> completeDrumController({
    required String batchId,
    required String cycleId,
  });

  /// Start aerator
  Future<void> startAerator({
    required String batchId,
    required String cycleId,
    required int cycles,
    required String duration,
  });

  /// Update aerator progress
  Future<void> updateAeratorProgress({
    required String batchId,
    required String cycleId,
    required int completedCycles,
    required Duration totalRuntime,
  });

  /// Complete aerator
  Future<void> completeAerator({
    required String batchId,
    required String cycleId,
  });
}