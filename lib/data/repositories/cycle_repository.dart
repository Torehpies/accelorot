import '../models/cycle_recommendation.dart';
import '../services/contracts/cycle_service.dart';

class CycleRepository {
  final CycleService _cycleService;

  CycleRepository(this._cycleService);

  Future<List<CycleRecommendation>> getTeamCycles() =>
      _cycleService.fetchTeamCycles();

  Future<CycleRecommendation?> getDrumController({
    required String batchId,
  }) =>
      _cycleService.getDrumController(batchId: batchId);

  Future<CycleRecommendation?> getAerator({
    required String batchId,
  }) =>
      _cycleService.getAerator(batchId: batchId);

  Future<String> startDrumController({
    required String batchId,
    required String machineId,
    required String userId,
    required int activeMinutes,
    required int restMinutes,
  }) =>
      _cycleService.startDrumController(
        batchId: batchId,
        machineId: machineId,
        userId: userId,
        activeMinutes: activeMinutes,
        restMinutes: restMinutes,
      );

  Future<void> completeDrumController({
    required String batchId,
  }) =>
      _cycleService.completeDrumController(batchId: batchId);

  Future<String> startAerator({
    required String batchId,
    required String machineId,
    required String userId,
    required int activeMinutes,
    required int restMinutes,
  }) =>
      _cycleService.startAerator(
        batchId: batchId,
        machineId: machineId,
        userId: userId,
        activeMinutes: activeMinutes,
        restMinutes: restMinutes,
      );

  Future<void> completeAerator({
    required String batchId,
  }) =>
      _cycleService.completeAerator(batchId: batchId);

  /// Update drum controller phase (for countdown sync)
  Future<void> updateDrumPhase({
    required String batchId,
    required String newPhase,
  }) =>
      _cycleService.updateDrumPhase(
        batchId: batchId,
        newPhase: newPhase,
      );

  /// Update aerator phase (for countdown sync)
  Future<void> updateAeratorPhase({
    required String batchId,
    required String newPhase,
  }) =>
      _cycleService.updateAeratorPhase(
        batchId: batchId,
        newPhase: newPhase,
      );

  /// Get a single cycle by ID
  Future<CycleRecommendation?> getCycle(String id) =>
      _cycleService.fetchCycleById(id);
}