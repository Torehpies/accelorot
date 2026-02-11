import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/services/api/model/team/team.dart';
import 'package:flutter_application_1/ui/core/constants/spacing.dart';
import 'package:flutter_application_1/ui/core/themes/web_colors.dart';
import 'package:flutter_application_1/ui/core/themes/web_text_styles.dart';
import 'package:flutter_application_1/ui/core/widgets/shared/empty_state.dart';
import 'package:flutter_application_1/ui/core/widgets/shared/pagination_controls.dart';
import 'package:flutter_application_1/ui/core/widgets/table/table_action_buttons.dart';
import 'package:flutter_application_1/ui/core/widgets/table/table_body.dart';
import 'package:flutter_application_1/ui/core/widgets/table/table_container.dart';
import 'package:flutter_application_1/ui/core/widgets/table/table_header.dart';
import 'package:flutter_application_1/ui/core/widgets/table/table_row.dart';
import 'package:flutter_application_1/ui/core/widgets/containers/web_base_container.dart';
import 'package:flutter_application_1/ui/team_management/view_model/team_management_notifier.dart';
import 'package:flutter_application_1/ui/team_management/widgets/add_team_dialog.dart';
import 'package:flutter_application_1/ui/team_management/widgets/view_team_dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class DesktopTeamManagementView extends ConsumerWidget {
  const DesktopTeamManagementView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(teamManagementProvider);
    final notifier = ref.read(teamManagementProvider.notifier);

    final pageCount =
        state.hasNextPage ? state.currentPage + 2 : state.currentPage + 1;

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
                showDialog(
                  context: context,
                  builder: (_) => AddTeamDialog(),
                );
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
          rowBuilder: (team) => _buildTeamRow(context, team, notifier),
          skeletonRowBuilder: () => _buildSkeletonRow(),
        ),
        paginationWidget: PaginationControls(
          currentPage: state.currentPage + 1,
          totalPages: pageCount,
          itemsPerPage: state.pageSize,
          isLoading: state.isLoading,
          onPageChanged: (page) => notifier.goToPage(page - 1),
        ),
      ),
    );
  }

  Widget _buildTeamRow(
    BuildContext context,
    Team team,
    TeamManagementNotifier notifier,
  ) {
    return GenericTableRow(
      hoverColor: const Color(0xFFF9FAFB),
      cellSpacing: AppSpacing.md,
      cells: [
        TableCellWidget(
          flex: 2,
          child: Text(
            team.teamName,
            style: WebTextStyles.body,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
        TableCellWidget(
          flex: 2,
          child: Text(
            team.address,
            style: WebTextStyles.body,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
        TableCellWidget(
          flex: 1,
          child: Center(
            child: TableActionButtons(
              actions: [
                TableActionButton(
                  icon: Icons.info,
                  tooltip: 'Quick View',
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => ViewTeamDialog(team: team),
                    );
                  },
                ),
                TableActionButton(
                  icon: Icons.arrow_right,
                  tooltip: 'View Team',
                  onPressed: () {
                    context.pushNamed(
                      'teamDetails',
                      pathParameters: {'teamId': team.teamId.toString()},
                      extra: team,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSkeletonRow() {
    return GenericTableRow(
      cellSpacing: AppSpacing.md,
      cells: [
        TableCellWidget(
          flex: 2,
          child: Center(child: _SkeletonBox(width: 120, height: 16)),
        ),
        TableCellWidget(
          flex: 2,
          child: Center(child: _SkeletonBox(width: 150, height: 16)),
        ),
        TableCellWidget(
          flex: 1,
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _SkeletonBox(width: 24, height: 24, borderRadius: 12),
                const SizedBox(width: 4),
                _SkeletonBox(width: 24, height: 24, borderRadius: 12),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SkeletonBox extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const _SkeletonBox({
    required this.width,
    required this.height,
    this.borderRadius = 6,
  });

  @override
  State<_SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<_SkeletonBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: Color.lerp(
              WebColors.skeletonLoader,
              WebColors.tableBorder,
              _anim.value,
            ),
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
        );
      },
    );
  }
}
