//firestore_uploads.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../frontend/operator/machine_management/models/machine_model.dart';
import 'firestore_collection.dart';
import 'machine_mock_data.dart';

class MachineFirestoreUpload {
  // ==================== MOCK DATA UPLOAD ====================

  // Upload mock machines to Firestore (only if none of the mock IDs exist)
  static Future<void> uploadAllMockMachines() async {
    try {
      final allExist = await MachineFirestoreCollections.allMockMachinesExist();
      if (allExist) return;
      await uploadMachines();
    } catch (e) {
      rethrow;
    }
  }

  // Force upload (deletes existing and re-uploads)
  static Future<void> forceUploadAllMockMachines() async {
    try {
      await MachineFirestoreCollections.deleteAllMachines();
      await uploadMachines();
    } catch (e) {
      rethrow;
    }
  }

  // Upload machines from mock data
  // Upload machines from mock data
  static Future<void> uploadMachines() async {
    try {
      final mockData = MachineMockData.getMockMachines();
      final batch = FirebaseFirestore.instance.batch();

      for (var data in mockData) {
        final machine = MachineModel.fromMap(data);

        // Check if machine already exists to prevent duplicates
        final exists = await MachineFirestoreCollections.machineExists(
          machine.machineId,
        );

        if (!exists) {
          final docRef = MachineFirestoreCollections.getMachinesCollection()
              .doc(machine.machineId);
          batch.set(docRef, machine.toFirestore());
        }
      }

      await batch.commit();
    } catch (e) {
      rethrow;
    }
  }

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
