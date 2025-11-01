//firestore_fetchs.dart

import '../../frontend/operator/machine_management/models/machine_model.dart';
import 'firestore_collection.dart';

class MachineFirestoreFetch {
  // ==================== OPERATOR METHODS ====================
  
  /// Fetch machines for an operator by looking up their teamId
  /// 1. Query teams/{teamId}/members where userId matches operatorId
  /// 2. Get teamId from the member document
  /// 3. Fetch all machines with that teamId + mock data (empty teamId)
  static Future<List<MachineModel>> getMachinesByOperatorId(String operatorId) async {
    try {
      // Step 1: Find which team this operator belongs to
      final teamsSnapshot = await MachineFirestoreCollections.getTeamsCollection().get();
      
      String? operatorTeamId;
      
      for (var teamDoc in teamsSnapshot.docs) {
        final membersSnapshot = await MachineFirestoreCollections
            .getTeamMembersCollection(teamDoc.id)
            .where('userId', isEqualTo: operatorId)
            .limit(1)
            .get();
        
        if (membersSnapshot.docs.isNotEmpty) {
          operatorTeamId = teamDoc.id;
          break;
        }
      }
      
      // Step 2: If operator belongs to a team, fetch team machines
      if (operatorTeamId != null) {
        return await getMachinesByTeamId(operatorTeamId);
      }
      
      // Step 3: If no team found, return empty list
      return [];
    } catch (e) {
      return [];
    }
  }

  // ==================== ADMIN METHODS ====================
  
  /// Fetch machines by teamId OR empty teamId (for Admins and Operators)
  /// Shows: machines with their teamId + mock data (empty teamId)
  static Future<List<MachineModel>> getMachinesByTeamId(String teamId) async {
    try {
      // Get machines with matching teamId
      final ownTeamSnapshot = await MachineFirestoreCollections.getMachinesCollection()
          .where('teamId', isEqualTo: teamId)
          .orderBy('dateCreated', descending: true)
          .get();

      // Get machines with empty teamId (mock data visible to all)
      final mockDataSnapshot = await MachineFirestoreCollections.getMachinesCollection()
          .where('teamId', isEqualTo: '')
          .orderBy('dateCreated', descending: true)
          .get();

      // Combine both lists and remove duplicates (just in case)
      final allDocs = [...ownTeamSnapshot.docs, ...mockDataSnapshot.docs];
      final uniqueDocs = allDocs.toSet().toList();
      
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

  // ==================== TEAM MEMBER FETCH METHODS ====================
  
  /// Fetch all members from a specific team (for Admin dropdown)
  /// Returns members from teams/{teamId}/members subcollection
  /// Filters out archived members
  static Future<List<Map<String, dynamic>>> getTeamMembers(String teamId) async {
    try {
      final snapshot = await MachineFirestoreCollections.getTeamMembersCollection(teamId)
          .where('isArchived', isEqualTo: false)
          .get();

      return snapshot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return {
              'uid': data['userId'] ?? doc.id,
              'memberId': doc.id,
              'name': data['name'] ?? 'Unknown',
              'role': data['role'] ?? 'Unknown',
              'email': data['email'] ?? '',
              ...data,
            };
          })
          .toList();
    } catch (e) {
      return [];
    }
  }
}