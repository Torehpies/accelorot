// lib/ui/reports/view/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/core/ui/responsive_layout.dart';
import 'package:flutter_application_1/ui/profile_screen/web_widgets/web_profile_view.dart';
import 'package:flutter_application_1/ui/profile_screen/widgets/profile_view.dart';

class ProfileScreenRoute extends StatelessWidget {
  const ProfileScreenRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobileView: const ProfileView(),
      desktopView: const WebProfileView(),
    );
  }
}
