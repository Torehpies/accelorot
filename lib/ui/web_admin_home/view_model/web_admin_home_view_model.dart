// lib/ui/web_admin_home/view_model/web_admin_home_view_model.dart

import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../data/repositories/admin_dashboard_repository.dart';

class WebAdminHomeViewModel extends ChangeNotifier {
  final AdminDashboardRepository _repository;
  final String? _teamId;

  WebAdminHomeViewModel(AdminDashboardRepository repository)
      : _repository = repository,
        _teamId = FirebaseAuth.instance.currentUser?.uid;

  bool _loading = false;
  AdminDashboardStats? _stats;

  bool get loading => _loading;
  AdminDashboardStats? get stats => _stats;

  Future<void> loadStats() async {
    if (_teamId == null) return;

    _loading = true;
    notifyListeners();

    try {
      _stats = await _repository.loadStats(_teamId);
    } catch (e) {
      // TODO: Handle error (e.g., via callback or state)
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}