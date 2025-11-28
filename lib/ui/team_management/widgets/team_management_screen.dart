import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/team_management/view_model/team_management_notifier.dart';
import 'package:flutter_application_1/ui/team_management/widgets/desktop_team_management_view.dart';
import 'package:flutter_application_1/ui/team_management/widgets/mobile_team_management_view.dart';
import 'package:flutter_application_1/utils/snackbar_utils.dart';
import 'package:flutter_application_1/widgets/common/responsive_layout.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TeamManagementScreen extends ConsumerStatefulWidget {
  const TeamManagementScreen({super.key});

  @override
  ConsumerState<TeamManagementScreen> createState() =>
      _TeamManagementScreenState();
}

class _TeamManagementScreenState extends ConsumerState<TeamManagementScreen> {
  @override
  void initState() {
    super.initState();
    ref.listenManual(teamManagementProvider, (previous, next) {
      if (next.errorMessage != null &&
          previous?.errorMessage != next.errorMessage) {
        if (mounted) {
          showSnackbar(context, next.errorMessage!, isError: true);
        }
      }
      if (next.successMessage != null &&
          previous?.successMessage != next.successMessage) {
        if (mounted) {
          showSnackbar(context, next.successMessage!);
        }
      }
    });
  }

  @override
  void dispose() {}

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(
      teamManagementProvider.select((state) => state.isLoading),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ResponsiveLayout(
          mobileView: MobileTeamManagementView(),
          desktopView: DesktopTeamManagementView(),
        ),
      ),
    );
  }
}
