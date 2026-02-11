import 'package:flutter_application_1/data/models/app_user.dart';
import 'package:flutter_application_1/data/services/contracts/data_layer_error.dart';
import 'package:flutter_application_1/data/services/contracts/result.dart';

abstract class AppUserService {
  Future<Map<String, dynamic>?> fetchRawUserData(String id);
  Future<Result<AppUser?, DataLayerError>> getAppUserAsync(String id);
  Stream<AppUser?> getAppUser(String id);
  Future<Result<void, DataLayerError>> updateUserField(
    String uid,
    Map<String, dynamic> data,
  );
  Future<Result<void, DataLayerError>> acceptApproval({
    required String uid,
    required String teamId,
  });
}
