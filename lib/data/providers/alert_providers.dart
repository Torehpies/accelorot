// lib/data/providers/alert_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/firebase/firebase_alert_service.dart';
import '../repositories/alert_repository.dart';
import 'batch_providers.dart';

/// Alert service provider
final alertServiceProvider = Provider((ref) {
  return FirestoreAlertService(
    batchService: ref.watch(batchServiceProvider),
  );
});

/// Alert repository provider
final alertRepositoryProvider = Provider<AlertRepository>((ref) {
  return AlertRepository(ref.watch(alertServiceProvider));
});