// lib/data/services/contracts/cycle_service.dart

import '../../models/cycle_recommendation.dart';

/// Abstract interface for cycle recommendation data operations
abstract class CycleService {
  /// Fetch all cycle recommendations for the current user's team
  /// Handles authentication and team resolution internally
  Future<List<CycleRecommendation>> fetchTeamCycles();
}