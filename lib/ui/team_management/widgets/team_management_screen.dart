import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/core/themes/app_theme.dart';
import 'package:flutter_application_1/ui/team_management/widgets/add_team_dialog.dart';
import 'package:flutter_application_1/ui/team_management/widgets/desktop_team_management_view.dart';
import 'package:flutter_application_1/ui/team_management/widgets/mobile_team_management_view.dart';
import 'package:flutter_application_1/ui/core/ui/responsive_layout.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TeamManagementScreen extends ConsumerWidget {
  const TeamManagementScreen({super.key});

  void _showAddTeamDialog(BuildContext context) {
    showDialog(context: context, builder: (_) => AddTeamDialog());
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ResponsiveLayout(
          mobileView: MobileTeamManagementView(),
          desktopView: DesktopTeamManagementView(),
        ),
      ),
      floatingActionButton: isMobile
          ? FloatingActionButton(
              onPressed: () => _showAddTeamDialog(context),
              backgroundColor: AppColors.green100,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }
}
