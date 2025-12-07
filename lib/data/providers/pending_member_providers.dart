import 'package:flutter_application_1/data/providers/app_user_providers.dart';
import 'package:flutter_application_1/data/providers/core_providers.dart';
import 'package:flutter_application_1/data/repositories/pending_member_repository/pending_member_repository.dart';
import 'package:flutter_application_1/data/repositories/pending_member_repository/pending_member_repository_remote.dart';
import 'package:flutter_application_1/data/services/contracts/pending_member_service.dart';
import 'package:flutter_application_1/data/services/firebase/firebase_pending_member_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'pending_member_providers.g.dart';

@Riverpod(keepAlive: true)
PendingMemberService pendingMemberService(Ref ref) {
  return FirebasePendingMemberService(
    ref.read(firebaseFirestoreProvider),
    ref.read(appUserServiceProvider),
  );
}

@Riverpod(keepAlive: true)
PendingMemberRepository pendingMemberRepository(Ref ref) {
  return PendingMemberRepositoryRemote(
    ref.read(pendingMemberServiceProvider),
    ref.read(appUserServiceProvider),
  );
}
