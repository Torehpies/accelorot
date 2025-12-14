// lib/data/repositories/machine_repository_remote.dart

import 'machine_repository.dart';
import '../../models/machine_model.dart';
import '../../services/contracts/machine_service.dart';

class MachineRepositoryRemote implements MachineRepository {
  final MachineService _machineService;

  MachineRepositoryRemote(this._machineService);

  @override
  Future<List<MachineModel>> getMachinesByTeam(String teamId) =>
      _machineService.fetchMachinesByTeam(teamId);

  // ... all other methods delegate to service
}