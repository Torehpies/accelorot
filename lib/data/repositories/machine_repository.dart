import '../models/machine_model.dart';
import '../services/contracts/machine_service.dart';

class MachineRepository {
  final MachineService _machineService;

  MachineRepository(this._machineService);

  Future<List<MachineModel>> getMachinesByTeam(String teamId) =>
      _machineService.fetchMachinesByTeam(teamId);

  Future<MachineModel?> getMachineById(String machineId) =>
      _machineService.fetchMachineById(machineId);

  Future<void> createMachine(CreateMachineRequest request) =>
      _machineService.createMachine(request);

  Future<void> updateMachine(UpdateMachineRequest request) =>
      _machineService.updateMachine(request);

  Future<void> archiveMachine(String machineId) =>
      _machineService.archiveMachine(machineId);

  Future<void> restoreMachine(String machineId) =>
      _machineService.restoreMachine(machineId);

  Future<bool> checkMachineExists(String machineId) =>
      _machineService.machineExists(machineId);

  Stream<List<MachineModel>> watchMachinesByTeam(String teamId) =>
      _machineService.watchMachinesByTeam(teamId);
}