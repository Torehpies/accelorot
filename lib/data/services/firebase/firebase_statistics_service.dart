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
  /// Path: batches/{batchId}/readings/{date}/time/{timeId}
  Future<List<Map<String, dynamic>>> _getSensorData({
    required String batchId,
    required String fieldName,
  }) async {
    try {
      if (batchId.isEmpty) return [];

      final List<Map<String, dynamic>> allReadings = [];

      // Get batch to find creation date
      final batchDoc = await _db.collection('batches').doc(batchId).get();
      if (!batchDoc.exists) {
        debugPrint('⚠️ Batch not found: $batchId');
        return [];
      }

      // Determine date range
      DateTime startDate = DateTime.now().subtract(const Duration(days: 30));
      final batchData = batchDoc.data();
      if (batchData != null && batchData['createdAt'] is Timestamp) {
        startDate = (batchData['createdAt'] as Timestamp).toDate();
      }

      startDate = DateTime(startDate.year, startDate.month, startDate.day);
      final endDate = DateTime.now();

      debugPrint('📅 Scanning $batchId from ${startDate.toString().substring(0, 10)} to ${endDate.toString().substring(0, 10)}');

      // Scan each date directly (bypasses phantom date documents)
      for (var day = startDate;
           day.isBefore(endDate.add(const Duration(days: 1)));
           day = day.add(const Duration(days: 1))) {
        
        final dateStr = day.toIso8601String().substring(0, 10);

        final timeSnapshot = await _db
            .collection('batches')
            .doc(batchId)
            .collection('readings')
            .doc(dateStr)
            .collection('time')
            .get();

        if (timeSnapshot.docs.isNotEmpty) {
          debugPrint('✅ $dateStr: ${timeSnapshot.docs.length} readings');

          for (var timeDoc in timeSnapshot.docs) {
            final data = timeDoc.data();
            if (data.containsKey(fieldName)) {
              allReadings.add({
                'id': timeDoc.id,
                'value': (data[fieldName] ?? 0).toDouble(),
                'timestamp': _parseTimestamp(data['timestamp']),
              });
            }
          }
        } else {
          // No readings for this day - add a zero value at midnight
          debugPrint('⚪ $dateStr: No readings, adding zero value');
          allReadings.add({
            'id': '$dateStr-00-00-00',
            'value': 0.0,
            'timestamp': DateTime(day.year, day.month, day.day, 0, 0, 0),
          });
        }
      }

      debugPrint('📊 Total $fieldName: ${allReadings.length}');

      allReadings.sort((a, b) {
        final timeA = a['timestamp'] as DateTime?;
        final timeB = b['timestamp'] as DateTime?;
        if (timeA == null || timeB == null) return 0;
        return timeA.compareTo(timeB);
      });

      return allReadings;
    } catch (e, stackTrace) {
      debugPrint('❌ Error fetching $fieldName: $e');
      debugPrint('Stack: $stackTrace');
      return [];
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

      return rawData.map((data) => TemperatureModel.fromMap(data)).toList();
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

      return rawData.map((data) => MoistureModel.fromMap(data)).toList();
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