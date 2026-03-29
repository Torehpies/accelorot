// lib/ui/tasks/services/task_aggregator_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../data/models/task_model.dart';
import '../../../data/repositories/task_repository.dart';

class TaskAggregatorService {
  final TaskRepository _taskRepo;
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  TaskAggregatorService({
    required TaskRepository taskRepo,
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _taskRepo = taskRepo,
        _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  Future<bool> isUserLoggedIn() async {
    final userId = _auth.currentUser?.uid;
    return userId != null && userId.isNotEmpty;
  }

  Future<String?> _getCurrentTeamId() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    final userDoc = await _firestore.collection('users').doc(uid).get();
    return userDoc.data()?['teamId'] as String?;
  }

  Future<String?> _getCurrentTeamRole() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    final userDoc = await _firestore.collection('users').doc(uid).get();
    return (userDoc.data()?['teamRole'] as String?)?.toLowerCase();
  }

  Future<String?> _getCurrentUserName() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    final userDoc = await _firestore.collection('users').doc(uid).get();
    final data = userDoc.data();
    if (data == null) return null;
    final firstName = data['firstName'] as String? ?? '';
    final lastName = data['lastName'] as String? ?? '';
    final fullName = '$firstName $lastName'.trim();
    return fullName.isNotEmpty ? fullName : data['email'] as String?;
  }

  Future<List<TaskModel>> getTasks() async {
    try {
      final teamId = await _getCurrentTeamId();
      if (teamId == null) return [];

      final uid = _auth.currentUser?.uid;
      final teamRole = await _getCurrentTeamRole();

      List<TaskModel> tasks;
      if (teamRole == 'operator' && uid != null) {
        tasks = await _taskRepo.getTasksAssignedToUser(teamId, uid);
      } else {
        tasks = await _taskRepo.getTasksByTeam(teamId);
      }

      tasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return tasks;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> createTask(CreateTaskRequest request) async {
    try {
      await _taskRepo.createTask(request);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateTask(UpdateTaskRequest request) async {
    try {
      await _taskRepo.updateTask(request);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, String?>> getCurrentUserInfo() async {
    final uid = _auth.currentUser?.uid;
    final name = await _getCurrentUserName();
    final teamId = await _getCurrentTeamId();
    final teamRole = await _getCurrentTeamRole();
    return {
      'uid': uid,
      'name': name,
      'teamId': teamId,
      'teamRole': teamRole,
    };
  }
}
