// lib/data/models/report.dart

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'report.freezed.dart';

/// Pure data model for machine reports
/// No UI concerns - just data
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
    required String priority, // 'low', 'medium', 'high', 'critical'
    required String status, // 'open', 'resolved'
    required DateTime createdAt,
    DateTime? resolvedAt,
    String? resolvedBy,
  }) = _Report;

  const Report._();

  // ===== FIRESTORE CONVERSION =====

  /// Create from Firestore document
  static Report fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return Report(
      id: doc.id,
      reportType: data['reportType'] ?? '',
      title: data['title'] ?? '',
      machineId: data['machineId'] ?? '',
      machineName: data['machineName'] ?? 'Unknown Machine',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? 'Unknown',
      userRole: data['userRole'] ?? 'Unknown',
      description: data['description'] ?? '',
      priority: data['priority'] ?? 'low',
      status: data['status'] ?? 'open',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      resolvedAt: (data['resolvedAt'] as Timestamp?)?.toDate(),
      resolvedBy: data['resolvedBy'],
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
      'resolvedAt': resolvedAt != null ? Timestamp.fromDate(resolvedAt!) : null,
      'resolvedBy': resolvedBy,
    };
  }

  // ===== DATA LOGIC HELPERS =====
  
  /// Check if report is resolved
  bool get isResolved => status.toLowerCase() == 'resolved';

}