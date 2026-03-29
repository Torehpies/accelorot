// lib/data/repositories/task_repository.dart

import '../models/task_model.dart';
import '../services/contracts/task_service.dart';

class TaskRepository {
  final TaskService _taskService;

  TaskRepository(this._taskService);

  Future<List<TaskModel>> getTasksByTeam(String teamId) =>
      _taskService.fetchTasksByTeam(teamId);

  Future<List<TaskModel>> getTasksAssignedToUser(
    String teamId,
    String userId,
  ) =>
      _taskService.fetchTasksAssignedToUser(teamId, userId);

  Future<TaskModel?> getTaskById(String teamId, String taskId) =>
      _taskService.fetchTaskById(teamId, taskId);

  Future<void> createTask(CreateTaskRequest request) =>
      _taskService.createTask(request);

  Future<void> updateTask(UpdateTaskRequest request) =>
      _taskService.updateTask(request);

  Future<void> deleteTask(String teamId, String taskId) =>
      _taskService.deleteTask(teamId, taskId);

  Stream<List<TaskModel>> watchTasksByTeam(String teamId) =>
      _taskService.watchTasksByTeam(teamId);

  Stream<List<TaskModel>> watchTasksAssignedToUser(
    String teamId,
    String userId,
  ) =>
      _taskService.watchTasksAssignedToUser(teamId, userId);
}
