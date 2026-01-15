// lib/data/services/firebase/firebase_alert_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../contracts/alert_service.dart';
import '../contracts/batch_service.dart';
import '../../models/alert.dart';

/// Firestore implementation of AlertService
/// Handles alert queries with team-aware logic
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

  // ===== FETCH OPERATIONS =====

  @override
  Future<List<Alert>> fetchTeamAlerts() async {
    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }

    try {
      // Get user's teamId
      final teamId = await _batchService.getUserTeamId(currentUserId!);

      // Team is required - no solo fallback
      if (teamId == null || teamId.isEmpty) {
        debugPrint('⚠️ User has no team assigned');
        return [];
      }

      // Fetch team-wide alerts
      final allAlerts = await _fetchTeamAlerts(teamId);

      // Sort by timestamp descending (newest first)
      allAlerts.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      debugPrint('✅ Fetched ${allAlerts.length} alerts');
      return allAlerts;
    } catch (e) {
      debugPrint('❌ Error fetching alerts: $e');
      throw Exception('Failed to fetch alerts: $e');
    }
  }

  /// Fetch alerts for team users (multi-step query)
  Future<List<Alert>> _fetchTeamAlerts(String teamId) async {
    final List<Alert> allAlerts = [];
    int successCount = 0;
    int failureCount = 0;

    // Get all machines belonging to this team
    final teamMachineIds = await _batchService.getTeamMachineIds(teamId);

    if (teamMachineIds.isEmpty) {
      debugPrint('ℹ️ No machines found for team: $teamId');
      return [];
    }

    // Get all batches for those machines
    final batches = await _batchService.getBatchesForMachines(teamMachineIds);

    if (batches.isEmpty) {
      debugPrint('ℹ️ No batches found for team machines');
      return [];
    }

    // Fetch alerts from each batch's subcollection in parallel
    final futures = batches.map((batchDoc) async {
      try {
        final alertsSnapshot = await _firestore
            .collection('batches')
            .doc(batchDoc.id)
            .collection('alerts')
            .orderBy('timestamp', descending: true)
            .get();

        final alerts = alertsSnapshot.docs
            .map((doc) => Alert.fromFirestore(doc))
            .toList();

        return {'success': true, 'alerts': alerts};
      } catch (e) {
        debugPrint('⚠️ Error fetching alerts from batch ${batchDoc.id}: $e');
        return {'success': false, 'alerts': <Alert>[]};
      }
    });

    final results = await Future.wait(futures);

    for (var result in results) {
      if (result['success'] as bool) {
        allAlerts.addAll(result['alerts'] as List<Alert>);
        successCount++;
      } else {
        failureCount++;
      }
    }

    debugPrint('📊 Fetched alerts from $successCount/${batches.length} batches ($failureCount failures)');
    return allAlerts;
  }

  @override
  Future<List<Alert>> fetchAlertsForBatch(String batchId) async {
    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }

    try {
      // PATH: batches/{batchId}/alerts
      final snapshot = await _firestore
          .collection('batches')
          .doc(batchId)
          .collection('alerts')
          .orderBy('timestamp', descending: true)
          .get();

      final alerts = snapshot.docs
          .map((doc) => Alert.fromFirestore(doc))
          .toList();

      debugPrint('✅ Fetched ${alerts.length} alerts for batch: $batchId');
      return alerts;
    } catch (e) {
      debugPrint('❌ Error fetching batch alerts: $e');
      throw Exception('Failed to fetch batch alerts: $e');
    }
  }

  @override
  Stream<List<Alert>> streamAlerts(String batchId) {
    // PATH: batches/{batchId}/alerts
    return _firestore
        .collection('batches')
        .doc(batchId)
        .collection('alerts')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Alert.fromFirestore(doc)).toList());
  }

// Fetch a single alert by ID
@override
Future<Alert?> fetchAlertById(String alertId) async {
  if (currentUserId == null) {
    throw Exception('User not authenticated');
  }

  try {
    // Get user's teamId
    final teamId = await _batchService.getUserTeamId(currentUserId!);

    if (teamId == null || teamId.isEmpty) {
      debugPrint('⚠️ User has no team assigned');
      return null;
    }

    // Get all machines belonging to this team
    final teamMachineIds = await _batchService.getTeamMachineIds(teamId);

    if (teamMachineIds.isEmpty) {
      debugPrint('ℹ️ No machines found for team: $teamId');
      return null;
    }

    // Get all batches for those machines
    final batches = await _batchService.getBatchesForMachines(teamMachineIds);

    if (batches.isEmpty) {
      debugPrint('ℹ️ No batches found for team machines');
      return null;
    }

    // Search each batch for the alert
    for (var batchDoc in batches) {
      try {
        final alertDoc = await _firestore
            .collection('batches')
            .doc(batchDoc.id)
            .collection('alerts')
            .doc(alertId)
            .get();

        if (alertDoc.exists) {
          debugPrint('✅ Found alert: $alertId in batch: ${batchDoc.id}');
          return Alert.fromFirestore(alertDoc);
        }
      } catch (e) {
        debugPrint('⚠️ Error checking batch ${batchDoc.id}: $e');
        continue;
      }
    }

    debugPrint('ℹ️ Alert not found: $alertId');
    return null;
  } catch (e) {
    debugPrint('❌ Error fetching alert by ID: $e');
    throw Exception('Failed to fetch alert: $e');
  }
}
}

