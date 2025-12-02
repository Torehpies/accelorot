// lib/data/services/firebase/firestore_batch_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../contracts/batch_service.dart';

/// Firestore implementation of BatchService
class FirestoreBatchService implements BatchService {
  final FirebaseFirestore _firestore;

  FirestoreBatchService(this._firestore);

  // Direct collection references
  CollectionReference get _batches => _firestore.collection('batches');
  CollectionReference get _users => _firestore.collection('users');
  CollectionReference get _machines => _firestore.collection('machines');

  @override
  Future<String?> getBatchId(String userId, String machineId) async {
    final batchQuery = await _batches
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
    final batchRef = _batches.doc(batchId);

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
    await _batches.doc(batchId).update({
      'updatedAt': Timestamp.now(),
    });
  }

  @override
  Future<String?> getUserTeamId(String userId) async {
    final userDoc = await _users.doc(userId).get();

    if (userDoc.exists) {
      final data = userDoc.data() as Map<String, dynamic>?;
      return data?['teamId'] as String?;
    }
    return null;
  }

  @override
  Future<List<String>> getTeamMachineIds(String teamId) async {
    final machinesSnapshot = await _machines
        .where('teamId', isEqualTo: teamId)
        .get();

    return machinesSnapshot.docs.map((doc) => doc.id).toList();
  }
}