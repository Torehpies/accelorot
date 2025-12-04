// lib/ui/web_operator/view_modal/pending_members_view_model.dart

import 'package:flutter/material.dart';
import '../../../data/repositories/operator_repository.dart';

class PendingMembersViewModel extends ChangeNotifier {
  final OperatorRepository _repository;
  final String _teamId;

  PendingMembersViewModel({
    required OperatorRepository repository,
    required String teamId,
  })  : _repository = repository,
        _teamId = teamId;

  List<Map<String, dynamic>> _pendingMembers = [];
  bool _loading = true;
  String? _error;

  // Getters
  List<Map<String, dynamic>> get pendingMembers => _pendingMembers;
  bool get loading => _loading;
  String? get error => _error;
  bool get hasPendingMembers => _pendingMembers.isNotEmpty;

  // Load pending members
  Future<void> loadPendingMembers() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _pendingMembers = await _repository.getPendingMembers(_teamId);
      _loading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _loading = false;
      notifyListeners();
    }
  }

  // Accept invitation
  Future<bool> acceptInvitation(int index) async {
    if (index < 0 || index >= _pendingMembers.length) {
      return false;
    }

    final member = _pendingMembers[index];

    try {
      await _repository.accept(
        teamId: _teamId,
        requestorId: member['requestorId'] as String,
        name: member['name'] as String,
        email: member['email'] as String,
        pendingDocId: member['id'] as String,
      );
      _pendingMembers.removeAt(index);
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Decline invitation
  Future<bool> declineInvitation(int index) async {
    if (index < 0 || index >= _pendingMembers.length) {
      return false;
    }

    final member = _pendingMembers[index];

    try {
      await _repository.decline(
        teamId: _teamId,
        requestorId: member['requestorId'] as String,
        pendingDocId: member['id'] as String,
      );
      _pendingMembers.removeAt(index);
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }
}