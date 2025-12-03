import 'package:flutter_application_1/data/providers/auth_providers.dart';
import 'package:flutter_application_1/data/providers/core_providers.dart';
import 'package:flutter_application_1/data/repositories/app_user_repository/app_user_repository.dart';
import 'package:flutter_application_1/data/repositories/app_user_repository/app_user_repository_remote.dart';
import 'package:flutter_application_1/data/services/contracts/app_user_service.dart';
import 'package:flutter_application_1/data/services/firebase/firebase_user_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_user_providers.g.dart';

@Riverpod(keepAlive: true)
AppUserService appUserService(Ref ref) {
  final firestore = ref.read(firebaseFirestoreProvider);
  return FirebaseAppUserService(firestore);
}

@Riverpod(keepAlive: true)
AppUserRepository appUserRepository(Ref ref) {
  final userService = ref.read(appUserServiceProvider);
  final authService = ref.read(authServiceProvider);
  final firebaseFirestore = ref.read(firebaseFirestoreProvider);
  return AppUserRepositoryRemote(userService, authService, firebaseFirestore);
}
