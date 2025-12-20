// lib/ui/web_admin_home/view_model/web_admin_home_view_model.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../data/repositories/operator_repository/operator_repository.dart';
import '../../../../data/repositories/machine_repository/machine_repository.dart';
import '../../../../data/models/operator_model.dart';
import '../../../../data/models/machine_model.dart';

class WebAdminHomeViewModel extends ChangeNotifier {
  final OperatorRepository operatorRepository;
  final MachineRepository machineRepository;

  WebAdminHomeViewModel({
    required this.operatorRepository,
    required this.machineRepository,
  });

  final String? _teamId = FirebaseAuth.instance.currentUser?.uid;

  bool _loading = false;
  bool get loading => _loading;

  List<OperatorModel> _operators = [];
  List<MachineModel> _machines = [];

  int get activeOperators => _operators.where((o) => !o.isArchived).length;
  int get archivedOperators => _operators.where((o) => o.isArchived).length;
  int get activeMachines => _machines.where((m) => !m.isArchived).length;
  int get archivedMachines => _machines.where((m) => m.isArchived).length;

  List<OperatorModel> get recentOperators => _operators.take(7).toList();
  List<MachineModel> get recentMachines => _machines.take(7).toList();

  Future<void> loadStats() async {
    if (_teamId == null) return;

    _loading = true;
    notifyListeners();

    try {
      _operators = await operatorRepository.getOperators(_teamId);
      _machines = await machineRepository.getMachinesByTeam(_teamId);
    } catch (e) {
      debugPrint('WebAdminHomeViewModel error: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
