import 'package:flutter_application_1/utils/roles.dart';

GlobalRole parseGlobalRole(String role) {
  return role.toLowerCase() == "superadmin"
      ? GlobalRole.superadmin
      : GlobalRole.user;
}

TeamRole? parseTeamRole(String? role) {
  return switch (role?.toLowerCase()) {
    'admin' => TeamRole.admin,
    'operator' => TeamRole.operator,
    _ => null,
  };
}
