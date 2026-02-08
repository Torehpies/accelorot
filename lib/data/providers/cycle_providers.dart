// lib/data/providers/cycle_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/firebase/firebase_cycle_service.dart';
import '../repositories/cycle_repository.dart';
import '../models/cycle_recommendation.dart';
import 'batch_providers.dart';

/// Cycle service provider
final cycleServiceProvider = Provider((ref) {
  return FirestoreCycleService(batchService: ref.watch(batchServiceProvider));
});

/// Cycle repository provider
final cycleRepositoryProvider = Provider<CycleRepository>((ref) {
  return CycleRepository(ref.watch(cycleServiceProvider));
});

/// Stream provider for real-time team cycles
/// Emits updates every 5 seconds with the latest cycles
final teamCyclesStreamProvider = StreamProvider.autoDispose<List<CycleRecommendation>>((ref) {
  final repository = ref.watch(cycleRepositoryProvider);
  
  return repository.streamTeamCycles();
});
