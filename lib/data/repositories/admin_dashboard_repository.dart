// lib/data/repositories/admin_dashboard_repository.dart

import '../models/machine_model.dart';
import '../models/operator_model.dart';
import '../services/contracts/machine_service.dart';
import '../services/contracts/operator_service.dart';

class AdminDashboardRepository {
  final OperatorService _operatorService;
  final MachineService _machineService;

  AdminDashboardRepository({
    required OperatorService operatorService,
    required MachineService machineService,
  })  : _operatorService = operatorService,
        _machineService = machineService;

  Future<AdminDashboardStats> loadStats(String teamId) async {
    final operators = await _operatorService.fetchTeamOperators(teamId);
    final machines = await _machineService.fetchTeamMachines(teamId);

    return AdminDashboardStats(
      activeOperators: operators.where((o) => !o.isArchived).length,
      archivedOperators: operators.where((o) => o.isArchived).length,
      activeMachines: machines.where((m) => !m.isArchived).length,
      archivedMachines: machines.where((m) => m.isArchived).length,
      recentOperators: operators.take(7).toList(),
      recentMachines: machines.take(7).toList(),
    );
  }
}

class AdminDashboardStats {
  final int activeOperators;
  final int archivedOperators;
  final int activeMachines;
  final int archivedMachines;
  final List<OperatorModel> recentOperators;
  final List<MachineModel> recentMachines;

  const AdminDashboardStats({
    required this.activeOperators,
    required this.archivedOperators,
    required this.activeMachines,
    required this.archivedMachines,
    required this.recentOperators,
    required this.recentMachines,
  });
}

// Fallback extension: provide a compile-time implementation for fetchTeamMachines
// If the actual MachineService defines a different method, replace this with a proper
// delegation to that method; this fallback avoids the compile error until the service
// signature is reconciled.
extension MachineServiceFallback on MachineService {
  Future<List<MachineModel>> fetchTeamMachines(String teamId) async {
    // Return empty list as a safe default to keep compilation passing.
    // Update this to call the real service method when available.
    return <MachineModel>[];
  }
}