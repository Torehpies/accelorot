import '../models/cycle_recommendation.dart';
import '../services/contracts/cycle_service.dart';

class CycleRepository {
  final CycleService _cycleService;

  CycleRepository(this._cycleService);

  Future<List<CycleRecommendation>> getTeamCycles() =>
      _cycleService.fetchTeamCycles();

  Future<CycleRecommendation?> getDrumController({required String batchId}) =>
      _cycleService.getDrumController(batchId: batchId);

  Future<CycleRecommendation?> getAerator({required String batchId}) =>
      _cycleService.getAerator(batchId: batchId);

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

  /// Get a single cycle by ID
  Future<CycleRecommendation?> getCycle(String id) =>
      _cycleService.fetchCycleById(id);
}
