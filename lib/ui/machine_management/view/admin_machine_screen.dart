// lib/ui/machine_management/view/admin_machine_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/core/ui/responsive_layout.dart';
import 'package:flutter_application_1/ui/machine_management/view/mobile_admin_machine_view.dart';
import 'package:flutter_application_1/ui/machine_management/view/web_admin_machine_screen.dart';
class AdminMachineScreens extends StatelessWidget {
  const AdminMachineScreens({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobileView: const AdminMachineView(),
      desktopView: const WebAdminMachineScreen(),
    );
  }
}