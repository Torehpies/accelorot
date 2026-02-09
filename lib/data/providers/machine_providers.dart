import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/firebase/firebase_machine_service.dart';
import '../repositories/machine_repository/machine_repository.dart';
import '../repositories/machine_repository/machine_repository_remote.dart';
import '../models/machine_model.dart';

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
