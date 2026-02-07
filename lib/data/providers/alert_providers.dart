// lib/data/providers/alert_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/firebase/firebase_alert_service.dart';
import '../repositories/alert_repository.dart';
import '../models/alert.dart';
import 'batch_providers.dart';

/// Alert service provider
final alertServiceProvider = Provider((ref) {
  return FirestoreAlertService(batchService: ref.watch(batchServiceProvider));
});

/// Alert repository provider
final alertRepositoryProvider = Provider<AlertRepository>((ref) {
  return AlertRepository(ref.watch(alertServiceProvider));
});

/// Stream provider for real-time team alerts
/// Emits updates every 5 seconds with the latest alerts (last 2 days by default)
final teamAlertsStreamProvider = StreamProvider.autoDispose<List<Alert>>((ref) {
  final repository = ref.watch(alertRepositoryProvider);
  final cutoffDate = DateTime.now().subtract(const Duration(days: 2));
  
  return repository.streamTeamAlerts(cutoffDate: cutoffDate);
});
