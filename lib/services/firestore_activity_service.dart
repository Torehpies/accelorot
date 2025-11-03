// lib/services/firestore_activity_service.dart
import 'package:flutter_application_1/frontend/screens/admin/operator_management/operator_view_service.dart';
import 'package:flutter_application_1/frontend/operator/activity_logs/models/activity_item.dart';
import 'firestore/firestore_collections.dart';
import 'firestore/firestore_upload.dart';
import 'firestore/firestore_fetch.dart';

class FirestoreActivityService {
  // ⭐ CRITICAL: Get the current logged-in user ID (for authentication checks only)
  static String? getCurrentUserId() {
    return FirestoreCollections.getCurrentUserId();
  }

  // Auth & Collections - Get effective user ID (operator being viewed or current user)
  static String getEffectiveUserId([String? viewingOperatorId]) {
    return OperatorViewService.getEffectiveUserId(viewingOperatorId);
  }

  // Upload Methods - ALL pass the resolved effective user ID
  static Future<void> uploadSubstrates({String? viewingOperatorId}) {
    final effectiveUserId = getEffectiveUserId(viewingOperatorId);
    return FirestoreUpload.uploadSubstrates(effectiveUserId);
  }

  static Future<void> uploadAlerts({String? viewingOperatorId}) {
    final effectiveUserId = getEffectiveUserId(viewingOperatorId);
    return FirestoreUpload.uploadAlerts(effectiveUserId);
  }

  static Future<void> uploadCyclesRecom({String? viewingOperatorId}) {
    final effectiveUserId = getEffectiveUserId(viewingOperatorId);
    return FirestoreUpload.uploadCyclesRecom(effectiveUserId);
  }

  // Fetch Methods - ALL pass the resolved effective user ID
  static Future<List<ActivityItem>> getSubstrates({String? viewingOperatorId}) {
    final effectiveUserId = getEffectiveUserId(viewingOperatorId);
    return FirestoreFetch.getSubstrates(effectiveUserId);
  }

  static Future<List<ActivityItem>> getAlerts({String? viewingOperatorId}) {
    final effectiveUserId = getEffectiveUserId(viewingOperatorId);
    return FirestoreFetch.getAlerts(effectiveUserId);
  }

  static Future<List<ActivityItem>> getCyclesRecom({
    String? viewingOperatorId,
  }) {
    final effectiveUserId = getEffectiveUserId(viewingOperatorId);
    return FirestoreFetch.getCyclesRecom(effectiveUserId);
  }

  static Future<List<ActivityItem>> getAllActivities({
    String? viewingOperatorId,
  }) {
    final effectiveUserId = getEffectiveUserId(viewingOperatorId);
    return FirestoreFetch.getAllActivities(effectiveUserId);
  }

  // CRITICAL: Add waste product with proper user context
  static Future<void> addWasteProduct(
    Map<String, dynamic> waste, {
    String? viewingOperatorId,
  }) {
    final effectiveUserId = getEffectiveUserId(viewingOperatorId);
    return FirestoreUpload.addWasteProduct(waste, effectiveUserId);
  }

  // Upload all mock data with proper user context
  static Future<void> uploadAllMockData({String? viewingOperatorId}) {
    final effectiveUserId = getEffectiveUserId(viewingOperatorId);
    return FirestoreUpload.uploadAllMockData(effectiveUserId);
  }

  // Force upload with proper user context
  static Future<void> forceUploadAllMockData({String? viewingOperatorId}) {
    final effectiveUserId = getEffectiveUserId(viewingOperatorId);
    return FirestoreUpload.forceUploadAllMockData(effectiveUserId);
  }

  // Submit report with proper user context
  static Future<void> submitReport(
    Map<String, dynamic> report, {
    String? viewingOperatorId,
  }) {
    final effectiveUserId = getEffectiveUserId(viewingOperatorId);
    return FirestoreUpload.submitReport(report, effectiveUserId);
  }

  static Future<List<ActivityItem>> getReports({String? viewingOperatorId}) {
    final effectiveUserId = getEffectiveUserId(viewingOperatorId);
    return FirestoreFetch.getReports(effectiveUserId);
  }
}
