import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/services/api/model/team/team.dart';
import 'package:flutter_application_1/data/services/api/model/team_member/team_member.dart';
import 'package:flutter_application_1/ui/core/constants/spacing.dart';
import 'package:flutter_application_1/ui/core/themes/web_colors.dart';
import 'package:flutter_application_1/ui/core/themes/web_text_styles.dart';
import 'package:flutter_application_1/ui/core/widgets/filters/date_filter_dropdown.dart';
import 'package:flutter_application_1/ui/core/widgets/filters/filter_dropdown.dart';
import 'package:flutter_application_1/ui/core/widgets/filters/search_field.dart';
import 'package:flutter_application_1/ui/core/widgets/shared/empty_state.dart';
import 'package:flutter_application_1/ui/core/widgets/shared/pagination_controls.dart';
import 'package:flutter_application_1/ui/core/widgets/table/table_action_buttons.dart';
import 'package:flutter_application_1/ui/core/widgets/table/table_body.dart';
import 'package:flutter_application_1/ui/core/widgets/table/table_container.dart';
import 'package:flutter_application_1/ui/core/widgets/table/table_header.dart';
import 'package:flutter_application_1/ui/core/widgets/table/table_row.dart';
import 'package:flutter_application_1/ui/team_management/models/team_member_filters.dart';
import 'package:flutter_application_1/ui/team_management/view_model/team_detail_notifier.dart';
import 'package:flutter_application_1/ui/team_management/widgets/add_admin_dialog.dart';
import 'package:flutter_application_1/ui/team_management/widgets/view_member_dialog.dart';
import 'package:flutter_application_1/ui/web_operator/widgets/status_badge.dart';
import 'package:flutter_application_1/ui/core/widgets/web_base_container.dart';
import 'package:flutter_application_1/ui/web_operator/widgets/tabs_row.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TeamDetailScreen extends ConsumerStatefulWidget {
  final Team team;

  const TeamDetailScreen({super.key, required this.team});

  @override
  TeamDetailScreenState createState() => TeamDetailScreenState();
}

