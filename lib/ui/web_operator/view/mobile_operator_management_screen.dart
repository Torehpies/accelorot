import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/web_operator/widgets/pending_members_tab.dart';
import 'package:flutter_application_1/ui/web_operator/widgets/team_header_with_tabs.dart';
import 'package:flutter_application_1/ui/web_operator/widgets/team_members_tab.dart';
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
		return Text("HI");
    // return SingleChildScrollView(
    //   child: Column(
    //     children: [
    //       TeamHeaderWithTabs(controller: _tabController),
    //       const SizedBox(height: 8),
    //       TabBarView(
    //         controller: _tabController,
    //         children: const [TeamMembersTab(), PendingMembersTab()],
    //       ),
    //     ],
    //   ),
    // );
  }
}
