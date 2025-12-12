import '../../models/machine_model.dart';

/// Abstract repository interface - defines the contract
abstract class MachineRepository {
  Future<List<MachineModel>> getMachinesByTeam(String teamId);
  Future<MachineModel?> getMachineById(String machineId);
  Future<void> createMachine(CreateMachineRequest request);
  Future<void> updateMachine(UpdateMachineRequest request);
  Future<void> archiveMachine(String machineId);  
  Future<void> restoreMachine(String machineId);
  Future<bool> checkMachineExists(String machineId);
  Stream<List<MachineModel>> watchMachinesByTeam(String teamId);
}