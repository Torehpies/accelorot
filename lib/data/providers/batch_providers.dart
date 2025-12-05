// lib/data/providers/batch_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase/firebase_batch_service.dart';

/// Batch service provider (shared dependency across all domains)
final batchServiceProvider = Provider((ref) {
  return FirestoreBatchService(FirebaseFirestore.instance);
});