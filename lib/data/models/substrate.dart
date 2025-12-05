// lib/data/models/substrate.dart

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'substrate.freezed.dart';

/// Pure data model for substrate/waste products
/// No UI concerns (colors, icons) - just data
@freezed
abstract class Substrate with _$Substrate {
  const factory Substrate({
    required String id,
    required String title, // Plant type label
    required double quantity,
    required String category, // 'Greens', 'Browns', 'Compost'
    required String description,
    required DateTime timestamp,
    required String userId,
    required String machineId,
    String? machineName,
    String? batchId,
    String? operatorName,
  }) = _Substrate;

  const Substrate._(); // Enable custom methods

  // ===== FIRESTORE CONVERSION =====

  /// Create from Firestore document
  static Substrate fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return Substrate(
      id: doc.id,
      title: data['title'] ?? '',
      quantity: _parseQuantity(data['value']),
      category: data['category'] ?? '',
      description: data['description'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      userId: data['userId'] ?? '',
      machineId: data['machineId'] ?? '',
      machineName: data['machineName'],
      batchId: data['batchId'],
      operatorName: data['operatorName'],
    );
  }

  /// Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'value': '${quantity}kg',
      'category': category,
      'description': description,
      'timestamp': Timestamp.fromDate(timestamp),
      'userId': userId,
      'machineId': machineId,
      'machineName': machineName,
      'batchId': batchId,
      'operatorName': operatorName,
    };
  }

  // ===== HELPERS =====

  /// Parse quantity from various formats ("10kg", "10", 10)
  static double _parseQuantity(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    
    final str = value.toString();
    final numStr = str.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(numStr) ?? 0.0;
  }
}