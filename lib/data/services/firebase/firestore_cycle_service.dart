// lib/data/services/firebase/activity_logs/firestore_cycle_service.dart

import '../../models/cycle_recommendation.dart';
import '../contracts/cycle_service.dart';
import '../contracts/batch_service.dart';
import 'firestore_collections.dart';

/// Firestore implementation of CycleService
class FirestoreCycleService implements CycleService {
  final BatchService _batchService;

  FirestoreCycleService(this._batchService);

  @override
  Future<List<CycleRecommendation>> fetchTeamCycles(String teamId) async {
    // Get all machines for this team
    final teamMachineIds = await _batchService.getTeamMachineIds(teamId);

    if (teamMachineIds.isEmpty) return [];

    // Get all batches for these machines
    final batchesSnapshot = await FirestoreCollections.batches
        .where('machineId', whereIn: teamMachineIds)
        .get();

    List<CycleRecommendation> allCycles = [];

    // Fetch cycles from each batch
    for (var batchDoc in batchesSnapshot.docs) {
      final cyclesSnapshot =
          await FirestoreCollections.cycles(batchDoc.id).get();

      final cycles = cyclesSnapshot.docs
          .map((doc) => CycleRecommendation.fromFirestore(doc))
          .toList();

      allCycles.addAll(cycles);
    }

    // Sort by timestamp descending
    allCycles.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return allCycles;
  }
}