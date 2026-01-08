// lib/ui/web_operator/view_model/operator_management_view_model.dart

import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/repositories/operator_repository/operator_repository_remote.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/operator_model.dart';
import '../../../data/providers/operator_providers.dart';

class OperatorManagementViewModel extends ChangeNotifier {
  final Ref ref;
  final String teamId;

  OperatorManagementViewModel({
    required this.ref,
    required this.teamId, required OperatorRepositoryRemote repository,
  });

  List<OperatorModel> _operators = [];
  bool _loading = true;
  String? _error;
  bool _showArchived = false;
  String _searchQuery = '';
  OperatorModel? _selectedOperator;

  // ───────── Getters ─────────
  List<OperatorModel> get operators => _operators;
  bool get loading => _loading;
  String? get error => _error;
  bool get showArchived => _showArchived;
  String get searchQuery => _searchQuery;
  OperatorModel? get selectedOperator => _selectedOperator;

  List<OperatorModel> get filteredOperators {
    final list = _showArchived
        ? _operators.where((o) => o.isArchived || o.hasLeft)
        : _operators.where((o) => !o.isArchived && !o.hasLeft);

    if (_searchQuery.isEmpty) return list.toList();

    final query = _searchQuery.toLowerCase();
    return list.where((o) =>
        o.name.toLowerCase().contains(query) ||
        o.email.toLowerCase().contains(query)).toList();
  }

  int get archivedCount =>
      _operators.where((o) => o.isArchived || o.hasLeft).length;

  int get activeCount =>
      _operators.where((o) => !o.isArchived && !o.hasLeft).length;

  // ───────── UI State ─────────
  void setShowArchived(bool value) {
    _showArchived = value;
    notifyListeners();
  }

  void setSearchQuery(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  void setSelectedOperator(OperatorModel? operator) {
    _selectedOperator = operator;
    notifyListeners();
  }

  void clearSelectedOperator() {
    _selectedOperator = null;
    notifyListeners();
  }

  // ───────── Actions ─────────
  Future<void> loadOperators() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final repo = ref.read(operatorRepositoryProvider);
      _operators = await repo.getOperators(teamId);
    } catch (e) {
      _error = e.toString();
    }

    _loading = false;
    notifyListeners();
  }

  Future<bool> archiveOperator(OperatorModel operator) async {
    try {
      final repo = ref.read(operatorRepositoryProvider);
      await repo.archive(teamId, operator.uid);
      await loadOperators();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> restoreOperator(OperatorModel operator) async {
    if (operator.hasLeft) return false;

    try {
      final repo = ref.read(operatorRepositoryProvider);
      await repo.restore(teamId, operator.uid);
      await loadOperators();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> removeOperatorPermanently(OperatorModel operator) async {
    try {
      final repo = ref.read(operatorRepositoryProvider);
      await repo.remove(teamId, operator.uid);
      await loadOperators();
      return true;
    } catch (_) {
      return false;
    }
  }
}
