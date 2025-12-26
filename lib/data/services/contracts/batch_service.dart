import 'package:cloud_firestore/cloud_firestore.dart';

/// Abstract interface for batch operations
/// Implementation: FirestoreBatchService
abstract class BatchService {
  /// Get batch ID for user and machine (returns null if not found)
  Future<String?> getBatchId(String userId, String machineId);
  
  /// Create a new batch (returns new batch ID)
  Future<String> createBatch(
    String userId,
    String machineId,
    int batchNumber, {
    String? batchName,
    String? startNotes,
  });
  
  /// Update batch timestamp
  Future<void> updateBatchTimestamp(String batchId);
  
  /// Complete a batch with final details
  Future<void> completeBatch(
    String batchId, {
    required double finalWeight,
    String? completionNotes,
  });
  
  /// Get user's team ID
  Future<String?> getUserTeamId(String userId);
  
  /// Get all machine IDs for a team
  Future<List<String>> getTeamMachineIds(String teamId);
  
  /// Get all active batches for a list of machine IDs
  /// Handles Firestore's whereIn limit (10 items) automatically
  Future<List<QueryDocumentSnapshot>> getBatchesForMachines(
    List<String> machineIds,
  );
}