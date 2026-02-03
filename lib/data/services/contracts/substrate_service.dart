// lib/data/services/contracts/substrate_service.dart

import '../../models/substrate.dart';

/// Abstract interface for substrate data operations
abstract class SubstrateService {
  /// Fetch all substrates for the current user's team
  /// Handles authentication and team resolution internally
  Future<List<Substrate>> fetchTeamSubstrates();

  /// Add a new substrate entry
  /// Handles authentication, batch creation/retrieval, and timestamp updates internally
  /// @param data - substrate data including machineId
  Future<void> addSubstrate(Map<String, dynamic> data);

  /// Fetch a single substrate by ID
  Future<Substrate?> fetchSubstrateById(String substrateId);
}
