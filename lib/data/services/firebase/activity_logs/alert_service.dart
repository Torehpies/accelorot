// lib/data/services/firebase/activity_logs/alert_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../models/alert.dart';
import 'batch_service.dart';

/// Service for alert operations
class AlertService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ===== FETCH OPERATIONS =====

  /// Fetch all alerts for a user (includes team-wide if user has teamId)
  static Future<List<Alert>> fetchAlerts(String userId) async {
    try {
      userId = BatchService.resolveUserId(userId);

      // Get user's teamId to fetch team-wide activities
      final teamId = await BatchService.getUserTeamId(userId);

      List<Alert> allAlerts = [];

      if (teamId != null && teamId.isNotEmpty) {
        // Fetch team-wide alerts
        debugPrint('🔍 Fetching team-wide alerts for teamId: $teamId');

        // Get all machines for this team
        final teamMachineIds = await BatchService.getTeamMachineIds(teamId);

        if (teamMachineIds.isNotEmpty) {
          // Get all batches for these machines
          final batches = await BatchService.getBatchesForMachines(
            teamMachineIds,
          );

          // Fetch alerts from each batch's alerts subcollection
          for (var batchDoc in batches) {
            try {
              final alertsSnapshot = await _firestore
                  .collection('batches')
                  .doc(batchDoc.id)
                  .collection('alerts')
                  .get();

              final alerts = alertsSnapshot.docs.map((doc) {
                final data = doc.data();
                data['id'] = doc.id;
                return Alert.fromMap(data);
              }).toList();

              allAlerts.addAll(alerts);
            } catch (e) {
              debugPrint('Error fetching alerts from batch ${batchDoc.id}: $e');
            }
          }
        }
      } else {
        // Fallback: Get only current user's batches
        final batches = await BatchService.getBatchesForUser(userId);

        for (var batchDoc in batches) {
          try {
            final alertsSnapshot = await _firestore
                .collection('batches')
                .doc(batchDoc.id)
                .collection('alerts')
                .get();

            final alerts = alertsSnapshot.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return Alert.fromMap(data);
            }).toList();

            allAlerts.addAll(alerts);
          } catch (e) {
            debugPrint('Error fetching alerts from batch ${batchDoc.id}: $e');
          }
        }
      }

      // Sort by timestamp descending
      allAlerts.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      debugPrint(
        '✅ Fetched ${allAlerts.length} alerts for ${teamId != null ? "team: $teamId" : "user: $userId"}',
      );

      return allAlerts;
    } catch (e) {
      debugPrint('Error fetching alerts: $e');
      rethrow;
    }
  }

  /// Fetch alerts for a specific batch (used by existing FirestoreAlertService pattern)
  static Future<List<Alert>> fetchAlertsForBatch(String batchId) async {
    try {
      final alertsSnapshot = await _firestore
          .collection('batches')
          .doc(batchId)
          .collection('alerts')
          .orderBy('timestamp', descending: true)
          .get();

      return alertsSnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Alert.fromMap(data);
      }).toList();
    } catch (e) {
      debugPrint('Error fetching alerts for batch $batchId: $e');
      return [];
    }
  }

  /// Fetch a specific alert by ID
  static Future<Alert?> fetchAlertById(String batchId, String alertId) async {
    try {
      final doc = await _firestore
          .collection('batches')
          .doc(batchId)
          .collection('alerts')
          .doc(alertId)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        data['id'] = doc.id;
        return Alert.fromMap(data);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching alert $alertId: $e');
      return null;
    }
  }

  // ===== STREAM OPERATIONS =====

  /// Stream real-time alerts for a batch
  static Stream<List<Alert>> streamAlerts(String batchId) {
    return _firestore
        .collection('batches')
        .doc(batchId)
        .collection('alerts')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return Alert.fromMap(data);
            }).toList());
  }
}