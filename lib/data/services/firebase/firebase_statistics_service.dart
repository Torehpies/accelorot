import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../contracts/statistics_service_contract.dart';

class FirestoreStatisticsService implements StatisticsServiceContract {
  final FirebaseFirestore _db;

  FirestoreStatisticsService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  /// Get today's collection name (e.g. "2025-10-23")
  String _getTodayCollection() {
    final now = DateTime.now();
    return "${now.year.toString().padLeft(4, '0')}-"
        "${now.month.toString().padLeft(2, '0')}-"
        "${now.day.toString().padLeft(2, '0')}";
  }

  /// Reusable fetch function for all sensor types
  Future<List<Map<String, dynamic>>> _getSensorData({
    required String machineId,
    required String fieldName,
  }) async {
    try {
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
    } catch (e) {
      debugPrint('❌ Error fetching $fieldName data: $e');
      rethrow;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getTemperatureData(
    String machineId,
  ) async {
    debugPrint('🌡️ Fetching temperature data for machine: $machineId');
    final data = await _getSensorData(
      machineId: machineId,
      fieldName: 'temp',
    );
    debugPrint('🌡️ Found ${data.length} temperature readings');
    return data;
  }

  @override
  Future<List<Map<String, dynamic>>> getMoistureData(String machineId) async {
    debugPrint('🌊 Fetching moisture data for machine: $machineId');
    final data = await _getSensorData(
      machineId: machineId,
      fieldName: 'moisture',
    );
    debugPrint('🌊 Found ${data.length} moisture readings');
    return data;
  }

  @override
  Future<List<Map<String, dynamic>>> getOxygenData(String machineId) async {
    debugPrint('💨 Fetching oxygen data for machine: $machineId');
    final data = await _getSensorData(
      machineId: machineId,
      fieldName: 'oxygen',
    );
    debugPrint('💨 Found ${data.length} oxygen readings');
    return data;
  }

  /// Helper to parse Firestore timestamp or ISO string
  DateTime? _parseTimestamp(dynamic timestamp) {
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