// lib/data/services/firebase/firestore_substrate_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../contracts/substrate_service.dart';
import '../contracts/batch_service.dart';
import '../../models/substrate.dart';

class FirestoreSubstrateService implements SubstrateService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final BatchService _batchService;

  FirestoreSubstrateService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    required BatchService batchService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _batchService = batchService;

  /// Get current authenticated user ID
  String? get currentUserId => _auth.currentUser?.uid;

  CollectionReference get _substratesCollection =>
      _firestore.collection('substrates');

  @override
  Future<List<Substrate>> fetchTeamSubstrates() async {
    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }

    final teamId = await _getTeamId(currentUserId!);

    try {
      final snapshot = await _substratesCollection
          .where('teamId', isEqualTo: teamId)
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Substrate.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch substrates: $e');
    }
  }

  @override
  Future<void> addSubstrate(Map<String, dynamic> data) async {
    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }

    final machineId = data['machineId'];
    if (machineId == null || machineId.toString().isEmpty) {
      throw Exception('Machine ID is required');
    }

    try {
      // Get or create batch
      String batchId = await _batchService.getBatchId(currentUserId!, machineId) ??
          await _batchService.createBatch(currentUserId!, machineId, 1);

      // Add substrate with metadata
      await _substratesCollection.add({
        ...data,
        'batchId': batchId,
        'createdBy': currentUserId,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Update batch timestamp
      await _batchService.updateBatchTimestamp(batchId);
    } catch (e) {
      throw Exception('Failed to add substrate: $e');
    }
  }

  /// Helper: Get team ID for the current user
  Future<String> _getTeamId(String userId) async {
    final teamId = await _batchService.getUserTeamId(userId);
    if (teamId == null || teamId.isEmpty) {
      throw Exception('User is not part of any team');
    }
    return teamId;
  }
}