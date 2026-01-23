// lib/utilities/parsers.dart

import 'package:cloud_firestore/cloud_firestore.dart';

/// Simple parsing utilities for data models
class DataParsers {
  DataParsers._();

  /// Strips non-numeric characters except decimal point
  static double parseQuantity(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();

    final str = value.toString();
    final numStr = str.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(numStr) ?? 0.0;
  }

  /// Parse a double from various formats
  static double parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  /// Parse DateTime from Firestore Timestamp, String, or DateTime
  static DateTime parseTimestamp(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }
}
