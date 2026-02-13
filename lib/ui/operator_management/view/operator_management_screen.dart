import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/core/themes/app_theme.dart';
import 'package:flutter_application_1/ui/core/ui/responsive_layout.dart';
import 'package:flutter_application_1/ui/operator_management/view/desktop_operator_management_screen.dart';
import 'package:flutter_application_1/ui/operator_management/view/mobile_operator_management_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OperatorManagementScreen extends ConsumerWidget {
  const OperatorManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: ResponsiveLayout(
        mobileView: const MobileOperatorManagementScreen(),
        desktopView: const DesktopOperatorManagementScreen(),
      ),
    );
  }
}