// lib/services/machine_services/firestore_uploads.dart

//import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/machine_model.dart';
import 'firestore_collection.dart';


class MachineFirestoreUpload {

  // ==================== CRUD OPERATIONS ====================

  // Add a new machine
  static Future<void> addMachine(MachineModel machine) async {
    try {
      await MachineFirestoreCollections.getMachinesCollection()
          .doc(machine.machineId)
          .set(machine.toFirestore());
    } catch (e) {
      rethrow;
    }
  }

  /// Update machine details (Admin only)
  /// Can update: machineName, userId
  /// Cannot update: machineId (immutable), teamId (immutable)
  static Future<void> updateMachine(MachineModel machine) async {
    try {
      await MachineFirestoreCollections.getMachinesCollection()
          .doc(machine.machineId)
          .update({
            'machineName': machine.machineName,
            'userId': machine.userId,
            // Note: machineId and teamId are NOT updated (immutable)
          });
    } catch (e) {
      rethrow;
    }
  }

  // ==================== ARCHIVE OPERATIONS ====================

  // Update machine archive status
  static Future<void> updateMachineArchiveStatus(
    String machineId,
    bool isArchived,
  ) async {
    try {
      await MachineFirestoreCollections.getMachinesCollection()
          .doc(machineId)
          .update({'isArchived': isArchived});
    } catch (e) {
      rethrow;
    }
  }

  // "Delete" machine → move to archive instead of actual deletion
  static Future<void> archiveMachine(String machineId) async {
    try {
      final docRef = MachineFirestoreCollections.getMachinesCollection().doc(
        machineId,
      );
      final doc = await docRef.get();

      if (!doc.exists) return;
      await docRef.update({'isArchived': true});
    } catch (e) {
      rethrow;
    }
  }

  // Restore an archived machine
  static Future<void> restoreMachine(String machineId) async {
    try {
      final docRef = MachineFirestoreCollections.getMachinesCollection().doc(
        machineId,
      );
      final doc = await docRef.get();

      if (!doc.exists) return;
      await docRef.update({'isArchived': false});
    } catch (e) {
      rethrow;
    }
  }
}
