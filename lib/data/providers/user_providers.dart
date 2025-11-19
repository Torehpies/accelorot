import 'package:flutter_application_1/data/repositories/user_repository.dart';
import 'package:flutter_application_1/data/services/contracts/user_service.dart';
import 'package:flutter_application_1/data/services/firebase/firebase_user_service.dart';
import 'package:flutter_application_1/providers/auth_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'user_providers.g.dart';

@Riverpod(keepAlive: true)
UserService userService(Ref ref) {
	final firestore = ref.watch(firebaseFirestoreProvider);
	return FirebaseUserService(firestore);
}

@Riverpod(keepAlive: true)
UserRepository userRepository(Ref ref) {
	final userService = ref.watch(userServiceProvider);
	return UserRepositoryImpl(userService);
}
