// lib/ui/machine_management/view/responsive_operator_machine_management.dart

import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/models/machine_model.dart';
import 'package:flutter_application_1/ui/core/ui/responsive_layout.dart';
import 'operator_machine_view.dart';
import '../../machine_management/view/web_operator_machine_screen.dart';

class ResponsiveOperatorMachineManagement extends StatelessWidget {
  final MachineModel? focusedMachine;
  final String? teamId;

  const ResponsiveOperatorMachineManagement({
    super.key, 
    this.focusedMachine,
     this.teamId
     });

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobileView: OperatorMachineView(teamId: focusedMachine?.teamId ?? ''),
      desktopView: OperatorMachineScreen(
        teamId: focusedMachine?.teamId ?? '',
      ),
    );
  }
}