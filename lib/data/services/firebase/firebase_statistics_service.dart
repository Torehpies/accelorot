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
            /*} else {
               // No readings for this day - add a zero value at midnight
               dailyReadings.add({
                'id': '$dateStr-00-00-00',
                'value': 0.0,
                'timestamp': DateTime(day.year, day.month, day.day, 0, 0, 0),
              });*/
            }
          } catch (e) {
            debugPrint('Error fetching day $dateStr: $e');
             /*dailyReadings.add({
                'id': '$dateStr-00-00-00',
                'value': 0.0,
                'timestamp': DateTime(day.year, day.month, day.day, 0, 0, 0),
              });*/
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

      // 1. Fetch exactly ONE document: the batch itself
      final batchDoc = await _db.collection('batches').doc(batchId).get();
      if (!batchDoc.exists) {
        debugPrint('⚠️ Batch not found: $batchId');
        return null;
      }

      final data = batchDoc.data()!;
      
      // 2. Simply check if the Cloud Function has cached the latest reading
      if (data.containsKey('latestSensorReadings') && data['latestSensorReadings'] != null) {
        final latest = data['latestSensorReadings'] as Map<String, dynamic>;
        return {
          'temperature': (latest['temperature'] ?? 0).toDouble(),
          'moisture': (latest['moisture'] ?? 0).toDouble(),
          'oxygen': (latest['oxygen'] ?? 0).toDouble(),
          'timestamp': _parseTimestamp(latest['timestamp']),
        };
      }

      // No cached readings found
      return null;
    } catch (e, stackTrace) {
      debugPrint('❌ Error fetching latest sensor readings: $e');
      debugPrint('Stack: $stackTrace');
      return null;
    }
  }

  @override
  Stream<Map<String, dynamic>?> getLatestSensorReadingsStream(String batchId) {
    if (batchId.isEmpty) return Stream.value(null);

    // Stream directly from the batch document, listening for changes to the latestSensorReadings field
    return _db
        .collection('batches')
        .doc(batchId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) return null;
      
      final data = snapshot.data()!;
      if (data.containsKey('latestSensorReadings') && data['latestSensorReadings'] != null) {
        final latest = data['latestSensorReadings'] as Map<String, dynamic>;
        return {
          'temperature': (latest['temperature'] ?? 0).toDouble(),
          'moisture': (latest['moisture'] ?? 0).toDouble(),
          'oxygen': (latest['oxygen'] ?? 0).toDouble(),
          'timestamp': _parseTimestamp(latest['timestamp']),
        };
      }
      return null;
    });
  }

  /// Generic stream for historical + real-time sensor data
  Stream<List<T>> _getSensorDataStream<T>({
    required String batchId,
    required String fieldName,
    required T Function(Map<String, dynamic>) fromMap,
  }) {
    if (batchId.isEmpty) return Stream.value([]);

    final todayStr = DateTime.now().toIso8601String().substring(0, 10);

    // 1. Fetch historical data up to yesterday
    final historicalFuture = _getSensorData(batchId: batchId, fieldName: fieldName).then((list) {
      // Filter out today's data from historical fetch if any, as the listener handles it
      return list.where((item) {
        final ts = item['timestamp'] as DateTime?;
        if (ts == null) return true;
        return ts.toIso8601String().substring(0, 10) != todayStr;
      }).toList();
    });

    // 2. Listen to today's data
    final todayStream = _db
        .collection('batches')
        .doc(batchId)
        .collection('readings')
        .doc(todayStr)
        .collection('time')
        .orderBy('timestamp', descending: false)
        .snapshots();

    // 3. Combine them
    return Stream.fromFuture(historicalFuture).asyncExpand((historical) {
      return todayStream.map((snapshot) {
        final todayReadings = snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            'value': (data[fieldName] ?? 0).toDouble(),
            'timestamp': _parseTimestamp(data['timestamp']),
          };
        }).toList();

        final combined = [...historical, ...todayReadings];
        return combined.map((data) => fromMap(data)).toList();
      });
    });
  }

  @override
  Stream<List<TemperatureModel>> getTemperatureDataStream(String batchId) {
    return _getSensorDataStream(
      batchId: batchId,
      fieldName: 'temperature',
      fromMap: (data) => TemperatureModel.fromMap(data),
    );
  }

  @override
  Stream<List<MoistureModel>> getMoistureDataStream(String batchId) {
    return _getSensorDataStream(
      batchId: batchId,
      fieldName: 'moisture',
      fromMap: (data) => MoistureModel.fromMap(data),
    );
  }

  @override
  Stream<List<OxygenModel>> getOxygenDataStream(String batchId) {
    return _getSensorDataStream(
      batchId: batchId,
      fieldName: 'oxygen',
      fromMap: (data) => OxygenModel.fromMap(data),
    );
  }
}
