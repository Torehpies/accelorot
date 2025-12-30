// lib/ui/mobile_admin_home/notifier/admin_dashboard_notifier.dart


import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../data/providers/operator_providers.dart';
import '../../../data/providers/machine_providers.dart';
import '../../../data/providers/profile_providers.dart';
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
    final userId = FirebaseAuth.instance.currentUser?.uid;
    
    if (userId == null) {
      return const AdminDashboardState();
    }

    try {
      // Fetch user profile to get teamId
      final profile = await ref.read(profileRepositoryProvider).getProfileByUid(userId);
    
      final teamId = profile?.teamId;
      
      if (teamId == null) {
        return const AdminDashboardState();
      }

      final operators = await ref.read(operatorRepositoryProvider).getOperators(teamId);
      final machines = await ref.read(machineRepositoryProvider).getMachinesByTeam(teamId);
      
      return AdminDashboardState(operators: operators, machines: machines);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> loadData() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    print('🔄 AdminDashboard loadData - userId: $userId');
    
    if (userId == null) {
      state = const AsyncValue.data(AdminDashboardState());
      return;
    }

    state = const AsyncValue.loading();
    try {
      // Fetch user profile to get teamId
      final profile = await ref.read(profileRepositoryProvider).getProfileByUid(userId);
      final teamId = profile?.teamId;
      
      if (teamId == null) {
        // User not assigned to a team yet
        state = const AsyncValue.data(AdminDashboardState());
        return;
      }


      final operators = await ref.read(operatorRepositoryProvider).getOperators(teamId);
      final machines = await ref.read(machineRepositoryProvider).getMachinesByTeam(teamId);
      

      state = AsyncValue.data(AdminDashboardState(operators: operators, machines: machines));
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  void refresh() => loadData();
}