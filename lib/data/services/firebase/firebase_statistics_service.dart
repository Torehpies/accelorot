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
      // Normalize endDate to midnight (start of today)
      final endDateNormalized = DateTime(endDate.year, endDate.month, endDate.day);

      debugPrint('📅 Scanning $batchId from ${startDate.toString().substring(0, 10)} to ${endDateNormalized.toString().substring(0, 10)}');

      // Generate list of dates to fetch
      final List<DateTime> datesToFetch = [];
      for (var day = startDate;
           !day.isAfter(endDateNormalized);
           day = day.add(const Duration(days: 1))) {
        datesToFetch.add(day);
      }

      // Parallel fetch using Future.wait
      final List<List<Map<String, dynamic>>> results = await Future.wait(
        datesToFetch.map((day) async {
          final dateStr = day.toIso8601String().substring(0, 10);
          final dailyReadings = <Map<String, dynamic>>[];

          try {
            final timeSnapshot = await _db
                .collection('batches')
                .doc(batchId)
                .collection('readings')
                .doc(dateStr)
                .collection('time')
                .get();

            if (timeSnapshot.docs.isNotEmpty) {
              for (var timeDoc in timeSnapshot.docs) {
                final data = timeDoc.data();
                if (data.containsKey(fieldName)) {
                  dailyReadings.add({
                    'id': timeDoc.id,
                    'value': (data[fieldName] ?? 0).toDouble(),
                    'timestamp': _parseTimestamp(data['timestamp']),
                  });
                }
              }
            } else {
               // No readings for this day - add a zero value at midnight
               dailyReadings.add({
                'id': '$dateStr-00-00-00',
                'value': 0.0,
                'timestamp': DateTime(day.year, day.month, day.day, 0, 0, 0),
              });
            }
          } catch (e) {
            debugPrint('Error fetching day $dateStr: $e');
             dailyReadings.add({
                'id': '$dateStr-00-00-00',
                'value': 0.0,
                'timestamp': DateTime(day.year, day.month, day.day, 0, 0, 0),
              });
          }
          return dailyReadings;
        }),
      );

      // Flatten results
      for (var dayResults in results) {
        allReadings.addAll(dayResults);
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

  @override
  Future<Map<String, dynamic>?> getLatestSensorReadings(String batchId) async {
    try {
      if (batchId.isEmpty) return null;

      // 1. Get the batch to find its creation and completion dates
      final batchDoc = await _db.collection('batches').doc(batchId).get();
      if (!batchDoc.exists) {
        debugPrint('⚠️ Batch not found: $batchId');
        return null;
      }

      final batchData = batchDoc.data()!;
      DateTime? startDate = _parseTimestamp(batchData['createdAt']);
      DateTime? endDate = _parseTimestamp(batchData['completedAt']) ?? DateTime.now();

      if (startDate == null) return null;

      // Normalize dates
      startDate = DateTime(startDate.year, startDate.month, startDate.day);
      final endDateNormalized = DateTime(endDate.year, endDate.month, endDate.day);

      // 2. Iterate backwards from end date to start date to find the most recent reading
      for (var day = endDateNormalized;
           !day.isBefore(startDate);
           day = day.subtract(const Duration(days: 1))) {
        
        final dateStr = day.toIso8601String().substring(0, 10);
        
        // 3. Query the time subcollection for this date, ordered by timestamp descending, limit 1
        final timeSnapshot = await _db
            .collection('batches')
            .doc(batchId)
            .collection('readings')
            .doc(dateStr)
            .collection('time')
            .orderBy('timestamp', descending: true)
            .limit(1)
            .get();

        if (timeSnapshot.docs.isNotEmpty) {
          final doc = timeSnapshot.docs.first;
          final data = doc.data();
          
          return {
            'temperature': (data['temperature'] ?? 0).toDouble(),
            'moisture': (data['moisture'] ?? 0).toDouble(),
            'oxygen': (data['oxygen'] ?? 0).toDouble(),
            'timestamp': _parseTimestamp(data['timestamp']),
          };
        }
      }

      // No readings found in the entire batch period
      return null;
    } catch (e, stackTrace) {
      debugPrint('❌ Error fetching latest sensor readings: $e');
      debugPrint('Stack: $stackTrace');
      return null;
    }
  }
}