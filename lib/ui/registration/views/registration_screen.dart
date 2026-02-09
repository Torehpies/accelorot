import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/core/themes/app_theme.dart';
import 'package:flutter_application_1/ui/core/ui/responsive_layout.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'desktop_registration_view.dart';
import 'mobile_registration_view.dart';
import 'tablet_registration_view.dart';

class RegistrationScreen extends ConsumerWidget {
  const RegistrationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background2,
      body: SafeArea(
        child: RepaintBoundary(
          child: ResponsiveLayout(
            mobileView: const MobileRegistrationView(),
            tabletView: const TabletRegistrationView(),
            desktopView: const DesktopRegistrationView(),
          ),
        ),
      ),
    );
  }
}
