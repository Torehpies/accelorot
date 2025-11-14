import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../frontend/screens/admin/home_screen/models/operator_model.dart';
import '../../../frontend/screens/admin/home_screen/models/machine_model.dart';
import '../../../frontend/screens/admin/home_screen/models/admin_stats.dart';

/// Firestore service for admin dashboard data
/// Handles all Firestore queries for operators and machines
class AdminFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get admin's team ID (which is the admin's own UID)
  /// The admin's UID serves as the team document ID
  String getTeamId(String adminUid) {
    return adminUid;
  }

  /// Fetch all operators for the admin's team
  /// Returns ALL operators (both active and archived)
  /// Path: teams/{teamId}/members where role == "Operator"
  Future<List<OperatorModel>> fetchOperators(String teamId) async {
    try {
      final snapshot = await _firestore
          .collection('teams')
          .doc(teamId)
          .collection('members')
          .where('role', isEqualTo: 'Operator')
          .get();

      return snapshot.docs
          .map((doc) => OperatorModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch operators: $e');
    }
  }

  /// Fetch all machines for the admin's team
  /// Returns ALL machines (both active and archived)
  /// Path: machines where teamId == adminTeamId
  Future<List<MachineModel>> fetchMachines(String teamId) async {
    try {
      final snapshot = await _firestore
          .collection('machines')
          .where('teamId', isEqualTo: teamId)
          .get();

      return snapshot.docs
          .map((doc) => MachineModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch machines: $e');
    }
  }

  /// Fetch statistics for the admin dashboard
  /// Counts ALL operators and machines (including archived)
  Future<AdminStats> fetchStats(String teamId) async {
    try {
      // Fetch all operators
      final operatorsSnapshot = await _firestore
          .collection('teams')
          .doc(teamId)
          .collection('members')
          .where('role', isEqualTo: 'Operator')
          .get();

      // Fetch all machines
      final machinesSnapshot = await _firestore
          .collection('machines')
          .where('teamId', isEqualTo: teamId)
          .get();

      return AdminStats(
        userCount: operatorsSnapshot.docs.length,
        machineCount: machinesSnapshot.docs.length,
      );
    } catch (e) {
      throw Exception('Failed to fetch stats: $e');
    }
  }

  /// Fetch operators for preview (first 4 active operators)
  /// Used for home screen display
  Future<List<OperatorModel>> fetchOperatorsPreview(String teamId) async {
    try {
      final operators = await fetchOperators(teamId);
      return operators.where((op) => !op.isArchived).take(4).toList();
    } catch (e) {
      throw Exception('Failed to fetch operators preview: $e');
    }
  }

  /// Fetch machines for preview (first 4 active machines)
  /// Used for home screen display
  Future<List<MachineModel>> fetchMachinesPreview(String teamId) async {
    try {
      final machines = await fetchMachines(teamId);
      return machines.where((machine) => !machine.isArchived).take(4).toList();
    } catch (e) {
      throw Exception('Failed to fetch machines preview: $e');
    }
  }

  /// Stream operators in real-time
  /// Useful for live updates
  Stream<List<OperatorModel>> streamOperators(String teamId) {
    return _firestore
        .collection('teams')
        .doc(teamId)
        .collection('members')
        .where('role', isEqualTo: 'Operator')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => OperatorModel.fromFirestore(doc))
              .toList(),
        );
  }

  /// Stream machines in real-time
  /// Useful for live updates
  Stream<List<MachineModel>> streamMachines(String teamId) {
    return _firestore
        .collection('machines')
        .where('teamId', isEqualTo: teamId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => MachineModel.fromFirestore(doc))
              .toList(),
        );
  }

  /// Update operator archive status
  Future<void> updateOperatorArchiveStatus({
    required String teamId,
    required String userId,
    required bool isArchived,
  }) async {
    try {
      await _firestore
          .collection('teams')
          .doc(teamId)
          .collection('members')
          .doc(userId)
          .update({'isArchived': isArchived});
    } catch (e) {
      throw Exception('Failed to update operator status: $e');
    }
  }

  /// Update machine archive status
  Future<void> updateMachineArchiveStatus({
    required String machineId,
    required bool isArchived,
  }) async {
    try {
      await _firestore.collection('machines').doc(machineId).update({
        'isArchived': isArchived,
      });
    } catch (e) {
      throw Exception('Failed to update machine status: $e');
    }
  }
}
