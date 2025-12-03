import 'package:flutter_application_1/data/models/app_user.dart';
import 'package:flutter_application_1/data/services/contracts/data_layer_error.dart';
import 'package:flutter_application_1/data/services/contracts/result.dart';

abstract class AuthRepository {
  Stream<AppUser?> get authStateChanges;
  AppUser? get currentUser;
  Future<Result<void, DataLayerError>> signIn({
    required String email,
    required String password,
  });
  Future<Result<void, DataLayerError>> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String globalRole,
    required String teamId,
  });
  Future<Result<void, DataLayerError>> signOut();
  Future<Result<void, DataLayerError>> signInWithGoogle();
}

