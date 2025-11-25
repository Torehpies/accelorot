// lib/web/admin/controllers/web_admin_home_controller.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/operator.dart';
import '../models/machine.dart';


class WebAdminHomeController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> loadStats() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('No authenticated user');
    }

    final teamId = user.uid;

    // Load Operators
    final membersSnapshot = await _firestore
        .collection('teams')
        .doc(teamId)
        .collection('members')
        .get();

    final operators = membersSnapshot.docs
        .map((doc) => Operator.fromMap(doc.data(), doc.id))
        .toList();
    final activeOperators = operators.where((op) => !op.isArchived).length;
    final archivedOperators = operators.length - activeOperators;

    // Load Machines
    final machinesSnapshot = await _firestore
        .collection('teams')
        .doc(teamId)
        .collection('machines')
        .get();

    final machines = machinesSnapshot.docs
        .map((doc) => Machine.fromMap(doc.data(), doc.id))
        .toList();
    final activeMachines = machines.where((m) => !m.isArchived).length;
    final archivedMachines = machines.length - activeMachines;

    return {
      'activeOperators': activeOperators,
      'archivedOperators': archivedOperators,
      'activeMachines': activeMachines,
      'archivedMachines': archivedMachines,
      'operators': operators.take(7).toList(),
      'machines': machines.take(7).toList(),
    };
  }
}