class TeamDetailScreenState extends ConsumerState<TeamDetailScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  String get _teamId => widget.team.teamId?.toString() ?? 'default-team-id';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(teamDetailProvider(_teamId));
    final notifier = ref.read(teamDetailProvider(_teamId).notifier);
    // Choose items based on active tab
    final items = _tabController.index == 0
        ? state.filteredAdmins
        : state.filteredMembers;
    final pageCount = state.hasNextPage
        ? state.currentPage + 2
        : state.currentPage + 1;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          tooltip: 'Back',
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          widget.team.teamName,
          style: WebTextStyles.h2,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: false,
      ),
      body: WebContentContainer(
        child: BaseTableContainer(
          leftHeaderWidget: TabsRow(
            controller: _tabController,
            tabTitles: ['Admins', 'Operators'],
          ),
          rightHeaderWidgets: [
            SizedBox(
              height: 32,
              child: DateFilterDropdown(
                isLoading: state.isLoading,
                onFilterChanged: (filter) => notifier.setDateFilter(filter),
              ),
            ),
            SearchField(
              isLoading: state.isLoading,
              onChanged: (query) => notifier.setSearch(query),
            ),
            Tooltip(
              message: 'Add Admin',
              child: ElevatedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => AddAdminDialog(teamId: _teamId),
                  );
                },
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Admin'),
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
                child: TableHeaderCell(
                  label: 'First Name',
                  sortable: true,
                  sortColumn: 'firstName',
                  currentSortColumn: state.sortColumn,
                  sortAscending: state.sortAscending,
                  onSort: () => notifier.onSort('firstName'),
                ),
              ),
              TableCellWidget(
                flex: 2,
                child: TableHeaderCell(
                  label: 'Last Name',
                  sortable: true,
                  sortColumn: 'lastName',
                  currentSortColumn: state.sortColumn,
                  sortAscending: state.sortAscending,
                  onSort: () => notifier.onSort('lastName'),
                ),
              ),
              TableCellWidget(
                flex: 3,
                child: TableHeaderCell(
                  label: 'Email',
                  sortable: true,
                  sortColumn: 'email',
                  currentSortColumn: state.sortColumn,
                  sortAscending: state.sortAscending,
                  onSort: () => notifier.onSort('email'),
                ),
              ),
              TableCellWidget(
                flex: 1,
                child: SizedBox(
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Status',
                          style: WebTextStyles.label.copyWith(
                            color:
                                state.statusFilter != TeamMemberStatusFilter.all
                                ? WebColors.greenAccent
                                : WebColors.textLabel,
                          ),
                        ),
                        const SizedBox(width: 8),
                        FilterDropdown<TeamMemberStatusFilter>(
                          label: 'Status',
                          value: state.statusFilter,
                          items: TeamMemberStatusFilter.values,
                          displayName: (filter) => filter.displayName,
                          onChanged: (filter) =>
                              notifier.setStatusFilter(filter),
                          isLoading: state.isLoading,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              TableCellWidget(
                flex: 1,
                child: const TableHeaderCell(label: 'Actions'),
              ),
            ],
          ),
          tableBody: TableBody<TeamMember>(
            items: items,
            isLoading: state.isLoading && state.members.isEmpty,
            emptyStateWidget: const EmptyState(
              title: 'No members found',
              subtitle: 'Try adjusting your filters or search',
              icon: Icons.person_search,
            ),
            rowBuilder: (member) => _buildMemberRow(member),
            skeletonRowBuilder: () => _buildSkeletonRow(),
          ),
          paginationWidget: PaginationControls(
            currentPage: state.currentPage + 1,
            totalPages: pageCount,
            itemsPerPage: state.pageSize,
            isLoading: state.isLoading,
            onPageChanged: (page) => notifier.goToPage(page - 1),
            onItemsPerPageChanged: notifier.setPageSize,
          ),
        ),
      ),
    );
  }

  Widget _buildMemberRow(TeamMember member) {
    return GenericTableRow(
      hoverColor: const Color(0xFFF9FAFB),
      cellSpacing: AppSpacing.md,
      cells: [
        // First Name (flex: 2)
        TableCellWidget(
          flex: 2,
          child: Text(
            member.firstName,
            style: WebTextStyles.body,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
        // Last Name (flex: 2)
        TableCellWidget(
          flex: 2,
          child: Text(
            member.lastName,
            style: WebTextStyles.body,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
        // Email (flex: 3)
        TableCellWidget(
          flex: 3,
          child: Text(
            member.email,
            style: WebTextStyles.body,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
        // Status (flex: 1)
        TableCellWidget(
          flex: 1,
          child: Center(child: StatusBadge(status: member.status.value)),
        ),
        // Actions (flex: 1)
        TableCellWidget(
          flex: 1,
          child: Center(
            child: TableActionButtons(
              actions: [
                TableActionButton(
                  icon: Icons.visibility,
                  tooltip: 'View',
                  onPressed: () => _showViewDialog(context, member),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showViewDialog(BuildContext context, dynamic member) {
    showDialog(
      context: context,
      builder: (_) => ViewMemberDialog(operator: member),
    );
  }

  Widget _buildSkeletonRow() {
    return GenericTableRow(
      cellSpacing: AppSpacing.md,
      cells: [
        TableCellWidget(
          flex: 2,
          child: Center(child: _SkeletonBox(width: 100, height: 16)),
        ),
        TableCellWidget(
          flex: 2,
          child: Center(child: _SkeletonBox(width: 100, height: 16)),
        ),
        TableCellWidget(
          flex: 3,
          child: Center(child: _SkeletonBox(width: 180, height: 16)),
        ),
        TableCellWidget(
          flex: 1,
          child: Center(
            child: _SkeletonBox(width: 70, height: 24, borderRadius: 5),
          ),
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
