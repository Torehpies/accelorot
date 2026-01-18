import '../../models/cycle_recommendation.dart';

/// Abstract interface for cycle recommendation data operations
abstract class CycleService {
  /// Fetch all cycle recommendations for the current user's team
  Future<List<CycleRecommendation>> fetchTeamCycles();

  /// Get drum controller for a batch
  Future<CycleRecommendation?> getDrumController({
    required String batchId,
  });

  /// Get aerator for a batch
  Future<CycleRecommendation?> getAerator({
    required String batchId,
  });

  /// Start drum controller
  Future<String> startDrumController({
    required String batchId,
    required String machineId,
    required String userId,
    required int activeMinutes,
    required int restMinutes,
  });

  /// Complete drum controller
  Future<void> completeDrumController({
    required String batchId,
  });

  /// Start aerator
  Future<String> startAerator({
    required String batchId,
    required String machineId,
    required String userId,
    required int activeMinutes,
    required int restMinutes,
  });

  /// Complete aerator
  Future<void> completeAerator({
    required String batchId,
  });

  /// Update drum controller phase (for countdown synchronization)
  Future<void> updateDrumPhase({
    required String batchId,
    required String newPhase,
  });

  /// Update aerator phase (for countdown synchronization)
  Future<void> updateAeratorPhase({
    required String batchId,
    required String newPhase,
  });

  Future<CycleRecommendation?> fetchCycleById(String cycleId);
}