// lib/services/machine_services/firestore_collection.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class MachineFirestoreCollections {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  static String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }

  // Collection References
  static CollectionReference getMachinesCollection() {
    return _firestore.collection('machines');
  }

  static CollectionReference getUsersCollection() {
    return _firestore.collection('users');
  }

  static CollectionReference getTeamsCollection() {
    return _firestore.collection('teams');
  }

  /// Get team members subcollection for a specific team
  /// Path: teams/{teamId}/members
  static CollectionReference getTeamMembersCollection(String teamId) {
    return _firestore.collection('teams').doc(teamId).collection('members');
  }


  // Check if any machine exists (generic)
  static Future<bool> machineDataExists() async {
    try {
      final snapshot = await getMachinesCollection().limit(1).get();
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Check if specific machine exists by machineId
  static Future<bool> machineExists(String machineId) async {
    try {
      final doc = await getMachinesCollection().doc(machineId).get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  // Delete all machines (for testing/reset)
  static Future<void> deleteAllMachines() async {
    try {
      final snapshot = await getMachinesCollection().get();
      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      rethrow;
    }
  }
}
