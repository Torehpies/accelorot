import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../data/providers/operator_providers.dart';
import '../../../../data/providers/machine_providers.dart';
import '../../../../data/models/operator_model.dart';
import '../../../../data/models/machine_model.dart';

/// STATE
class WebAdminHomeState {
  final bool loading;
  final List<OperatorModel> operators;
  final List<MachineModel> machines;

  const WebAdminHomeState({
    this.loading = false,
    this.operators = const [],
    this.machines = const [],
  });

  WebAdminHomeState copyWith({
    bool? loading,
    List<OperatorModel>? operators,
    List<MachineModel>? machines,
  }) {
    return WebAdminHomeState(
      loading: loading ?? this.loading,
      operators: operators ?? this.operators,
      machines: machines ?? this.machines,
    );
  }

  int get activeOperators => operators.where((o) => !o.isArchived).length;
  int get archivedOperators => operators.where((o) => o.isArchived).length;
  int get activeMachines => machines.where((m) => !m.isArchived).length;
  int get archivedMachines => machines.where((m) => m.isArchived).length;

  List<OperatorModel> get recentOperators => operators.take(7).toList();
  List<MachineModel> get recentMachines => machines.take(7).toList();
}

/// NOTIFIER
class WebAdminHomeNotifier extends Notifier<WebAdminHomeState> {
  @override
  WebAdminHomeState build() {
    return const WebAdminHomeState();
  }

  Future<void> loadStats() async {
    final teamId = FirebaseAuth.instance.currentUser?.uid;
    if (teamId == null) return;

    state = state.copyWith(loading: true);

    try {
      final operators =
          await ref.read(operatorRepositoryProvider).getOperators(teamId);
      final machines =
          await ref.read(machineRepositoryProvider).getMachinesByTeam(teamId);

      state = state.copyWith(
        loading: false,
        operators: operators,
        machines: machines,
      );
    } catch (e) {
      state = state.copyWith(loading: false);
    }
  }
}

/// PROVIDER
final webAdminHomeProvider =
    NotifierProvider<WebAdminHomeNotifier, WebAdminHomeState>(
  WebAdminHomeNotifier.new,
);