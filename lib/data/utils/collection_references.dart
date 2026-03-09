import 'package:cloud_firestore/cloud_firestore.dart';

CollectionReference<Map<String, dynamic>> sessionCollection(
  FirebaseFirestore firestore,
  String uid,
) {
  return firestore.collection('users').doc(uid).collection('sessions');
}
