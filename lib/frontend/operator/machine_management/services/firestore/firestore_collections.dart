import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../mock_data/machine_mock_data.dart';

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

  // Check if all mock machine data already exists
  static Future<bool> allMockMachinesExist() async {
    try {
      final mockData = MachineMockData.getMockMachines();
      final mockIds = mockData.map((data) => data['machineId'] as String).toList();

      for (final id in mockIds) {
        final doc = await getMachinesCollection().doc(id).get();
        if (!doc.exists) {
          // Found at least one missing mock machine
          return false;
        }
      }
      return true; // All mock machines exist
    } catch (e) {
      print('❌ Error checking mock data existence: $e');
      return false;
    }
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
