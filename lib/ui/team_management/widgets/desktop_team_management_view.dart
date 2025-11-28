import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/team_management/widgets/team_management_layout.dart';

class DesktopTeamManagementView extends StatelessWidget {
  const DesktopTeamManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: TeamManagementLayout());
  }
}
