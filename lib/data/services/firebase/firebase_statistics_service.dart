import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../contracts/statistics_service.dart';
import '../../models/temperature_model.dart';
import '../../models/moisture_model.dart';
import '../../models/oxygen_model.dart';

class FirebaseStatisticsService implements StatisticsService {
  final FirebaseFirestore _db;

  FirebaseStatisticsService({FirebaseFirestore? firestore})
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

      if (snapshot.docs.isEmpty) {
        debugPrint('📭 No documents found in collection: $dateKey');
        return [];
      }

      // Filter only documents belonging to this machine
      final filtered = snapshot.docs.where((doc) {
        final data = doc.data();
        return data['machine-id'] == machineId;
      }).toList();

      if (filtered.isEmpty) {
        debugPrint('📭 No documents found for machine: $machineId');
        return [];
      }

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
    } catch (e, stackTrace) {
      debugPrint('❌ Error fetching $fieldName data: $e');
      debugPrint('Stack trace: $stackTrace');
      throw Exception('Failed to fetch $fieldName data: $e');
    }
  }

  @override
  Future<List<TemperatureModel>> getTemperatureData(String machineId) async {
    try {
      debugPrint('🌡️ Fetching temperature data for machine: $machineId');
      final rawData = await _getSensorData(
        machineId: machineId,
        fieldName: 'temp',
      );
      debugPrint('🌡️ Found ${rawData.length} temperature readings');

      return rawData.map((data) => TemperatureModel.fromMap(data)).toList();
    } catch (e, stackTrace) {
      debugPrint('❌ Error in getTemperatureData: $e');
      debugPrint('Stack trace: $stackTrace');
      throw Exception('Failed to fetch temperature data: $e');
    }
  }

  @override
  Future<List<MoistureModel>> getMoistureData(String machineId) async {
    try {
      debugPrint('🌊 Fetching moisture data for machine: $machineId');
      final rawData = await _getSensorData(
        machineId: machineId,
        fieldName: 'moisture',
      );
      debugPrint('🌊 Found ${rawData.length} moisture readings');

      return rawData.map((data) => MoistureModel.fromMap(data)).toList();
    } catch (e, stackTrace) {
      debugPrint('❌ Error in getMoistureData: $e');
      debugPrint('Stack trace: $stackTrace');
      throw Exception('Failed to fetch moisture data: $e');
    }
  }

  @override
  Future<List<OxygenModel>> getOxygenData(String machineId) async {
    try {
      debugPrint('💨 Fetching oxygen data for machine: $machineId');
      final rawData = await _getSensorData(
        machineId: machineId,
        fieldName: 'oxygen',
      );
      debugPrint('💨 Found ${rawData.length} oxygen readings');

      return rawData.map((data) => OxygenModel.fromMap(data)).toList();
    } catch (e, stackTrace) {
      debugPrint('❌ Error in getOxygenData: $e');
      debugPrint('Stack trace: $stackTrace');
      throw Exception('Failed to fetch oxygen data: $e');
    }
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
