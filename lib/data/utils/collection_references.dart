import 'package:cloud_firestore/cloud_firestore.dart';

CollectionReference<Map<String, dynamic>> sessionCollection(
  String uid,
  FirebaseFirestore firestore,
) {
  return firestore.collection('users').doc(uid).collection('sessions');
}
