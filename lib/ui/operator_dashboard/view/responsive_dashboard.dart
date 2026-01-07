import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/models/machine_model.dart';
import 'home_screen.dart';
import 'web_home_screen.dart';

class ResponsiveDashboard extends StatelessWidget {
  final MachineModel? focusedMachine;

  const ResponsiveDashboard({super.key, this.focusedMachine});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Use web layout for screens wider than 600px, mobile otherwise
        if (constraints.maxWidth > 600) {
          return WebHomeScreen(focusedMachine: focusedMachine);
        } else {
          return HomeScreen(focusedMachine: focusedMachine);
        }
      },
    );
  }
}