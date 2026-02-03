import 'batch_repository.dart';
import '../../models/batch_model.dart';
import '../../services/contracts/batch_service.dart';

class BatchRepositoryRemote implements BatchRepository {
  final BatchService _batchService;

  BatchRepositoryRemote(this._batchService);

  @override
  Future<String?> getBatchId(String userId, String machineId) =>
      _batchService.getBatchId(userId, machineId);

  @override
  Future<String> createBatch(
    String userId,
    String machineId,
    int batchNumber, {
    String? batchName,
    String? startNotes,
  }) => _batchService.createBatch(
    userId,
    machineId,
    batchNumber,
    batchName: batchName,
    startNotes: startNotes,
  );

  @override
  Future<void> updateBatchTimestamp(String batchId) =>
      _batchService.updateBatchTimestamp(batchId);

  @override
  Future<void> completeBatch(
    String batchId, {
    required double finalWeight,
    String? completionNotes,
  }) => _batchService.completeBatch(
    batchId,
    finalWeight: finalWeight,
    completionNotes: completionNotes,
  );

  @override
  Future<String?> getUserTeamId(String userId) =>
      _batchService.getUserTeamId(userId);

  @override
  Future<List<String>> getTeamMachineIds(String teamId) =>
      _batchService.getTeamMachineIds(teamId);

  @override
  Future<List<BatchModel>> getBatchesForMachines(
    List<String> machineIds,
  ) async {
    final docs = await _batchService.getBatchesForMachines(machineIds);
    return docs.map((doc) => BatchModel.fromFirestore(doc)).toList();
  }

  @override
  Future<BatchModel?> getActiveBatchForMachine(String machineId) async {
    final docs = await _batchService.getBatchesForMachines([machineId]);
    if (docs.isEmpty) return null;
    return BatchModel.fromFirestore(docs.first);
  }
}
