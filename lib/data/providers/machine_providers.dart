import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/firebase/firebase_machine_service.dart';
import '../repositories/machine_repository/machine_repository.dart';
import '../repositories/machine_repository/machine_repository_remote.dart';
import '../models/machine_model.dart';
import 'profile_providers.dart';

// Service Provider
final machineServiceProvider = Provider<FirebaseMachineService>((ref) {
  return FirebaseMachineService();
});

// Repository Provider
final machineRepositoryProvider = Provider<MachineRepository>((ref) {
  final service = ref.watch(machineServiceProvider);
  return MachineRepositoryRemote(service);
});

// Provider for machines by team
final machinesStreamProvider =
    StreamProvider.family<List<MachineModel>, String>((ref, teamId) {
      final repository = ref.watch(machineRepositoryProvider);
      return repository.watchMachinesByTeam(teamId);
    });

// StreamProvider for single machine (real-time updates for drumActive/aeratorActive)
final machineStreamProvider = StreamProvider.family<MachineModel?, String>((
  ref,
  machineId,
) {
  final repository = ref.watch(machineRepositoryProvider);
  return repository.watchMachineById(machineId);
});

// FutureProvider for single machine
final machineByIdProvider = FutureProvider.family<MachineModel?, String>((
  ref,
  machineId,
) async {
  final repository = ref.watch(machineRepositoryProvider);
  return repository.getMachineById(machineId);
});

/// AsyncNotifier for user's team machines
class UserTeamMachinesNotifier extends AsyncNotifier<List<MachineModel>> {
  @override
  Future<List<MachineModel>> build() async {
    final repository = ref.watch(machineRepositoryProvider);
    final profileRepo = ref.watch(profileRepositoryProvider);

    // Get current user's profile to get teamId
    final profile = await profileRepo.getCurrentProfile();
    if (profile?.teamId == null) return [];

    return repository.getMachinesByTeam(profile!.teamId!);
  }

  /// Refresh machines manually
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => build());
  }
}

/// Provider using the AsyncNotifier
final userTeamMachinesProvider =
    AsyncNotifierProvider<UserTeamMachinesNotifier, List<MachineModel>>(
      () => UserTeamMachinesNotifier(),
    );
