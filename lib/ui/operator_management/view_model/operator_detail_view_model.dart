import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/data/repositories/operator_repository.dart';

class OperatorDetailViewModel extends ChangeNotifier {
  final OperatorRepository repository;
  OperatorDetailViewModel(this.repository);

  bool processing = false;
  String get teamId => FirebaseAuth.instance.currentUser?.uid ?? '';

  Future<void> archive(String operatorUid) async {
    processing = true;
    notifyListeners();
    try {
      await repository.archive(teamId, operatorUid);
    } finally {
      processing = false;
      notifyListeners();
    }
  }

  Future<void> remove(String operatorUid) async {
    processing = true;
    notifyListeners();
    try {
      await repository.remove(teamId, operatorUid);
    } finally {
      processing = false;
      notifyListeners();
    }
  }
}