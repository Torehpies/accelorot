
import '../models/batch_model.dart';
import '../services/contracts/batch_service.dart';

/// Repository for batch-related operations
/// Wraps BatchService to provide data access layer
class BatchRepository {
  final BatchService _batchService;

  BatchRepository(this._batchService);

  /// Get batch ID for user and machine
  Future<String?> getBatchId(String userId, String machineId) =>
      _batchService.getBatchId(userId, machineId);

  /// Create a new batch
  Future<String> createBatch(
    String userId,
    String machineId,
    int batchNumber,
  ) =>
      _batchService.createBatch(userId, machineId, batchNumber);

  /// Update batch timestamp
  Future<void> updateBatchTimestamp(String batchId) =>
      _batchService.updateBatchTimestamp(batchId);

  /// Get user's team ID
  Future<String?> getUserTeamId(String userId) =>
      _batchService.getUserTeamId(userId);

  /// Get all machine IDs for a team
  Future<List<String>> getTeamMachineIds(String teamId) =>
      _batchService.getTeamMachineIds(teamId);

  /// Get all active batches for machines
  Future<List<BatchModel>> getBatchesForMachines(List<String> machineIds) async {
    final docs = await _batchService.getBatchesForMachines(machineIds);
    return docs.map((doc) => BatchModel.fromFirestore(doc)).toList();
  }

  /// Get active batch for a specific machine
  Future<BatchModel?> getActiveBatchForMachine(String machineId) async {
    final docs = await _batchService.getBatchesForMachines([machineId]);
    if (docs.isEmpty) return null;
    return BatchModel.fromFirestore(docs.first);
  }
}