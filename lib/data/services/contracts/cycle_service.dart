// lib/data/services/contracts/cycle_service.dart

import '../../models/cycle_recommendation.dart';

/// Abstract interface for cycle and recommendation operations
/// Implementation: FirestoreCycleService
abstract class CycleService {
  /// Fetch all cycles and recommendations for a team
  Future<List<CycleRecommendation>> fetchTeamCycles(String teamId);
}