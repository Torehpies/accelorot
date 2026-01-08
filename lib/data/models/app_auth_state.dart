import 'package:flutter_application_1/data/models/app_user.dart';
import 'package:flutter_application_1/utils/roles.dart';
import 'package:flutter_application_1/utils/user_status.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_auth_state.freezed.dart';

@freezed
abstract class AppAuthState with _$AppAuthState {
  const factory AppAuthState.loading() = _Loading;
  const factory AppAuthState.unauthenticated() = _Unauthenticated;
  const factory AppAuthState.unverified({required dynamic firebaseUser}) =
      _Unverified;
  const factory AppAuthState.missingUserDoc({required dynamic firebaseUser}) =
      _MissingUserDoc;
  const factory AppAuthState.authenticated({
    required dynamic firebaseUser,
    required AppUser userDoc,
    required UserStatus status,
    required GlobalRole globalRole,
    required TeamRole? teamRole,
  }) = _Authenticated;

  //final User? firebaseUser;
  //final UserDoc? userDoc;
  //final UserStatus status;

  //final GlobalRole? globalRole;
  //final TeamRole? teamRole;

  //const AppAuthState({
  //  required this.firebaseUser,
  //  required this.userDoc,
  //  required this.status,
  //  this.globalRole,
  //  this.teamRole,
  //});

  //bool get isSuperAdmin => globalRole == GlobalRole.superadmin;
  //bool get isTeamAdmin => teamRole == TeamRole.admin;
  //bool get isTeamOperator => teamRole == TeamRole.operator;
}
