// lib/data/providers/repository_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/activity_repository.dart';

/// Provider for activity repository
/// Returns abstract interface, concrete implementation is ActivityLogsRepository
final activityRepositoryProvider = Provider<ActivityRepository>((ref) {
  return ActivityLogsRepository();
});