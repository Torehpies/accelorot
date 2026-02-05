import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/services/api/model/pending_member/pending_member.dart';
import 'package:flutter_application_1/ui/core/constants/spacing.dart';
import 'package:flutter_application_1/ui/core/themes/web_colors.dart';
import 'package:flutter_application_1/ui/core/widgets/filters/date_filter_dropdown.dart';
import 'package:flutter_application_1/ui/core/widgets/filters/search_field.dart';
import 'package:flutter_application_1/ui/core/widgets/shared/empty_state.dart';
import 'package:flutter_application_1/ui/core/widgets/shared/pagination_controls.dart';
import 'package:flutter_application_1/ui/core/widgets/table/table_body.dart';
import 'package:flutter_application_1/ui/core/widgets/table/table_container.dart';
import 'package:flutter_application_1/ui/core/widgets/table/table_header.dart';
import 'package:flutter_application_1/ui/core/widgets/table/table_row.dart';
import 'package:flutter_application_1/ui/web_operator/providers/operators_date_filter_provider.dart';
import 'package:flutter_application_1/ui/web_operator/view_model/pending_members_notifier.dart';
import 'package:flutter_application_1/ui/web_operator/widgets/add_operator_dialog.dart';
import 'package:flutter_application_1/ui/web_operator/widgets/pending_member_row.dart';
import 'package:flutter_application_1/ui/web_operator/widgets/tabs_row.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PendingMembersTab extends ConsumerStatefulWidget {
  final TabController tabController;

  const PendingMembersTab({super.key, required this.tabController});

  @override
  ConsumerState<PendingMembersTab> createState() => _PendingMembersTabState();
}

class _PendingMembersTabState extends ConsumerState<PendingMembersTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final state = ref.watch(pendingMembersProvider);
    final notifier = ref.read(pendingMembersProvider.notifier);

    final pageCount = state.hasNextPage
        ? state.currentPage + 2
        : state.currentPage + 1;

    return BaseTableContainer(
      // ── Left header: tab switcher (same controller, shared with TeamMembersTab) ──
      leftHeaderWidget: TabsRow(controller: widget.tabController),

      // ── Right header: date filter, search, add button ──
      rightHeaderWidgets: [
        SizedBox(
          height: 32,
          child: DateFilterDropdown(
            isLoading: state.isLoading,
            onFilterChanged: (filter) {
              ref.read(operatorsDateFilterProvider.notifier).setFilter(filter);
            },
          ),
        ),
        SearchField(
          isLoading: state.isLoading,
          onChanged: (query) => notifier.setSearch(query),
        ),
        Tooltip(
          message: 'Add Operator',
          child: ElevatedButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) => AddOperatorDialog(),
              );
            },
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add Operator'),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],

      // ── Table header: sortable columns ──
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
            flex: 2,
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
            flex: 2,
            child: TableHeaderCell(
              label: 'Requested At',
              sortable: true,
              sortColumn: 'requestedAt',
              currentSortColumn: state.sortColumn,
              sortAscending: state.sortAscending,
              onSort: () => notifier.onSort('requestedAt'),
            ),
          ),
          TableCellWidget(
            flex: 1,
            child: const TableHeaderCell(label: 'Actions'),
          ),
        ],
      ),

      // ── Table body: rows + skeleton + empty state ──
      tableBody: TableBody<PendingMember>(
        items: state.filteredMembers,
        isLoading: state.isLoading && state.members.isEmpty,
        emptyStateWidget: const EmptyState(
          title: 'No pending members found',
          subtitle: 'Try adjusting your filters or search',
          icon: Icons.person_search,
        ),
        rowBuilder: (member) =>
            PendingMemberRow(member: member, notifier: notifier),
        skeletonRowBuilder: () => _buildSkeletonRow(),
      ),

      // ── Pagination ──
      paginationWidget: PaginationControls(
        currentPage: state.currentPage + 1,
        totalPages: pageCount,
        itemsPerPage: state.pageSize,
        isLoading: state.isLoading,
        onPageChanged: (page) => notifier.goToPage(page - 1),
        onItemsPerPageChanged: notifier.setPageSize,
      ),
    );
  }
}

// ── Skeleton row matching [2, 2, 3, 2, 1] column layout ──
Widget _buildSkeletonRow() {
  return GenericTableRow(
    cellSpacing: AppSpacing.md,
    cells: [
      // First Name
      TableCellWidget(
        flex: 2,
        child: Center(child: _SkeletonBox(width: 100, height: 16)),
      ),
      // Last Name
      TableCellWidget(
        flex: 2,
        child: Center(child: _SkeletonBox(width: 100, height: 16)),
      ),
      // Email
      TableCellWidget(
        flex: 3,
        child: Center(child: _SkeletonBox(width: 180, height: 16)),
      ),
      // Requested At — date text block
      TableCellWidget(
        flex: 2,
        child: Center(child: _SkeletonBox(width: 130, height: 16)),
      ),
      // Action icons (accept + decline)
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

/// Simple pulsing skeleton box — matches the animation pattern used across the app
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

