import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/team_management/widgets/team_management_layout.dart';

class MobileTeamManagementView extends StatelessWidget {
	//TODO content
  const MobileTeamManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    // Uses SingleChildScrollView for keyboard safety on mobile
    return SingleChildScrollView(
      child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 32.0, // Reduced vertical padding from login view
            ),
            // Delegates the content rendering to the shared form
            child: const TeamManagementLayout(),
          ),
        ),
    );
  }
}
