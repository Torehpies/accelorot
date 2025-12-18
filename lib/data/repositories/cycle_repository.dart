import '../models/cycle_recommendation.dart';
import '../services/contracts/cycle_service.dart';

class CycleRepository {
  final CycleService _cycleService;

  CycleRepository(this._cycleService);

  Future<List<CycleRecommendation>> getTeamCycles() =>
      _cycleService.fetchTeamCycles();

  Future<CycleRecommendation> getOrCreateCycleForBatch({
    required String batchId,
    required String machineId,
    required String userId,
  }) =>
      _cycleService.getOrCreateCycleForBatch(
        batchId: batchId,
        machineId: machineId,
        userId: userId,
      );

  Future<void> startDrumController({
    required String batchId,
    required String cycleId,
    required int cycles,
    required String duration,
  }) =>
      _cycleService.startDrumController(
        batchId: batchId,
        cycleId: cycleId,
        cycles: cycles,
        duration: duration,
      );

  Future<void> updateDrumProgress({
    required String batchId,
    required String cycleId,
    required int completedCycles,
    required Duration totalRuntime,
  }) =>
      _cycleService.updateDrumProgress(
        batchId: batchId,
        cycleId: cycleId,
        completedCycles: completedCycles,
        totalRuntime: totalRuntime,
      );

  Future<void> completeDrumController({
    required String batchId,
    required String cycleId,
  }) =>
      _cycleService.completeDrumController(
        batchId: batchId,
        cycleId: cycleId,
      );

  Future<void> startAerator({
    required String batchId,
    required String cycleId,
    required int cycles,
    required String duration,
  }) =>
      _cycleService.startAerator(
        batchId: batchId,
        cycleId: cycleId,
        cycles: cycles,
        duration: duration,
      );

  Future<void> updateAeratorProgress({
    required String batchId,
    required String cycleId,
    required int completedCycles,
    required Duration totalRuntime,
  }) =>
      _cycleService.updateAeratorProgress(
        batchId: batchId,
        cycleId: cycleId,
        completedCycles: completedCycles,
        totalRuntime: totalRuntime,
      );

  Future<void> completeAerator({
    required String batchId,
    required String cycleId,
  }) =>
      _cycleService.completeAerator(
        batchId: batchId,
        cycleId: cycleId,
      );
}