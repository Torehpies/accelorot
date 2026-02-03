import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase/firebase_batch_service.dart';
import '../repositories/batch_repository/batch_repository.dart';
import '../repositories/batch_repository/batch_repository_remote.dart';
import '../models/batch_model.dart';
import 'profile_providers.dart';

/// Batch service provider (shared dependency across all domains)
final batchServiceProvider = Provider((ref) {
  return FirestoreBatchService(FirebaseFirestore.instance);
});

/// Batch repository provider
final batchRepositoryProvider = Provider<BatchRepository>((ref) {
  return BatchRepositoryRemote(ref.watch(batchServiceProvider));
});

/// Provider for batches by machine IDs
final batchesForMachinesProvider =
    FutureProvider.family<List<BatchModel>, List<String>>((
      ref,
      machineIds,
    ) async {
      final repository = ref.watch(batchRepositoryProvider);
      return repository.getBatchesForMachines(machineIds);
    });

/// batches of team ID
final batchesForTeamProvider = FutureProvider.family<List<BatchModel>, String>((
  ref,
  teamId,
) async {
  final repository = ref.watch(batchRepositoryProvider);
  final machineIds = await repository.getTeamMachineIds(teamId);
  return repository.getBatchesForMachines(machineIds);
});

/// AsyncNotifier for user's team batches (better for state management)
class UserTeamBatchesNotifier extends AsyncNotifier<List<BatchModel>> {
  @override
  Future<List<BatchModel>> build() async {
    final repository = ref.watch(batchRepositoryProvider);
    final profileRepo = ref.watch(profileRepositoryProvider);

    // Get current user's profile to get teamId
    final profile = await profileRepo.getCurrentProfile();
    if (profile?.teamId == null) return [];

    // Get all machines for the team
    final machineIds = await repository.getTeamMachineIds(profile!.teamId!);

    // Get batches for those machines
    return repository.getBatchesForMachines(machineIds);
  }

  /// Refresh batches manually
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => build());
  }
}

/// Provider using the AsyncNotifier
final userTeamBatchesProvider =
    AsyncNotifierProvider<UserTeamBatchesNotifier, List<BatchModel>>(
      () => UserTeamBatchesNotifier(),
    );

/// Provider for active batch for a specific machine
final activeBatchForMachineProvider =
    FutureProvider.family<BatchModel?, String>((ref, machineId) async {
      final repository = ref.watch(batchRepositoryProvider);
      return repository.getActiveBatchForMachine(machineId);
    });
