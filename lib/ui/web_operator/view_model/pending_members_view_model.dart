// lib/ui/web_operator/view_modal/pending_members_view_model.dart

import 'package:flutter/material.dart';

import '../../../data/repositories/operator_repository/operator_repository.dart';

class PendingMembersViewModel extends ChangeNotifier {
  final OperatorRepository repository;
  final String teamId;

  PendingMembersViewModel({
    required this.repository,
    required this.teamId,
  });

  List<Map<String, dynamic>> _pendingMembers = [];
  bool _loading = true;
  String? _error;

  // ───────── Getters ─────────
  List<Map<String, dynamic>> get pendingMembers => _pendingMembers;
  bool get loading => _loading;
  String? get error => _error;
  bool get hasPendingMembers => _pendingMembers.isNotEmpty;

  // ───────── Load ─────────
  Future<void> loadPendingMembers() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _pendingMembers = await repository.getPendingMembers(teamId);
    } catch (e) {
      _error = e.toString();
    }

    _loading = false;
    notifyListeners();
  }

  // ───────── Accept ─────────
  Future<bool> acceptInvitation(int index) async {
    if (index < 0 || index >= _pendingMembers.length) return false;

    final member = _pendingMembers[index];

    try {
      await repository.accept(
        teamId: teamId,
        requestorId: member['requestorId'] as String,
        name: member['name'] as String,
        email: member['email'] as String,
        pendingDocId: member['id'] as String,
      );

      _pendingMembers.removeAt(index);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  // ───────── Decline ─────────
  Future<bool> declineInvitation(int index) async {
    if (index < 0 || index >= _pendingMembers.length) return false;

    final member = _pendingMembers[index];

    try {
      await repository.decline(
        teamId: teamId,
        requestorId: member['requestorId'] as String,
        pendingDocId: member['id'] as String,
      );

      _pendingMembers.removeAt(index);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }
}
