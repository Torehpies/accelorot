import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/data/models/user_doc.dart';
import 'package:flutter_application_1/utils/roles.dart';
import 'package:flutter_application_1/utils/user_status.dart';

class AppAuthState {
  final User? firebaseUser;
  final UserDoc? userDoc;
  final UserStatus status;

  final GlobalRole? globalRole;
  final TeamRole? teamRole;

  const AppAuthState({
    required this.firebaseUser,
    required this.userDoc,
    required this.status,
    this.globalRole,
    this.teamRole,
  });

  bool get isSuperAdmin => globalRole == GlobalRole.superadmin;
  bool get isTeamAdmin => teamRole == TeamRole.admin;
  bool get isTeamOperator => teamRole == TeamRole.operator;
}

