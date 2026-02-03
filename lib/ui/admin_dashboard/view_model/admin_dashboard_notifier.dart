// lib/ui/mobile_admin_home/view_model/admin_dashboard_notifier.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../data/providers/operator_providers.dart';
import '../../../data/providers/machine_providers.dart';
import '../../../data/providers/profile_providers.dart';
import '../../../data/providers/report_providers.dart';
import '../../../data/models/machine_model.dart';
import '../../../data/models/operator_model.dart';
import '../../../data/models/report.dart';

class AdminDashboardState {
  final List<OperatorModel> operators;
  final List<MachineModel> machines;
  final List<Report> reports;
  final bool isLoading;
  final Object? error;

  const AdminDashboardState({
    this.operators = const [],
    this.machines = const [],
    this.reports = const [],
    this.isLoading = false,
    this.error,
  });

  AdminDashboardState copyWith({
    List<OperatorModel>? operators,
    List<MachineModel>? machines,
    List<Report>? reports,
    bool? isLoading,
    Object? error,
  }) {
    return AdminDashboardState(
      operators: operators ?? this.operators,
      machines: machines ?? this.machines,
      reports: reports ?? this.reports,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  int get totalOperators => operators.length;
  int get totalMachines => machines.length;
  int get totalReports => reports.length;
}

class AdminDashboardNotifier extends AsyncNotifier<AdminDashboardState> {
  @override
  Future<AdminDashboardState> build() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      return const AdminDashboardState();
    }

    try {
      final profile = await ref
          .read(profileRepositoryProvider)
          .getCurrentProfile();
      final teamId = profile?.teamId;

      if (teamId == null) {
        return const AdminDashboardState();
      }

      // Use existing repository methods and stream providers
      final operators = await ref
          .read(operatorRepositoryProvider)
          .getOperators(teamId);
      final machines = await ref.read(machinesStreamProvider(teamId).future);
      final reports = await ref.read(reportRepositoryProvider).getTeamReports();

      return AdminDashboardState(
        operators: operators,
        machines: machines,
        reports: reports,
      );
    } catch (e) {
      return AdminDashboardState(error: e);
    }
  }

  Future<void> loadData() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      state = const AsyncValue.data(AdminDashboardState());
      return;
    }

    state = const AsyncValue.loading();

    try {
      final profile = await ref
          .read(profileRepositoryProvider)
          .getCurrentProfile();
      final teamId = profile?.teamId;

      if (teamId == null) {
        state = const AsyncValue.data(AdminDashboardState());
        return;
      }

      final operators = await ref
          .read(operatorRepositoryProvider)
          .getOperators(teamId);
      final machines = await ref.read(machinesStreamProvider(teamId).future);
      final reports = await ref.read(reportRepositoryProvider).getTeamReports();

      state = AsyncValue.data(
        AdminDashboardState(
          operators: operators,
          machines: machines,
          reports: reports,
        ),
      );
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  void refresh() => loadData();
}

// Provider must be at the top level (not inside a class)
final adminDashboardProvider =
    AsyncNotifierProvider<AdminDashboardNotifier, AdminDashboardState>(
      () => AdminDashboardNotifier(),
    );
