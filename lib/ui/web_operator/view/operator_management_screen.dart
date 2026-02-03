import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/core/themes/app_theme.dart';
import 'package:flutter_application_1/ui/core/ui/responsive_layout.dart';
import 'package:flutter_application_1/ui/core/widgets/shared/mobile_header.dart';
import 'package:flutter_application_1/ui/web_operator/view/desktop_operator_management_screen.dart';
import 'package:flutter_application_1/ui/web_operator/view/mobile_operator_management_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OperatorManagementScreen extends ConsumerWidget {
  const OperatorManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDesktop = MediaQuery.of(context).size.width >= kTabletBreakpoint;
    return Scaffold(
      appBar: isDesktop
          ? null
          : const MobileHeader(title: 'Operator Management'),
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ResponsiveLayout(
          mobileView: const MobileOperatorManagementScreen(),
          desktopView: const DesktopOperatorManagementScreen(),
        ),
      ),
    );
  }
}
