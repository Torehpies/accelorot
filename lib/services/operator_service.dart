// lib/services/operator_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class OperatorService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fetch all operator documents from the `operators` collection.
  ///
  /// Returns a list of maps where each map contains at least:
  /// - id, name, email, role, isArchived, dateAdded
  /// Any other fields from the document are preserved.
  static Future<List<Map<String, dynamic>>> fetchOperators() async {
    // Query users where role == 'Operator'
    final snapshot = await _firestore
        .collection('users')
        .where('role', isEqualTo: 'Operator')
        .get();

    return snapshot.docs.map((d) {
      final data = d.data();

      return {
        'id': d.id,
        'uid': d.id,
        // Compose a display name if explicit 'name' not present
        'name':
            data['name'] ??
            '${(data['firstname'] ?? '')} ${(data['lastname'] ?? '')}'.trim(),
        'email': data['email'] ?? '',
        'role': data['role'] ?? '',
        'isArchived': data['isArchived'] ?? false,
        'dateAdded': data['dateAdded'] ?? '',
        // include all raw fields as well in case the UI needs them
        ...data,
      };
    }).toList();
  }
}
