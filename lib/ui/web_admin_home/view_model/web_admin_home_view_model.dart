// lib/ui/web_admin_home/view_model/web_admin_home_view_model.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Data model for cleaner state
class AdminStats {
  final int activeOperators;
  final int archivedOperators;
  final int activeMachines;
  final int archivedMachines;
  final List<Map<String, dynamic>> operators;
  final List<Map<String, dynamic>> machines;

  AdminStats({
    required this.activeOperators,
    required this.archivedOperators,
    required this.activeMachines,
    required this.archivedMachines,
    required this.operators,
    required this.machines,
  });
}

// Riverpod AsyncNotifier
class WebAdminHomeNotifier extends AsyncNotifier<AdminStats> {
  @override
  Future<AdminStats> build() async {
    return _loadStats();
  }

  Future<AdminStats> _loadStats() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Return empty stats if no user
      return AdminStats(
        activeOperators: 0,
        archivedOperators: 0,
        activeMachines: 0,
        archivedMachines: 0,
        operators: [],
        machines: [],
      );
    }

    final teamId = user.uid;
    final firestore = FirebaseFirestore.instance;

    // Load Operators
    final membersSnapshot = await firestore
        .collection('teams')
        .doc(teamId)
        .collection('members')
        .get();

    final activeOperators = membersSnapshot.docs
        .where((doc) => doc.data()['isArchived'] != true)
        .length;
    final archivedOperators = membersSnapshot.docs.length - activeOperators;

    final operators = membersSnapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'id': doc.id,
        'name': data['name'] ?? '—',
        'email': data['email'] ?? '—',
        'isArchived': data['isArchived'] == true,
      };
    }).toList().take(7).toList();

    // Load Machines
    final machinesSnapshot = await firestore
        .collection('teams')
        .doc(teamId)
        .collection('machines')
        .get();

    final activeMachines = machinesSnapshot.docs
        .where((doc) => doc.data()['isArchived'] != true)
        .length;
    final archivedMachines = machinesSnapshot.docs.length - activeMachines;

    final machines = machinesSnapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'id': doc.id,
        'name': data['name'] ?? '—',
        'machineId': data['machineId'] ?? '—',
        'isArchived': data['isArchived'] == true,
      };
    }).toList().take(7).toList();

    return AdminStats(
      activeOperators: activeOperators,
      archivedOperators: archivedOperators,
      activeMachines: activeMachines,
      archivedMachines: archivedMachines,
      operators: operators,
      machines: machines,
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_loadStats);
  }
}

// Provider
final webAdminHomeProvider = AsyncNotifierProvider<WebAdminHomeNotifier, AdminStats>(
  WebAdminHomeNotifier.new,
);