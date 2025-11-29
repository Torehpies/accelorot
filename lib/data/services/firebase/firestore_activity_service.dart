// lib/data/services/firebase/firestore_activity_service.dart

import 'package:flutter/material.dart';
import 'package:flutter_application_1/frontend/screens/admin/operator_management/operator_view_service.dart';
import 'package:flutter_application_1/data/models/activity_item.dart';
import 'package:flutter_application_1/data/services/firebase/activity_logs/firestore_collections.dart';
import 'package:flutter_application_1/data/services/firebase/activity_logs/firestore_upload.dart';
import 'package:flutter_application_1/data/services/firebase/activity_logs/firestore_fetch.dart';
import 'package:flutter_application_1/data/services/firebase/firestore_alert_service.dart';

/// Service layer for activity-related Firestore operations
/// Handles authentication context and delegates to fetch/upload services
class FirestoreActivityService {
  // ===== AUTHENTICATION & USER CONTEXT =====

  /// Get the current logged-in user ID (for authentication checks only)
  static String? getCurrentUserId() {
    return FirestoreCollections.getCurrentUserId();
  }

  /// Get effective user ID (operator being viewed or current user)
  static String getEffectiveUserId([String? viewingOperatorId]) {
    return OperatorViewService.getEffectiveUserId(viewingOperatorId);
  }

  // ===== FETCH METHODS (Async) =====

  /// Fetch all substrate activities for the effective user
  static Future<List<ActivityItem>> getSubstrates({
    String? viewingOperatorId,
  }) async {
    final effectiveUserId = getEffectiveUserId(viewingOperatorId);
    return FirestoreFetch.getSubstrates(effectiveUserId);
  }

  /// Fetch all alert activities for the effective user
  static Future<List<ActivityItem>> getAlerts({
    String? viewingOperatorId,
  }) async {
    final effectiveUserId = getEffectiveUserId(viewingOperatorId);
    final batchId = viewingOperatorId ?? effectiveUserId;
    
    final alertsData = await FirestoreAlertService.fetchAlertsForBatch(batchId);
    
    // Convert to ActivityItem
    return alertsData.map((alert) => _convertAlertToActivityItem(alert)).toList();
  }

  /// Fetch all cycles and recommendations for the effective user
  static Future<List<ActivityItem>> getCyclesRecom({
    String? viewingOperatorId,
  }) async {
    final effectiveUserId = getEffectiveUserId(viewingOperatorId);
    return FirestoreFetch.getCyclesRecom(effectiveUserId);
  }

  /// Fetch all reports for the effective user
  static Future<List<ActivityItem>> getReports({
    String? viewingOperatorId,
  }) async {
    final effectiveUserId = getEffectiveUserId(viewingOperatorId);
    return FirestoreFetch.getReports(effectiveUserId);
  }

  /// Fetch ALL activities (combined from all sources)
  static Future<List<ActivityItem>> getAllActivities({
    String? viewingOperatorId,
  }) async {
    final effectiveUserId = getEffectiveUserId(viewingOperatorId);
    return FirestoreFetch.getAllActivities(effectiveUserId);
  }

  // ===== UPLOAD/WRITE METHODS (Async) =====

  /// Upload substrate data to Firestore
  static Future<void> uploadSubstrates({String? viewingOperatorId}) async {
    final effectiveUserId = getEffectiveUserId(viewingOperatorId);
    await FirestoreUpload.uploadSubstrates(effectiveUserId);
  }

  /// Upload alert data to Firestore
  static Future<void> uploadAlerts({String? viewingOperatorId}) async {
    final effectiveUserId = getEffectiveUserId(viewingOperatorId);
    await FirestoreUpload.uploadAlerts(effectiveUserId);
  }

  /// Upload cycles and recommendations to Firestore
  static Future<void> uploadCyclesRecom({String? viewingOperatorId}) async {
    final effectiveUserId = getEffectiveUserId(viewingOperatorId);
    await FirestoreUpload.uploadCyclesRecom(effectiveUserId);
  }

  /// Upload all mock data (for testing/demo)
  static Future<void> uploadAllMockData({String? viewingOperatorId}) async {
    await uploadSubstrates(viewingOperatorId: viewingOperatorId);
    await uploadAlerts(viewingOperatorId: viewingOperatorId);
    await uploadCyclesRecom(viewingOperatorId: viewingOperatorId);
  }

  /// Add a waste product entry
  static Future<void> addWasteProduct(
    Map<String, dynamic> waste, {
    String? viewingOperatorId,
  }) async {
    final effectiveUserId = getEffectiveUserId(viewingOperatorId);
    await FirestoreUpload.addWasteProduct(waste, effectiveUserId);
  }

  /// Submit a report
  static Future<void> submitReport(
    Map<String, dynamic> report, {
    String? viewingOperatorId,
  }) async {
    final effectiveUserId = getEffectiveUserId(viewingOperatorId);
    await FirestoreUpload.submitReport(report, effectiveUserId);
  }

  // ===== PRIVATE HELPERS =====

  /// Convert alert data from Firestore to ActivityItem
  static ActivityItem _convertAlertToActivityItem(Map<String, dynamic> alert) {
    final rawSensorType = (alert['sensor_type'] ?? '').toString();
    final sensorType = _toProperCase(rawSensorType);
    final status = (alert['status'] ?? '').toString().toLowerCase();

    // Determine category and icon
    String category;
    IconData icon;
    if (sensorType.toLowerCase().contains('temp')) {
      category = 'Temperature';
      icon = Icons.thermostat;
    } else if (sensorType.toLowerCase().contains('moisture')) {
      category = 'Moisture';
      icon = Icons.water_drop;
    } else if (sensorType.toLowerCase().contains('oxygen')) {
      category = 'Oxygen';
      icon = Icons.air;
    } else {
      category = 'Other';
      icon = Icons.warning;
    }

    // Determine color based on alert status
    String color;
    if (status == 'below') {
      color = 'blue';
    } else if (status == 'above') {
      color = 'red';
    } else {
      color = 'grey';
    }

    final message = _toProperCase(alert['message'] ?? 'Alert');

    return ActivityItem(
      title: message,
      value: '${alert['reading_value']}',
      statusColor: color,
      icon: icon,
      description:
          'Sensor: $sensorType\nReading: ${alert['reading_value']}\nThreshold: ${alert['threshold']} (${alert['status']})',
      category: category,
      timestamp: DateTime.tryParse(alert['timestamp'] ?? '') ?? DateTime.now(),
      machineId: alert['machine_id'],
    );
  }

  /// Capitalize first letter of string
  static String _toProperCase(String input) {
    if (input.isEmpty) return input;
    return input[0].toUpperCase() + input.substring(1).toLowerCase();
  }
}