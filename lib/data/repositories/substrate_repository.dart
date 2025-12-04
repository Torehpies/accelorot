// lib/data/repositories/substrate_repository.dart

import '../models/substrate.dart';
import '../services/contracts/substrate_service.dart';

/// Repository for substrate-related operations
/// Wraps SubstrateService to provide data access layer
class SubstrateRepository {
  final SubstrateService _substrateService;

  SubstrateRepository(this._substrateService);

  /// Fetch all substrates for the current user's team
  Future<List<Substrate>> getTeamSubstrates() =>
      _substrateService.fetchTeamSubstrates();

  /// Add a new substrate entry
  Future<void> addSubstrate(Map<String, dynamic> data) =>
      _substrateService.addSubstrate(data);
}