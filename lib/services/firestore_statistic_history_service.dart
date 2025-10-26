import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// 🧠 Handles all Firestore reads for historical environmental data
class FirestoreStatisticHistoryService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// 🧭 Returns collection name for a given date (e.g. "2025-10-25")
  static String _getCollectionForDate(DateTime date) {
    return "${date.year.toString().padLeft(4, '0')}-"
        "${date.month.toString().padLeft(2, '0')}-"
        "${date.day.toString().padLeft(2, '0')}";
  }

  /// 🔹 Fetch sensor data for a specific machine and date
  static Future<List<Map<String, dynamic>>> _getSensorDataForDate({
    required String machineId,
    required String fieldName,
    required DateTime date,
  }) async {
    final collectionName = _getCollectionForDate(date);
    debugPrint('📅 Fetching $fieldName readings from $collectionName for machine $machineId');

    try {
      final snapshot = await _db.collection(collectionName).get();
      if (snapshot.docs.isEmpty) return [];

      // Filter documents for the specific machine
      final filtered = snapshot.docs.where((doc) {
        final data = doc.data();
        return data['machine-id'] == machineId;
      }).toList();

      if (filtered.isEmpty) return [];

      // Sort by timestamp
      filtered.sort((a, b) {
        final aTime = _parseTimestamp(a.data()['timestamp']) ?? DateTime(1970);
        final bTime = _parseTimestamp(b.data()['timestamp']) ?? DateTime(1970);
        return aTime.compareTo(bTime);
      });

      // Map to a consistent format
      return filtered.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'value': (data[fieldName] is num ? (data[fieldName] as num).toDouble() : 0.0),
          'timestamp': _parseTimestamp(data['timestamp']),
        };
      }).toList();
    } catch (e, stack) {
      debugPrint('❌ Error fetching $fieldName from $collectionName: $e\n$stack');
      return [];
    }
  }

  /// 🔹 Fetch data for multiple days concurrently
  static Future<Map<String, List<Map<String, dynamic>>>> getDataForRange({
    required String machineId,
    required String fieldName,
    required DateTime start,
    required DateTime end,
  }) async {
    final totalDays = end.difference(start).inDays + 1;

    final futures = List.generate(totalDays, (i) async {
      final date = start.add(Duration(days: i));
      final collectionKey = _getCollectionForDate(date);

      final readings = await _getSensorDataForDate(
        machineId: machineId,
        fieldName: fieldName,
        date: date,
      );

      debugPrint('✅ $collectionKey: Found ${readings.length} readings');
      return MapEntry(collectionKey, readings);
    });

    final results = await Future.wait(futures);
    return Map.fromEntries(results);
  }

  /// 🧩 Helper to parse Firestore timestamp, ISO string, or milliseconds
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
    if (timestamp is int) return DateTime.fromMillisecondsSinceEpoch(timestamp);
    return null;
  }
}
