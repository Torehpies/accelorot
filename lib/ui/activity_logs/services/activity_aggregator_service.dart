// lib/ui/activity_logs/services/activity_aggregator_service.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../../../data/models/activity_log_item.dart';
import '../../../data/repositories/substrate_repository.dart';
import '../../../data/repositories/alert_repository.dart';
import '../../../data/repositories/report_repository.dart';
import '../../../data/repositories/cycle_repository.dart';
import '../mappers/activity_presentation_mapper.dart';

/// Cached data with timestamp for TTL validation
class CachedData<T> {
  final T data;
  final DateTime timestamp;

  CachedData(this.data, this.timestamp);

  /// Check if cache has expired based on TTL
  bool isExpired(Duration ttl) {
    return DateTime.now().difference(timestamp) > ttl;
  }
}

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

  // ===== MEMORY CACHE =====
  static const _cacheTTL = Duration(minutes: 5);
  
  // ===== CUTOFF CONFIGURATION =====
  /// Default cutoff in days for alerts and cycles (change this to adjust globally)
  static const defaultCutoffDays = 2;
  
  final Map<String, CachedData<List<ActivityLogItem>>> _cache = {};
  CachedData<ActivityResult>? _allActivitiesCache;

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
    // Check cache first
    final cached = _cache['substrates'];
    if (cached != null && !cached.isExpired(_cacheTTL)) {
      debugPrint('✅ Returning cached substrates (${cached.data.length} items)');
      return cached.data;
    }

    final stopwatch = Stopwatch()..start();
    try {
      debugPrint('🔄 Fetching fresh substrates from Firebase...');
      final substrates = await _substrateRepo.getAllSubstrates();
      final items = substrates
          .map(
            (substrate) => ActivityPresentationMapper.fromSubstrate(substrate),
          )
          .toList();

      // Update cache
      _cache['substrates'] = CachedData(items, DateTime.now());

      stopwatch.stop();
      debugPrint(
        '🟢 SUBSTRATES FETCH: ${stopwatch.elapsedMilliseconds}ms (${items.length} items)',
      );

      return items;
    } catch (e) {
      stopwatch.stop();
      debugPrint(
        '🔴 SUBSTRATES FETCH FAILED: ${stopwatch.elapsedMilliseconds}ms - Error: $e',
      );
      rethrow;
    }
  }

  /// Fetch raw substrate entities (for progressive loading)
  Future<List<dynamic>> getSubstratesRaw() async {
    return await _substrateRepo.getAllSubstrates();
  }

  /// Fetch and transform alert activities
  Future<List<ActivityLogItem>> getAlerts({DateTime? cutoffDate, int? limit}) async {
    // Check cache first
    final cached = _cache['alerts'];
    if (cached != null && !cached.isExpired(_cacheTTL)) {
      debugPrint('✅ Returning cached alerts (${cached.data.length} items)');
      return cached.data;
    }

    final stopwatch = Stopwatch()..start();
    try {
      debugPrint('🔄 Fetching fresh alerts from Firebase...');
      final alerts = await _alertRepo.getTeamAlerts(cutoffDate: cutoffDate, limit: limit);
      final items = alerts
          .map((alert) => ActivityPresentationMapper.fromAlert(alert))
          .toList();

      // Update cache
      _cache['alerts'] = CachedData(items, DateTime.now());

      stopwatch.stop();
      debugPrint(
        '🟡 ALERTS FETCH: ${stopwatch.elapsedMilliseconds}ms (${items.length} items)',
      );

      return items;
    } catch (e) {
      stopwatch.stop();
      debugPrint(
        '🔴 ALERTS FETCH FAILED: ${stopwatch.elapsedMilliseconds}ms - Error: $e',
      );
      rethrow;
    }
  }

  /// Fetch raw alert entities (for progressive loading)
  Future<List<dynamic>> getAlertsRaw({DateTime? cutoffDate, int? limit}) async {
    return await _alertRepo.getTeamAlerts(cutoffDate: cutoffDate, limit: limit);
  }

  /// Fetch and transform report activities
  Future<List<ActivityLogItem>> getReports() async {
    // Check cache first
    final cached = _cache['reports'];
    if (cached != null && !cached.isExpired(_cacheTTL)) {
      debugPrint('✅ Returning cached reports (${cached.data.length} items)');
      return cached.data;
    }

    final stopwatch = Stopwatch()..start();
    try {
      debugPrint('🔄 Fetching fresh reports from Firebase...');
      final reports = await _reportRepo.getTeamReports();
      final items = reports
          .map((report) => ActivityPresentationMapper.fromReport(report))
          .toList();

      // Update cache
      _cache['reports'] = CachedData(items, DateTime.now());

      stopwatch.stop();
      debugPrint(
        '🔵 REPORTS FETCH: ${stopwatch.elapsedMilliseconds}ms (${items.length} items)',
      );

      return items;
    } catch (e) {
      stopwatch.stop();
      debugPrint(
        '🔴 REPORTS FETCH FAILED: ${stopwatch.elapsedMilliseconds}ms - Error: $e',
      );
      rethrow;
    }
  }

  /// Fetch raw report entities (for progressive loading)
  Future<List<dynamic>> getReportsRaw({int? limit}) async {
    return await _reportRepo.getTeamReports(limit: limit);
  }

  /// Fetch and transform cycle & recommendation activities
  Future<List<ActivityLogItem>> getCyclesRecom({DateTime? cutoffDate, int? limit}) async {
    // Check cache first
    final cached = _cache['cycles'];
    if (cached != null && !cached.isExpired(_cacheTTL)) {
      debugPrint('✅ Returning cached cycles (${cached.data.length} items)');
      return cached.data;
    }

    final stopwatch = Stopwatch()..start();
    try {
      debugPrint('🔄 Fetching fresh cycles from Firebase...');
      final cycles = await _cycleRepo.getTeamCycles(cutoffDate: cutoffDate, limit: limit);
      final items = cycles
          .map(
            (cycle) =>
                ActivityPresentationMapper.fromCycleRecommendation(cycle),
          )
          .toList();

      // Update cache
      _cache['cycles'] = CachedData(items, DateTime.now());

      stopwatch.stop();
      debugPrint(
        '🟣 CYCLES FETCH: ${stopwatch.elapsedMilliseconds}ms (${items.length} items)',
      );

      return items;
    } catch (e) {
      stopwatch.stop();
      debugPrint(
        '🔴 CYCLES FETCH FAILED: ${stopwatch.elapsedMilliseconds}ms - Error: $e',
      );
      rethrow;
    }
  }

  /// Fetch raw cycle entities (for progressive loading)
  Future<List<dynamic>> getCyclesRaw({DateTime? cutoffDate, int? limit}) async {
    return await _cycleRepo.getTeamCycles(cutoffDate: cutoffDate, limit: limit);
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
    debugPrint(
      '📊 Fetching activity counts (filterRecentDays: ${filterRecentDays ?? "all"})',
    );

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

    debugPrint(
      '📊 Counts: substrates=${substrates.length}, alerts=${alerts.length}, cycles=${cycles.length}, reports=${reports.length}',
    );

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
  /// [forceRefresh] - If true, bypass cache and fetch fresh data
  Future<ActivityResult> getAllActivitiesWithCache({
    int? limit,
    int? filterRecentDays,
    bool forceRefresh = false,
  }) async {
    // Check cache first (unless force refresh)
    if (!forceRefresh && _allActivitiesCache != null && !_allActivitiesCache!.isExpired(_cacheTTL)) {
      debugPrint('✅ Returning cached all activities (${_allActivitiesCache!.data.items.length} items)');
      return _allActivitiesCache!.data;
    }
    final totalStopwatch = Stopwatch()..start();

    debugPrint('📊 ===== ACTIVITY FETCH START =====');
    debugPrint('   🔄 Force refresh: $forceRefresh');
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
        _substrateRepo
            .getAllSubstrates(), // Substrates: fetch all (usually small dataset)
        _alertRepo.getTeamAlerts(
          limit: limit,
          cutoffDate: cutoffDate,
        ), // Alerts: paginated + 2-day filter
        _cycleRepo.getTeamCycles(
          limit: limit,
          cutoffDate: cutoffDate,
        ), // Cycles: paginated + 2-day filter
        _reportRepo.getTeamReports(limit: limit), // Reports: paginated only
      ]);

      parallelStopwatch.stop();
      debugPrint(
        '⚡ PARALLEL FETCH COMPLETE: ${parallelStopwatch.elapsedMilliseconds}ms',
      );

      final substrates = results[0] as List;
      final alerts = results[1] as List;
      final cycles = results[2] as List;
      final reports = results[3] as List;

      // Process substrates
      final substrateStopwatch = Stopwatch()..start();
      for (var substrate in substrates) {
        try {
          final cacheKey = 'substrate_${substrate.id}';
          cache[cacheKey] = substrate;
          allItems.add(ActivityPresentationMapper.fromSubstrate(substrate));
          debugPrint('   🔑 Cached substrate: $cacheKey');
        } catch (e) {
          debugPrint('⚠️ Error processing substrate ${substrate.id}: $e');
        }
      }
      substrateStopwatch.stop();
      debugPrint(
        '   🟢 Substrates processed: ${substrateStopwatch.elapsedMilliseconds}ms (${substrates.length} items)',
      );

      // Process alerts
      final alertStopwatch = Stopwatch()..start();
      for (var alert in alerts) {
        try {
          final cacheKey = 'alert_${alert.id}';
          cache[cacheKey] = alert;
          allItems.add(ActivityPresentationMapper.fromAlert(alert));
          debugPrint('   🔑 Cached alert: $cacheKey');
        } catch (e) {
          debugPrint('⚠️ Error processing alert ${alert.id}: $e');
        }
      }
      alertStopwatch.stop();
      debugPrint(
        '   🟡 Alerts processed: ${alertStopwatch.elapsedMilliseconds}ms (${alerts.length} items)',
      );

      // Process cycles
      final cycleStopwatch = Stopwatch()..start();
      for (var cycle in cycles) {
        try {
          final cacheKey = 'cycle_${cycle.id}';
          cache[cacheKey] = cycle;
          allItems.add(ActivityPresentationMapper.fromCycleRecommendation(cycle));
          debugPrint('   🔑 Cached cycle: $cacheKey');
        } catch (e) {
          debugPrint('⚠️ Error processing cycle ${cycle.id}: $e');
        }
      }
      cycleStopwatch.stop();
      debugPrint(
        '   🟣 Cycles processed: ${cycleStopwatch.elapsedMilliseconds}ms (${cycles.length} items)',
      );

      // Process reports
      final reportStopwatch = Stopwatch()..start();
      for (var report in reports) {
        try {
          final cacheKey = 'report_${report.id}';
          cache[cacheKey] = report;
          allItems.add(ActivityPresentationMapper.fromReport(report));
          debugPrint('   🔑 Cached report: $cacheKey');
        } catch (e) {
          debugPrint('⚠️ Error processing report ${report.id}: $e');
        }
      }
      reportStopwatch.stop();
      debugPrint(
        '   🔵 Reports processed: ${reportStopwatch.elapsedMilliseconds}ms (${reports.length} items)',
      );

      // Sort by timestamp descending (newest first)
      final sortStopwatch = Stopwatch()..start();
      allItems.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      sortStopwatch.stop();
      debugPrint(
        '🔗 ITEMS SORTED: ${sortStopwatch.elapsedMilliseconds}ms (${allItems.length} total items)',
      );

      debugPrint('💾 ENTITY CACHE BUILT: ${cache.length} entities cached');

      final result = ActivityResult(allItems, cache);
      
      // Update cache
      _allActivitiesCache = CachedData(result, DateTime.now());

      totalStopwatch.stop();
      debugPrint('✅ TOTAL FETCH TIME: ${totalStopwatch.elapsedMilliseconds}ms');
      debugPrint('📊 ===== ACTIVITY FETCH END =====\n');

      return result;
    } catch (e) {
      totalStopwatch.stop();
      debugPrint(
        '❌ TOTAL FETCH FAILED: ${totalStopwatch.elapsedMilliseconds}ms - Error: $e',
      );
      debugPrint('📊 ===== ACTIVITY FETCH END (WITH ERROR) =====\n');
      rethrow;
    }
  }

  // ===== CACHE MANAGEMENT =====

  /// Clear all cached data (use for manual refresh/logout)
  void clearCache() {
    _cache.clear();
    _allActivitiesCache = null;
    debugPrint('🗑️ All activity cache cleared');
  }

  /// Clear specific category cache
  void clearCategoryCache(String category) {
    _cache.remove(category);
    _allActivitiesCache = null; // Also clear combined cache
    debugPrint('🗑️ Cache cleared for category: $category');
  }
}
