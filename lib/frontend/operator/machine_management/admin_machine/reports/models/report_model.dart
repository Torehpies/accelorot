// lib/frontend/operator/machine_management/reports/models/report_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class ReportModel {
  final String reportId;
  final String machineId;
  final String? machineName;
  final String title;
  final String description;
  final String reportType; // maintenance_issue, observation, safety_concern
  final String status; // open, in_progress, closed
  final String priority; // high, medium, low
  final String userName;
  final DateTime createdAt;

  ReportModel({
    required this.reportId,
    required this.machineId,
    this.machineName,
    required this.title,
    required this.description,
    required this.reportType,
    required this.status,
    required this.priority,
    required this.userName,
    required this.createdAt,
  });

  /// Create ReportModel from Firestore DocumentSnapshot
  factory ReportModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return ReportModel(
      reportId: doc.id,
      machineId: data['machineId'] ?? '',
      machineName: data['machineName'],
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      reportType: data['reportType'] ?? 'observation',
      status: data['status'] ?? 'open',
      priority: data['priority'] ?? 'medium',
      userName: data['userName'] ?? 'Unknown',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Convert ReportModel to Firestore-compatible Map
  Map<String, dynamic> toFirestore() {
    return {
      'machineId': machineId,
      'machineName': machineName,
      'title': title,
      'description': description,
      'reportType': reportType,
      'status': status,
      'priority': priority,
      'userName': userName,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Create a copy with updated fields
  ReportModel copyWith({
    String? reportId,
    String? machineId,
    String? machineName,
    String? title,
    String? description,
    String? reportType,
    String? status,
    String? priority,
    String? userName,
    DateTime? createdAt,
  }) {
    return ReportModel(
      reportId: reportId ?? this.reportId,
      machineId: machineId ?? this.machineId,
      machineName: machineName ?? this.machineName,
      title: title ?? this.title,
      description: description ?? this.description,
      reportType: reportType ?? this.reportType,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      userName: userName ?? this.userName,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Get human-readable report type label
  String get reportTypeLabel {
    switch (reportType.toLowerCase()) {
      case 'maintenance_issue':
        return 'Maintenance Issue';
      case 'observation':
        return 'Observation';
      case 'safety_concern':
        return 'Safety Concern';
      default:
        return reportType;
    }
  }

  /// Get human-readable status label
  String get statusLabel {
    switch (status.toLowerCase()) {
      case 'open':
        return 'Open';
      case 'in_progress':
        return 'In Progress';
      case 'closed':
        return 'Closed';
      default:
        return status;
    }
  }

  /// Get human-readable priority label
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

  /// Check if report matches search query
  bool matchesSearchQuery(String query) {
    final lowerQuery = query.toLowerCase();
    return title.toLowerCase().contains(lowerQuery) ||
        description.toLowerCase().contains(lowerQuery) ||
        (machineName?.toLowerCase().contains(lowerQuery) ?? false) ||
        machineId.toLowerCase().contains(lowerQuery) ||
        userName.toLowerCase().contains(lowerQuery) ||
        reportTypeLabel.toLowerCase().contains(lowerQuery) ||
        statusLabel.toLowerCase().contains(lowerQuery) ||
        priorityLabel.toLowerCase().contains(lowerQuery);
  }
}
