import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../contracts/machine_service.dart';
import '../../models/machine_model.dart';

class FirebaseMachineService implements MachineService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  FirebaseMachineService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  // Helper: get team-scoped machines subcollection
  CollectionReference _getMachinesCollection(String teamId) {
    return _firestore.collection('teams').doc(teamId).collection('machines');
  }

  @override
  Future<List<MachineModel>> fetchMachinesByTeam(String teamId) async {
    if (teamId.isEmpty) throw Exception('teamId is required');
    try {
      final snapshot = await _getMachinesCollection(teamId)
          .orderBy('dateCreated', descending: true) // Note: field must exist
          .get();

      return snapshot.docs
          .map((doc) => MachineModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch machines: $e');
    }
  }

  @override
  Future<MachineModel?> fetchMachineById(String machineId) async {
    // ❗ You cannot fetch by ID alone without teamId!
    // This method is **not usable** in a subcollection architecture.
    // Consider removing it or adding teamId to signature.
    throw UnimplementedError('Use fetchMachineByIdAndTeam instead');
  }

  // ✅ Alternative (recommended):
  Future<MachineModel?> fetchMachineByIdAndTeam(String teamId, String machineId) async {
    try {
      final doc = await _getMachinesCollection(teamId).doc(machineId).get();
      if (!doc.exists) return null;
      return MachineModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to fetch machine: $e');
    }
  }

  @override
  Future<void> createMachine(CreateMachineRequest request) async {
    if (currentUserId == null) {
      throw Exception('User must be authenticated');
    }
    if (request.teamId.isEmpty) {
      throw Exception('teamId is required');
    }

    // Since machines live under team, machineId only needs to be unique per team
    // So machineExists() must also include teamId!
    final exists = await machineExistsInTeam(request.teamId, request.machineId);
    if (exists) {
      throw Exception('Machine ID already exists in this team');
    }

    try {
      await _getMachinesCollection(request.teamId).doc(request.machineId).set({
        'machineId': request.machineId, // store it explicitly
        'machineName': request.machineName,
        'teamId': request.teamId,
        'dateCreated': FieldValue.serverTimestamp(),
        'isArchived': false,
        'createdBy': currentUserId,
      });
    } catch (e) {
      throw Exception('Failed to create machine: $e');
    }
  }

  @override
  Future<void> updateMachine(UpdateMachineRequest request) async {
    // ❗ Again: you need teamId to locate the machine!
    // This method signature is insufficient.
    throw UnimplementedError('updateMachine must include teamId');
  }

  // ✅ Fix: Add teamId
  Future<void> updateMachineInTeam(String teamId, UpdateMachineRequest request) async {
    if (currentUserId == null) {
      throw Exception('User must be authenticated');
    }

    try {
      final updates = <String, dynamic>{
        'lastModified': FieldValue.serverTimestamp(),
        'modifiedBy': currentUserId,
      };

      if (request.machineName != null) {
        updates['machineName'] = request.machineName;
      }
      if (request.currentBatchId != null) {
        updates['currentBatchId'] = request.currentBatchId;
      }
      if (request.metadata != null) {
        updates['metadata'] = request.metadata;
      }

      await _getMachinesCollection(teamId).doc(request.machineId).update(updates);
    } catch (e) {
      throw Exception('Failed to update machine: $e');
    }
  }

  @override
  Future<void> archiveMachine(String machineId) async {
    // ❗ Same issue: need teamId
    throw UnimplementedError('archiveMachine must include teamId');
  }

  // ✅ Proper version:
  Future<void> archiveMachineInTeam(String teamId, String machineId) async {
    if (currentUserId == null) {
      throw Exception('User must be authenticated');
    }

    try {
      await _getMachinesCollection(teamId).doc(machineId).update({
        'isArchived': true,
        'archivedAt': FieldValue.serverTimestamp(),
        'archivedBy': currentUserId,
      });
    } catch (e) {
      throw Exception('Failed to archive machine: $e');
    }
  }

  @override
  Future<void> restoreMachine(String machineId) async {
    throw UnimplementedError('restoreMachine must include teamId');
  }

  Future<void> restoreMachineInTeam(String teamId, String machineId) async {
    if (currentUserId == null) {
      throw Exception('User must be authenticated');
    }

    try {
      await _getMachinesCollection(teamId).doc(machineId).update({
        'isArchived': false,
        'restoredAt': FieldValue.serverTimestamp(),
        'restoredBy': currentUserId,
      });
    } catch (e) {
      throw Exception('Failed to restore machine: $e');
    }
  }

  @override
  Future<bool> machineExists(String machineId) async {
    // ❗ Cannot check globally — must check within a team
    throw UnimplementedError('Use machineExistsInTeam(teamId, machineId)');
  }

  Future<bool> machineExistsInTeam(String teamId, String machineId) async {
    try {
      final doc = await _getMachinesCollection(teamId).doc(machineId).get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  @override
  Stream<List<MachineModel>> watchMachinesByTeam(String teamId) {
    if (teamId.isEmpty) throw Exception('teamId is required');
    return _getMachinesCollection(teamId)
        .orderBy('dateCreated', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => MachineModel.fromFirestore(doc)).toList());
  }
}