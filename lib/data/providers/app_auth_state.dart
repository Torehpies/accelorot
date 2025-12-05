import 'package:flutter_application_1/data/models/app_auth_state.dart';
import 'package:flutter_application_1/data/providers/auth_providers.dart';
import 'package:flutter_application_1/data/providers/core_providers.dart';
import 'package:flutter_application_1/utils/role_mapper.dart';
import 'package:flutter_application_1/utils/user_status.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_auth_state.g.dart';

@Riverpod(keepAlive: true)
AppAuthState authStateModel(Ref ref) {
  final firebaseUserAsync = ref.watch(firebaseAuthProvider);
  final userDocAsync = ref.watch(userDocProvider);

  final firebaseUser = firebaseUserAsync.currentUser;
  final userDoc = userDocAsync.value;

  // Case 1: Not logged in
  if (firebaseUser == null) {
    return const AppAuthState(
      firebaseUser: null,
      userDoc: null,
      status: UserStatus.unauthenticated,
    );
  }

  // Case 2: Not verified
  if (!firebaseUser.emailVerified) {
    return AppAuthState(
      firebaseUser: firebaseUser,
      userDoc: userDoc,
      status: UserStatus.unverified,
    );
  }

  // Case 3: No userDoc yet
  if (userDoc == null) {
    return AppAuthState(
      firebaseUser: firebaseUser,
      userDoc: null,
      status: UserStatus.unauthenticated,
    );
  }

  // Map status
  final mappedStatus = switch (userDoc.status) {
    'pending' => UserStatus.pending,
    'active' => UserStatus.active,
    'archived' => UserStatus.archived,
    'teamSelect' => UserStatus.teamSelect,
    _ => UserStatus.pending,
  };

  // Map roles
  final globalRole = parseGlobalRole(userDoc.globalRole);
  final teamRole = parseTeamRole(userDoc.teamRole);

  return AppAuthState(
    firebaseUser: firebaseUser,
    userDoc: userDoc,
    status: mappedStatus,
    globalRole: globalRole,
    teamRole: teamRole,
  );
}
