// lib/data/services/contracts/machine_service.dart

import '../../models/machine_model.dart';

abstract class MachineService {
  /// Fetch all machines for a specific team
  Future<List<MachineModel>> fetchMachinesByTeam(String teamId);

  /// Fetch a single machine by ID
  Future<MachineModel?> fetchMachineById(String machineId);

  /// Create a new machine
  Future<void> createMachine(CreateMachineRequest request);

  /// Update an existing machine
  Future<void> updateMachine(UpdateMachineRequest request);

  /// Archive a machine
  Future<void> archiveMachine(String machineId);

  /// Restore an archived machine
  Future<void> restoreMachine(String machineId);

  /// Check if a machine ID exists
  Future<bool> machineExists(String machineId);

  /// Stream of machines for real-time updates
  Stream<List<MachineModel>> watchMachinesByTeam(String teamId);

  /// Stream a single machine for real-time updates
  Stream<MachineModel?> watchMachineById(String machineId);

  /// Update drum active status
  Future<void> updateDrumActive(String machineId, bool isActive);

  /// Update aerator active status
  Future<void> updateAeratorActive(String machineId, bool isActive);
}
