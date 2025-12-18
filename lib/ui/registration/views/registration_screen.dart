import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/core/ui/responsive_layout.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'desktop_registration_view.dart';
import 'mobile_registration_view.dart';

class RegistrationScreen extends ConsumerWidget {
  const RegistrationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ResponsiveLayout(
          mobileView: MobileRegistrationView(),
          desktopView: DesktopRegistrationView(),
        ),
      ),
    );
  }
}
