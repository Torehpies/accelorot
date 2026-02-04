import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/core/widgets/web_base_container.dart';
import 'package:flutter_application_1/ui/web_operator/widgets/pending_members_tab.dart';
import 'package:flutter_application_1/ui/web_operator/widgets/summary_header.dart';
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

    return WebContentContainer(
      child: WebStatsTableLayout(
        statsRow: const SummaryHeader(),
        table: TabBarView(
          controller: _tabController,
          children: [
            TeamMembersTab(tabController: _tabController),
            PendingMembersTab(tabController: _tabController),
          ],
        ),
      ),
    );
  }
}