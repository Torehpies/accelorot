// lib/data/services/firebase/firestore_collections.dart

import 'package:cloud_firestore/cloud_firestore.dart';

/// Helper class for Firestore collection references
class FirestoreCollections {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ===== ROOT COLLECTIONS =====
  
  static CollectionReference get users => _firestore.collection('users');
  
  static CollectionReference get machines => _firestore.collection('machines');
  
  static CollectionReference get batches => _firestore.collection('batches');

  // ===== NESTED COLLECTIONS =====
  
  static CollectionReference substrates(String batchId) =>
      batches.doc(batchId).collection('substrates');

  static CollectionReference alerts(String batchId) =>
      batches.doc(batchId).collection('alerts');

  static CollectionReference cycles(String batchId) =>
      batches.doc(batchId).collection('cyclesRecom');

  static CollectionReference reports(String machineId) =>
      machines.doc(machineId).collection('reports');
}