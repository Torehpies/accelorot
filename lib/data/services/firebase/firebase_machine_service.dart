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
  
  CollectionReference get _machinesCollection =>
      _firestore.collection('machines');

  @override
  Future<List<MachineModel>> fetchMachinesByTeam(String teamId) async {
    try {
      final snapshot = await _machinesCollection
          .where('teamId', isEqualTo: teamId)
          .orderBy('dateCreated', descending: true)
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
    try {
      final doc = await _machinesCollection.doc(machineId).get();
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

    final exists = await machineExists(request.machineId);
    if (exists) {
      throw Exception('Machine ID already exists');
    }

    try {
      // Convert status to Firestore string value
      String statusValue;
      switch (request.status) {
        case MachineStatus.active:
          statusValue = 'Active';
          break;
        case MachineStatus.inactive:
          statusValue = 'Inactive';
          break;
        case MachineStatus.underMaintenance:
          statusValue = 'Under Maintenance';
          break;
      }

      await _machinesCollection.doc(request.machineId).set({
        'machineName': request.machineName,
        'teamId': request.teamId,
        'dateCreated': FieldValue.serverTimestamp(),
        'isArchived': false,
        'status': statusValue,
        'createdBy': currentUserId,
      });
    } catch (e) {
      throw Exception('Failed to create machine: $e');
    }
  }

  @override
  Future<void> updateMachine(UpdateMachineRequest request) async {
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
      
      if (request.status != null) {
        String statusValue;
        switch (request.status!) {
          case MachineStatus.active:
            statusValue = 'Active';
            updates['status'] = statusValue;
            updates['isArchived'] = false;
            break;
          case MachineStatus.inactive:
            statusValue = 'Inactive';
            updates['status'] = statusValue;
            updates['isArchived'] = true;
            break;
          case MachineStatus.underMaintenance:
            statusValue = 'Under Maintenance';
            updates['status'] = statusValue;
            updates['isArchived'] = false;
            break;
        }
      }
      
      if (request.currentBatchId != null) {
        updates['currentBatchId'] = request.currentBatchId;
      }
      if (request.metadata != null) {
        updates['metadata'] = request.metadata;
      }

      await _machinesCollection.doc(request.machineId).update(updates);
    } catch (e) {
      throw Exception('Failed to update machine: $e');
    }
  }

  @override
  Future<void> archiveMachine(String machineId) async {
    if (currentUserId == null) {
      throw Exception('User must be authenticated');
    }

    try {
      await _machinesCollection.doc(machineId).update({
        'isArchived': true, // KEEP: for mobile compatibility
        'status': 'Inactive', // ADD: new status field
        'archivedAt': FieldValue.serverTimestamp(),
        'archivedBy': currentUserId,
      });
    } catch (e) {
      throw Exception('Failed to archive machine: $e');
    }
  }

  @override
  Future<void> restoreMachine(String machineId) async {
    if (currentUserId == null) {
      throw Exception('User must be authenticated');
    }

    try {
      await _machinesCollection.doc(machineId).update({
        'isArchived': false, // KEEP: for mobile compatibility
        'status': 'Active', // ADD: new status field
        'restoredAt': FieldValue.serverTimestamp(),
        'restoredBy': currentUserId,
      });
    } catch (e) {
      throw Exception('Failed to restore machine: $e');
    }
  }

  @override
  Future<bool> machineExists(String machineId) async {
    try {
      final doc = await _machinesCollection.doc(machineId).get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  @override
  Stream<List<MachineModel>> watchMachinesByTeam(String teamId) {
    return _machinesCollection
        .where('teamId', isEqualTo: teamId)
        .orderBy('dateCreated', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => MachineModel.fromFirestore(doc)).toList());
  }
}