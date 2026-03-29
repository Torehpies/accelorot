// lib/data/services/contracts/task_service.dart

import '../../models/task_model.dart';

abstract class TaskService {
  Future<List<TaskModel>> fetchTasksByTeam(String teamId);
  Future<List<TaskModel>> fetchTasksAssignedToUser(
    String teamId,
    String userId,
  );
  Future<TaskModel?> fetchTaskById(String teamId, String taskId);
  Future<void> createTask(CreateTaskRequest request);
  Future<void> updateTask(UpdateTaskRequest request);
  Future<void> deleteTask(String teamId, String taskId);
  Stream<List<TaskModel>> watchTasksByTeam(String teamId);
  Stream<List<TaskModel>> watchTasksAssignedToUser(
    String teamId,
    String userId,
  );
}
