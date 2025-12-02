// lib/data/services/firebase/firestore_cycle_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../contracts/cycle_service.dart';
import '../contracts/batch_service.dart';
import '../../models/cycle_recommendation.dart';

class FirestoreCycleService implements CycleService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final BatchService _batchService;

  FirestoreCycleService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    required BatchService batchService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _batchService = batchService;

  /// Get current authenticated user ID
  String? get currentUserId => _auth.currentUser?.uid;

  CollectionReference get _cyclesCollection =>
      _firestore.collection('cycle_recommendations');

  @override
  Future<List<CycleRecommendation>> fetchTeamCycles() async {
    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }

    final teamId = await _getTeamId(currentUserId!);

    try {
      final snapshot = await _cyclesCollection
          .where('teamId', isEqualTo: teamId)
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => CycleRecommendation.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch cycles: $e');
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