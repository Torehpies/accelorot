// lib/data/services/firebase/activity_logs/firestore_batch_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../contracts/batch_service.dart';
import 'firestore_collections.dart';

/// Firestore implementation of BatchService
class FirestoreBatchService implements BatchService {
  final FirebaseFirestore _firestore;

  FirestoreBatchService(this._firestore);

  @override
  Future<String?> getBatchId(String userId, String machineId) async {
    final batchQuery = await FirestoreCollections.batches
        .where('userId', isEqualTo: userId)
        .where('machineId', isEqualTo: machineId)
        .where('isActive', isEqualTo: true)
        .limit(1)
        .get();

    if (batchQuery.docs.isNotEmpty) {
      return batchQuery.docs.first.id;
    }
    return null;
  }

  @override
  Future<String> createBatch(String userId, String machineId, int batchNumber) async {
    final batchId = '${machineId}_batch_$batchNumber';
    final batchRef = FirestoreCollections.batches.doc(batchId);

    await batchRef.set({
      'userId': userId,
      'machineId': machineId,
      'batchNumber': batchNumber,
      'isActive': true,
      'createdAt': Timestamp.now(),
      'updatedAt': Timestamp.now(),
    });

    return batchId;
  }

  @override
  Future<void> updateBatchTimestamp(String batchId) async {
    await FirestoreCollections.batches.doc(batchId).update({
      'updatedAt': Timestamp.now(),
    });
  }

  @override
  Future<String?> getUserTeamId(String userId) async {
    final userDoc = await _firestore.collection('users').doc(userId).get();

    if (userDoc.exists) {
      return userDoc.data()?['teamId'] as String?;
    }
    return null;
  }

  @override
  Future<List<String>> getTeamMachineIds(String teamId) async {
    final machinesSnapshot = await _firestore
        .collection('machines')
        .where('teamId', isEqualTo: teamId)
        .get();

    return machinesSnapshot.docs.map((doc) => doc.id).toList();
  }
}