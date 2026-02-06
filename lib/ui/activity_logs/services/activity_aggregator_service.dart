// lib/ui/activity_logs/services/activity_aggregator_service.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
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
    final stopwatch = Stopwatch()..start();
    try {
      final substrates = await _substrateRepo.getAllSubstrates();
      final items = substrates
          .map((substrate) => ActivityPresentationMapper.fromSubstrate(substrate))
          .toList();
      
      stopwatch.stop();
      debugPrint('🟢 SUBSTRATES FETCH: ${stopwatch.elapsedMilliseconds}ms (${items.length} items)');
      
      return items;
    } catch (e) {
      stopwatch.stop();
      debugPrint('🔴 SUBSTRATES FETCH FAILED: ${stopwatch.elapsedMilliseconds}ms - Error: $e');
      rethrow;
    }
  }

  /// Fetch and transform alert activities
  Future<List<ActivityLogItem>> getAlerts() async {
    final stopwatch = Stopwatch()..start();
    try {
      final alerts = await _alertRepo.getTeamAlerts();
      final items = alerts
          .map((alert) => ActivityPresentationMapper.fromAlert(alert))
          .toList();
      
      stopwatch.stop();
      debugPrint('🟡 ALERTS FETCH: ${stopwatch.elapsedMilliseconds}ms (${items.length} items)');
      
      return items;
    } catch (e) {
      stopwatch.stop();
      debugPrint('🔴 ALERTS FETCH FAILED: ${stopwatch.elapsedMilliseconds}ms - Error: $e');
      rethrow;
    }
  }

  /// Fetch and transform report activities
  Future<List<ActivityLogItem>> getReports() async {
    final stopwatch = Stopwatch()..start();
    try {
      final reports = await _reportRepo.getTeamReports();
      final items = reports
          .map((report) => ActivityPresentationMapper.fromReport(report))
          .toList();
      
      stopwatch.stop();
      debugPrint('🔵 REPORTS FETCH: ${stopwatch.elapsedMilliseconds}ms (${items.length} items)');
      
      return items;
    } catch (e) {
      stopwatch.stop();
      debugPrint('🔴 REPORTS FETCH FAILED: ${stopwatch.elapsedMilliseconds}ms - Error: $e');
      rethrow;
    }
  }

  /// Fetch and transform cycle & recommendation activities
  Future<List<ActivityLogItem>> getCyclesRecom() async {
    final stopwatch = Stopwatch()..start();
    try {
      final cycles = await _cycleRepo.getTeamCycles();
      final items = cycles
          .map(
            (cycle) => ActivityPresentationMapper.fromCycleRecommendation(cycle),
          )
          .toList();
      
      stopwatch.stop();
      debugPrint('🟣 CYCLES FETCH: ${stopwatch.elapsedMilliseconds}ms (${items.length} items)');
      
      return items;
    } catch (e) {
      stopwatch.stop();
      debugPrint('🔴 CYCLES FETCH FAILED: ${stopwatch.elapsedMilliseconds}ms - Error: $e');
      rethrow;
    }
  }

  /// Fetch all activities from all sources and combine them
  @Deprecated('Use getAllActivitiesWithCache() instead')
  Future<List<ActivityLogItem>> getAllActivities() async {
    final result = await getAllActivitiesWithCache();
    return result.items;
  }

  /// Get counts only for stats cards (without fetching full entities)
  /// [filterRecentDays] - Only count items from last N days (null = count all)
  Future<Map<String, int>> getActivityCounts({int? filterRecentDays}) async {
    debugPrint('📊 Fetching activity counts (filterRecentDays: ${filterRecentDays ?? "all"})');
    
    final DateTime? cutoffDate = filterRecentDays != null
        ? DateTime.now().subtract(Duration(days: filterRecentDays))
        : null;

    final results = await Future.wait([
      _substrateRepo.getAllSubstrates(),
      _alertRepo.getTeamAlerts(cutoffDate: cutoffDate), // No limit for counts
      _cycleRepo.getTeamCycles(cutoffDate: cutoffDate), // No limit for counts
      _reportRepo.getTeamReports(), // No limit for counts
    ]);

    final substrates = results[0] as List;
    final alerts = results[1] as List;
    final cycles = results[2] as List;
    final reports = results[3] as List;

    debugPrint('📊 Counts: substrates=${substrates.length}, alerts=${alerts.length}, cycles=${cycles.length}, reports=${reports.length}');

    return {
      'substrates': substrates.length,
      'alerts': alerts.length,
      'operations': cycles.length, // operations = cycles
      'reports': reports.length,
    };
  }

  /// Fetch all activities and build an entity cache for instant dialog loading
  /// [limit] - Maximum number of items to fetch per category (null = fetch all)
  /// [filterRecentDays] - Only fetch items from last N days (null = no time filter)
  Future<ActivityResult> getAllActivitiesWithCache({
    int? limit,
    int? filterRecentDays,
  }) async {
    final totalStopwatch = Stopwatch()..start();
    
    debugPrint('📊 ===== ACTIVITY FETCH START =====');
    debugPrint('   📋 Limit per category: ${limit ?? "unlimited"}');
    debugPrint('   📅 Filter recent days: ${filterRecentDays ?? "no filter"}');
    
    try {
      final cache = <String, dynamic>{};
      final allItems = <ActivityLogItem>[];

      // Calculate cutoff date if filtering by recent days
      final DateTime? cutoffDate = filterRecentDays != null
          ? DateTime.now().subtract(Duration(days: filterRecentDays))
          : null;

      // Fetch all data in parallel with pagination/filtering
      final parallelStopwatch = Stopwatch()..start();
      
      final results = await Future.wait([
        _substrateRepo.getAllSubstrates(), // Substrates: fetch all (usually small dataset)
        _alertRepo.getTeamAlerts(limit: limit, cutoffDate: cutoffDate), // Alerts: paginated + 2-day filter
        _cycleRepo.getTeamCycles(limit: limit, cutoffDate: cutoffDate), // Cycles: paginated + 2-day filter
        _reportRepo.getTeamReports(limit: limit), // Reports: paginated only
      ]);
      
      parallelStopwatch.stop();
      debugPrint('⚡ PARALLEL FETCH COMPLETE: ${parallelStopwatch.elapsedMilliseconds}ms');

      final substrates = results[0] as List;
      final alerts = results[1] as List;
      final cycles = results[2] as List;
      final reports = results[3] as List;

      // Process substrates
      final substrateStopwatch = Stopwatch()..start();
      for (var substrate in substrates) {
        cache['substrate_${substrate.id}'] = substrate;
        allItems.add(ActivityPresentationMapper.fromSubstrate(substrate));
      }
      substrateStopwatch.stop();
      debugPrint('   🟢 Substrates processed: ${substrateStopwatch.elapsedMilliseconds}ms (${substrates.length} items)');

      // Process alerts
      final alertStopwatch = Stopwatch()..start();
      for (var alert in alerts) {
        cache['alert_${alert.id}'] = alert;
        allItems.add(ActivityPresentationMapper.fromAlert(alert));
      }
      alertStopwatch.stop();
      debugPrint('   🟡 Alerts processed: ${alertStopwatch.elapsedMilliseconds}ms (${alerts.length} items)');

      // Process cycles
      final cycleStopwatch = Stopwatch()..start();
      for (var cycle in cycles) {
        cache['cycle_${cycle.id}'] = cycle;
        allItems.add(ActivityPresentationMapper.fromCycleRecommendation(cycle));
      }
      cycleStopwatch.stop();
      debugPrint('   🟣 Cycles processed: ${cycleStopwatch.elapsedMilliseconds}ms (${cycles.length} items)');

      // Process reports
      final reportStopwatch = Stopwatch()..start();
      for (var report in reports) {
        cache['report_${report.id}'] = report;
        allItems.add(ActivityPresentationMapper.fromReport(report));
      }
      reportStopwatch.stop();
      debugPrint('   🔵 Reports processed: ${reportStopwatch.elapsedMilliseconds}ms (${reports.length} items)');

      // Sort by timestamp descending (newest first)
      final sortStopwatch = Stopwatch()..start();
      allItems.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      sortStopwatch.stop();
      debugPrint('🔗 ITEMS SORTED: ${sortStopwatch.elapsedMilliseconds}ms (${allItems.length} total items)');

      debugPrint('💾 ENTITY CACHE BUILT: ${cache.length} entities cached');
      
      totalStopwatch.stop();
      debugPrint('✅ TOTAL FETCH TIME: ${totalStopwatch.elapsedMilliseconds}ms');
      debugPrint('📊 ===== ACTIVITY FETCH END =====\n');

      return ActivityResult(allItems, cache);
    } catch (e) {
      totalStopwatch.stop();
      debugPrint('❌ TOTAL FETCH FAILED: ${totalStopwatch.elapsedMilliseconds}ms - Error: $e');
      debugPrint('📊 ===== ACTIVITY FETCH END (WITH ERROR) =====\n');
      rethrow;
    }
  }
}
