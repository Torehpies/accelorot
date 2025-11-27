import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/data/models/operator_model.dart';
import 'package:flutter_application_1/data/repositories/operator_repository.dart';

class OperatorManagementViewModel extends ChangeNotifier {
  final OperatorRepository repository;
  OperatorManagementViewModel(this.repository);

  List<Operator> operators = [];
  bool loading = false;
  String? error;
  bool showArchived = false;

  String get teamId => FirebaseAuth.instance.currentUser?.uid ?? '';

  Future<void> loadOperators() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final tid = teamId;
      if (tid.isEmpty) throw Exception('No user logged in');
      operators = await repository.getOperators(tid);
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> restoreOperator(String uid) async {
    final tid = teamId;
    await repository.restore(tid, uid);
    await loadOperators();
  }

  Future<void> archiveOperator(String uid) async {
    final tid = teamId;
    await repository.archive(tid, uid);
    await loadOperators();
  }

  void toggleShowArchived() {
    showArchived = !showArchived;
    notifyListeners();
  }
}