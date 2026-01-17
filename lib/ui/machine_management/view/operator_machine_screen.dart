// lib/ui/machine_management/view/operator_machine_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/core/ui/responsive_layout.dart';
import 'package:flutter_application_1/ui/machine_management/view/web_operator_machine_screen.dart';
import 'package:flutter_application_1/ui/machine_management/view/operator_machine_view.dart';

class OperatorMachineScreens extends StatelessWidget {
  const OperatorMachineScreens({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobileView: const OperatorMachineView(),
      desktopView: const WebOperatorMachineScreen(),
    );
  }
}