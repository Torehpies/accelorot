// lib/data/providers/task_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/firebase/firebase_task_service.dart';
import '../repositories/task_repository.dart';
import '../models/task_model.dart';

final taskServiceProvider = Provider<FirebaseTaskService>((ref) {
  return FirebaseTaskService();
});

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  final service = ref.watch(taskServiceProvider);
  return TaskRepository(service);
});

final tasksByTeamStreamProvider =
    StreamProvider.family<List<TaskModel>, String>((ref, teamId) {
  final repository = ref.watch(taskRepositoryProvider);
  return repository.watchTasksByTeam(teamId);
});

final tasksAssignedToUserStreamProvider = StreamProvider.family<
    List<TaskModel>, ({String teamId, String userId})>((ref, params) {
  final repository = ref.watch(taskRepositoryProvider);
  return repository.watchTasksAssignedToUser(params.teamId, params.userId);
});

final teamTasksFutureProvider =
    FutureProvider.family<List<TaskModel>, String>((ref, teamId) async {
  final repository = ref.watch(taskRepositoryProvider);
  return repository.getTasksByTeam(teamId);
});
