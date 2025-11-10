import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class FirestoreStatisticsService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// 🧭 Get today's collection name (e.g. "2025-10-23")
  static String _getTodayCollection() {
    final now = DateTime.now();
    return "${now.year.toString().padLeft(4, '0')}-"
        "${now.month.toString().padLeft(2, '0')}-"
        "${now.day.toString().padLeft(2, '0')}";
  }

  /// 🧩 Reusable fetch function for all sensor types
  static Future<List<Map<String, dynamic>>> _getSensorData({
    required String machineId,
    required String fieldName,
  }) async {
    final dateKey = _getTodayCollection();
    final snapshot = await _db.collection(dateKey).get();

    if (snapshot.docs.isEmpty) return [];

    // Filter only documents belonging to this machine
    final filtered = snapshot.docs.where((doc) {
      final data = doc.data();
      return data['machine-id'] == machineId;
    }).toList();

    if (filtered.isEmpty) return [];

    // Sort by document ID (e.g. "01-15:24:38" → time order)
    filtered.sort((a, b) => a.id.compareTo(b.id));

    return filtered.map((doc) {
      final data = doc.data();
      return {
        'id': doc.id,
        'value': (data[fieldName] ?? 0).toDouble(),
        'timestamp': _parseTimestamp(data['timestamp']),
      };
    }).toList();
  }

  /// 🔹 Fetch moisture data for given machine
  static Future<List<Map<String, dynamic>>> getMoistureData(
    String machineId,
  ) async {
    debugPrint('🌊 Fetching moisture data for machine: $machineId');
    final data = await _getSensorData(
      machineId: machineId,
      fieldName: 'moisture',
    );
    debugPrint('🌊 Found ${data.length} moisture readings');
    debugPrint('🌊 First reading: ${data.isNotEmpty ? data.first : "none"}');
    debugPrint('🌊 Last reading: ${data.isNotEmpty ? data.last : "none"}');
    return data;
  }

  /// 🔹 Fetch temperature data for given machine
  static Future<List<Map<String, dynamic>>> getTemperatureData(
    String machineId,
  ) async {
    return _getSensorData(machineId: machineId, fieldName: 'temp');
  }

  /// 🔹 Fetch oxygen data for given machine
  static Future<List<Map<String, dynamic>>> getOxygenData(
    String machineId,
  ) async {
    return _getSensorData(machineId: machineId, fieldName: 'oxygen');
  }

  /// 🧩 Helper to parse Firestore timestamp or ISO string
  static DateTime? _parseTimestamp(dynamic timestamp) {
    if (timestamp == null) return null;
    if (timestamp is Timestamp) return timestamp.toDate();
    if (timestamp is String) {
      try {
        return DateTime.parse(timestamp);
      } catch (_) {
        return null;
      }
    }
    return null;
  }
}
