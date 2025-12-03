// lib/data/providers/report_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/firebase/firebase_report_service.dart';
import '../repositories/report_repository.dart';
import 'batch_providers.dart';

/// Report service provider
final reportServiceProvider = Provider((ref) {
  return FirestoreReportService(
    batchService: ref.watch(batchServiceProvider),
  );
});

/// Report repository provider
final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  return ReportRepository(ref.watch(reportServiceProvider));
});