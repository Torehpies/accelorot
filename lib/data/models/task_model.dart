// lib/data/models/task_model.dart

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'task_model.freezed.dart';
part 'task_model.g.dart';

@freezed
abstract class TaskModel with _$TaskModel {
  const factory TaskModel({
    required String id,
    required String title,
    required String description,
    required String teamId,
    String? machineId,
    String? machineName,
    required String assignedToId,
    required String assignedToName,
    required String createdById,
    required String createdByName,
    required String status, // 'pending', 'in_progress', 'completed'
    required String priority, // 'low', 'medium', 'high'
    DateTime? dueDate,
    required DateTime createdAt,
    DateTime? updatedAt,
    DateTime? completedAt,
    String? notes,
  }) = _TaskModel;

  const TaskModel._();

  factory TaskModel.fromJson(Map<String, dynamic> json) =>
      _$TaskModelFromJson(json);

  static TaskModel fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? <String, dynamic>{};

    return TaskModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      teamId: data['teamId'] ?? '',
      machineId: data['machineId'] as String?,
      machineName: data['machineName'] as String?,
      assignedToId: data['assignedToId'] ?? '',
      assignedToName: data['assignedToName'] ?? 'Unknown',
      createdById: data['createdById'] ?? '',
      createdByName: data['createdByName'] ?? 'Unknown',
      status: data['status'] ?? 'pending',
      priority: data['priority'] ?? 'medium',
      dueDate: (data['dueDate'] as Timestamp?)?.toDate(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
      notes: data['notes'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'teamId': teamId,
      if (machineId != null) 'machineId': machineId,
      if (machineName != null) 'machineName': machineName,
      'assignedToId': assignedToId,
      'assignedToName': assignedToName,
      'createdById': createdById,
      'createdByName': createdByName,
      'status': status,
      'priority': priority,
      if (dueDate != null) 'dueDate': Timestamp.fromDate(dueDate!),
      'createdAt': Timestamp.fromDate(createdAt),
      if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
      if (completedAt != null) 'completedAt': Timestamp.fromDate(completedAt!),
      if (notes != null) 'notes': notes,
    };
  }

  bool get isCompleted => status.toLowerCase() == 'completed';

  bool get isOverdue {
    if (dueDate == null || isCompleted) return false;
    return DateTime.now().isAfter(dueDate!);
  }

  String get statusLabel {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'in_progress':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      default:
        return status;
    }
  }

  String get priorityLabel {
    switch (priority.toLowerCase()) {
      case 'high':
        return 'High';
      case 'medium':
        return 'Medium';
      case 'low':
        return 'Low';
      default:
        return priority;
    }
  }

  bool matchesSearchQuery(String query) {
    final lowerQuery = query.toLowerCase();
    return title.toLowerCase().contains(lowerQuery) ||
        description.toLowerCase().contains(lowerQuery) ||
        assignedToName.toLowerCase().contains(lowerQuery) ||
        createdByName.toLowerCase().contains(lowerQuery) ||
        (machineName?.toLowerCase().contains(lowerQuery) ?? false) ||
        statusLabel.toLowerCase().contains(lowerQuery) ||
        priorityLabel.toLowerCase().contains(lowerQuery);
  }
}

@freezed
abstract class CreateTaskRequest with _$CreateTaskRequest {
  const factory CreateTaskRequest({
    required String teamId,
    required String title,
    required String description,
    required String assignedToId,
    required String assignedToName,
    required String createdByName,
    String? createdById,
    String? machineId,
    String? machineName,
    required String priority,
    DateTime? dueDate,
    String? notes,
  }) = _CreateTaskRequest;

  factory CreateTaskRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateTaskRequestFromJson(json);
}

@freezed
abstract class UpdateTaskRequest with _$UpdateTaskRequest {
  const factory UpdateTaskRequest({
    required String taskId,
    required String teamId,
    String? title,
    String? description,
    String? status,
    String? priority,
    DateTime? dueDate,
    String? notes,
    String? assignedToId,
    String? assignedToName,
  }) = _UpdateTaskRequest;

  factory UpdateTaskRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateTaskRequestFromJson(json);
}
