import 'package:flutter_application_1/data/providers/user_providers.dart';
import 'package:flutter_application_1/data/repositories/pending_member_repository.dart';
import 'package:flutter_application_1/data/services/contracts/pending_member_service.dart';
import 'package:flutter_application_1/data/services/firebase/firebase_pending_member_service.dart';
import 'package:flutter_application_1/providers/auth_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'pending_members_providers.g.dart';

@Riverpod(keepAlive: true)
PendingMemberService pendingMemberService(Ref ref) {
	final firestore = ref.watch(firebaseFirestoreProvider);
	return FirebasePendingMemberService(firestore);
}

@Riverpod(keepAlive: true)
PendingMemberRepository pendingMemberRepository(Ref ref) {
	final pendingMemberService = ref.watch(pendingMemberServiceProvider);
	final userRepository = ref.watch(userRepositoryProvider);

	return PendingMemberRepositoryImpl(pendingMemberService, userRepository);
}
