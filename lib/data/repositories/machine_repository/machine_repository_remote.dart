import 'machine_repository.dart';
import '../../models/machine_model.dart';
import '../../services/contracts/machine_service.dart';

/// Firebase/remote implementation of the repository
class MachineRepositoryRemote implements MachineRepository {
  final MachineService _machineService;

  MachineRepositoryRemote(this._machineService);

  @override
  Future<List<MachineModel>> getMachinesByTeam(String teamId) =>
      _machineService.fetchMachinesByTeam(teamId);

  @override
  Future<MachineModel?> getMachineById(String machineId) =>
      _machineService.fetchMachineById(machineId);

  @override
  Future<void> createMachine(CreateMachineRequest request) =>
      _machineService.createMachine(request);

  @override
  Future<void> updateMachine(UpdateMachineRequest request) =>
      _machineService.updateMachine(request);

  @override
  Future<void> archiveMachine(String machineId) =>
      _machineService.archiveMachine(machineId);

  @override
  Future<void> restoreMachine(String machineId) =>
      _machineService.restoreMachine(machineId);

  @override
  Future<bool> checkMachineExists(String machineId) =>
      _machineService.machineExists(machineId);

  @override
  Stream<List<MachineModel>> watchMachinesByTeam(String teamId) =>
      _machineService.watchMachinesByTeam(teamId);

  @override
  Stream<MachineModel?> watchMachineById(String machineId) =>
      _machineService.watchMachineById(machineId);

  @override
  Future<void> updateDrumActive(String machineId, bool isActive) =>
      _machineService.updateDrumActive(machineId, isActive);

  @override
  Future<void> updateAeratorActive(String machineId, bool isActive) =>
      _machineService.updateAeratorActive(machineId, isActive);
}
