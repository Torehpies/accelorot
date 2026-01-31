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

  /// Reusable fetch function for all sensor types
  Future<List<Map<String, dynamic>>> _getSensorData({
    required String batchId,
    required String fieldName,
  }) async {
    try {
      final snapshot = await _db
          .collection('batches')
          .doc(batchId)
          .collection('readings')
          .orderBy('timestamp', descending: false)
          .get();

      if (snapshot.docs.isEmpty) {
        debugPrint('📭 No readings found for batch: $batchId');
        return [];
      }

      return snapshot.docs.map((doc) {
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
  Future<List<TemperatureModel>> getTemperatureData(String batchId) async {
    try {
      debugPrint('🌡️ Fetching temperature data for batch: $batchId');
      final rawData = await _getSensorData(
        batchId: batchId,
        fieldName: 'temperature',
      );
      debugPrint('🌡️ Found ${rawData.length} temperature readings');
      
      return rawData
          .map((data) => TemperatureModel.fromMap(data))
          .toList();
    } catch (e, stackTrace) {
      debugPrint('❌ Error in getTemperatureData: $e');
      debugPrint('Stack trace: $stackTrace');
      throw Exception('Failed to fetch temperature data: $e');
    }
  }

  @override
  Future<List<MoistureModel>> getMoistureData(String batchId) async {
    try {
      debugPrint('🌊 Fetching moisture data for batch: $batchId');
      final rawData = await _getSensorData(
        batchId: batchId,
        fieldName: 'moisture',
      );
      debugPrint('🌊 Found ${rawData.length} moisture readings');
      
      return rawData
          .map((data) => MoistureModel.fromMap(data))
          .toList();
    } catch (e, stackTrace) {
      debugPrint('❌ Error in getMoistureData: $e');
      debugPrint('Stack trace: $stackTrace');
      throw Exception('Failed to fetch moisture data: $e');
    }
  }

  @override
  Future<List<OxygenModel>> getOxygenData(String batchId) async {
    try {
      debugPrint('💨 Fetching oxygen data for batch: $batchId');
      final rawData = await _getSensorData(
        batchId: batchId,
        fieldName: 'oxygen',
      );
      debugPrint('💨 Found ${rawData.length} oxygen readings');
      
      return rawData
          .map((data) => OxygenModel.fromMap(data))
          .toList();
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