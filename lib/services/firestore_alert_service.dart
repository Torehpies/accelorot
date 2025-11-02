// firestore_alert_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreAlertService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fetch all alerts for a specific batch (e.g., "123456_03")
  static Future<List<Map<String, dynamic>>> fetchAlertsForBatch(String batchId) async {
    try {
      final alertsSnapshot = await _firestore
          .collection('batches')
          .doc(batchId)
          .collection('alerts')
          .orderBy('timestamp', descending: true)
          .get();

      // Return all alert documents as list of maps
      return alertsSnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'machine_id': data['machine_id'],
          'sensor_type': data['sensor_type'],
          'reading_value': data['reading_value'],
          'threshold': data['threshold'],
          'status': data['status'],
          'message': data['message'],
          'timestamp': data['timestamp'],
          'readings': data['readings'] ?? {},
        };
      }).toList();
    } catch (e) {
      return [];
    }
  }

  /// Fetch a specific alert document by its ID (e.g., "2025-10-30_21-05-47_temperature")
  static Future<Map<String, dynamic>?> fetchAlertById(String batchId, String alertId) async {
    try {
      final doc = await _firestore
          .collection('batches')
          .doc(batchId)
          .collection('alerts')
          .doc(alertId)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        return {
          'id': doc.id,
          'machine_id': data['machine_id'],
          'sensor_type': data['sensor_type'],
          'reading_value': data['reading_value'],
          'threshold': data['threshold'],
          'status': data['status'],
          'message': data['message'],
          'timestamp': data['timestamp'],
          'readings': data['readings'] ?? {},
        };
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  /// Listen to real-time updates for alerts within a batch
  static Stream<List<Map<String, dynamic>>> streamAlerts(String batchId) {
    return _firestore
        .collection('batches')
        .doc(batchId)
        .collection('alerts')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              return {
                'id': doc.id,
                'machine_id': data['machine_id'],
                'sensor_type': data['sensor_type'],
                'reading_value': data['reading_value'],
                'threshold': data['threshold'],
                'status': data['status'],
                'message': data['message'],
                'timestamp': data['timestamp'],
                'readings': data['readings'] ?? {},
              };
            }).toList());
  }
}
