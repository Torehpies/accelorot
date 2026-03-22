import 'package:flutter/foundation.dart';
// lib/data/providers/activity_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../ui/activity_logs/services/activity_aggregator_service.dart';
import '../../ui/activity_logs/services/activity_filter_service.dart';
import '../models/activity_log_item.dart';
import 'substrate_providers.dart';
import 'alert_providers.dart';
import 'report_providers.dart';
import 'cycle_providers.dart';
import 'batch_providers.dart';
import 'profile_providers.dart';
import 'core_providers.dart';

// ===== ACTIVITY AGGREGATOR PROVIDER =====

/// Provider for ActivityAggregatorService
/// Depends on all repository providers
final activityAggregatorProvider = Provider<ActivityAggregatorService>((ref) {
  final service = ActivityAggregatorService(
    substrateRepo: ref.watch(substrateRepositoryProvider),
    alertRepo: ref.watch(alertRepositoryProvider),
    reportRepo: ref.watch(reportRepositoryProvider),
    cycleRepo: ref.watch(cycleRepositoryProvider),
    auth: FirebaseAuth.instance,
  );

  // Clear memory cache when user logs out or switches accounts
  ref.listen(authStateChangesProvider, (previous, next) {
    if (previous?.value?.uid != next?.value?.uid) {
      service.clearCache();
    }
  });

  return service;
});

// ===== ACTIVITY FILTER SERVICE PROVIDER =====

final activityFilterServiceProvider = Provider<ActivityFilterService>((ref) {
  return ActivityFilterService();
});

// ===== ACTIVITY DATA PROVIDERS =====

/// Provider for all activities (substrates + alerts + cycles + reports)
final allActivitiesProvider = FutureProvider<List<ActivityLogItem>>((
  ref,
) async {
  // Watch auth state to rebuild when user changes
  ref.watch(authStateChangesProvider);

  final aggregator = ref.watch(activityAggregatorProvider);
  
  // Fetch up to 50 latest activities from the last 7 days
  // forceRefresh: true ensures it bypasses the aggregator's 5-minute memory cache
  // since FutureProvider inherently handles its own state caching lifecycle.
  final result = await aggregator.getAllActivitiesWithCache(
    limit: 50,
    filterRecentDays: 7,
  );
  return result.items;
});

/// Provider for substrates only
final substrateActivitiesProvider = FutureProvider<List<ActivityLogItem>>((
  ref,
) async {
  final aggregator = ref.watch(activityAggregatorProvider);
  return aggregator.getSubstrates(limit: 50, cutoffDate: DateTime.now().subtract(const Duration(days: 7)));
});

/// Provider for alerts only
final alertActivitiesProvider = FutureProvider<List<ActivityLogItem>>((
  ref,
) async {
  final aggregator = ref.watch(activityAggregatorProvider);
  return aggregator.getAlerts(limit: 50, cutoffDate: DateTime.now().subtract(const Duration(days: 7)));
});

/// Provider for cycles only
final cycleActivitiesProvider = FutureProvider<List<ActivityLogItem>>((
  ref,
) async {
  final aggregator = ref.watch(activityAggregatorProvider);
  return aggregator.getCyclesRecom(limit: 50, cutoffDate: DateTime.now().subtract(const Duration(days: 7)));
});

/// Provider for reports only
final reportActivitiesProvider = FutureProvider<List<ActivityLogItem>>((
  ref,
) async {
  final aggregator = ref.watch(activityAggregatorProvider);
  return aggregator.getReports(limit: 50);
});

/// Provider for activities filtered by user's team
final userTeamActivitiesProvider = FutureProvider<List<ActivityLogItem>>((
  ref,
) async {
  // Watch auth state to rebuild when user changes
  ref.watch(authStateChangesProvider);

  final aggregator = ref.watch(activityAggregatorProvider);
  final profileRepo = ref.watch(profileRepositoryProvider);
  final batchRepo = ref.watch(batchRepositoryProvider);

  // Start fetching activities immediately (doesn't depend on teamId yet)
  final sw = Stopwatch()..start();
  final activitiesFuture = aggregator.getAllActivitiesWithCache(
    limit: 50,
    filterRecentDays: 7,
  );

  // Get user's team concurrently
  final profile = await profileRepo.getCurrentProfile();
  if (profile?.teamId == null) return [];

  // Get team's machine IDs
  final machineIds = await batchRepo.getTeamMachineIds(profile!.teamId!);

  // Wait for activities to finish
  final result = await activitiesFuture;
  debugPrint('userTeamActivitiesProvider load took: ${sw.elapsedMilliseconds}ms');

  // Filter activities by team's machines or team membership
  return result.items.where((activity) {
    // For machine-based activities (substrates, cycles, some alerts)
    if (activity.machineId != null) {
      return machineIds.contains(activity.machineId);
    }

    // For reports and other activities without machines
    // Include if they belong to the team (check teamId if available, or include all for now)
    if (activity.type == ActivityType.report) {
      return true; // Include all reports from team members
    }

    // Include alerts and other activities without machineId
    return true;
  }).toList();
});

// ===== STREAMING ACTIVITY PROVIDERS =====

/// Stream provider for all activities with real-time updates
/// Used by both operator dashboard (Activity Logs) and admin dashboard (Recent Activities Table)
final allActivitiesStreamProvider = StreamProvider<List<ActivityLogItem>>((ref) {
  // Watch auth state to rebuild when user changes
  ref.watch(authStateChangesProvider);

  final aggregator = ref.watch(activityAggregatorProvider);
  return aggregator.streamAllActivities();
});



