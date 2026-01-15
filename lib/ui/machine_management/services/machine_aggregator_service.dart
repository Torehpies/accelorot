// lib/ui/machine_management/services/machine_aggregator_service.dart

import 'package:firebase_auth/firebase_auth.dart';
import '../../../data/models/machine_model.dart';
import '../../../data/repositories/machine_repository/machine_repository.dart';

/// Service to aggregate and manage machine data
class MachineAggregatorService {
  final MachineRepository _machineRepo;
  final FirebaseAuth _auth;

  MachineAggregatorService({
    required MachineRepository machineRepo,
    FirebaseAuth? auth,
  })  : _machineRepo = machineRepo,
        _auth = auth ?? FirebaseAuth.instance;

  // ===== USER MANAGEMENT =====

  /// Check if a user is currently logged in
  Future<bool> isUserLoggedIn() async {
    final userId = _auth.currentUser?.uid;
    return userId != null && userId.isNotEmpty;
  }

  // ===== FETCH METHODS =====

  /// Fetch all machines for the team
  Future<List<MachineModel>> getMachines(String teamId) async {
    try {
      final machines = await _machineRepo.getMachinesByTeam(teamId);
      
      // Sort by creation date descending (newest first)
      machines.sort((a, b) => b.dateCreated.compareTo(a.dateCreated));
      
      return machines;
    } catch (e) {
      rethrow;
    }
  }

  /// Fetch a single machine by ID
  Future<MachineModel?> getMachineById(String machineId) async {
    try {
      return await _machineRepo.getMachineById(machineId);
    } catch (e) {
      rethrow;
    }
  }

  /// Check if machine ID exists
  Future<bool> checkMachineExists(String machineId) async {
    try {
      return await _machineRepo.checkMachineExists(machineId);
    } catch (e) {
      rethrow;
    }
  }

  // ===== CREATE METHODS =====

  /// Create a new machine
  Future<void> createMachine(CreateMachineRequest request) async {
    try {
      await _machineRepo.createMachine(request);
    } catch (e) {
      rethrow;
    }
  }

  // ===== UPDATE METHODS =====

  /// Update an existing machine
  Future<void> updateMachine(UpdateMachineRequest request) async {
    try {
      await _machineRepo.updateMachine(request);
    } catch (e) {
      rethrow;
    }
  }

  /// Archive a machine
  Future<void> archiveMachine(String machineId) async {
    try {
      await _machineRepo.archiveMachine(machineId);
    } catch (e) {
      rethrow;
    }
  }

  /// Restore an archived machine
  Future<void> restoreMachine(String machineId) async {
    try {
      await _machineRepo.restoreMachine(machineId);
    } catch (e) {
      rethrow;
    }
  }
}