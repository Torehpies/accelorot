import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/core/themes/app_theme.dart';
import 'package:flutter_application_1/ui/core/widgets/filters/date_filter_dropdown.dart';
import 'package:flutter_application_1/ui/core/widgets/filters/search_field.dart';
import 'package:flutter_application_1/ui/operator_management/providers/operators_date_filter_provider.dart';
import 'package:flutter_application_1/ui/operator_management/view_model/pending_members_notifier.dart';
import 'package:flutter_application_1/ui/operator_management/view_model/team_members_notifier.dart';
import 'package:flutter_application_1/ui/operator_management/widgets/tabs_row.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TeamHeaderWithTabs extends StatelessWidget {
  final TabController controller;
  final List<String> tabTitles;

  const TeamHeaderWithTabs({
    super.key,
    required this.controller,
    required this.tabTitles,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= kTabletBreakpoint;
    final isTablet =
        MediaQuery.of(context).size.width >= kTabletBreakpoint &&
        MediaQuery.of(context).size.width < kDesktopBreakpoint;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: isDesktop
            ? MainAxisAlignment.start
            : MainAxisAlignment.center,
        children: [
          TabsRow(controller: controller, tabTitles: tabTitles),
          if (isDesktop) ..._buildFilters(controller, isTablet),
        ],
      ),
    );
  }
}

List<Widget> _buildFilters(TabController controller, bool isTablet) => [
  const Spacer(),
  Consumer(
    builder: (context, ref, child) {
      final activeTabIndex = controller.index;
      return DateFilterDropdown(
        isLoading: activeTabIndex == 0
            ? ref.watch(teamMembersProvider).isLoading
            : ref.watch(pendingMembersProvider).isLoading,
        onFilterChanged: (filter) {
          ref.read(operatorsDateFilterProvider.notifier).setFilter(filter);
        },
      );
    },
  ),
  const SizedBox(width: 12),
  Consumer(
    builder: (context, ref, child) {
      final activeTabIndex = controller.index;
      final isLoading = activeTabIndex == 0
          ? ref.watch(teamMembersProvider).isLoading
          : ref.watch(pendingMembersProvider).isLoading;

      return SizedBox(
        width: 220,
        child: SearchField(
          isLoading: isLoading,
          onChanged: (query) {
            if (activeTabIndex == 0) {
              ref.read(teamMembersProvider.notifier).setSearch(query);
            } else {
              ref.read(pendingMembersProvider.notifier).setSearch(query);
            }
          },
        ),
      );
    },
  ),
  const SizedBox(width: 12),
  Tooltip(
    message: 'Add Operator',
    child: ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Icon(Icons.add),
          ?!isTablet ? const Text('Add Operator') : null,
        ],
      ),
    ),
  ),
];
