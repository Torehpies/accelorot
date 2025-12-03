// lib/data/providers/activity_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/activity_repository.dart';
import 'substrate_providers.dart';
import 'alert_providers.dart';
import 'report_providers.dart';
import 'cycle_providers.dart';

/// Activity repository provider (aggregates all activities for UI)
final activityRepositoryProvider = Provider<ActivityRepository>((ref) {
  return ActivityRepository(
    substrateRepo: ref.watch(substrateRepositoryProvider),
    alertRepo: ref.watch(alertRepositoryProvider),
    reportRepo: ref.watch(reportRepositoryProvider),
    cycleRepo: ref.watch(cycleRepositoryProvider),
  );
});