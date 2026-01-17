import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/models/machine_model.dart';
import 'package:flutter_application_1/ui/core/ui/responsive_layout.dart';
import 'operator_machine_view.dart';
import '../../machine_management/view/web_operator_machine_screen.dart';

class ResponsiveMachineManagement extends StatelessWidget {
  final MachineModel? focusedMachine;
  final String? teamId;

  const ResponsiveMachineManagement({super.key, this.focusedMachine, this.teamId});

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