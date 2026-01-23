import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/core/themes/app_theme.dart';
import 'package:flutter_application_1/ui/core/widgets/filters/date_filter_dropdown.dart';
import 'package:flutter_application_1/ui/web_operator/view_model/pending_members_notifier.dart';
import 'package:flutter_application_1/ui/web_operator/view_model/team_members_notifier.dart';
import 'package:flutter_application_1/ui/web_operator/widgets/tabs_row.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TeamHeaderWithTabs extends StatelessWidget {
  final TabController controller;

  const TeamHeaderWithTabs({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= kTabletBreakpoint;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: isDesktop
            ? MainAxisAlignment.start
            : MainAxisAlignment.center,
        children: [
          TabsRow(controller: controller),
          if (isDesktop) ..._buildFilters(controller),
        ],
      ),
    );
  }
}

List<Widget> _buildFilters(TabController controller) => [
  const Spacer(),
  Consumer(
    builder: (context, ref, child) {
      final activeTabIndex = controller.index;
      final isTeamMembersTab = activeTabIndex == 0;
      return DateFilterDropdown(
        isLoading: isTeamMembersTab
            ? ref.watch(teamMembersProvider).isLoading
            : ref.watch(pendingMembersProvider).isLoading,
        onFilterChanged: (filter) {
          if (isTeamMembersTab) {
            ref.read(teamMembersProvider.notifier).setDateFilter(filter);
          } else {
            ref.read(pendingMembersProvider.notifier).setDateFilter(filter);
          }
        },
      );
    },
  ),
  const SizedBox(width: 12),
  SizedBox(
    width: 220,
    child: TextField(
      decoration: InputDecoration(
        isDense: true,
        prefixIcon: const Icon(Icons.search, size: 18),
        hintText: 'Search…',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
      ),
    ),
  ),
  const SizedBox(width: 12),
  ElevatedButton(
    onPressed: () {},
    style: ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
    ),
    child: const Text('Add Operator'),
  ),
];
