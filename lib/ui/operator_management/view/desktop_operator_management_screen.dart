// lib/ui/operator_management/view/desktop_operator_management_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/core/widgets/containers/web_base_container.dart';
import 'package:flutter_application_1/ui/core/widgets/filters/date_filter_dropdown.dart';
import 'package:flutter_application_1/ui/core/widgets/filters/search_field.dart';
import 'package:flutter_application_1/ui/core/widgets/table/table_container.dart';
import 'package:flutter_application_1/ui/operator_management/providers/operators_date_filter_provider.dart';
import 'package:flutter_application_1/ui/operator_management/view_model/pending_members_notifier.dart';
import 'package:flutter_application_1/ui/operator_management/view_model/team_members_notifier.dart';
import 'package:flutter_application_1/ui/operator_management/widgets/add_operator_dialog.dart';
import 'package:flutter_application_1/ui/operator_management/widgets/pending_members_tab.dart';
import 'package:flutter_application_1/ui/operator_management/widgets/summary_header.dart';
import 'package:flutter_application_1/ui/operator_management/widgets/tabs_row.dart';
import 'package:flutter_application_1/ui/operator_management/widgets/team_members_tab.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _kMembersTab = 0;

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

  // ── Search — routes to correct notifier based on active tab ──

  void _handleSearch(String query) {
    if (_tabController.index == _kMembersTab) {
      ref.read(teamMembersProvider.notifier).setSearch(query);
    } else {
      ref.read(pendingMembersProvider.notifier).setSearch(query);
    }
  }

  // ── Loading state — drives search field disabled state ──

  bool get _isLoading => _tabController.index == _kMembersTab
      ? ref.watch(teamMembersProvider).isLoading
      : ref.watch(pendingMembersProvider).isLoading;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return WebContentContainer(
      child: WebStatsTableLayout(
        statsRow: const SummaryHeader(),
        table: BaseTableContainer(
          // ── Tab switcher ──
          leftHeaderWidget: TabsRow(
            controller: _tabController,
            tabTitles: const ['Members', 'For Approval'],
          ),

          // ── Date filter + search + add button ──
          rightHeaderWidgets: [
            SizedBox(
              height: 32,
              child: DateFilterDropdown(
                isLoading: _isLoading,
                onFilterChanged: (filter) => ref
                    .read(operatorsDateFilterProvider.notifier)
                    .setFilter(filter),
              ),
            ),
            SearchField(
              isLoading: _isLoading,
              onChanged: _handleSearch,
            ),
            Tooltip(
              message: 'Add Operator',
              child: ElevatedButton.icon(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => AddOperatorDialog(),
                ),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Operator'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],

          // ── Only the table content swaps on tab change ──
          tableBody: TabBarView(
            controller: _tabController,
            physics: const NeverScrollableScrollPhysics(),
            children: const [
              TeamMembersTab(),
              PendingMembersTab(),
            ],
          ),
        ),
      ),
    );
  }
}