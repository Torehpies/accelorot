import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../ui/activity_logs/services/activity_aggregator_service.dart';
import '../../ui/activity_logs/services/activity_filter_service.dart';
import '../models/activity_log_item.dart';
import 'substrate_providers.dart';
import 'alert_providers.dart';
import 'report_providers.dart';
import 'cycle_providers.dart';

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
final allActivitiesProvider = FutureProvider<List<ActivityLogItem>>((ref) async {
  final aggregator = ref.watch(activityAggregatorProvider);
  return aggregator.getAllActivities();
});

/// Provider for substrates only
final substrateActivitiesProvider = FutureProvider<List<ActivityLogItem>>((ref) async {
  final aggregator = ref.watch(activityAggregatorProvider);
  return aggregator.getSubstrates();
});

/// Provider for alerts only
final alertActivitiesProvider = FutureProvider<List<ActivityLogItem>>((ref) async {
  final aggregator = ref.watch(activityAggregatorProvider);
  return aggregator.getAlerts();
});

/// Provider for cycles only
final cycleActivitiesProvider = FutureProvider<List<ActivityLogItem>>((ref) async {
  final aggregator = ref.watch(activityAggregatorProvider);
  return aggregator.getCyclesRecom();
});

/// Provider for reports only
final reportActivitiesProvider = FutureProvider<List<ActivityLogItem>>((ref) async {
  final aggregator = ref.watch(activityAggregatorProvider);
  return aggregator.getReports();
});