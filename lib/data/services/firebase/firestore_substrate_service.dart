// lib/data/services/firebase/activity_logs/firestore_substrate_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/substrate.dart';
import '../contracts/substrate_service.dart';
import '../contracts/batch_service.dart';
import 'firestore_collections.dart';

/// Firestore implementation of SubstrateService
class FirestoreSubstrateService implements SubstrateService {
  final FirebaseFirestore _firestore;
  final BatchService _batchService;

  FirestoreSubstrateService(this._firestore, this._batchService);

  @override
  Future<List<Substrate>> fetchTeamSubstrates(String teamId) async {
    // Get all machines for this team
    final teamMachineIds = await _batchService.getTeamMachineIds(teamId);

    if (teamMachineIds.isEmpty) return [];

    // Get all batches for these machines
    final batchesSnapshot = await FirestoreCollections.batches
        .where('machineId', whereIn: teamMachineIds)
        .get();

    List<Substrate> allSubstrates = [];

    // Fetch substrates from each batch
    for (var batchDoc in batchesSnapshot.docs) {
      final substratesSnapshot =
          await FirestoreCollections.substrates(batchDoc.id).get();

      final substrates = substratesSnapshot.docs
          .map((doc) => Substrate.fromFirestore(doc))
          .toList();

      allSubstrates.addAll(substrates);
    }

    // Sort by timestamp descending
    allSubstrates.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return allSubstrates;
  }

  @override
  Future<void> addSubstrate(Map<String, dynamic> data, String batchId) async {
    final userId = data['userId'];
    final machineId = data['machineId'];
    final category = data['category'];
    final timestamp = data['timestamp'] as DateTime;

    // Fetch machine name
    String? machineName;
    final machineDoc = await _firestore.collection('machines').doc(machineId).get();
    if (machineDoc.exists) {
      machineName = machineDoc.data()?['machineName'];
    }

    // Fetch operator name
    String operatorName = 'Unknown';
    final userDoc = await _firestore.collection('users').doc(userId).get();
    if (userDoc.exists) {
      final userData = userDoc.data();
      final firstName = userData?['firstname'] ?? '';
      final lastName = userData?['lastname'] ?? '';
      operatorName = '$firstName $lastName'.trim();
      if (operatorName.isEmpty) {
        operatorName = userData?['email'] ?? 'Unknown';
      }
    }

    // Create document
    final docId = '${timestamp.millisecondsSinceEpoch}_$userId';
    final docRef = FirestoreCollections.substrates(batchId).doc(docId);

    // Save data (NO statusColor or icon)
    final firestoreData = {
      'title': data['plantTypeLabel'],
      'value': '${data['quantity']}kg',
      'description': data['description'],
      'category': category,
      'timestamp': Timestamp.fromDate(timestamp),
      'userId': userId,
      'machineId': machineId,
      'machineName': machineName ?? 'Unknown Machine',
      'operatorName': operatorName,
      'batchId': batchId,
    };

    await docRef.set(firestoreData);
  }
}