import 'package:cloud_firestore/cloud_firestore.dart';

abstract class AppUserService {
	Future<Map<String, dynamic>?> fetchRawUserData(String id);
	Stream<DocumentSnapshot<Map<String, dynamic>>> watchRawUserData(String id);
}
