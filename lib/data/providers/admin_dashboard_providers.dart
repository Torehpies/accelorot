// lib/data/providers/dashboard_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/admin_dashboard_repository.dart';
//import '../repositories/operator_repository/operator_repository.dart';
//import '../repositories/machine_repository/machine_repository.dart';
//import '../repositories/report_repository.dart';
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