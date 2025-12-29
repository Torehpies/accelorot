// lib/frontend/operator/dashboard/compost_progress/models/compost_batch_model.dart

class CompostBatch {
  final String batchName;
  final String batchNumber; // "Batch-" + user's 6-digit number
  final String? startedBy; // Operator name (null for now)
  final DateTime batchStart;
  final String? startNotes; // Notes when starting batch

  // Completion fields
  String status; // 'active' or 'completed'
  String? completionNotes; // Notes when completing batch
  DateTime? completedAt;
  double? finalWeight; // in kg

  CompostBatch({
    required this.batchName,
    required this.batchNumber,
    this.startedBy,
    required this.batchStart,
    this.startNotes,
    this.status = 'active',
    this.completionNotes,
    this.completedAt,
    this.finalWeight,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'batchName': batchName,
      'batchNumber': batchNumber,
      'startedBy': startedBy,
      'batchStart': batchStart.toIso8601String(),
      'startNotes': startNotes,
      'status': status,
      'completionNotes': completionNotes,
      'completedAt': completedAt?.toIso8601String(),
      'finalWeight': finalWeight,
    };
  }

  // Create from Firestore Map
  factory CompostBatch.fromMap(Map<String, dynamic> map) {
    return CompostBatch(
      batchName: map['batchName'] ?? '',
      batchNumber: map['batchNumber'] ?? '',
      startedBy: map['startedBy'],
      batchStart: DateTime.parse(map['batchStart']),
      startNotes: map['startNotes'],
      status: map['status'] ?? 'active',
      completionNotes: map['completionNotes'],
      completedAt: map['completedAt'] != null
          ? DateTime.parse(map['completedAt'])
          : null,
      finalWeight: map['finalWeight']?.toDouble(),
    );
  }

  CompostBatch copyWith({
    String? batchName,
    String? batchNumber,
    String? startedBy,
    DateTime? batchStart,
    String? startNotes,
    String? status,
    String? completionNotes,
    DateTime? completedAt,
    double? finalWeight,
  }) {
    return CompostBatch(
      batchName: batchName ?? this.batchName,
      batchNumber: batchNumber ?? this.batchNumber,
      startedBy: startedBy ?? this.startedBy,
      batchStart: batchStart ?? this.batchStart,
      startNotes: startNotes ?? this.startNotes,
      status: status ?? this.status,
      completionNotes: completionNotes ?? this.completionNotes,
      completedAt: completedAt ?? this.completedAt,
      finalWeight: finalWeight ?? this.finalWeight,
    );
  }
}
