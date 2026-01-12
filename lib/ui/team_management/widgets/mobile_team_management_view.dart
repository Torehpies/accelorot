import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/team_management/widgets/desktop_team_management_view.dart';

class MobileTeamManagementView extends StatelessWidget {
  //TODO Mobile version of mobile team management
  const MobileTeamManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 24.0,
          vertical: 32.0, // Reduced vertical padding from login view
        ),
        child: const DesktopTeamManagementView(),
      ),
    );
  }
}
