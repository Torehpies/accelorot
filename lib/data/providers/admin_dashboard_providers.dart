// lib/data/providers/admin_dashboard_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/dashboard_repository.dart'; // This should now work
import 'operator_providers.dart';
import 'machine_providers.dart';
import 'report_providers.dart';

/// Provider for DashboardRepository
final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  final operatorRepo = ref.watch(operatorRepositoryProvider);
  final machineRepo = ref.watch(machineRepositoryProvider);
  final reportRepo = ref.watch(reportRepositoryProvider);

  return DashboardRepositoryImpl(
    operatorRepo: operatorRepo,
    machineRepo: machineRepo,
    reportRepo: reportRepo,
  );
});