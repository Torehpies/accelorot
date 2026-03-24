import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/services/api/model/team/team.dart';
import 'package:flutter_application_1/ui/core/constants/spacing.dart';
import 'package:flutter_application_1/ui/core/themes/web_colors.dart';
import 'package:flutter_application_1/ui/core/themes/web_text_styles.dart';
import 'package:flutter_application_1/ui/core/widgets/shared/empty_state.dart';
import 'package:flutter_application_1/ui/core/widgets/shared/pagination_controls.dart';
import 'package:flutter_application_1/ui/core/widgets/table/table_body.dart';
import 'package:flutter_application_1/ui/core/widgets/table/table_container.dart';
import 'package:flutter_application_1/ui/core/widgets/table/table_header.dart';
import 'package:flutter_application_1/ui/core/widgets/table/table_row.dart';
import 'package:flutter_application_1/ui/core/widgets/containers/web_base_container.dart';
import 'package:flutter_application_1/ui/team_management/view_model/team_management_notifier.dart';
import 'package:flutter_application_1/ui/team_management/dialogs/add_team_dialog.dart';
import 'package:flutter_application_1/ui/team_management/widgets/skeleton_row.dart';
import 'package:flutter_application_1/ui/team_management/widgets/team_row.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DesktopTeamManagementView extends ConsumerWidget {
  const DesktopTeamManagementView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(teamManagementProvider);
    final notifier = ref.read(teamManagementProvider.notifier);

    final pageCount = state.hasNextPage
        ? state.currentPage + 2
        : state.currentPage + 1;

    return WebContentContainer(
      child: BaseTableContainer(
        leftHeaderWidget: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.group, color: WebColors.textSecondary),
            const SizedBox(width: AppSpacing.sm),
            Text('Teams', style: WebTextStyles.sectionTitle),
          ],
        ),
        rightHeaderWidgets: [
          Tooltip(
            message: 'Add Team',
            child: ElevatedButton.icon(
              onPressed: () {
                showDialog(context: context, builder: (_) => AddTeamDialog());
              },
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Team'),
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
        tableHeader: TableHeader(
          isLoading: state.isLoading,
          columns: [
            TableCellWidget(
              flex: 2,
              child: const TableHeaderCell(label: 'Team Name'),
            ),
            TableCellWidget(
              flex: 2,
              child: const TableHeaderCell(label: 'Address'),
            ),
            TableCellWidget(
              flex: 1,
              child: const TableHeaderCell(label: 'Actions'),
            ),
          ],
        ),
        tableBody: TableBody<Team>(
          items: state.teams,
          isLoading: state.isLoading && state.teams.isEmpty,
          emptyStateWidget: const EmptyState(
            title: 'No teams found',
            subtitle: 'Try adding a new team',
            icon: Icons.group_off,
          ),
          rowBuilder: (team) => TeamRow(team: team, notifier: notifier),
          skeletonRowBuilder: () => SkeletonRow(),
        ),
        paginationWidget: PaginationControls(
          currentPage: state.currentPage + 1,
          totalPages: pageCount,
          itemsPerPage: state.pageSize,
          isLoading: state.isLoading,
          onPageChanged: (page) => notifier.goToPage(page - 1),
          onItemsPerPageChanged: (newSize) => notifier.setPageSize(newSize),
        ),
      ),
    );
  }
}
