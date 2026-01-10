import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/core/themes/app_theme.dart';
import 'package:flutter_application_1/ui/core/ui/responsive_layout.dart';
import 'package:flutter_application_1/ui/web_operator/view/desktop_operator_management_screen.dart';
import 'package:flutter_application_1/ui/web_operator/view/web_operator_management_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OperatorManagementScreen extends ConsumerWidget {
  const OperatorManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ResponsiveLayout(
          mobileView: const OldDesktopOperatorManagementScreen(),
          desktopView: const DesktopOperatorManagementScreen(),
        ),
      ),
    );
  }
}
