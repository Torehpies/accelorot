// lib/ui/web_operator/view_modal/operator_management_view_model.dart

import 'package:flutter/material.dart';
import '../../../data/models/operator_model.dart';
import '../../../data/repositories/operator_repository.dart';

class OperatorManagementViewModel extends ChangeNotifier {
  final OperatorRepository _repository;
  final String _teamId; // Add teamId field

  OperatorManagementViewModel({
    required OperatorRepository repository,
    required String teamId,
  })  : _repository = repository,
        _teamId = teamId;

  List<OperatorModel> _operators = [];
  bool _loading = true;
  String? _error;
  bool _showArchived = false;
  String _searchQuery = '';
  OperatorModel? _selectedOperator;

  // Getters
  List<OperatorModel> get operators => _operators;
  bool get loading => _loading;
  String? get error => _error;
  bool get showArchived => _showArchived;
  String get searchQuery => _searchQuery;
  OperatorModel? get selectedOperator => _selectedOperator;

  List<OperatorModel> get filteredOperators {
    final currentList = _showArchived
        ? _operators.where((o) => o.isArchived || o.hasLeft).toList()
        : _operators.where((o) => !o.isArchived && !o.hasLeft).toList();

    if (_searchQuery.isEmpty) return currentList;

    return currentList.where((operator) {
      final name = operator.name.toLowerCase();
      final email = operator.email.toLowerCase();
      final query = _searchQuery.toLowerCase();
      return name.contains(query) || email.contains(query);
    }).toList();
  }

  int get archivedCount =>
      _operators.where((o) => o.isArchived || o.hasLeft).length;
  int get activeCount =>
      _operators.where((o) => !o.isArchived && !o.hasLeft).length;

  // Setters
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

  // Load operators
  Future<void> loadOperators() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _operators = await _repository.getOperators(_teamId);
      _loading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _loading = false;
      notifyListeners();
    }
  }

  // Archive operator
  Future<bool> archiveOperator(OperatorModel operator) async {
    try {
      await _repository.archive(_teamId, operator.uid);
      await loadOperators();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Restore operator
  Future<bool> restoreOperator(OperatorModel operator) async {
    if (operator.hasLeft) {
      return false;
    }

    try {
      await _repository.restore(_teamId, operator.uid);
      await loadOperators();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Remove operator permanently
  Future<bool> removeOperatorPermanently(OperatorModel operator) async {
    try {
      await _repository.remove(_teamId, operator.uid);
      await loadOperators();
      return true;
    } catch (e) {
      return false;
    }
  }
}