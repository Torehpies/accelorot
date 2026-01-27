import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/models/machine_model.dart';
import 'package:flutter_application_1/ui/core/ui/responsive_layout.dart';
import 'home_screen.dart';
import 'web_home_screen.dart';

class ResponsiveLandingPage extends StatelessWidget {
  final MachineModel? focusedMachine;

  const ResponsiveLandingPage({super.key, this.focusedMachine});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobileView: HomeScreen(focusedMachine: focusedMachine),
      desktopView: LandingPageView(focusedMachine: focusedMachine),
    );
  }
}
