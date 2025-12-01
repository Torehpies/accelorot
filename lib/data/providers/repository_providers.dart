// lib/data/providers/repository_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../repositories/activity_repository.dart';
import '../services/contracts/substrate_service.dart';
import '../services/contracts/alert_service.dart';
import '../services/contracts/report_service.dart';
import '../services/contracts/cycle_service.dart';
import '../services/contracts/batch_service.dart';
import '../services/firebase/firestore_substrate_service.dart';
import '../services/firebase/firestore_alert_service.dart';
import '../services/firebase/firestore_report_service.dart';
import '../services/firebase/firestore_cycle_service.dart';
import '../services/firebase/firestore_batch_service.dart';

// ===== FIRESTORE INSTANCE =====

final _firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

// ===== SERVICE PROVIDERS =====

final batchServiceProvider = Provider<BatchService>((ref) {
  final firestore = ref.read(_firestoreProvider);
  return FirestoreBatchService(firestore);
});

final substrateServiceProvider = Provider<SubstrateService>((ref) {
  final firestore = ref.read(_firestoreProvider);
  final batchService = ref.read(batchServiceProvider);
  return FirestoreSubstrateService(firestore, batchService);
});

final alertServiceProvider = Provider<AlertService>((ref) {
  final batchService = ref.read(batchServiceProvider);
  return FirestoreAlertService(batchService);
});

final reportServiceProvider = Provider<ReportService>((ref) {
  final firestore = ref.read(_firestoreProvider);
  return FirestoreReportService(firestore);
});

final cycleServiceProvider = Provider<CycleService>((ref) {
  final batchService = ref.read(batchServiceProvider);
  return FirestoreCycleService(batchService);
});

// ===== REPOSITORY PROVIDER =====

/// Provider for activity repository
/// Returns abstract interface, concrete implementation is ActivityLogsRepository
final activityRepositoryProvider = Provider<ActivityRepository>((ref) {
  return ActivityLogsRepository(
    substrateService: ref.read(substrateServiceProvider),
    alertService: ref.read(alertServiceProvider),
    reportService: ref.read(reportServiceProvider),
    cycleService: ref.read(cycleServiceProvider),
    batchService: ref.read(batchServiceProvider),
  );
});
