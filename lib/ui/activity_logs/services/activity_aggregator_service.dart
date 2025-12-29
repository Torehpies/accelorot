// lib/ui/activity_logs/services/activity_aggregator_service.dart

import 'package:firebase_auth/firebase_auth.dart';
import '../../../data/models/activity_log_item.dart';
import '../../../data/repositories/substrate_repository.dart';
import '../../../data/repositories/alert_repository.dart';
import '../../../data/repositories/report_repository.dart';
import '../../../data/repositories/cycle_repository.dart';
import '../mappers/activity_presentation_mapper.dart';

/// Service that aggregates activities from multiple repositories
/// and transforms them into UI-ready presentation models.
/// 
/// This is a presentation-layer service, not a data repository.
/// It orchestrates data fetching from multiple sources and applies
/// UI-specific transformations.
class ActivityAggregatorService {
  final SubstrateRepository _substrateRepo;
  final AlertRepository _alertRepo;
  final ReportRepository _reportRepo;
  final CycleRepository _cycleRepo;
  final FirebaseAuth _auth;

  ActivityAggregatorService({
    required SubstrateRepository substrateRepo,
    required AlertRepository alertRepo,
    required ReportRepository reportRepo,
    required CycleRepository cycleRepo,
    FirebaseAuth? auth,
  })  : _substrateRepo = substrateRepo,
        _alertRepo = alertRepo,
        _reportRepo = reportRepo,
        _cycleRepo = cycleRepo,
        _auth = auth ?? FirebaseAuth.instance;

  // ===== USER MANAGEMENT =====

  /// Check if a user is currently logged in
  Future<bool> isUserLoggedIn() async {
    final userId = _auth.currentUser?.uid;
    return userId != null && userId.isNotEmpty;
  }

  // ===== FETCH & TRANSFORM METHODS =====

  /// Fetch and transform substrate activities
  Future<List<ActivityLogItem>> getSubstrates() async {
  final substrates = await _substrateRepo.getAllSubstrates(); 
    return substrates
        .map((substrate) => ActivityPresentationMapper.fromSubstrate(substrate))
        .toList();
  }

  /// Fetch and transform alert activities
  Future<List<ActivityLogItem>> getAlerts() async {
    final alerts = await _alertRepo.getTeamAlerts();
    return alerts
        .map((alert) => ActivityPresentationMapper.fromAlert(alert))
        .toList();
  }

  /// Fetch and transform report activities
  Future<List<ActivityLogItem>> getReports() async {
    final reports = await _reportRepo.getTeamReports();
    return reports
        .map((report) => ActivityPresentationMapper.fromReport(report))
        .toList();
  }

  /// Fetch and transform cycle & recommendation activities
  Future<List<ActivityLogItem>> getCyclesRecom() async {
    final cycles = await _cycleRepo.getTeamCycles();
    return cycles
        .map((cycle) => ActivityPresentationMapper.fromCycleRecommendation(cycle))
        .toList();
  }

  /// Fetch all activities from all sources and combine them
  /// 
  Future<List<ActivityLogItem>> getAllActivities() async {
    try {
      // ✅ FIXED: Fetch and transform in one step
      final results = await Future.wait([
        getSubstrates(),
        getAlerts(),
        getCyclesRecom(),
        getReports(),
      ]);

      // Flatten list of lists into single list
      final allActivities = results.expand((list) => list).toList();

      // Sort by timestamp descending (newest first)
      allActivities.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      return allActivities;
    } catch (e) {
      // ✅ FIXED: Added error handling
      rethrow;
    }
  }
}