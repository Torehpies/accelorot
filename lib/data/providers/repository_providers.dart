// lib/data/providers/repository_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase/firebase_substrate_service.dart';
import '../services/firebase/firebase_alert_service.dart';
import '../services/firebase/firebase_report_service.dart';
import '../services/firebase/firebase_cycle_service.dart';
import '../services/firebase/firebase_batch_service.dart';
import '../repositories/substrate_repository.dart';
import '../repositories/alert_repository.dart';
import '../repositories/report_repository.dart';
import '../repositories/cycle_repository.dart';
import '../repositories/activity__log_repository.dart';

// ===== SERVICE PROVIDERS =====

/// Batch service provider (shared dependency)
final batchServiceProvider = Provider((ref) {
  return FirestoreBatchService(FirebaseFirestore.instance);
});

/// Substrate service provider
final substrateServiceProvider = Provider((ref) {
  return FirestoreSubstrateService(
    batchService: ref.watch(batchServiceProvider),
  );
});

/// Alert service provider
final alertServiceProvider = Provider((ref) {
  return FirestoreAlertService(
    batchService: ref.watch(batchServiceProvider),
  );
});

/// Report service provider
final reportServiceProvider = Provider((ref) {
  return FirestoreReportService(
    batchService: ref.watch(batchServiceProvider),
  );
});

/// Cycle service provider
final cycleServiceProvider = Provider((ref) {
  return FirestoreCycleService(
    batchService: ref.watch(batchServiceProvider),
  );
});

// ===== REPOSITORY PROVIDERS =====

/// Substrate repository provider
final substrateRepositoryProvider = Provider<SubstrateRepository>((ref) {
  final service = ref.watch(substrateServiceProvider);
  return SubstrateRepository(service);
});

/// Alert repository provider
final alertRepositoryProvider = Provider<AlertRepository>((ref) {
  final service = ref.watch(alertServiceProvider);
  return AlertRepository(service);
});

/// Report repository provider
final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  final service = ref.watch(reportServiceProvider);
  return ReportRepository(service);
});

/// Cycle repository provider
final cycleRepositoryProvider = Provider<CycleRepository>((ref) {
  final service = ref.watch(cycleServiceProvider);
  return CycleRepository(service);
});

/// Activity repository provider (aggregates all activities for UI)
final activityRepositoryProvider = Provider<ActivityRepository>((ref) {
  return ActivityRepository(
    substrateRepo: ref.watch(substrateRepositoryProvider),
    alertRepo: ref.watch(alertRepositoryProvider),
    reportRepo: ref.watch(reportRepositoryProvider),
    cycleRepo: ref.watch(cycleRepositoryProvider),
  );
});