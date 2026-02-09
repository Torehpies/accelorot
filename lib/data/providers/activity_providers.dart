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
  return ActivityAggregatorService(
    substrateRepo: ref.watch(substrateRepositoryProvider),
    alertRepo: ref.watch(alertRepositoryProvider),
    reportRepo: ref.watch(reportRepositoryProvider),
    cycleRepo: ref.watch(cycleRepositoryProvider),
    auth: FirebaseAuth.instance,
  );
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
  final result = await aggregator.getAllActivitiesWithCache();
  return result.items;
});

/// Provider for substrates only
final substrateActivitiesProvider = FutureProvider<List<ActivityLogItem>>((
  ref,
) async {
  final aggregator = ref.watch(activityAggregatorProvider);
  return aggregator.getSubstrates();
});

/// Provider for alerts only
final alertActivitiesProvider = FutureProvider<List<ActivityLogItem>>((
  ref,
) async {
  final aggregator = ref.watch(activityAggregatorProvider);
  return aggregator.getAlerts();
});

/// Provider for cycles only
final cycleActivitiesProvider = FutureProvider<List<ActivityLogItem>>((
  ref,
) async {
  final aggregator = ref.watch(activityAggregatorProvider);
  return aggregator.getCyclesRecom();
});

/// Provider for reports only
final reportActivitiesProvider = FutureProvider<List<ActivityLogItem>>((
  ref,
) async {
  final aggregator = ref.watch(activityAggregatorProvider);
  return aggregator.getReports();
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

  // Get user's team
  final profile = await profileRepo.getCurrentProfile();
  if (profile?.teamId == null) return [];

  // Get team's machine IDs
  final machineIds = await batchRepo.getTeamMachineIds(profile!.teamId!);

  // Get all activities
  final result = await aggregator.getAllActivitiesWithCache();

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
