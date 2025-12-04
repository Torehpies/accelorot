// lib/data/repositories/cycle_repository.dart

import '../models/cycle_recommendation.dart';
import '../services/contracts/cycle_service.dart';

/// Repository for cycle-related operations
/// Wraps CycleService to provide data access layer
class CycleRepository {
  final CycleService _cycleService;

  CycleRepository(this._cycleService);

  /// Fetch all cycle recommendations for the current user's team
  Future<List<CycleRecommendation>> getTeamCycles() =>
      _cycleService.fetchTeamCycles();
}