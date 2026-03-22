// lib/ui/operator_management/view/mobile_operator_management_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/widgets/containers/mobile_common_widgets.dart';
import '../../core/widgets/containers/mobile_sliver_header.dart';
import '../../core/widgets/containers/mobile_list_content.dart';
import '../../core/widgets/containers/mobile_tab_selector.dart';
import '../../core/widgets/filters/mobile_dropdown_filter_button.dart';
import '../../core/widgets/filters/mobile_date_filter_button.dart';
import '../../core/themes/app_theme.dart';
import '../../../data/services/api/model/team_member/team_member.dart';
import '../../../data/services/api/model/pending_member/pending_member.dart';
import '../view_model/team_members_notifier.dart';
import '../view_model/pending_members_notifier.dart';
import '../models/team_member_filters.dart';
import '../bottom_sheets/team_member_view_sheet.dart';
import '../bottom_sheets/team_member_edit_sheet.dart';
import '../bottom_sheets/pending_member_view_sheet.dart';
import '../../core/ui/confirm_dialog.dart';
import '../../core/widgets/sample_cards/data_card.dart';
import '../../core/widgets/sample_cards/data_card_skeleton.dart';
import '../../../utils/get_operator_status_style.dart';

const _kMembersTab = 0;
const _kPendingTab = 1;

class MobileOperatorManagementScreen extends ConsumerStatefulWidget {
  const MobileOperatorManagementScreen({super.key});

  @override
  ConsumerState<MobileOperatorManagementScreen> createState() =>
      _MobileOperatorManagementScreenState();
}

