// lib/data/services/contracts/substrate_service.dart

import '../../models/substrate.dart';

/// Abstract interface for substrate operations
/// Implementation: FirestoreSubstrateService
abstract class SubstrateService {
  /// Fetch all substrates for a team
  Future<List<Substrate>> fetchTeamSubstrates(String teamId);
  
  /// Add a new substrate entry
  Future<void> addSubstrate(Map<String, dynamic> data, String batchId);
}