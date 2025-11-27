import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/data/repositories/operator_repository.dart';

class AcceptOperatorViewModel extends ChangeNotifier {
  final OperatorRepository repository;
  AcceptOperatorViewModel(this.repository);

  List<Map<String, dynamic>> pendingMembers = [];
  bool loading = false;
  String? error;

  String get teamId => FirebaseAuth.instance.currentUser?.uid ?? '';

  Future<void> loadPending() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final tid = teamId;
      if (tid.isEmpty) throw Exception('No user logged in');
      final raw = await repository.getPendingMembers(tid);
      
      // Add formatted date
      pendingMembers = raw.map((m) {
        return {
          ...m,
          'requestedAt': m['requestedAt'] as DateTime?,
        };
      }).toList();
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> accept(int index) async {
    final item = pendingMembers[index];
    await repository.accept(
      teamId: teamId,
      requestorId: item['requestorId'],
      name: item['name'] ?? 'Unknown',
      email: item['email'] ?? '',
      pendingDocId: item['id'],
    );
    await loadPending();
  }

  Future<void> decline(int index) async {
    final item = pendingMembers[index];
    await repository.decline(
      teamId: teamId,
      requestorId: item['requestorId'],
      pendingDocId: item['id'],
    );
    await loadPending();
  }
}