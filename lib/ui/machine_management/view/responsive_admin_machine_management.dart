// lib/ui/machine_management/view/responsive_admin_machine_management.dart

import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/core/ui/responsive_layout.dart';
import 'admin_machine_view.dart';
import 'web_admin_machine_screen.dart';

class ResponsiveAdminMachineManagement extends StatelessWidget {
  final String? teamId;

  const ResponsiveAdminMachineManagement({
    super.key,
    this.teamId,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobileView: const AdminMachineView(),
      desktopView: AdminMachineScreen(
        teamId: teamId ?? '',
      ),
    );
  }
}
