// lib/data/services/firebase/firebase_task_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../contracts/task_service.dart';
import '../../models/task_model.dart';

class FirebaseTaskService implements TaskService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  FirebaseTaskService({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  String get _currentUserId {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');
    return user.uid;
  }

  CollectionReference _tasksCollection(String teamId) =>
      _firestore.collection('teams').doc(teamId).collection('tasks');

  @override
  Future<List<TaskModel>> fetchTasksByTeam(String teamId) async {
    try {
      final snapshot = await _tasksCollection(teamId)
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => TaskModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch tasks: $e');
    }
  }

  @override
  Future<List<TaskModel>> fetchTasksAssignedToUser(
    String teamId,
    String userId,
  ) async {
    try {
      final snapshot = await _tasksCollection(teamId)
          .where('assignedToId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => TaskModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch assigned tasks: $e');
    }
  }

  @override
  Future<TaskModel?> fetchTaskById(String teamId, String taskId) async {
    try {
      final doc = await _tasksCollection(teamId).doc(taskId).get();
      if (!doc.exists) return null;
      return TaskModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to fetch task: $e');
    }
  }

  @override
  Future<void> createTask(CreateTaskRequest request) async {
    try {
      final userId = request.createdById ?? _currentUserId;
      final timestamp = DateTime.now();
      final docId = 'task_${timestamp.millisecondsSinceEpoch}';

      final task = TaskModel(
        id: docId,
        title: request.title,
        description: request.description,
        teamId: request.teamId,
        machineId: request.machineId,
        machineName: request.machineName,
        assignedToId: request.assignedToId,
        assignedToName: request.assignedToName,
        createdById: userId,
        createdByName: request.createdByName,
        status: 'pending',
        priority: request.priority,
        dueDate: request.dueDate,
        createdAt: timestamp,
        notes: request.notes,
      );

      await _tasksCollection(request.teamId).doc(docId).set(task.toFirestore());
    } catch (e) {
      throw Exception('Failed to create task: $e');
    }
  }

  @override
  Future<void> updateTask(UpdateTaskRequest request) async {
    try {
      final updateData = <String, dynamic>{'updatedAt': Timestamp.now()};

      if (request.title != null) updateData['title'] = request.title;
      if (request.description != null) {
        updateData['description'] = request.description;
      }
      if (request.status != null) {
        updateData['status'] = request.status;
        if (request.status == 'completed') {
          updateData['completedAt'] = Timestamp.now();
        }
      }
      if (request.priority != null) updateData['priority'] = request.priority;
      if (request.dueDate != null) {
        updateData['dueDate'] = Timestamp.fromDate(request.dueDate!);
      }
      if (request.notes != null) updateData['notes'] = request.notes;
      if (request.assignedToId != null) {
        updateData['assignedToId'] = request.assignedToId;
      }
      if (request.assignedToName != null) {
        updateData['assignedToName'] = request.assignedToName;
      }

      await _tasksCollection(request.teamId)
          .doc(request.taskId)
          .update(updateData);
    } catch (e) {
      throw Exception('Failed to update task: $e');
    }
  }

  @override
  Future<void> deleteTask(String teamId, String taskId) async {
    try {
      await _tasksCollection(teamId).doc(taskId).delete();
    } catch (e) {
      throw Exception('Failed to delete task: $e');
    }
  }

  @override
  Stream<List<TaskModel>> watchTasksByTeam(String teamId) {
    return _tasksCollection(teamId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => TaskModel.fromFirestore(doc)).toList());
  }

  @override
  Stream<List<TaskModel>> watchTasksAssignedToUser(
    String teamId,
    String userId,
  ) {
    return _tasksCollection(teamId)
        .where('assignedToId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => TaskModel.fromFirestore(doc)).toList());
  }
}
