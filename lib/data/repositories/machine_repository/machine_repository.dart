import '../../models/machine_model.dart';

abstract class MachineRepository {
  Future<List<MachineModel>> getMachinesByTeam(String teamId);
  Future<MachineModel?> getMachineById(String machineId);
  Future<void> createMachine(CreateMachineRequest request);
  Future<void> updateMachine(UpdateMachineRequest request);
  Future<void> archiveMachine(String machineId);
  Future<void> restoreMachine(String machineId);
  Future<bool> checkMachineExists(String machineId);
  Stream<List<MachineModel>> watchMachinesByTeam(String teamId);
  Future<void> updateDrumActive(String machineId, bool isActive);
  Future<void> updateAeratorActive(String machineId, bool isActive);
}
