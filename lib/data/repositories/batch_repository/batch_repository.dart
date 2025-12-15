import '../../models/batch_model.dart';


abstract class BatchRepository {

  Future<String?> getBatchId(String userId, String machineId);


  Future<String> createBatch(
    String userId,
    String machineId,
    int batchNumber,
  );


  Future<void> updateBatchTimestamp(String batchId);
  Future<String?> getUserTeamId(String userId);

  /// Get all machine IDs for a team
  Future<List<String>> getTeamMachineIds(String teamId);

  /// Get all active batches for machines
  Future<List<BatchModel>> getBatchesForMachines(List<String> machineIds);
  Future<BatchModel?> getActiveBatchForMachine(String machineId);
}