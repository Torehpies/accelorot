import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/models/machine_model.dart';
import 'package:flutter_application_1/ui/core/ui/responsive_layout.dart';
import '../view/operator_machine_view.dart';
import '../../web_operator_machine_management/view/machines_view.dart';

class ResponsiveMachineManagement extends StatelessWidget {
  final MachineModel? focusedMachine;

  const ResponsiveMachineManagement({super.key, this.focusedMachine});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobileView: OperatorMachineView(),
      desktopView: MachinesView(),
    );
  }
}