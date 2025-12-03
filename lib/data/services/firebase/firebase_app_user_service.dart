import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/data/services/contracts/app_user_service.dart';

class FirebaseAppUserService implements AppUserService {
  final FirebaseFirestore firestore;
  FirebaseAppUserService(this.firestore);

  @override
  Future<Map<String, dynamic>?> fetchRawUserData(String id) async {
    final snapshot = await firestore.collection('users').doc(id).get();

    return snapshot.data();
  }

  @override
  Stream<DocumentSnapshot<Map<String, dynamic>>> watchRawUserData(String id) {
    final result = firestore.collection('users').doc(id).snapshots();
		return result;
  }
}
