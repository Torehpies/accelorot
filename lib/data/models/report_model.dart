import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'report_model.freezed.dart';
part 'report_model.g.dart';

@freezed
abstract class ReportModel with _$ReportModel {
  const ReportModel._();
  
  const factory ReportModel({
    required String reportId,
    required String machineId,
    String? machineName,
    required String title,
    required String description,
    @Default('observation') String reportType,
    @Default('open') String status,
    @Default('medium') String priority,
    required String userName,
    String? userId,
    required DateTime createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) = _ReportModel;

  factory ReportModel.fromJson(Map<String, dynamic> json) =>
      _$ReportModelFromJson(json);

  factory ReportModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? <String, dynamic>{};
    
    return ReportModel(
      reportId: doc.id,
      machineId: data['machineId'] ?? '',
      machineName: data['machineName'] as String?,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      reportType: data['reportType'] ?? 'observation',
      status: data['status'] ?? 'open',
      priority: data['priority'] ?? 'medium',
      userName: data['userName'] ?? 'Unknown',
      userId: data['userId'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      metadata: data['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'machineId': machineId,
      if (machineName != null) 'machineName': machineName,
      'title': title,
      'description': description,
      'reportType': reportType,
      'status': status,
      'priority': priority,
      'userName': userName,
      if (userId != null) 'userId': userId,
      'createdAt': Timestamp.fromDate(createdAt),
      if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
      if (metadata != null) 'metadata': metadata,
    };
  }

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
        (machineName?.toLowerCase().contains(lowerQuery) ?? false) ||
        machineId.toLowerCase().contains(lowerQuery) ||
        userName.toLowerCase().contains(lowerQuery) ||
        reportTypeLabel.toLowerCase().contains(lowerQuery) ||
        statusLabel.toLowerCase().contains(lowerQuery) ||
        priorityLabel.toLowerCase().contains(lowerQuery);
  }
}

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