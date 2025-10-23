// lib/services/machine_services/firestore/firestore_fetchs.dart

import '../../../frontend/operator/machine_management/models/machine_model.dart';
import 'firestore_collection.dart';

class MachineFirestoreFetch {
  // ==================== OPERATOR METHODS ====================
  
  /// Fetch machines assigned to a specific user (for Operators)
  /// Returns all machines where userId matches the provided userId
  static Future<List<MachineModel>> getMachinesByUserId(String userId) async {
    try {
      final snapshot = await MachineFirestoreCollections.getMachinesCollection()
          .where('userId', isEqualTo: userId)
          .orderBy('dateCreated', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => MachineModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // ==================== ADMIN METHODS ====================
  
  /// Fetch machines by teamId OR empty teamId (for Admins)
  /// Admins see: machines with their teamId + mock data (empty teamId)
  static Future<List<MachineModel>> getMachinesByTeamId(String teamId) async {
    try {
      // Get machines with matching teamId
      final ownTeamSnapshot = await MachineFirestoreCollections.getMachinesCollection()
          .where('teamId', isEqualTo: teamId)
          .orderBy('dateCreated', descending: true)
          .get();

      // Get machines with empty teamId (mock data visible to all admins)
      final mockDataSnapshot = await MachineFirestoreCollections.getMachinesCollection()
          .where('teamId', isEqualTo: '')
          .orderBy('dateCreated', descending: true)
          .get();

      // Combine both lists and remove duplicates (just in case)
      final allDocs = [...ownTeamSnapshot.docs, ...mockDataSnapshot.docs];
      final uniqueDocs = allDocs.toSet().toList(); // Remove any duplicates
      
      return uniqueDocs
          .map((doc) => MachineModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // ==================== GENERAL FETCH METHODS ====================
  
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

  // ==================== USER FETCH METHODS ====================
  
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

  // Fetch all users with role Operator (for dropdown in add/edit machine)
  static Future<List<Map<String, dynamic>>> getOperators() async {
    try {
      final snapshot = await MachineFirestoreCollections.getUsersCollection()
          .where('role', whereIn: ['Operator'])
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