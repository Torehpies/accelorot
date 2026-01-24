import '../../models/machine_model.dart';
import '../contracts/machine_service.dart';

class LocalMachineService implements MachineService {
  @override
  Future<List<MachineModel>> fetchMachinesByTeam(String teamId) {
    throw UnimplementedError('Local database not yet implemented');
  }

  @override
  Future<MachineModel?> fetchMachineById(String machineId) {
    throw UnimplementedError('Local database not yet implemented');
  }

  @override
  Future<void> createMachine(CreateMachineRequest request) {
    throw UnimplementedError('Local database not yet implemented');
  }

  @override
  Future<void> updateMachine(UpdateMachineRequest request) {
    throw UnimplementedError('Local database not yet implemented');
  }

  @override
  Future<void> archiveMachine(String machineId) {
    throw UnimplementedError('Local database not yet implemented');
  }

  @override
  Future<void> restoreMachine(String machineId) {
    throw UnimplementedError('Local database not yet implemented');
  }

  @override
  Future<bool> machineExists(String machineId) {
    throw UnimplementedError('Local database not yet implemented');
  }

  @override
  Stream<List<MachineModel>> watchMachinesByTeam(String teamId) {
    throw UnimplementedError('Local database not yet implemented');
  }
}
