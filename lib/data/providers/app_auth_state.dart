import 'package:flutter_application_1/data/models/app_auth_state.dart';
import 'package:flutter_application_1/data/providers/auth_providers.dart';
import 'package:flutter_application_1/data/providers/core_providers.dart';
import 'package:flutter_application_1/utils/role_mapper.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_auth_state.g.dart';

@Riverpod(keepAlive: true)
AppAuthState authStateModel(Ref ref) {
  final authStream = ref.watch(authStateChangesProvider);

  return authStream.when(
    data: (firebaseUser) {
      if (firebaseUser == null) {
        return const AppAuthState.unauthenticated();
      }

      if (!firebaseUser.emailVerified) {
        return AppAuthState.unverified(firebaseUser: firebaseUser);
      }

      final appUserAsync = ref.watch(appUserProvider);

      return appUserAsync.when(
        data: (appUser) {
          if (appUser == null && !appUserAsync.isLoading) {
					print("MISSUNG USER DOC");
            return AppAuthState.missingUserDoc(firebaseUser: firebaseUser);
          }
          if (appUser == null) {
            return AppAuthState.loading();
          }
          final globalRole = parseGlobalRole(appUser.globalRole);
          final teamRole = parseTeamRole(appUser.teamRole);

					print("AUTHENTICATED");
          return AppAuthState.authenticated(
            firebaseUser: firebaseUser,
            userDoc: appUser,
            status: appUser.status,
            globalRole: globalRole,
            teamRole: teamRole,
          );
        },
        error: (_, _) {
          return const AppAuthState.unauthenticated();
        },
        loading: () {
          return const AppAuthState.loading();
        },
      );

      //final appUser = appUserAsync.value;
    },
    error: (_, _) {
      return const AppAuthState.unauthenticated();
    },
    loading: () {
      return const AppAuthState.loading();
    },
  );
}
