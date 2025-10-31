// lib/controllers/invitation_controller.dart

import 'package:flutter/material.dart';
import '../services/invitation_service.dart';

class InvitationController extends ChangeNotifier {
  final InvitationService _invitationService = InvitationService();

  String? _currentCode;
  String? _expiryDate;
  bool _isGenerating = false;

  // Getters
  String? get currentCode => _currentCode;
  String? get expiryDate => _expiryDate;
  bool get isGenerating => _isGenerating;

  // Get or create invitation code
  Future<bool> getOrCreateCode() async {
    _isGenerating = true;
    notifyListeners();

    try {
      final result = await _invitationService.getOrCreateInvitationCode();
      _currentCode = result['code'];
      _expiryDate = result['expiry'];
      _isGenerating = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isGenerating = false;
      notifyListeners();
      return false;
    }
  }

  // Generate new code
  Future<bool> generateNewCode() async {
    _isGenerating = true;
    notifyListeners();

    try {
      final result = await _invitationService.generateNewInvitationCode();
      _currentCode = result['code'];
      _expiryDate = result['expiry'];
      _isGenerating = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isGenerating = false;
      notifyListeners();
      return false;
    }
  }

  void reset() {
    _currentCode = null;
    _expiryDate = null;
    _isGenerating = false;
    notifyListeners();
  }
}