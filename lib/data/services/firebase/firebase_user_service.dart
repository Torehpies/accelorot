import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseUserService {
	final FirebaseFirestore firestore;
	FirebaseUserService(this.firestore);

	Future<Map<String, dynamic>?> fetchRawUserData(String id) async {
		final snapshot = await firestore.collection('users').doc(id).get();

		return snapshot.data();
	}
}
