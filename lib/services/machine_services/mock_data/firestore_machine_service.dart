import '../../../frontend/operator/machine_management/models/machine_model.dart';
import '../firestore/firestore_collection.dart';
import '../firestore/firestore_uploads.dart';
import '../firestore/firestore_fetchs.dart';

/// Main service class for machine management with Firestore.
/// Provides a unified API for all machine operations.
class FirestoreMachineService {
  // ==================== AUTH & COLLECTIONS ====================
  static String? getCurrentUserId() =>
      MachineFirestoreCollections.getCurrentUserId();

  static Future<bool> machineDataExists() =>
      MachineFirestoreCollections.machineDataExists();

  static Future<bool> machineExists(String machineId) =>
      MachineFirestoreCollections.machineExists(machineId);

  // ==================== UPLOAD METHODS ====================
  static Future<void> uploadAllMockMachines() =>
      MachineFirestoreUpload.uploadAllMockMachines();

  static Future<void> forceUploadAllMockMachines() =>
      MachineFirestoreUpload.forceUploadAllMockMachines();

  static Future<void> addMachine(MachineModel machine) =>
      MachineFirestoreUpload.addMachine(machine);

  static Future<void> updateMachineArchiveStatus(
    String machineId,
    bool isArchived,
  ) =>
      MachineFirestoreUpload.updateMachineArchiveStatus(
          machineId, isArchived);

  // Archive instead of deleting permanently
  static Future<void> deleteMachine(String machineId) =>
      MachineFirestoreUpload.archiveMachine(machineId);

  // Restore machine from archive
  static Future<void> restoreMachine(String machineId) =>
      MachineFirestoreUpload.restoreMachine(machineId);

  // ==================== FETCH METHODS ====================
  static Future<List<MachineModel>> getActiveMachines() =>
      MachineFirestoreFetch.getActiveMachines();

  static Future<List<MachineModel>> getArchivedMachines() =>
      MachineFirestoreFetch.getArchivedMachines();

  static Future<List<MachineModel>> getAllMachines() =>
      MachineFirestoreFetch.getAllMachines();

  static Future<MachineModel?> getMachineById(String machineId) =>
      MachineFirestoreFetch.getMachineById(machineId);

  static Future<Map<String, dynamic>?> getUserById(String userId) =>
      MachineFirestoreFetch.getUserById(userId);

  static Future<List<Map<String, dynamic>>> getOperatorsAndAdmins() =>
      MachineFirestoreFetch.getOperatorsAndAdmins();
}