class _MobileOperatorManagementScreenState
    extends ConsumerState<MobileOperatorManagementScreen> {
  int _selectedTab = _kMembersTab;
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void dispose() {
    _searchFocusNode.dispose();
    super.dispose();
  }

  // ── Tab ──

  void _onTabChanged(int index) {
    setState(() => _selectedTab = index);
    _searchFocusNode.unfocus();
  }

  // ── Search ──

  void _handleSearch(String query) {
    if (_selectedTab == _kMembersTab) {
      ref.read(teamMembersProvider.notifier).setSearch(query);
    } else {
      ref.read(pendingMembersProvider.notifier).setSearch(query);
    }
  }

  // ── Members bottom sheets ──

  void _showMemberView(TeamMember member) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TeamMemberViewSheet(
        member: member,
        onEdit: () {
          Navigator.of(context).pop();
          _showMemberEdit(member);
        },
      ),
    );
  }

  void _showMemberEdit(TeamMember member) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      builder: (context) => TeamMemberEditSheet(
        member: member,
        onUpdate: ref.read(teamMembersProvider.notifier).updateOperator,
      ),
    );
  }

  // ── Pending bottom sheets ──

  void _showPendingView(PendingMember member) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PendingMemberViewSheet(
        member: member,
        onAccept: () => _handleAccept(member),
        onDecline: () => _handleDecline(member),
      ),
    );
  }

  Future<void> _handleAccept(PendingMember member) async {
    Navigator.of(context).pop();
    final confirmed = await showConfirmDialog(
      context: context,
      title: 'Accept Request',
      message: 'Accept ${member.firstName} ${member.lastName}?',
    );
    if (confirmed == true) {
      await ref.read(pendingMembersProvider.notifier).acceptRequest(member);
    }
  }

  Future<void> _handleDecline(PendingMember member) async {
    Navigator.of(context).pop();
    final confirmed = await showConfirmDialog(
      context: context,
      title: 'Decline Request',
      message: 'Decline ${member.firstName} ${member.lastName}?',
    );
    if (confirmed == true) {
      await ref.read(pendingMembersProvider.notifier).declineRequest(member);
    }
  }

  // ── Header config (loading state + filters) ──

  bool get _isLoading => _selectedTab == _kMembersTab
      ? ref.watch(teamMembersProvider).isLoading
      : ref.watch(pendingMembersProvider).isLoading;

  List<Widget> get _filterWidgets {
    if (_selectedTab == _kMembersTab) {
      final membersState = ref.watch(teamMembersProvider);
      return [
        MobileDropdownFilterButton<TeamMemberStatusFilter>(
          icon: Icons.tune,
          currentFilter: membersState.statusFilter,
          options: TeamMemberStatusFilter.values,
          onFilterChanged: (filter) =>
              ref.read(teamMembersProvider.notifier).setStatusFilter(filter),
          isLoading: membersState.isLoading,
        ),
        const SizedBox(width: 8),
        MobileDateFilterButton(
          onFilterChanged: (filter) =>
              ref.read(teamMembersProvider.notifier).setDateFilter(filter),
          isLoading: membersState.isLoading,
        ),
      ];
    } else {
      final pendingState = ref.watch(pendingMembersProvider);
      return [
        MobileDateFilterButton(
          onFilterChanged: (filter) =>
              ref.read(pendingMembersProvider.notifier).setDateFilter(filter),
          isLoading: pendingState.isLoading,
        ),
      ];
    }
  }

  // ── Empty states ──

  EmptyStateConfig get _membersEmptyState {
    final state = ref.watch(teamMembersProvider);
    return EmptyStateConfig(
      icon: Icons.people_outline,
      message: state.hasActiveFilters
          ? 'No members match your filters'
          : 'No team members found',
      actionLabel: state.hasActiveFilters ? 'Clear Filters' : null,
      onAction: state.hasActiveFilters
          ? () => ref.read(teamMembersProvider.notifier).refresh()
          : null,
    );
  }

  EmptyStateConfig get _pendingEmptyState {
    final state = ref.watch(pendingMembersProvider);
    return EmptyStateConfig(
      icon: Icons.hourglass_empty_outlined,
      message: state.hasActiveFilters
          ? 'No pending requests match your filters'
          : 'No pending requests found',
      actionLabel: state.hasActiveFilters ? 'Clear Filters' : null,
      onAction: state.hasActiveFilters
          ? () => ref.read(pendingMembersProvider.notifier).refresh()
          : null,
    );
  }

  // ── Card builders ──

  Widget _buildMemberCard(BuildContext context, TeamMember member, int index) {
    final style = getStatusStyle(member.status.value);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DataCard<TeamMember>(
        data: member,
        icon: Icons.person,
        iconColor: style.textColor,
        iconBgColor: style.color,
        title: '${member.lastName}, ${member.firstName}',
        category: _capitalize(member.status.value),
        status: member.email,
        onTap: () => _showMemberView(member),
      ),
    );
  }

  Widget _buildPendingCard(
      BuildContext context, PendingMember member, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DataCard<PendingMember>(
        data: member,
        icon: Icons.person_outline,
        iconBgColor: AppColors.green100,
        title: '${member.lastName}, ${member.firstName}',
        status: member.email,
        onTap: () => _showPendingView(member),
      ),
    );
  }

  String _capitalize(String value) =>
      value.isEmpty ? value : value[0].toUpperCase() + value.substring(1);

  // ── Build ──

  @override
  Widget build(BuildContext context) {
    final membersState = ref.watch(teamMembersProvider);
    final pendingState = ref.watch(pendingMembersProvider);
    final membersNotifier = ref.read(teamMembersProvider.notifier);
    final pendingNotifier = ref.read(pendingMembersProvider.notifier);

    return MobileScaffoldContainer(
      onTap: () => _searchFocusNode.unfocus(),
      body: RefreshIndicator(
        onRefresh: () async {
          if (_selectedTab == _kMembersTab) {
            await membersNotifier.refresh();
          } else {
            await pendingNotifier.refresh();
          }
        },
        color: AppColors.green100,
        child: CustomScrollView(
          slivers: [
            // Header: title + tab selector + search + filters
            MobileSliverHeader(
              title: 'Operator List',
              selectorWidgets: [
                MobileTabSelector(
                  labels: const ['Members', 'For Approval'],
                  selectedIndex: _selectedTab,
                  onChanged: _onTabChanged,
                ),
              ],
              searchConfig: SearchBarConfig(
                onSearchChanged: _handleSearch,
                searchHint: _selectedTab == _kMembersTab
                    ? 'Search members...'
                    : 'Search pending...',
                isLoading: _isLoading,
                searchFocusNode: _searchFocusNode,
              ),
              filterWidgets: _filterWidgets,
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 8)),

            // Members list — client-side paginated, infinite scroll
            if (_selectedTab == _kMembersTab)
              MobileListContent<TeamMember>(
                isLoading: membersState.isLoading,
                isInitialLoad: membersState.allMembers.isEmpty,
                hasError: false,
                items: membersState.allMembers,
                displayedItems: membersState.displayedMembers,
                hasMoreToLoad: membersState.hasMoreToLoad,
                remainingCount: membersState.remainingCount,
                emptyStateConfig: _membersEmptyState,
                onRefresh: () async => membersNotifier.refresh(),
                onLoadMore: membersNotifier.loadMoreItems,
                onRetry: () => membersNotifier.refresh(),
                itemBuilder: _buildMemberCard,
                skeletonBuilder: (context, index) => const DataCardSkeleton(),
              ),

            // Pending list — client-side paginated, infinite scroll
            if (_selectedTab == _kPendingTab)
              MobileListContent<PendingMember>(
                isLoading: pendingState.isLoading,
                isInitialLoad: pendingState.allMembers.isEmpty,
                hasError: pendingState.isError,
                errorMessage: pendingState.error?.toString(),
                items: pendingState.allMembers,
                displayedItems: pendingState.displayedMembers,
                hasMoreToLoad: pendingState.hasMoreToLoad,
                remainingCount: pendingState.remainingCount,
                emptyStateConfig: _pendingEmptyState,
                onRefresh: () async => pendingNotifier.refresh(),
                onLoadMore: pendingNotifier.loadMoreItems,
                onRetry: () => pendingNotifier.refresh(),
                itemBuilder: _buildPendingCard,
                skeletonBuilder: (context, index) => const DataCardSkeleton(),
              ),
          ],
        ),
      ),
    );
  }
}