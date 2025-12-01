// lib/data/services/firebase/activity_logs/firestore_alert_service.dart

import '../../models/alert.dart';
import '../contracts/alert_service.dart';
import '../contracts/batch_service.dart';
import 'firestore_collections.dart';

/// Firestore implementation of AlertService
class FirestoreAlertService implements AlertService {
  final BatchService _batchService;

  FirestoreAlertService(this._batchService);

  @override
  Future<List<Alert>> fetchTeamAlerts(String teamId) async {
    // Get all machines for this team
    final teamMachineIds = await _batchService.getTeamMachineIds(teamId);

    if (teamMachineIds.isEmpty) return [];

    // Get all batches for these machines
    final batchesSnapshot = await FirestoreCollections.batches
        .where('machineId', whereIn: teamMachineIds)
        .get();

    List<Alert> allAlerts = [];

    // Fetch alerts from each batch
    for (var batchDoc in batchesSnapshot.docs) {
      final alertsSnapshot =
          await FirestoreCollections.alerts(batchDoc.id).get();

      final alerts = alertsSnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Alert.fromMap(data);
      }).toList();

      allAlerts.addAll(alerts);
    }

    // Sort by timestamp descending
    allAlerts.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return allAlerts;
  }

  @override
  Future<List<Alert>> fetchAlertsForBatch(String batchId) async {
    final alertsSnapshot = await FirestoreCollections.alerts(batchId)
        .orderBy('timestamp', descending: true)
        .get();

    return alertsSnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return Alert.fromMap(data);
    }).toList();
  }

  @override
  Stream<List<Alert>> streamAlerts(String batchId) {
    return FirestoreCollections.alerts(batchId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              data['id'] = doc.id;
              return Alert.fromMap(data);
            }).toList());
  }
}