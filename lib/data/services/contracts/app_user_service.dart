import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/data/services/contracts/data_layer_error.dart';
import 'package:flutter_application_1/data/services/contracts/result.dart';

abstract class AppUserService {
  Future<Map<String, dynamic>?> fetchRawUserData(String id);
  Stream<DocumentSnapshot<Map<String, dynamic>>> watchRawUserData(String id);
  Future<Result<void, DataLayerError>> updateUserField(
    String uid,
    Map<String, dynamic> data,
  );
}
