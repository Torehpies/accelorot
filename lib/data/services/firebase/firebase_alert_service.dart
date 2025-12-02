// lib/data/services/firebase/firestore_alert_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../contracts/alert_service.dart';
import '../contracts/batch_service.dart';
import '../../models/alert.dart';

class FirestoreAlertService implements AlertService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final BatchService _batchService;

  FirestoreAlertService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    required BatchService batchService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _batchService = batchService;

  /// Get current authenticated user ID
  String? get currentUserId => _auth.currentUser?.uid;

  CollectionReference get _alertsCollection =>
      _firestore.collection('alerts');

  @override
  Future<List<Alert>> fetchTeamAlerts() async {
    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }

    final teamId = await _getTeamId(currentUserId!);

    try {
      final snapshot = await _alertsCollection
          .where('teamId', isEqualTo: teamId)
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Alert.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch alerts: $e');
    }
  }

  @override
  Future<List<Alert>> fetchAlertsForBatch(String batchId) async {
    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }

    try {
      final snapshot = await _alertsCollection
          .where('batchId', isEqualTo: batchId)
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Alert.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch batch alerts: $e');
    }
  }

  @override
  Stream<List<Alert>> streamAlerts(String batchId) {
    return _alertsCollection
        .where('batchId', isEqualTo: batchId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Alert.fromFirestore(doc)).toList());
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