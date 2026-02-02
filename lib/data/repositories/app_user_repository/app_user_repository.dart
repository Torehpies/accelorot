import 'package:flutter_application_1/data/models/app_user.dart';
import 'package:flutter_application_1/data/services/contracts/data_layer_error.dart';
import 'package:flutter_application_1/data/services/contracts/result.dart';

abstract class AppUserRepository {
  Future<Result<AppUser, DataLayerError>> getUser(String id);
  Future<Result<void, DataLayerError>> createUserProfile({
    required String uid,
    required String email,
    required String firstName,
    required String lastName,
    required String globalRole,
    required String status,
    String requestTeamId,
  });
  AppUser mapRawDataToDomain(Map<String, dynamic> rawData);
}
