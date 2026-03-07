// lib/data/providers/substrate_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/substrate.dart';
import '../models/substrate_preset.dart';
import '../services/firebase/firebase_substrate_service.dart';
import '../repositories/substrate_repository.dart';
import 'batch_providers.dart';

/// Substrate service provider
final substrateServiceProvider = Provider((ref) {
  return FirestoreSubstrateService(
    batchService: ref.watch(batchServiceProvider),
  );
});

/// Substrate repository provider
final substrateRepositoryProvider = Provider<SubstrateRepository>((ref) {
  return SubstrateRepository(ref.watch(substrateServiceProvider));
});

/// Stream provider for substrates of a specific batch
final batchSubstratesProvider =
    StreamProvider.family<List<Substrate>, String>((ref, batchId) {
      final repository = ref.watch(substrateRepositoryProvider);
      return repository.streamSubstratesForBatch(batchId);
    });

/// Stream provider for team substrate presets
final teamPresetsProvider =
    StreamProvider<List<SubstratePreset>>((ref) {
      final repository = ref.watch(substrateRepositoryProvider);
      return repository.streamTeamPresets();
    });

/// Stream provider for team custom substrate materials
final teamCustomMaterialsProvider =
    StreamProvider<List<SubstrateMaterial>>((ref) {
      final repository = ref.watch(substrateRepositoryProvider);
      return repository.streamTeamCustomMaterials();
    });

/// Stream provider for team custom additives
final teamCustomAdditivesProvider =
    StreamProvider<List<String>>((ref) {
      final repository = ref.watch(substrateRepositoryProvider);
      return repository.streamTeamCustomAdditives();
    });
