import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/services/api/model/team/team.dart';
import 'package:flutter_application_1/ui/core/widgets/table/table_body.dart';
import 'package:flutter_application_1/ui/core/widgets/table/table_container.dart';
import 'package:flutter_application_1/ui/core/widgets/table/table_header.dart';
import 'package:flutter_application_1/ui/core/widgets/table/table_action_buttons.dart';
import 'package:flutter_application_1/ui/core/widgets/table/table_row.dart';
import 'package:flutter_application_1/ui/web_operator/widgets/team_header_with_tabs.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/ui/team_management/view_model/team_detail_notifier.dart';

class TeamDetailScreen extends ConsumerStatefulWidget {
  final Team team;

  const TeamDetailScreen({super.key, required this.team});

  @override
  TeamDetailScreenState createState() => TeamDetailScreenState();
}

class TeamDetailScreenState extends ConsumerState<TeamDetailScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

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
    final teamId = widget.team.teamId != null
        ? widget.team.teamId.toString()
        : 'default-team-id';
    final state = ref.watch(teamDetailProvider(teamId));

    return Scaffold(
      appBar: AppBar(
        title: Text('Team Details - ${widget.team.teamName}'),
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          TeamHeaderWithTabs(
            controller: _tabController,
            tabTitles: ['Admins', 'Operators'],
          ),
          Expanded(
            child: state.isLoading
                ? Center(child: CircularProgressIndicator())
                : state.errorMessage != null
                ? Center(child: Text(state.errorMessage!))
                : TabBarView(
                    controller: _tabController,
                    children: [_buildAdminsTab(state), _buildMembersTab(state)],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminsTab(TeamDetailState state) {
    return BaseTableContainer(
      tableHeader: TableHeader(
        columns: [
          TableCellWidget(flex: 3, child: Text('Name')),
          TableCellWidget(flex: 3, child: Text('Email')),
          TableCellWidget(flex: 2, child: Text('Actions')),
        ],
      ),
      tableBody: TableBody(
        items: state.admins,
        rowBuilder: (admin) => GenericTableRow(
          cells: [
            TableCellWidget(
              flex: 3,
              child: Text('${admin.firstName} ${admin.lastName}'),
            ),
            TableCellWidget(flex: 3, child: Text(admin.email)),
            TableCellWidget(
              flex: 2,
              child: TableActionButtons(
                actions: [
                  TableActionButton(
                    icon: Icons.edit,
                    tooltip: 'Edit',
                    onPressed: () {},
                  ),
                  TableActionButton(
                    icon: Icons.delete,
                    tooltip: 'Remove',
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMembersTab(TeamDetailState state) {
    return BaseTableContainer(
      tableHeader: TableHeader(
        columns: [
          TableCellWidget(flex: 3, child: Text('Name')),
          TableCellWidget(flex: 3, child: Text('Email')),
          TableCellWidget(flex: 2, child: Text('Actions')),
        ],
      ),
      tableBody: TableBody(
        items: state.members,
        rowBuilder: (member) => GenericTableRow(
          cells: [
            TableCellWidget(
              flex: 3,
              child: Text('${member.firstName} ${member.lastName}'),
            ),
            TableCellWidget(flex: 3, child: Text(member.email)),
            TableCellWidget(
              flex: 2,
              child: TableActionButtons(
                actions: [
                  TableActionButton(
                    icon: Icons.arrow_upward,
                    tooltip: 'Promote',
                    onPressed: () {},
                  ),
                  TableActionButton(
                    icon: Icons.delete,
                    tooltip: 'Remove',
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
