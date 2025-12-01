// lib/data/services/contracts/batch_service.dart

/// Abstract interface for batch operations
/// Implementation: FirestoreBatchService
abstract class BatchService {
  /// Get batch ID for user and machine (returns null if not found)
  Future<String?> getBatchId(String userId, String machineId);
  
  /// Create a new batch (returns new batch ID)
  Future<String> createBatch(String userId, String machineId, int batchNumber);
  
  /// Update batch timestamp
  Future<void> updateBatchTimestamp(String batchId);
  
  /// Get user's team ID
  Future<String?> getUserTeamId(String userId);
  
  /// Get all machine IDs for a team
  Future<List<String>> getTeamMachineIds(String teamId);
}