// lib/ui/operator_management/widgets/pending_members_tab.dart

import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/services/api/model/pending_member/pending_member.dart';
import 'package:flutter_application_1/ui/core/constants/spacing.dart';
import 'package:flutter_application_1/ui/core/themes/web_colors.dart';
import 'package:flutter_application_1/ui/core/widgets/shared/empty_state.dart';
import 'package:flutter_application_1/ui/core/widgets/shared/pagination_controls.dart';
import 'package:flutter_application_1/ui/core/widgets/table/table_body.dart';
import 'package:flutter_application_1/ui/core/widgets/table/table_header.dart';
import 'package:flutter_application_1/ui/core/widgets/table/table_row.dart';
import 'package:flutter_application_1/ui/operator_management/view_model/pending_members_notifier.dart';
import 'package:flutter_application_1/ui/operator_management/widgets/pending_member_row.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PendingMembersTab extends ConsumerStatefulWidget {
  const PendingMembersTab({super.key});

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

    return Column(
      children: [
        // ── Table header ──
        Container(
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: WebColors.tableBorder, width: 1),
            ),
          ),
          child: TableHeader(
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
              const TableCellWidget(
                flex: 1,
                child: TableHeaderCell(label: 'Actions'),
              ),
            ],
          ),
        ),

        // ── Table body ──
        Expanded(
          child: TableBody<PendingMember>(
            items: state.paginatedMembers,
            isLoading: state.isLoading && state.allMembers.isEmpty,
            emptyStateWidget: const EmptyState(
              title: 'No pending members found',
              subtitle: 'Try adjusting your filters or search',
              icon: Icons.person_search,
            ),
            rowBuilder: (member) =>
                PendingMemberRow(member: member, notifier: notifier),
            skeletonRowBuilder: _buildSkeletonRow,
          ),
        ),

        // ── Pagination ──
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.tableCellHorizontal,
            vertical: AppSpacing.lg,
          ),
          child: PaginationControls(
            currentPage: state.currentPage + 1,
            totalPages: state.totalPages,
            itemsPerPage: state.itemsPerPage,
            isLoading: state.isLoading,
            onPageChanged: (page) => notifier.onPageChanged(page - 1),
            onItemsPerPageChanged: notifier.onItemsPerPageChanged,
          ),
        ),
      ],
    );
  }
}

// ── Skeleton row: [2, 2, 2, 2, 1] ──

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
        flex: 2,
        child: Center(child: _SkeletonBox(width: 180, height: 16)),
      ),
      TableCellWidget(
        flex: 2,
        child: Center(child: _SkeletonBox(width: 130, height: 16)),
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

// ── Pulsing skeleton box ──

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