// lib/data/providers/substrate_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
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