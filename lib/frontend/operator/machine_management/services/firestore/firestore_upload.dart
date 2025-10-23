import 'package:cloud_firestore/cloud_firestore.dart';
import '../mock_data/machine_mock_data.dart';
import '../../models/machine_model.dart';
import 'firestore_collections.dart';

class MachineFirestoreUpload {
  // Upload mock machines to Firestore (only if none of the mock IDs exist)
  static Future<void> uploadAllMockMachines() async {
    try {
      // Check if all required mock machines already exist
      final allExist = await MachineFirestoreCollections.allMockMachinesExist();
      if (allExist) {
        print('✅ All mock machines already exist in Firestore. Skipping upload.');
        return;
      }

      await uploadMachines();
    } catch (e) {
      print('❌ Error uploading mock machines: $e');
      rethrow;
    }
  }

  // Force upload (deletes existing and re-uploads)
  static Future<void> forceUploadAllMockMachines() async {
    try {
      await MachineFirestoreCollections.deleteAllMachines();
      await uploadMachines();
    } catch (e) {
      print('❌ Error force uploading machines: $e');
      rethrow;
    }
  }

  // Upload machines from mock data
  static Future<void> uploadMachines() async {
    try {
      final mockData = MachineMockData.getMockMachines();
      final batch = FirebaseFirestore.instance.batch();

      for (var data in mockData) {
        final machine = MachineModel.fromMap(data);
        final docRef = MachineFirestoreCollections.getMachinesCollection()
            .doc(machine.machineId); // Use machineId as document ID

        batch.set(docRef, machine.toFirestore());
      }

      await batch.commit();
      print('✅ Successfully uploaded ${mockData.length} machines to Firestore');
    } catch (e) {
      print('❌ Error uploading machines: $e');
      rethrow;
    }
  }

  // Add a new machine
  static Future<void> addMachine(MachineModel machine) async {
    try {
      await MachineFirestoreCollections.getMachinesCollection()
          .doc(machine.machineId)
          .set(machine.toFirestore());
      print('✅ Machine ${machine.machineId} added successfully');
    } catch (e) {
      print('❌ Error adding machine: $e');
      rethrow;
    }
  }

  // Update machine archive status
  static Future<void> updateMachineArchiveStatus(
    String machineId,
    bool isArchived,
  ) async {
    try {
      await MachineFirestoreCollections.getMachinesCollection()
          .doc(machineId)
          .update({'isArchived': isArchived});
      print('✅ Machine $machineId archive status updated');
    } catch (e) {
      print('❌ Error updating machine: $e');
      rethrow;
    }
  }

  // "Delete" machine → move to archive instead of actual deletion
  static Future<void> archiveMachine(String machineId) async {
    try {
      final docRef = MachineFirestoreCollections.getMachinesCollection()
          .doc(machineId);
      final doc = await docRef.get();

      if (!doc.exists) {
        print('⚠️ Machine $machineId not found.');
        return;
      }

      // Mark as archived rather than removing
      await docRef.update({'isArchived': true});
      print('✅ Machine $machineId archived successfully');
    } catch (e) {
      print('❌ Error archiving machine: $e');
      rethrow;
    }
  }

  // Restore an archived machine
  static Future<void> restoreMachine(String machineId) async {
    try {
      final docRef = MachineFirestoreCollections.getMachinesCollection()
          .doc(machineId);
      final doc = await docRef.get();

      if (!doc.exists) {
        print('⚠️ Machine $machineId not found.');
        return;
      }

      await docRef.update({'isArchived': false});
      print('✅ Machine $machineId restored successfully');
    } catch (e) {
      print('❌ Error restoring machine: $e');
      rethrow;
    }
  }
}
