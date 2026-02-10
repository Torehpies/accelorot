import 'package:cloud_firestore/cloud_firestore.dart';

/// Used for document refrencing for Firebase to shorten code further,
/// though medyo late na ksjfdhksjdhf
/// - SIPIR

DocumentReference<Map<String, dynamic>> memberRef(
  String teamId,
  String uid,
  FirebaseFirestore firestore,
) {
  return firestore
      .collection('teams')
      .doc(teamId)
      .collection('members')
      .doc(uid);
}

DocumentReference<Map<String, dynamic>> userRef(
  String uid,
  FirebaseFirestore firestore,
) {
  return firestore.collection('users').doc(uid);
}
