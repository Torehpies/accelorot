import 'package:flutter_application_1/frontend/operator/activity_logs/models/activity_item.dart';
import 'firestore/firestore_collections.dart';
import 'firestore/firestore_upload.dart';
import 'firestore/firestore_fetch.dart';

/// Main service class that provides a unified API for Firestore activity operations.
/// This delegates to specialized classes for different concerns.
class FirestoreActivityService {
  // Auth & Collections
  static String? getCurrentUserId() => FirestoreCollections.getCurrentUserId();

  // Upload Methods
  static Future<void> uploadSubstrates() => FirestoreUpload.uploadSubstrates();
  static Future<void> uploadAlerts() => FirestoreUpload.uploadAlerts();
  static Future<void> uploadCyclesRecom() => FirestoreUpload.uploadCyclesRecom();
  static Future<void> uploadAllMockData() => FirestoreUpload.uploadAllMockData();
  static Future<void> forceUploadAllMockData() =>
      FirestoreUpload.forceUploadAllMockData();
  static Future<void> addWasteProduct(Map<String, dynamic> waste) =>
      FirestoreUpload.addWasteProduct(waste);

  // Fetch Methods
  static Future<List<ActivityItem>> getSubstrates() =>
      FirestoreFetch.getSubstrates();
  static Future<List<ActivityItem>> getAlerts() => FirestoreFetch.getAlerts();
  static Future<List<ActivityItem>> getCyclesRecom() =>
      FirestoreFetch.getCyclesRecom();
  static Future<List<ActivityItem>> getAllActivities() =>
      FirestoreFetch.getAllActivities();
}