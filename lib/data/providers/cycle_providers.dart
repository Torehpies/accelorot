// lib/data/providers/cycle_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/firebase/firebase_cycle_service.dart';
import '../repositories/cycle_repository.dart';
import 'batch_providers.dart';

/// Cycle service provider
final cycleServiceProvider = Provider((ref) {
  return FirestoreCycleService(
    batchService: ref.watch(batchServiceProvider),
  );
});

/// Cycle repository provider
final cycleRepositoryProvider = Provider<CycleRepository>((ref) {
  return CycleRepository(ref.watch(cycleServiceProvider));
});