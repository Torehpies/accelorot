// lib/data/repositories/substrate_repository.dart

import '../models/substrate.dart';
import '../services/contracts/substrate_service.dart';

/// Repository for substrate-related operations
class SubstrateRepository {
  final SubstrateService _service;

  SubstrateRepository(this._service);

  /// Add new substrate entry
  Future<void> addSubstrate(CreateSubstrateRequest request) async {
    await _service.addSubstrate(request.toFirestore());
  }

  /// Get substrates for current team
  Future<List<Substrate>> getAllSubstrates() async {
    return await _service.fetchTeamSubstrates();
  }

  /// Get a single substrate by ID
  Future<Substrate?> getSubstrate(String id) async {
    return await _service.fetchSubstrateById(id);
  }
}
