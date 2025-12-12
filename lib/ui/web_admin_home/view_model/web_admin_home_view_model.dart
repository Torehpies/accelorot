// lib/ui/web_admin_home/view_model/web_admin_home_view_model.dart

import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../data/repositories/machine_repository/machine_repository.dart';
import '../../../data/repositories/operator_repository.dart';
import '../../../data/models/operator_model.dart';
import '../../../data/models/machine_model.dart';

class WebAdminHomeViewModel extends ChangeNotifier {
  final OperatorRepository _operatorRepository;
  final MachineRepository _machineRepository;
  final String? _teamId;

  WebAdminHomeViewModel({
    required OperatorRepository operatorRepository,
    required MachineRepository machineRepository,
  })  : _operatorRepository = operatorRepository,
        _machineRepository = machineRepository,
        _teamId = FirebaseAuth.instance.currentUser?.uid;

  // --- State ---
  bool _loading = false;
  List<OperatorModel> _operators = [];
  List<MachineModel> _machines = [];

  bool get loading => _loading;
  int get activeOperators => _operators.where((o) => !o.isArchived).length;
  int get archivedOperators => _operators.where((o) => o.isArchived).length;
  int get activeMachines => _machines.where((m) => !m.isArchived).length;
  int get archivedMachines => _machines.where((m) => m.isArchived).length;
  List<OperatorModel> get recentOperators => _operators.take(7).toList();
  List<MachineModel> get recentMachines => _machines.take(7).toList();

  // --- Public Methods ---
  Future<void> loadStats() async {
    final teamId = _teamId;
    if (teamId == null) {
      debugPrint('No teamId: user not authenticated');
      return;
    }

    _loading = true;
    notifyListeners();

    try {
      // ✅ Use the correct method names from your repositories
      final operators = await _operatorRepository.getOperators(teamId);
      final machines = await _machineRepository.getMachinesByTeam(teamId);

      _operators = operators;
      _machines = machines;
    } catch (e) {
      debugPrint('Error loading dashboard stats: $e');
      // TODO: Optionally show error UI or snackbar
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}