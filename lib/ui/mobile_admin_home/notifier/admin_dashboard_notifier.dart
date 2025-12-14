// lib/ui/mobile_admin_home/notifier/admin_dashboard_notifier.dart


import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../data/providers/repository_providers.dart';
import '../../../data/models/machine_model.dart';
import '../../../data/models/operator_model.dart';

class AdminDashboardState {
  final List<OperatorModel> operators;
  final List<MachineModel> machines;
  final bool isLoading;
  final Object? error;

  const AdminDashboardState({
    this.operators = const [],
    this.machines = const [],
    this.isLoading = false,
    this.error,
  });

  AdminDashboardState copyWith({
    List<OperatorModel>? operators,
    List<MachineModel>? machines,
    bool? isLoading,
    Object? error,
  }) {
    return AdminDashboardState(
      operators: operators ?? this.operators,
      machines: machines ?? this.machines,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  int get totalOperators => operators.length;
  int get totalMachines => machines.length;
}

final adminDashboardProvider = AsyncNotifierProvider<AdminDashboardNotifier, AdminDashboardState>(
  AdminDashboardNotifier.new,
);

class AdminDashboardNotifier extends AsyncNotifier<AdminDashboardState> {
  @override
  Future<AdminDashboardState> build() async {
    return const AdminDashboardState();
  }

  Future<void> loadData() async {
    final teamId = FirebaseAuth.instance.currentUser?.uid;
    if (teamId == null) {
      state = const AsyncValue.data(AdminDashboardState());
      return;
    }

    state = const AsyncValue.loading(); // ✅ Loading state
    try {
      // ✅ Now these are defined!
      final operators = await ref.read(operatorRepositoryProvider).getOperators(teamId);
      final machines = await ref.read(machineRepositoryProvider).getMachinesByTeam(teamId);
      
      state = AsyncValue.data(AdminDashboardState(operators: operators, machines: machines));
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  void refresh() => loadData();
}