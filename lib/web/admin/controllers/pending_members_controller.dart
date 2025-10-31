// lib/controllers/pending_members_controller.dart

import 'package:flutter/material.dart';
import '../models/pending_member_model.dart';
import '../services/operator_service.dart';

class PendingMembersController extends ChangeNotifier {
  final OperatorService _operatorService = OperatorService();

  List<PendingMemberModel> _pendingMembers = [];
  bool _loading = true;
  String? _error;

  // Getters
  List<PendingMemberModel> get pendingMembers => _pendingMembers;
  bool get loading => _loading;
  String? get error => _error;
  bool get hasPendingMembers => _pendingMembers.isNotEmpty;

  // Load pending members
  Future<void> loadPendingMembers() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _pendingMembers = await _operatorService.loadPendingMembers();
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
      await _operatorService.acceptPendingMember(member);
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
      await _operatorService.declinePendingMember(member);
      _pendingMembers.removeAt(index);
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }
}
