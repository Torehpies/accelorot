import '../../models/cycle_recommendation.dart';

/// Abstract interface for cycle recommendation data operations
abstract class CycleService {
  /// Fetch all cycle recommendations for the current user's team
  Future<List<CycleRecommendation>> fetchTeamCycles();

  /// Get drum controller for a batch
  Future<CycleRecommendation?> getDrumController({required String batchId});

  /// Get aerator for a batch
  Future<CycleRecommendation?> getAerator({required String batchId});

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

  Future<CycleRecommendation?> fetchCycleById(String cycleId);
}
