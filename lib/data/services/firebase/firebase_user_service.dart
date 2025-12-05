import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user_model.dart';
import '../contracts/user_service.dart';

class FirebaseUserService implements UserService {
  final FirebaseFirestore firestore;

  FirebaseUserService(this.firestore);

  @override
  Future<List<UserModel>> fetchUsers() async {
    final snapshot = await firestore.collection('users').get();

    return snapshot.docs
        .map((doc) => UserModel.fromMap(doc.id, doc.data()))
        .toList();
  }

  @override
  Future<UserModel?> getUserById(String id) async {
    final doc = await firestore.collection('users').doc(id).get();

    if (!doc.exists || doc.data() == null) return null;

    return UserModel.fromMap(doc.id, doc.data()!);
  }
}
