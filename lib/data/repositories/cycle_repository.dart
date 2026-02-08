import '../models/cycle_recommendation.dart';
import '../services/contracts/cycle_service.dart';

class CycleRepository {
  final CycleService _cycleService;

  CycleRepository(this._cycleService);

  Future<List<CycleRecommendation>> getTeamCycles({
    int? limit,
    DateTime? cutoffDate,
  }) =>
      _cycleService.fetchTeamCycles(limit: limit, cutoffDate: cutoffDate);

  Future<List<CycleRecommendation>> getDrumControllers({
    required String batchId,
  }) => _cycleService.getDrumControllers(batchId: batchId);

  Future<List<CycleRecommendation>> getAerators({required String batchId}) =>
      _cycleService.getAerators(batchId: batchId);
  Future<String> startDrumController({
    required String batchId,
    required String machineId,
    required String userId,
    required int cycles,
    required String duration,
  }) => _cycleService.startDrumController(
    batchId: batchId,
    machineId: machineId,
    userId: userId,
    cycles: cycles,
    duration: duration,
  );

  Future<void> updateDrumProgress({
    required String batchId,
    required int completedCycles,
    required Duration totalRuntime,
  }) => _cycleService.updateDrumProgress(
    batchId: batchId,
    completedCycles: completedCycles,
    totalRuntime: totalRuntime,
  );

  Future<void> completeDrumController({required String batchId}) =>
      _cycleService.completeDrumController(batchId: batchId);

  Future<String> startAerator({
    required String batchId,
    required String machineId,
    required String userId,
    required int cycles,
    required String duration,
  }) => _cycleService.startAerator(
    batchId: batchId,
    machineId: machineId,
    userId: userId,
    cycles: cycles,
    duration: duration,
  );

  Future<void> updateAeratorProgress({
    required String batchId,
    required int completedCycles,
    required Duration totalRuntime,
  }) => _cycleService.updateAeratorProgress(
    batchId: batchId,
    completedCycles: completedCycles,
    totalRuntime: totalRuntime,
  );

  Future<void> completeAerator({required String batchId}) =>
      _cycleService.completeAerator(batchId: batchId);

  /// Stop drum controller (manual stop, not completion)
  Future<void> stopDrumController({
    required String batchId,
    required int totalRuntimeSeconds,
  }) => _cycleService.stopDrumController(
    batchId: batchId,
    totalRuntimeSeconds: totalRuntimeSeconds,
  );

  /// Stop aerator (manual stop, not completion)
  Future<void> stopAerator({
    required String batchId,
    required int totalRuntimeSeconds,
  }) => _cycleService.stopAerator(
    batchId: batchId,
    totalRuntimeSeconds: totalRuntimeSeconds,
  );

  /// Pause drum controller
  Future<void> pauseDrumController({
    required String batchId,
    required int accumulatedRuntimeSeconds,
  }) => _cycleService.pauseDrumController(
    batchId: batchId,
    accumulatedRuntimeSeconds: accumulatedRuntimeSeconds,
  );

  /// Resume drum controller
  Future<void> resumeDrumController({required String batchId}) =>
      _cycleService.resumeDrumController(batchId: batchId);

  /// Pause aerator
  Future<void> pauseAerator({
    required String batchId,
    required int accumulatedRuntimeSeconds,
  }) => _cycleService.pauseAerator(
    batchId: batchId,
    accumulatedRuntimeSeconds: accumulatedRuntimeSeconds,
  );

  /// Resume aerator
  Future<void> resumeAerator({required String batchId}) =>
      _cycleService.resumeAerator(batchId: batchId);

  /// Get a single cycle by ID
  Future<CycleRecommendation?> getCycle(String id) =>
      _cycleService.fetchCycleById(id);

  /// Stream all cycles for the team with real-time updates
  Stream<List<CycleRecommendation>> streamTeamCycles() =>
      _cycleService.streamTeamCycles();
}
