// lib/ui/machine_management/view/operator_machine_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/widgets/mobile_common_widgets.dart';
import '../../core/widgets/mobile_list_header.dart';
import '../../core/widgets/mobile_list_content.dart';
import '../../core/themes/app_theme.dart';
import '../../../data/models/machine_model.dart';
import '../../../services/sess_service.dart';
import '../view_model/mobile_machine_viewmodel.dart';
import '../models/mobile_machine_state.dart';
import '../widgets/operator_machine_card.dart';

class OperatorMachineView extends ConsumerStatefulWidget {
  const OperatorMachineView({super.key});

  @override
  ConsumerState<OperatorMachineView> createState() => _OperatorMachineViewState();
}

class _OperatorMachineViewState extends ConsumerState<OperatorMachineView> {
  String? _teamId;
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _loadTeamIdAndInit();
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadTeamIdAndInit() async {
    final sessionService = SessionService();
    final userData = await sessionService.getCurrentUserData();

    _teamId = userData?['teamId'] as String?;

    if (_teamId != null) {
      ref.read(mobileMachineViewModelProvider.notifier).initialize(_teamId!);
    }

    if (mounted) setState(() {});
  }

  EmptyStateConfig _getEmptyStateConfig(MobileMachineState state) {
    String message;

    switch (state.selectedStatusFilter) {
      case MachineStatusFilter.inactive:
        message = 'No archived machines';
        break;
      case MachineStatusFilter.active:
        message = 'No active machines';
        break;
      case MachineStatusFilter.underMaintenance:
        message = 'No suspended machines';
        break;
      default:
        message = 'No machines available.\nContact your admin for machine assignment.';
    }

    if (state.hasActiveFilters) {
      message = 'No machines match your filters';
    }

    return EmptyStateConfig(
      icon: Icons.inbox_outlined,
      message: message,
      actionLabel: state.hasActiveFilters ? 'Clear All Filters' : null,
      onAction: state.hasActiveFilters
          ? () {
              ref.read(mobileMachineViewModelProvider.notifier).clearAllFilters();
            }
          : null,
    );
  }

  Widget _buildMachineCard(BuildContext context, MachineModel machine, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: OperatorMachineCard(machine: machine),
    );
  }

  Widget _buildSkeletonCard(BuildContext context, int index) {
    return Container(
      height: 120,
      margin: const EdgeInsets.only(bottom: 20, left: 16, right: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.backgroundBorder.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.grey,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 16, color: AppColors.grey),
                const SizedBox(height: 8),
                Container(height: 14, width: 150, color: AppColors.grey),
                const Spacer(),
                Container(height: 24, width: 80, color: AppColors.grey),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mobileMachineViewModelProvider);
    final notifier = ref.read(mobileMachineViewModelProvider.notifier);

    return MobileScaffoldContainer(
      onTap: () => _searchFocusNode.unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: MobileListHeader(
          title: 'My Machines',
          showAddButton: false, // Operators cannot add machines
          filterBarConfig: MobileFilterBarConfig(
            onSearchChanged: notifier.setSearchQuery,
            onStatusFilterChanged: notifier.setStatusFilter,
            onDateFilterChanged: notifier.setDateFilter,
            currentStatusFilter: state.selectedStatusFilter,
            currentDateFilter: state.dateFilter,
            isLoading: state.isLoading,
            searchHint: 'Search machines...',
            searchFocusNode: _searchFocusNode,
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: MobileListContent<MachineModel>(
            isLoading: state.isLoading,
            isInitialLoad: state.machines.isEmpty,
            hasError: state.hasError,
            errorMessage: state.errorMessage,
            items: state.filteredMachines,
            displayedItems: state.displayedMachines,
            hasMoreToLoad: state.hasMoreToLoad,
            remainingCount: state.remainingCount,
            emptyStateConfig: _getEmptyStateConfig(state),
            onRefresh: () async {
              if (_teamId != null) {
                await notifier.refresh(_teamId!);
              }
            },
            onLoadMore: notifier.loadMore,
            onRetry: () {
              notifier.clearError();
              if (_teamId != null) notifier.initialize(_teamId!);
            },
            itemBuilder: _buildMachineCard,
            skeletonBuilder: _buildSkeletonCard,
          ),
        ),
      ),
    );
  }
}