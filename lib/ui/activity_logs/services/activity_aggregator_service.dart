// lib/ui/activity_logs/services/activity_aggregator_service.dart

import 'package:firebase_auth/firebase_auth.dart';
import '../../../data/models/activity_log_item.dart';
import '../../../data/repositories/substrate_repository.dart';
import '../../../data/repositories/alert_repository.dart';
import '../../../data/repositories/report_repository.dart';
import '../../../data/repositories/cycle_repository.dart';
import '../mappers/activity_presentation_mapper.dart';

/// Result object containing both activity items and full entity cache
class ActivityResult {
  final List<ActivityLogItem> items;
  final Map<String, dynamic> entityCache;

  ActivityResult(this.items, this.entityCache);
}

/// Service to aggregate and transform activity data from multiple sources
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
  }) : _substrateRepo = substrateRepo,
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
        .map(
          (cycle) => ActivityPresentationMapper.fromCycleRecommendation(cycle),
        )
        .toList();
  }

  /// Fetch all activities from all sources and combine them
  @Deprecated('Use getAllActivitiesWithCache() instead')
  Future<List<ActivityLogItem>> getAllActivities() async {
    final result = await getAllActivitiesWithCache();
    return result.items;
  }

  /// Fetch all activities and build an entity cache for instant dialog loading
  Future<ActivityResult> getAllActivitiesWithCache() async {
    try {
      final cache = <String, dynamic>{};
      final allItems = <ActivityLogItem>[];

      // Fetch all data in parallel
      final results = await Future.wait([
        _substrateRepo.getAllSubstrates(),
        _alertRepo.getTeamAlerts(),
        _cycleRepo.getTeamCycles(),
        _reportRepo.getTeamReports(),
      ]);

      final substrates = results[0] as List;
      final alerts = results[1] as List;
      final cycles = results[2] as List;
      final reports = results[3] as List;

      // Process substrates
      for (var substrate in substrates) {
        cache['substrate_${substrate.id}'] = substrate;
        allItems.add(ActivityPresentationMapper.fromSubstrate(substrate));
      }

      // Process alerts
      for (var alert in alerts) {
        cache['alert_${alert.id}'] = alert;
        allItems.add(ActivityPresentationMapper.fromAlert(alert));
      }

      // Process cycles
      for (var cycle in cycles) {
        cache['cycle_${cycle.id}'] = cycle;
        allItems.add(ActivityPresentationMapper.fromCycleRecommendation(cycle));
      }

      // Process reports
      for (var report in reports) {
        cache['report_${report.id}'] = report;
        allItems.add(ActivityPresentationMapper.fromReport(report));
      }

      // Sort by timestamp descending (newest first)
      allItems.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      return ActivityResult(allItems, cache);
    } catch (e) {
      rethrow;
    }
  }
}
