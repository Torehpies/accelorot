import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/core/themes/app_theme.dart';
import 'package:flutter_application_1/ui/core/themes/web_colors.dart';
import 'package:flutter_application_1/ui/web_operator/widgets/pending_members_tab.dart';
import 'package:flutter_application_1/ui/web_operator/widgets/summary_header.dart';
import 'package:flutter_application_1/ui/web_operator/widgets/team_header_with_tabs.dart';
import 'package:flutter_application_1/ui/web_operator/widgets/team_members_tab.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DesktopOperatorManagementScreen extends ConsumerStatefulWidget {
  const DesktopOperatorManagementScreen({super.key});

  @override
  ConsumerState<DesktopOperatorManagementScreen> createState() =>
      _DesktopOperatorManagementScreenState();
}

class _DesktopOperatorManagementScreenState
    extends ConsumerState<DesktopOperatorManagementScreen>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TabController _tabController;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: WebColors.primaryBorder, width: 1.5),
      ),
      child: Column(
        children: [
          SummaryHeader(),
          const SizedBox(height: 10),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: AppColors.background2,
              ),
              child: Column(
                children: [
                  TeamHeaderWithTabs(controller: _tabController),
                  const SizedBox(height: 8),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: const [TeamMembersTab(), PendingMembersTab()],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
