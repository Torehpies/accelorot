// lib/frontend/operator/machine_management/services/firestore/firestore_fetch.dart

import '../../../frontend/operator/machine_management/models/machine_model.dart';
import 'firestore_collection.dart';

class MachineFirestoreFetch {
  // Fetch all active machines
  static Future<List<MachineModel>> getActiveMachines() async {
    try {
      final snapshot = await MachineFirestoreCollections.getMachinesCollection()
          .where('isArchived', isEqualTo: false)
          .orderBy('dateCreated', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => MachineModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // Fetch all archived machines
  static Future<List<MachineModel>> getArchivedMachines() async {
    try {
      final snapshot = await MachineFirestoreCollections.getMachinesCollection()
          .where('isArchived', isEqualTo: true)
          .orderBy('dateCreated', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => MachineModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // Fetch all machines (active + archived)
  static Future<List<MachineModel>> getAllMachines() async {
    try {
      final snapshot = await MachineFirestoreCollections.getMachinesCollection()
          .orderBy('dateCreated', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => MachineModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // Fetch single machine by ID
  static Future<MachineModel?> getMachineById(String machineId) async {
    try {
      final doc = await MachineFirestoreCollections.getMachinesCollection()
          .doc(machineId)
          .get();

      if (doc.exists) {
        return MachineModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Fetch user data by userId (for displaying user name in machines)
  static Future<Map<String, dynamic>?> getUserById(String userId) async {
    try {
      final doc = await MachineFirestoreCollections.getUsersCollection()
          .doc(userId)
          .get();

      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Fetch all users with role Operator or Admin (for dropdown)
  static Future<List<Map<String, dynamic>>> getOperatorsAndAdmins() async {
    try {
      final snapshot = await MachineFirestoreCollections.getUsersCollection()
          .where('role', whereIn: ['Operator', 'Admin'])
          .get();

      return snapshot.docs
          .map((doc) => {
                'uid': doc.id,
                ...doc.data() as Map<String, dynamic>,
              })
          .toList();
    } catch (e) {
      return [];
    }
  }
}
