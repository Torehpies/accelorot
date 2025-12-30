// lib/data/models/report.dart

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'report.freezed.dart';
part 'report.g.dart';

/// Unified report model combining data layer and UI layer needs
/// Replaces both report.dart and report_model.dart
@freezed
abstract class Report with _$Report {
  const factory Report({
    required String id,
    required String reportType, // 'maintenance_issue', 'observation', 'safety_concern'
    required String title,
    required String machineId,
    required String machineName,
    required String userId,
    required String userName,
    required String userRole,
    required String description,
    required String priority, // 'low', 'medium', 'high'
    required String status, // 'open', 'in_progress', 'completed', 'on_hold'
    required DateTime createdAt,
    DateTime? updatedAt,
    DateTime? resolvedAt,
    String? resolvedBy,
    Map<String, dynamic>? metadata,
  }) = _Report;

  const Report._();

  // ===== JSON SERIALIZATION (for report_model compatibility) =====
  
  factory Report.fromJson(Map<String, dynamic> json) => _$ReportFromJson(json);

  // ===== FIRESTORE CONVERSION (for report.dart compatibility) =====

  /// Create from Firestore document
  static Report fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? <String, dynamic>{};
    
    return Report(
      id: doc.id, 
      reportType: data['reportType'] ?? 'observation',  
      title: data['title'] ?? '',
      machineId: data['machineId'] ?? '',
      machineName: data['machineName'] ?? 'Unknown Machine',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? 'Unknown',
      userRole: data['userRole'] ?? 'operator',
      description: data['description'] ?? '',
      priority: data['priority'] ?? 'medium',
      status: data['status'] ?? 'open',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      resolvedAt: (data['resolvedAt'] as Timestamp?)?.toDate(),
      resolvedBy: data['resolvedBy'],
      metadata: data['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'reportType': reportType,
      'title': title,
      'machineId': machineId,
      'machineName': machineName,
      'userId': userId,
      'userName': userName,
      'userRole': userRole,
      'description': description,
      'priority': priority,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
      if (resolvedAt != null) 'resolvedAt': Timestamp.fromDate(resolvedAt!),
      if (resolvedBy != null) 'resolvedBy': resolvedBy,
      if (metadata != null) 'metadata': metadata,
    };
  }

  // ===== DISPLAY HELPERS (for UI compatibility) =====

  /// Check if report is resolved
  bool get isResolved => status.toLowerCase() == 'completed' || status.toLowerCase() == 'on_hold';

  /// Get formatted report type label
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

  /// Get formatted status label
  String get statusLabel {
    switch (status.toLowerCase()) {
      case 'open':
        return 'Open';
      case 'in_progress':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      case 'on_hold':
        return 'On Hold';
      default:
        return status;
    }
  }

  /// Get formatted priority label
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

  /// Check if report matches search query (for filtering)
  bool matchesSearchQuery(String query) {
    final lowerQuery = query.toLowerCase();
    return title.toLowerCase().contains(lowerQuery) ||
        description.toLowerCase().contains(lowerQuery) ||
        machineName.toLowerCase().contains(lowerQuery) ||
        machineId.toLowerCase().contains(lowerQuery) ||
        userName.toLowerCase().contains(lowerQuery) ||
        reportTypeLabel.toLowerCase().contains(lowerQuery) ||
        statusLabel.toLowerCase().contains(lowerQuery) ||
        priorityLabel.toLowerCase().contains(lowerQuery);
  }
}

// ===== REQUEST MODELS (for mutations) =====

@freezed
abstract class CreateReportRequest with _$CreateReportRequest {
  const factory CreateReportRequest({
    required String machineId,
    String? machineName,
    required String title,
    required String description,
    required String reportType,
    required String priority,
    required String userName,
    String? userId,
  }) = _CreateReportRequest;
  
  factory CreateReportRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateReportRequestFromJson(json);
}

@freezed
abstract class UpdateReportRequest with _$UpdateReportRequest {
  const factory UpdateReportRequest({
    required String reportId,
    String? title,
    String? description,
    String? status,
    String? priority,
    Map<String, dynamic>? metadata,
  }) = _UpdateReportRequest;
  
  factory UpdateReportRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateReportRequestFromJson(json);
}