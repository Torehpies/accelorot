// lib/data/providers/activity_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../ui/activity_logs/services/activity_aggregator_service.dart';
import 'substrate_providers.dart';
import 'alert_providers.dart';
import 'report_providers.dart';
import 'cycle_providers.dart';

/// Activity aggregator service provider
/// 
/// Combines activities from all repositories (substrates, alerts, 
/// reports, cycles) and transforms them to UI-ready presentation models.
/// 
/// This is a presentation-layer service that orchestrates data fetching
/// and transformation, not a data repository.
final activityAggregatorProvider = Provider<ActivityAggregatorService>((ref) {
  return ActivityAggregatorService(
    substrateRepo: ref.watch(substrateRepositoryProvider),
    alertRepo: ref.watch(alertRepositoryProvider),
    reportRepo: ref.watch(reportRepositoryProvider),
    cycleRepo: ref.watch(cycleRepositoryProvider),
  );
});