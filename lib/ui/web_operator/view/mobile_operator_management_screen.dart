import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/web_operator/widgets/mobile_pending_members_tab.dart';
import 'package:flutter_application_1/ui/web_operator/widgets/mobile_team_members_tab.dart';
import 'package:flutter_application_1/ui/web_operator/widgets/team_header_with_tabs.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MobileOperatorManagementScreen extends ConsumerStatefulWidget {
  const MobileOperatorManagementScreen({super.key});

  @override
  ConsumerState<MobileOperatorManagementScreen> createState() =>
      _MobileOperatorManagementScreenState();
}

class _MobileOperatorManagementScreenState
    extends ConsumerState<MobileOperatorManagementScreen>
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
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
      ),
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          TeamHeaderWithTabs(controller: _tabController),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.65,
            child: TabBarView(
              controller: _tabController,
              children: const [
                MobileTeamMembersTab(),
                MobilePendingMembersTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
